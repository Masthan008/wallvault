'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Image as ImageIcon, Users, X, Eye, Tag, Calendar, ExternalLink, Save, Trash2, Upload, AlertCircle } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { useAuth } from '@/components/AuthProvider';
import { collection, query, where, onSnapshot, doc, updateDoc, deleteDoc } from 'firebase/firestore';
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
  description: string;
  isPremium: boolean;
  priceNum: number;
}

export default function CreatorDashboard() {
  const { user } = useAuth();
  const [uploads, setUploads] = useState<WallpaperRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedWallpaper, setSelectedWallpaper] = useState<WallpaperRow | null>(null);

  // Editing states
  const [editName, setEditName] = useState('');
  const [editDescription, setEditDescription] = useState('');
  const [editCategory, setEditCategory] = useState('');
  const [editIsPremium, setEditIsPremium] = useState(false);
  const [editPrice, setEditPrice] = useState('49');
  
  // New image file replacement state
  const [newImageFile, setNewImageFile] = useState<File | null>(null);
  const [newImagePreview, setNewImagePreview] = useState<string | null>(null);
  
  const [savingEdit, setSavingEdit] = useState(false);
  const [deletingEdit, setDeletingEdit] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

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

      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        const priceNum = data.price || 0;
        const downloadsNum = data.downloads || 0;
        downloadsSum += downloadsNum;
        earningsSum += (priceNum * downloadsNum * 0.7); // 70% creator share

        items.push({
          id: docSnap.id,
          name: data.name || 'Untitled',
          downloads: downloadsNum,
          status: data.status || 'pending',
          price: priceNum > 0 ? `₹${priceNum}` : 'Free',
          imageUrl: data.imageUrl || '',
          category: data.category || 'abstract',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          description: data.description || '',
          isPremium: data.isPremium || false,
          priceNum: priceNum,
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

  // Sync editing form states when selected wallpaper changes
  useEffect(() => {
    if (selectedWallpaper) {
      setEditName(selectedWallpaper.name);
      setEditDescription(selectedWallpaper.description);
      setEditCategory(selectedWallpaper.category);
      setEditIsPremium(selectedWallpaper.isPremium);
      setEditPrice(selectedWallpaper.priceNum.toString());
      setNewImageFile(null);
      setNewImagePreview(null);
      setErrorMsg('');
    }
  }, [selectedWallpaper]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setNewImageFile(file);
      setNewImagePreview(URL.createObjectURL(file));
    }
  };

  const handleSaveChanges = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedWallpaper) return;
    setSavingEdit(true);
    setErrorMsg('');

    try {
      let finalImageUrl = selectedWallpaper.imageUrl;

      // 1. If the creator chose a new image, upload to Cloudinary first
      if (newImageFile) {
        const timestamp = Math.round(new Date().getTime() / 1000);
        const apiSecret = 'JMJq080FCoudvQVTzncRW4Ghd84';
        const apiKey = '972246177422269';
        const cloudName = 'dn30vxcoq';

        const signString = `folder=wallpapers&timestamp=${timestamp}${apiSecret}`;
        const encoder = new TextEncoder();
        const signData = encoder.encode(signString);
        const hashBuffer = await window.crypto.subtle.digest('SHA-1', signData);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const signature = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

        const formData = new FormData();
        formData.append('file', newImageFile);
        formData.append('api_key', apiKey);
        formData.append('timestamp', timestamp.toString());
        formData.append('folder', 'wallpapers');
        formData.append('signature', signature);

        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
          method: 'POST',
          body: formData,
        });

        if (response.ok) {
          const data = await response.json();
          finalImageUrl = data.secure_url;
        } else {
          throw new Error('Cloudinary replacement image upload failed.');
        }
      }

      // 2. Update Firestore wallpaper document
      await updateDoc(doc(db, 'wallpapers', selectedWallpaper.id), {
        name: editName.trim(),
        description: editDescription.trim(),
        category: editCategory.toLowerCase(),
        isPremium: editIsPremium,
        price: editIsPremium ? parseFloat(editPrice) : 0,
        imageUrl: finalImageUrl,
        thumbnailUrl: finalImageUrl,
        status: 'pending', // Reset status to pending so admin reviews updates!
        updatedAt: new Date(),
      });

      setSelectedWallpaper(null);
    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || 'Failed to save modifications.');
    } finally {
      setSavingEdit(false);
    }
  };

  const handleDeleteWallpaper = async () => {
    if (!selectedWallpaper) return;
    if (!confirm('Are you sure you want to permanently delete this wallpaper? This cannot be undone.')) return;
    setDeletingEdit(true);
    try {
      await deleteDoc(doc(db, 'wallpapers', selectedWallpaper.id));
      setSelectedWallpaper(null);
    } catch (err: any) {
      console.error(err);
      setErrorMsg('Failed to delete wallpaper asset.');
    } finally {
      setDeletingEdit(false);
    }
  };

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
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        className="flex items-center justify-between"
      >
        <div>
          <h1 className="text-3xl font-black tracking-tight text-white">
            Dashboard
          </h1>
          <p className="mt-1 text-xs text-[#52525b] font-medium">Welcome back! Real-time portfolio performance.</p>
        </div>
      </motion.div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard
          label="Earnings (70%)"
          value={`₹${totalEarnings}`}
          icon={DollarSign}
          glowColor="gold"
          index={0}
        />
        <KPICard
          label="Downloads"
          value={totalDownloads}
          icon={Download}
          glowColor="purple"
          index={1}
        />
        <KPICard
          label="Wallpapers"
          value={totalWallpapers}
          icon={ImageIcon}
          glowColor="cyan"
          index={2}
        />
        <KPICard
          label="Est. Followers"
          value={Math.round(totalDownloads * 0.15)}
          icon={Users}
          index={3}
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

      {/* Creator Wallpaper Detail Preview & Edit Modal */}
      <AnimatePresence>
        {selectedWallpaper && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.2 }}
              className="w-full max-w-3xl bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row h-[550px]"
            >
              {/* Wallpaper Preview Container */}
              <div className="flex-1 bg-black flex items-center justify-center relative group min-h-[250px] md:min-h-0">
                {newImagePreview ? (
                  <img
                    src={newImagePreview}
                    alt="Replacement Preview"
                    className="absolute inset-0 w-full h-full object-contain border-2 border-dashed border-accent-cyan"
                  />
                ) : selectedWallpaper.imageUrl ? (
                  <img
                    src={selectedWallpaper.imageUrl}
                    alt={selectedWallpaper.name}
                    className="absolute inset-0 w-full h-full object-contain"
                  />
                ) : (
                  <ImageIcon className="w-12 h-12 text-text-muted animate-pulse" />
                )}
                
                {/* Upload Image Overlay Trigger */}
                <label className="absolute bottom-4 left-4 p-2 bg-black/60 hover:bg-black/90 text-white rounded-lg border border-white/10 transition-colors flex items-center gap-1.5 text-xs font-bold uppercase cursor-pointer">
                  <Upload className="w-3.5 h-3.5" />
                  <span>Change Image</span>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </label>

                <a
                  href={newImagePreview || selectedWallpaper.imageUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="absolute bottom-4 right-4 p-2 bg-black/60 hover:bg-black/90 text-white rounded-lg border border-white/10 transition-colors flex items-center gap-1.5 text-xs font-bold uppercase"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                  <span>View Full Size</span>
                </a>
              </div>

              {/* Wallpaper Details & Edit Form Column */}
              <div className="w-full md:w-96 p-6 flex flex-col justify-between border-t md:border-t-0 md:border-l border-border-glass bg-bg-primary overflow-y-auto">
                <div className="space-y-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="text-base font-bold text-white leading-tight">Edit Wallpaper</h3>
                      <p className="text-[10px] text-text-muted mt-1 uppercase font-bold tracking-wider">ID: {selectedWallpaper.id}</p>
                    </div>
                    <button
                      onClick={() => setSelectedWallpaper(null)}
                      className="p-1 text-text-muted hover:text-white rounded transition-colors cursor-pointer"
                    >
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  {errorMsg && (
                    <div className="p-3 bg-accent-error/10 border border-accent-error/20 text-accent-error text-[10px] rounded-xl flex items-center gap-2">
                      <AlertCircle className="w-4 h-4 shrink-0" />
                      <span>{errorMsg}</span>
                    </div>
                  )}

                  <form onSubmit={handleSaveChanges} className="space-y-3 pt-3 border-t border-white/[0.04] text-xs">
                    <div className="space-y-1">
                      <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Wallpaper Name</label>
                      <input
                        type="text"
                        value={editName}
                        onChange={(e) => setEditName(e.target.value)}
                        required
                        className="w-full px-2.5 py-2 glass-input text-xs"
                      />
                    </div>

                    <div className="space-y-1">
                      <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Description</label>
                      <textarea
                        value={editDescription}
                        onChange={(e) => setEditDescription(e.target.value)}
                        rows={2}
                        className="w-full px-2.5 py-2 glass-input text-xs"
                        placeholder="Write something about your artwork..."
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Category</label>
                        <select
                          value={editCategory}
                          onChange={(e) => setEditCategory(e.target.value)}
                          className="w-full px-2.5 py-2 glass-input text-xs text-text-secondary cursor-pointer"
                        >
                          <option value="abstract">Abstract</option>
                          <option value="anime">Anime</option>
                          <option value="cars">Cars</option>
                          <option value="nature">Nature</option>
                          <option value="space">Space</option>
                          <option value="dark">Dark</option>
                        </select>
                      </div>

                      <div className="space-y-1">
                        <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Review Status</label>
                        <div className="py-2.5">
                          <StatusBadge status={selectedWallpaper.status as any} />
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Pricing Option</label>
                      <div className="grid grid-cols-2 gap-2">
                        <button
                          type="button"
                          onClick={() => setEditIsPremium(false)}
                          className={`py-1.5 rounded text-[10px] font-bold uppercase tracking-wider transition-colors cursor-pointer ${
                            !editIsPremium
                              ? 'bg-white text-black'
                              : 'bg-[#18181b] border border-[#27272a] text-text-muted'
                          }`}
                        >
                          Free
                        </button>
                        <button
                          type="button"
                          onClick={() => setEditIsPremium(true)}
                          className={`py-1.5 rounded text-[10px] font-bold uppercase tracking-wider transition-colors cursor-pointer ${
                            editIsPremium
                              ? 'bg-white text-black'
                              : 'bg-[#18181b] border border-[#27272a] text-text-muted'
                          }`}
                        >
                          Premium
                        </button>
                      </div>
                    </div>

                    {editIsPremium && (
                      <div className="space-y-1">
                        <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Price (INR)</label>
                        <div className="relative">
                          <DollarSign className="absolute left-2.5 top-2.5 w-3.5 h-3.5 text-text-muted" />
                          <input
                            type="number"
                            value={editPrice}
                            onChange={(e) => setEditPrice(e.target.value)}
                            required
                            className="w-full pl-8 pr-2.5 py-2 glass-input text-xs"
                          />
                        </div>
                      </div>
                    )}
                  </form>
                </div>

                <div className="space-y-2 pt-4 border-t border-white/[0.04]">
                  <button
                    onClick={handleSaveChanges}
                    disabled={savingEdit || deletingEdit}
                    className="w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
                  >
                    <Save className="w-4 h-4" />
                    <span>{savingEdit ? 'Saving Changes...' : 'Save details'}</span>
                  </button>
                  <button
                    type="button"
                    onClick={handleDeleteWallpaper}
                    disabled={savingEdit || deletingEdit}
                    className="w-full py-2 bg-accent-error/10 hover:bg-accent-error/20 text-accent-error border border-accent-error/20 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
                  >
                    <Trash2 className="w-4 h-4" />
                    <span>{deletingEdit ? 'Deleting...' : 'Delete Wallpaper'}</span>
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
