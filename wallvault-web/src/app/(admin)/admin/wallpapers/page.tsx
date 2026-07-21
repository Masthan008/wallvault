'use client';

import React, { useEffect, useState } from 'react';
import { Check, X, Image as ImageIcon, ExternalLink, Calendar, User, Tag, Search, Edit2, Trash2, Save, DollarSign } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { collection, query, onSnapshot, doc, updateDoc, deleteDoc, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';

interface WallpaperItem {
  id: string;
  name: string;
  creator: string;
  creatorId: string;
  category: string;
  date: string;
  imageUrl: string;
  status: 'pending' | 'approved' | 'rejected';
  isPremium: boolean;
  price: number;
}

export default function AdminWallpapers() {
  const [wallpapers, setWallpapers] = useState<WallpaperItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'pending' | 'active'>('pending');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Selected wallpaper for detail view / editing
  const [selectedWallpaper, setSelectedWallpaper] = useState<WallpaperItem | null>(null);
  
  // Form editing states
  const [editName, setEditName] = useState('');
  const [editCategory, setEditCategory] = useState('');
  const [editIsPremium, setEditIsPremium] = useState(false);
  const [editPrice, setEditPrice] = useState('49');
  const [savingEdit, setSavingEdit] = useState(false);

  useEffect(() => {
    // Listen to all wallpapers in real-time
    const q = query(collection(db, 'wallpapers'), orderBy('createdAt', 'desc'));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: WallpaperItem[] = [];
      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        items.push({
          id: docSnap.id,
          name: data.name || 'Untitled',
          creator: data.creatorName || 'Unknown',
          creatorId: data.creatorId || '',
          category: data.category || 'abstract',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          imageUrl: data.imageUrl || '',
          status: data.status || 'pending',
          isPremium: data.isPremium || false,
          price: data.price || 0,
        });
      });
      setWallpapers(items);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  // Sync editing form states when selected wallpaper changes
  useEffect(() => {
    if (selectedWallpaper) {
      setEditName(selectedWallpaper.name);
      setEditCategory(selectedWallpaper.category);
      setEditIsPremium(selectedWallpaper.isPremium);
      setEditPrice(selectedWallpaper.price.toString());
    }
  }, [selectedWallpaper]);

  const handleApprove = async (id: string) => {
    try {
      await updateDoc(doc(db, 'wallpapers', id), {
        status: 'approved',
        updatedAt: new Date(),
      });
      setSelectedWallpaper(null);
    } catch (e) {
      console.error("Approve failed: ", e);
    }
  };

  const handleReject = async (id: string) => {
    try {
      await updateDoc(doc(db, 'wallpapers', id), {
        status: 'rejected',
        updatedAt: new Date(),
      });
      setSelectedWallpaper(null);
    } catch (e) {
      console.error("Reject failed: ", e);
    }
  };

  const handleSaveEdit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedWallpaper) return;
    setSavingEdit(true);
    try {
      await updateDoc(doc(db, 'wallpapers', selectedWallpaper.id), {
        name: editName.trim(),
        category: editCategory.toLowerCase(),
        isPremium: editIsPremium,
        price: editIsPremium ? parseFloat(editPrice) : 0,
        updatedAt: new Date(),
      });
      setSelectedWallpaper(null);
    } catch (err) {
      console.error('Failed to update wallpaper details: ', err);
    } finally {
      setSavingEdit(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to permanently remove this wallpaper from the platform?')) return;
    try {
      await deleteDoc(doc(db, 'wallpapers', id));
      setSelectedWallpaper(null);
    } catch (err) {
      console.error('Failed to delete wallpaper: ', err);
    }
  };

  // Filter items based on active tab and search query
  const pendingItems = wallpapers.filter(w => w.status === 'pending');
  
  const activeItems = wallpapers.filter(w => {
    const matchesTab = w.status === 'approved';
    const matchesSearch = searchQuery === '' ||
      w.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      w.creator.toLowerCase().includes(searchQuery.toLowerCase()) ||
      w.category.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesTab && matchesSearch;
  });

  const columns = [
    {
      header: 'Preview',
      accessor: (row: WallpaperItem) => (
        <div 
          onClick={() => setSelectedWallpaper(row)}
          className="w-16 h-20 rounded-lg bg-white/[0.02] overflow-hidden flex items-center justify-center border border-white/[0.06] shadow-md transition-transform duration-300 hover:scale-105 cursor-zoom-in"
        >
          {row.imageUrl ? (
            <img src={row.imageUrl} alt={row.name} className="w-full h-full object-cover" />
          ) : (
            <ImageIcon className="w-6 h-6 text-text-muted" />
          )}
        </div>
      ),
    },
    {
      header: 'Wallpaper details',
      accessor: (row: WallpaperItem) => (
        <div onClick={() => setSelectedWallpaper(row)} className="cursor-pointer">
          <h4 className="font-bold text-white text-sm hover:underline">{row.name}</h4>
          <div className="flex items-center gap-2 mt-0.5">
            <span className="text-[10px] text-accent-cyan uppercase font-extrabold tracking-wider">{row.category}</span>
            <span className="text-[10px] text-text-muted font-mono">• {row.isPremium ? `₹${row.price}` : 'Free'}</span>
          </div>
        </div>
      ),
    },
    {
      header: 'Creator',
      accessor: (row: WallpaperItem) => (
        <span className="text-accent-purple font-extrabold text-xs">{row.creator}</span>
      ),
    },
    {
      header: 'Submitted Date',
      accessor: (row: WallpaperItem) => (
        <span className="text-text-secondary font-mono text-xs">{row.date}</span>
      ),
    },
    {
      header: 'Actions',
      accessor: (row: WallpaperItem) => (
        <div className="flex space-x-2">
          {row.status === 'pending' ? (
            <>
              <button 
                onClick={() => handleApprove(row.id)}
                className="p-2 bg-accent-success/10 text-accent-success hover:bg-accent-success/20 rounded-lg border border-accent-success/20 transition-all duration-300 active:scale-95 cursor-pointer"
              >
                <Check className="w-4 h-4 stroke-[3px]" />
              </button>
              <button 
                onClick={() => handleReject(row.id)}
                className="p-2 bg-accent-error/10 text-accent-error hover:bg-accent-error/20 rounded-lg border border-accent-error/20 transition-all duration-300 active:scale-95 cursor-pointer"
              >
                <X className="w-4 h-4 stroke-[3px]" />
              </button>
            </>
          ) : (
            <>
              <button 
                onClick={() => setSelectedWallpaper(row)}
                className="p-2 bg-white/[0.02] text-text-secondary hover:text-white rounded-lg border border-white/[0.05] transition-all duration-200 active:scale-95 cursor-pointer"
              >
                <Edit2 className="w-3.5 h-3.5" />
              </button>
              <button 
                onClick={() => handleDelete(row.id)}
                className="p-2 bg-accent-error/10 text-accent-error hover:bg-accent-error/20 rounded-lg border border-accent-error/20 transition-all duration-200 active:scale-95 cursor-pointer"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </>
          )}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="space-y-6">
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
      >
        <h1 className="text-3xl font-black tracking-tight text-white">
          Wallpaper Management
        </h1>
        <p className="mt-1 text-xs text-[#52525b] font-medium">Moderate submissions, search assets, edit properties, or delete items.</p>
      </motion.div>

      {/* Tabs Layout */}
      <div className="flex border-b border-white/[0.06] gap-1 p-1 bg-white/[0.01] rounded-xl w-fit">
        {(['pending', 'active'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`relative px-4 py-2 text-[10px] font-bold uppercase tracking-[0.1em] rounded-lg transition-all duration-200 cursor-pointer ${
              activeTab === tab
                ? 'text-white'
                : 'text-[#52525b] hover:text-[#a1a1aa]'
            }`}
          >
            {activeTab === tab && (
              <motion.div
                layoutId="admin-wallpaper-tab"
                className="absolute inset-0 bg-white/[0.06] border border-white/[0.08] rounded-lg"
                transition={{ type: 'spring', stiffness: 350, damping: 30 }}
              />
            )}
            <span className="relative z-10">
              {tab === 'pending' ? `Pending (${pendingItems.length})` : `Live (${wallpapers.filter(w => w.status === 'approved').length})`}
            </span>
          </button>
        ))}
      </div>

      {/* Search Input for Live tab */}
      {activeTab === 'active' && (
        <div className="relative max-w-md">
          <Search className="absolute left-3.5 top-3 w-4 h-4 text-text-muted" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search wallpapers, creators, categories..."
            className="w-full pl-10 pr-4 py-2.5 glass-input text-xs"
          />
        </div>
      )}

      {/* Database list rendering */}
      <div className="space-y-4">
        {activeTab === 'pending' ? (
          <DataTable columns={columns} data={pendingItems} emptyMessage="All wallpapers reviewed!" />
        ) : (
          <DataTable columns={columns} data={activeItems} emptyMessage="No approved wallpapers match query search." />
        )}
      </div>

      {/* Custom Detail modal & Edit properties sheet */}
      <AnimatePresence>
        {selectedWallpaper && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md" onClick={(e) => { if (e.target === e.currentTarget) setSelectedWallpaper(null); }}>
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.2 }}
              className="w-full max-w-2xl bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row h-[500px]"
            >
              {/* Wallpaper Preview Side */}
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
                  <span>Full Size</span>
                </a>
              </div>

              {/* Details and Actions Forms Side */}
              <div className="w-full md:w-80 p-6 flex flex-col justify-between border-t md:border-t-0 md:border-l border-border-glass bg-bg-primary overflow-y-auto">
                <div className="space-y-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="text-base font-bold text-white leading-tight">
                        {selectedWallpaper.status === 'pending' ? selectedWallpaper.name : 'Edit Wallpaper'}
                      </h3>
                      <p className="text-[9px] text-text-muted mt-1 uppercase font-bold tracking-wider">ID: {selectedWallpaper.id}</p>
                    </div>
                    <button
                      onClick={() => setSelectedWallpaper(null)}
                      className="p-1 text-text-muted hover:text-white rounded transition-colors"
                    >
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  {selectedWallpaper.status === 'pending' ? (
                    // Moderation Details mode
                    <div className="space-y-3 pt-3 border-t border-white/[0.04] text-xs">
                      <div className="flex items-center gap-2.5 text-text-secondary">
                        <User className="w-4 h-4 text-text-muted" />
                        <div>
                          <p className="text-[8px] uppercase font-bold text-text-muted">Creator</p>
                          <p className="font-semibold text-white">{selectedWallpaper.creator}</p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2.5 text-text-secondary">
                        <Tag className="w-4 h-4 text-text-muted" />
                        <div>
                          <p className="text-[8px] uppercase font-bold text-text-muted">Category</p>
                          <p className="font-semibold text-accent-cyan uppercase tracking-wider">{selectedWallpaper.category}</p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2.5 text-text-secondary">
                        <Calendar className="w-4 h-4 text-text-muted" />
                        <div>
                          <p className="text-[8px] uppercase font-bold text-text-muted">Submitted</p>
                          <p className="font-semibold text-white">{selectedWallpaper.date}</p>
                        </div>
                      </div>
                    </div>
                  ) : (
                    // Active Edit Form Mode
                    <form onSubmit={handleSaveEdit} className="space-y-3 pt-3 border-t border-white/[0.04]">
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
                  )}
                </div>

                <div className="space-y-2 pt-4 border-t border-white/[0.04]">
                  {selectedWallpaper.status === 'pending' ? (
                    <>
                      <button
                        onClick={() => handleApprove(selectedWallpaper.id)}
                        className="w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                      >
                        <Check className="w-4 h-4 stroke-[3px]" />
                        <span>Approve</span>
                      </button>
                      <button
                        onClick={() => handleReject(selectedWallpaper.id)}
                        className="w-full py-2 bg-accent-error/10 hover:bg-accent-error/20 text-accent-error border border-accent-error/20 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                      >
                        <X className="w-4 h-4 stroke-[3px]" />
                        <span>Reject</span>
                      </button>
                    </>
                  ) : (
                    <>
                      <button
                        onClick={handleSaveEdit}
                        disabled={savingEdit}
                        className="w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
                      >
                        <Save className="w-4 h-4" />
                        <span>{savingEdit ? 'Saving...' : 'Save details'}</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(selectedWallpaper.id)}
                        className="w-full py-2 bg-accent-error/10 hover:bg-accent-error/20 text-accent-error border border-accent-error/20 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                      >
                        <Trash2 className="w-4 h-4" />
                        <span>Delete Asset</span>
                      </button>
                    </>
                  )}
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}


