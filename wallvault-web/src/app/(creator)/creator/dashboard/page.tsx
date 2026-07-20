'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Image as ImageIcon, Users, X, Eye, Tag, Calendar, ExternalLink } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { useAuth } from '@/components/AuthProvider';
import { collection, query, where, onSnapshot, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';

interface WallpaperRow {
  id: string;
  name: string;
  downloads: number;
  status: string;
  price: string;
  imageUrl: string;
  category: string;
  date: string;
}

export default function CreatorDashboard() {
  const { user } = useAuth();
  const [uploads, setUploads] = useState<WallpaperRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedWallpaper, setSelectedWallpaper] = useState<WallpaperRow | null>(null);

  // Stats
  const [totalEarnings, setTotalEarnings] = useState(0);
  const [totalDownloads, setTotalDownloads] = useState(0);
  const [totalWallpapers, setTotalWallpapers] = useState(0);

  useEffect(() => {
    if (!user) return;

    // Listen to wallpapers uploaded by this creator in real-time
    const q = query(
      collection(db, 'wallpapers'),
      where('creatorId', '==', user.uid)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: WallpaperRow[] = [];
      let downloadsSum = 0;
      let earningsSum = 0;

      snapshot.forEach((doc) => {
        const data = doc.data();
        const priceNum = data.price || 0;
        const downloadsNum = data.downloads || 0;
        downloadsSum += downloadsNum;
        earningsSum += (priceNum * downloadsNum * 0.7); // 70% creator share

        items.push({
          id: doc.id,
          name: data.name || 'Untitled',
          downloads: downloadsNum,
          status: data.status || 'pending',
          price: priceNum > 0 ? `₹${priceNum}` : 'Free',
          imageUrl: data.imageUrl || '',
          category: data.category || 'abstract',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
        });
      });

      setUploads(items);
      setTotalDownloads(downloadsSum);
      setTotalEarnings(Math.round(earningsSum));
      setTotalWallpapers(items.length);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching creator wallpapers: ", error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const columns = [
    {
      header: 'Wallpaper',
      accessor: (row: WallpaperRow) => (
        <div 
          onClick={() => setSelectedWallpaper(row)}
          className="flex items-center space-x-3 cursor-pointer group"
        >
          <div className="w-12 h-16 rounded overflow-hidden bg-white/[0.02] flex items-center justify-center border border-white/[0.05] shadow-sm transition-transform group-hover:scale-105">
            {row.imageUrl ? (
              <img src={row.imageUrl} alt={row.name} className="w-full h-full object-cover" />
            ) : (
              <ImageIcon className="w-5 h-5 text-text-muted" />
            )}
          </div>
          <span className="font-bold text-white text-sm hover:underline group-hover:text-accent-cyan transition-colors">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Type / Price',
      accessor: (row: WallpaperRow) => (
        <span className="text-text-secondary text-xs uppercase tracking-wider font-extrabold">{row.price}</span>
      ),
    },
    {
      header: 'Downloads',
      accessor: (row: WallpaperRow) => (
        <span className="font-mono text-text-secondary text-sm">{row.downloads}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: WallpaperRow) => (
        <div onClick={() => setSelectedWallpaper(row)} className="cursor-pointer">
          <StatusBadge status={row.status as any} />
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="space-y-6">
        <SkeletonLoader variant="card" count={4} />
        <SkeletonLoader variant="table" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-extrabold tracking-tight text-white">
            Dashboard
          </h1>
          <p className="mt-1 text-xs text-text-secondary">Welcome back! Here is how your portfolio is doing in real-time.</p>
        </div>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard
          label="Total Earnings (70% Split)"
          value={`₹${totalEarnings}`}
          icon={DollarSign}
          glowColor="gold"
        />
        <KPICard
          label="Total Downloads"
          value={totalDownloads.toString()}
          icon={Download}
          glowColor="purple"
        />
        <KPICard
          label="Total Wallpapers"
          value={totalWallpapers.toString()}
          icon={ImageIcon}
          glowColor="cyan"
        />
        <KPICard
          label="Estimated Followers"
          value={Math.round(totalDownloads * 0.15).toString()} // estimated at 15% download rate
          icon={Users}
        />
      </div>

      {/* Recent uploads */}
      <div className="space-y-4">
        <h2 className="text-xs font-bold uppercase tracking-wider text-text-muted">Your Uploads</h2>
        {uploads.length === 0 ? (
          <div className="p-12 text-center text-text-muted border border-white/[0.05] rounded-2xl bg-white/[0.01]">
            <p className="text-sm font-semibold">No wallpapers uploaded yet.</p>
            <p className="text-xs text-text-muted mt-1 font-normal">Go to "Upload Wallpaper" to submit your first creation!</p>
          </div>
        ) : (
          <DataTable columns={columns} data={uploads} />
        )}
      </div>

      {/* Creator Wallpaper Detail Preview Modal */}
      <AnimatePresence>
        {selectedWallpaper && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.2 }}
              className="w-full max-w-2xl bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row h-[500px]"
            >
              {/* Wallpaper Preview Container */}
              <div className="flex-1 bg-black flex items-center justify-center relative group min-h-[250px] md:min-h-0">
                {selectedWallpaper.imageUrl ? (
                  <img
                    src={selectedWallpaper.imageUrl}
                    alt={selectedWallpaper.name}
                    className="absolute inset-0 w-full h-full object-contain"
                  />
                ) : (
                  <ImageIcon className="w-12 h-12 text-text-muted animate-pulse" />
                )}
                <a
                  href={selectedWallpaper.imageUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="absolute bottom-4 right-4 p-2 bg-black/60 hover:bg-black/90 text-white rounded-lg border border-white/10 transition-colors flex items-center gap-1.5 text-xs font-bold uppercase"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                  <span>View Full Size</span>
                </a>
              </div>

              {/* Wallpaper Details Column */}
              <div className="w-full md:w-80 p-6 flex flex-col justify-between border-t md:border-t-0 md:border-l border-border-glass bg-bg-primary">
                <div className="space-y-5">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="text-base font-bold text-white leading-tight">{selectedWallpaper.name}</h3>
                      <p className="text-[10px] text-text-muted mt-1 uppercase font-bold tracking-wider">ID: {selectedWallpaper.id}</p>
                    </div>
                    <button
                      onClick={() => setSelectedWallpaper(null)}
                      className="p-1 text-text-muted hover:text-white rounded transition-colors"
                    >
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  <div className="space-y-3 pt-3 border-t border-white/[0.04] text-xs">
                    <div className="flex items-center gap-2.5 text-text-secondary">
                      <Tag className="w-4 h-4 text-text-muted" />
                      <div>
                        <p className="text-[8px] uppercase font-bold text-text-muted">Category</p>
                        <p className="font-semibold text-accent-cyan uppercase tracking-wider">{selectedWallpaper.category}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2.5 text-text-secondary">
                      <Download className="w-4 h-4 text-text-muted" />
                      <div>
                        <p className="text-[8px] uppercase font-bold text-text-muted">Downloads</p>
                        <p className="font-semibold text-white font-mono">{selectedWallpaper.downloads}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2.5 text-text-secondary">
                      <Calendar className="w-4 h-4 text-text-muted" />
                      <div>
                        <p className="text-[8px] uppercase font-bold text-text-muted">Uploaded</p>
                        <p className="font-semibold text-white font-mono">{selectedWallpaper.date}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2.5 text-text-secondary">
                      <DollarSign className="w-4 h-4 text-text-muted" />
                      <div>
                        <p className="text-[8px] uppercase font-bold text-text-muted">Pricing Option</p>
                        <p className="font-semibold text-white">{selectedWallpaper.price}</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="space-y-3 pt-4 border-t border-white/[0.04]">
                  <div className="flex flex-col space-y-1">
                    <span className="text-[8px] uppercase font-bold text-text-muted">Review Status</span>
                    <StatusBadge status={selectedWallpaper.status as any} />
                  </div>
                  <button
                    onClick={() => setSelectedWallpaper(null)}
                    className="w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                  >
                    Close Preview
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}


