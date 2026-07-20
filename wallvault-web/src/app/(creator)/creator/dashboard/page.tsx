'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Image as ImageIcon, Users, Loader2 } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { useAuth } from '@/components/AuthProvider';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';

interface WallpaperRow {
  id: string;
  name: string;
  downloads: number;
  status: string;
  price: string;
}

export default function CreatorDashboard() {
  const { user } = useAuth();
  const [uploads, setUploads] = useState<WallpaperRow[]>([]);
  const [loading, setLoading] = useState(true);

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
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded bg-[#1A1A24] flex items-center justify-center">
            <ImageIcon className="w-5 h-5 text-text-muted" />
          </div>
          <span className="font-semibold text-white">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Type / Price',
      accessor: (row: WallpaperRow) => (
        <span className="text-[#8B8B9E]">{row.price}</span>
      ),
    },
    {
      header: 'Downloads',
      accessor: (row: WallpaperRow) => (
        <span className="font-mono text-[#8B8B9E]">{row.downloads}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: WallpaperRow) => (
        <StatusBadge status={row.status as any} />
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-[#B829DD]" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-bold tracking-tight text-white">Dashboard</h1>
          <p className="mt-1 text-sm text-[#8B8B9E]">Welcome back! Here is how your portfolio is doing in real-time.</p>
        </div>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard
          label="Total Earnings (70% Split)"
          value={`₹${totalEarnings}`}
          icon={DollarSign}
          trend={totalEarnings > 0 ? { value: 100, isPositive: true } : undefined}
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
        <h2 className="text-2xl font-bold text-white">Your Uploads</h2>
        {uploads.length === 0 ? (
          <div className="p-8 text-center text-text-muted border border-[#1A1A24] rounded-2xl bg-[#12121A]/50">
            No wallpapers uploaded yet. Go to "Upload Wallpaper" to submit your first creation!
          </div>
        ) : (
          <DataTable columns={columns} data={uploads} />
        )}
      </div>
    </div>
  );
}
