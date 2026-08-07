'use client';

import React, { useEffect, useState } from 'react';
import { Check, X, Image as ImageIcon, ExternalLink, Calendar, User, Tag, Search, Edit2, Trash2, Save, DollarSign, Plus, Upload, Loader2, Sparkles } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { collection, query, onSnapshot, doc, updateDoc, deleteDoc, orderBy, addDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';
import { useCategories } from '@/lib/useCategories';
import { useAuth } from '@/components/AuthProvider';
import { PageHeader } from '@/components/motion/PageHeader';
import { AnimatedModal } from '@/components/motion/AnimatedModal';

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
  const { user } = useAuth();
  const { categories, addCategory } = useCategories();
  const reduce = useReducedMotion();

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

  // Admin Upload Modal state
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [adminFiles, setAdminFiles] = useState<File[]>([]);
  const [adminCategory, setAdminCategory] = useState('Abstract');
  const [adminCustomCategory, setAdminCustomCategory] = useState('');
  const [isAdminNewCatMode, setIsAdminNewCatMode] = useState(false);
  const [adminIsPremium, setAdminIsPremium] = useState(false);
  const [adminPrice, setAdminPrice] = useState('49');
  const [uploadingAdmin, setUploadingAdmin] = useState(false);
  const adminFileInputRef = React.useRef<HTMLInputElement>(null);

  const handleAdminUploadSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!adminFiles || adminFiles.length === 0) return;
    setUploadingAdmin(true);

    const targetCat = isAdminNewCatMode && adminCustomCategory.trim() ? adminCustomCategory.trim() : adminCategory;
    if (isAdminNewCatMode && adminCustomCategory.trim()) {
      await addCategory(adminCustomCategory.trim());
    }

    try {
      for (const file of adminFiles) {
        const cleanName = file.name.replace(/\.[^/.]+$/, '').replace(/[-_]/g, ' ');
        const name = cleanName.charAt(0).toUpperCase() + cleanName.slice(1);

        let imageUrl = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=800';
        try {
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
          formData.append('file', file);
          formData.append('api_key', apiKey);
          formData.append('timestamp', timestamp.toString());
          formData.append('folder', 'wallpapers');
          formData.append('signature', signature);

          const res = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
            method: 'POST',
            body: formData,
          });
          if (res.ok) {
            const data = await res.json();
            imageUrl = data.secure_url;
          }
        } catch (err) {
          console.warn('Cloudinary upload fallback triggered');
        }

        await addDoc(collection(db, 'wallpapers'), {
          name,
          category: targetCat.toLowerCase(),
          categoryDisplayName: targetCat,
          creatorId: user?.uid || 'admin',
          creatorName: 'WallVault Official',
          imageUrl,
          thumbnailUrl: imageUrl,
          isPremium: adminIsPremium,
          price: adminIsPremium ? parseFloat(adminPrice) : 0,
          status: 'approved',
          downloads: 0,
          views: 0,
          likes: 0,
          rating: 5.0,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      }

      setShowUploadModal(false);
      setAdminFiles([]);
      setAdminCustomCategory('');
      setIsAdminNewCatMode(false);
    } catch (err) {
      console.error('Failed admin bulk upload:', err);
    } finally {
      setUploadingAdmin(false);
    }
  };

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
          className="w-16 h-20 rounded-lg bg-white/[0.02] overflow-hidden flex items-center justify-center border border-white/[0.06] shadow-md transition-all duration-300 hover:scale-105 cursor-zoom-in hover:border-accent-cyan/40 hover:shadow-[0_0_16px_rgba(6,182,212,0.12)]"
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
              <motion.button
                whileHover={{ scale: 1.12, y: -1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleApprove(row.id)}
                className="p-2 bg-accent-success/10 text-accent-success hover:bg-accent-success/20 rounded-lg border border-accent-success/20 transition-all duration-300 cursor-pointer"
              >
                <Check className="w-4 h-4 stroke-[3px]" />
              </motion.button>
              <motion.button
                whileHover={{ scale: 1.12, y: -1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleReject(row.id)}
                className="p-2 bg-accent-error/10 text-accent-error hover:bg-accent-error/20 rounded-lg border border-accent-error/20 transition-all duration-300 cursor-pointer"
              >
                <X className="w-4 h-4 stroke-[3px]" />
              </motion.button>
            </>
          ) : (
            <>
              <motion.button
                whileHover={{ scale: 1.12, y: -1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => setSelectedWallpaper(row)}
                className="p-2 bg-white/[0.02] text-text-secondary hover:text-white rounded-lg border border-white/[0.05] transition-all duration-200 cursor-pointer"
              >
                <Edit2 className="w-3.5 h-3.5" />
              </motion.button>
              <motion.button
                whileHover={{ scale: 1.12, y: -1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleDelete(row.id)}
                className="p-2 bg-accent-error/10 text-accent-error hover:bg-accent-error/20 rounded-lg border border-accent-error/20 transition-all duration-200 cursor-pointer"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </motion.button>
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
      <PageHeader
        title="Wallpaper Management"
        subtitle="Moderate submissions, search assets, edit properties, or delete items."
        badge="Moderation"
        badgeColor="#06b6d4"
        actions={
          <motion.button
            whileHover={{ y: -2, scale: 1.02 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => setShowUploadModal(true)}
            className="btn-shine flex items-center space-x-2 px-4 py-2.5 bg-accent-cyan/15 text-accent-cyan border border-accent-cyan/30 hover:bg-accent-cyan/25 rounded-xl font-bold text-xs uppercase tracking-wider transition-all duration-200 cursor-pointer shadow-lg"
          >
            <Plus className="w-4 h-4 stroke-[3px]" />
            <span>Upload Wallpapers (Single / Bulk)</span>
          </motion.button>
        }
      />

      {/* Tabs Layout */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="flex gap-1 p-1 bg-white/[0.01] rounded-xl w-fit border border-white/[0.05]"
      >
        {(['pending', 'active'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`relative px-4 py-2 text-[10px] font-bold uppercase tracking-[0.1em] rounded-lg transition-colors duration-200 cursor-pointer ${
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
            <span className="relative z-10 flex items-center gap-2">
              {tab === 'pending' ? `Pending (${pendingItems.length})` : `Live (${wallpapers.filter(w => w.status === 'approved').length})`}
              {tab === 'pending' && pendingItems.length > 0 && (
                <span className="w-1.5 h-1.5 rounded-full bg-accent-gold animate-pulse" />
              )}
            </span>
          </button>
        ))}
      </motion.div>

      {/* Search Input for Live tab */}
      <AnimatePresence>
        {activeTab === 'active' && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="relative max-w-md"
          >
            <Search className="absolute left-3.5 top-3 w-4 h-4 text-text-muted" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search wallpapers, creators, categories..."
              className="w-full pl-10 pr-4 py-2.5 glass-input text-xs"
            />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Database list rendering */}
      <div className="space-y-4">
        {activeTab === 'pending' ? (
          <DataTable columns={columns} data={pendingItems} emptyMessage="All wallpapers reviewed!" />
        ) : (
          <DataTable columns={columns} data={activeItems} emptyMessage="No approved wallpapers match query search." />
        )}
      </div>

      {/* Custom Detail modal & Edit properties sheet */}
      <AnimatedModal open={!!selectedWallpaper} onClose={() => setSelectedWallpaper(null)} maxWidthClass="max-w-2xl">
        {selectedWallpaper && (
          <div className="bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row h-[500px]">
            {/* Wallpaper Preview Side */}
            <div className="flex-1 bg-black flex items-center justify-center relative group min-h-[250px] md:min-h-0">
              <motion.img
                key={selectedWallpaper.imageUrl}
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4 }}
                src={selectedWallpaper.imageUrl}
                alt={selectedWallpaper.name}
                className="absolute inset-0 w-full h-full object-contain"
              />
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
                    <p className="text-[9px] text-text-muted mt-1 uppercase font-bold tracking-wider font-mono">ID: {selectedWallpaper.id.slice(0, 12)}</p>
                  </div>
                  <motion.button
                    whileHover={{ rotate: 90 }}
                    whileTap={{ scale: 0.85 }}
                    onClick={() => setSelectedWallpaper(null)}
                    className="p-1 text-text-muted hover:text-white rounded transition-colors cursor-pointer"
                  >
                    <X className="w-5 h-5" />
                  </motion.button>
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
                        <motion.button
                          whileTap={{ scale: 0.95 }}
                          type="button"
                          onClick={() => setEditIsPremium(false)}
                          className={`py-1.5 rounded text-[10px] font-bold uppercase tracking-wider transition-colors cursor-pointer ${
                            !editIsPremium
                              ? 'bg-white text-black'
                              : 'bg-[#18181b] border border-[#27272a] text-text-muted'
                          }`}
                        >
                          Free
                        </motion.button>
                        <motion.button
                          whileTap={{ scale: 0.95 }}
                          type="button"
                          onClick={() => setEditIsPremium(true)}
                          className={`py-1.5 rounded text-[10px] font-bold uppercase tracking-wider transition-colors cursor-pointer ${
                            editIsPremium
                              ? 'bg-white text-black'
                              : 'bg-[#18181b] border border-[#27272a] text-text-muted'
                          }`}
                        >
                          Premium
                        </motion.button>
                      </div>
                    </div>

                    {editIsPremium && (
                      <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        className="space-y-1 overflow-hidden"
                      >
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
                      </motion.div>
                    )}
                  </form>
                )}
              </div>

              <div className="space-y-2 pt-4 border-t border-white/[0.04]">
                {selectedWallpaper.status === 'pending' ? (
                  <>
                    <motion.button
                      whileHover={{ y: -1 }}
                      whileTap={{ scale: 0.97 }}
                      onClick={() => handleApprove(selectedWallpaper.id)}
                      className="btn-shine w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                    >
                      <Check className="w-4 h-4 stroke-[3px]" />
                      <span>Approve</span>
                    </motion.button>
                    <motion.button
                      whileHover={{ y: -1 }}
                      whileTap={{ scale: 0.97 }}
                      onClick={() => handleReject(selectedWallpaper.id)}
                      className="w-full py-2 bg-accent-error/10 hover:bg-accent-error/20 text-accent-error border border-accent-error/20 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                    >
                      <X className="w-4 h-4 stroke-[3px]" />
                      <span>Reject</span>
                    </motion.button>
                  </>
                ) : (
                  <>
                    <motion.button
                      whileHover={{ y: -1 }}
                      whileTap={{ scale: 0.97 }}
                      onClick={handleSaveEdit}
                      disabled={savingEdit}
                      className="btn-shine w-full py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
                    >
                      <Save className="w-4 h-4" />
                      <span>{savingEdit ? 'Saving...' : 'Save details'}</span>
                    </motion.button>
                    <motion.button
                      whileHover={{ y: -1 }}
                      whileTap={{ scale: 0.97 }}
                      type="button"
                      onClick={() => handleDelete(selectedWallpaper.id)}
                      className="w-full py-2 bg-accent-error/10 hover:bg-accent-error/20 text-accent-error border border-accent-error/20 font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                    >
                      <Trash2 className="w-4 h-4" />
                      <span>Delete Asset</span>
                    </motion.button>
                  </>
                )}
              </div>
            </div>
          </div>
        )}
      </AnimatedModal>

      {/* Admin Bulk / Single Upload Modal */}
      <AnimatedModal open={showUploadModal} onClose={() => setShowUploadModal(false)} maxWidthClass="max-w-xl">
        <div className="bg-[#09090b] border border-white/[0.08] rounded-2xl overflow-hidden shadow-2xl p-6 space-y-6">
          <div className="flex items-center justify-between border-b border-white/[0.06] pb-4">
            <div>
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <Upload className="w-5 h-5 text-accent-cyan" />
                Admin Asset Upload
              </h3>
              <p className="text-[10px] text-[#52525b] font-medium mt-0.5">Upload single or up to 100 wallpapers directly to live status.</p>
            </div>
            <motion.button
              whileHover={{ rotate: 90 }}
              onClick={() => setShowUploadModal(false)}
              className="p-1 text-[#52525b] hover:text-white rounded cursor-pointer"
            >
              <X className="w-5 h-5" />
            </motion.button>
          </div>

          <form onSubmit={handleAdminUploadSubmit} className="space-y-4">
            {/* File Drop Area */}
            <input
              type="file"
              ref={adminFileInputRef}
              multiple
              accept="image/*"
              className="hidden"
              onChange={(e) => {
                if (e.target.files) {
                  setAdminFiles(Array.from(e.target.files).slice(0, 100));
                }
              }}
            />
            <motion.div
              whileHover={{ scale: 1.005 }}
              onClick={() => adminFileInputRef.current?.click()}
              className="p-6 border-2 border-dashed border-white/[0.08] hover:border-accent-cyan/40 bg-white/[0.01] hover:bg-white/[0.02] rounded-xl flex flex-col items-center justify-center text-center cursor-pointer transition-all"
            >
              {adminFiles.length > 0 ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="space-y-1"
                >
                  <p className="text-xs font-bold text-accent-cyan flex items-center gap-1.5">
                    <Sparkles className="w-3.5 h-3.5" /> {adminFiles.length} wallpaper file(s) selected
                  </p>
                  <p className="text-[10px] text-[#52525b]">{adminFiles.map(f => f.name).slice(0, 3).join(', ')}{adminFiles.length > 3 ? '...' : ''}</p>
                </motion.div>
              ) : (
                <>
                  <div className="p-3 rounded-xl bg-accent-cyan/10 border border-accent-cyan/20 mb-2">
                    <Upload className="w-6 h-6 text-accent-cyan" />
                  </div>
                  <p className="text-xs font-bold text-white">Click to select single or bulk images (Max 100)</p>
                  <p className="text-[10px] text-[#52525b] mt-0.5">PNG, JPG, WebP formats supported</p>
                </>
              )}
            </motion.div>

            {/* Category Selection or New Folder Mode */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between">
                <label className="block text-[9px] font-bold uppercase tracking-wider text-[#52525b]">Category / Folder</label>
                {!isAdminNewCatMode ? (
                  <button
                    type="button"
                    onClick={() => setIsAdminNewCatMode(true)}
                    className="text-[9px] font-bold text-accent-cyan hover:underline cursor-pointer"
                  >
                    + Create New Folder
                  </button>
                ) : (
                  <button
                    type="button"
                    onClick={() => setIsAdminNewCatMode(false)}
                    className="text-[9px] font-bold text-[#52525b] hover:underline cursor-pointer"
                  >
                    Select Existing
                  </button>
                )}
              </div>
              <AnimatePresence mode="wait">
                {!isAdminNewCatMode ? (
                  <motion.select
                    key="cat"
                    initial={{ opacity: 0, y: 6 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -6 }}
                    transition={{ duration: 0.2 }}
                    value={adminCategory}
                    onChange={(e) => {
                      if (e.target.value === '__new__') setIsAdminNewCatMode(true);
                      else setAdminCategory(e.target.value);
                    }}
                    className="w-full px-3 py-2.5 glass-input text-xs cursor-pointer"
                  >
                    {categories.map((cat) => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                    <option value="__new__">+ Create New Folder...</option>
                  </motion.select>
                ) : (
                  <motion.input
                    key="catinput"
                    initial={{ opacity: 0, y: 6 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -6 }}
                    transition={{ duration: 0.2 }}
                    type="text"
                    value={adminCustomCategory}
                    onChange={(e) => setAdminCustomCategory(e.target.value)}
                    placeholder="Enter new folder / category name..."
                    required={isAdminNewCatMode}
                    className="w-full px-3 py-2.5 glass-input text-xs"
                  />
                )}
              </AnimatePresence>
            </div>

            {/* Pricing Mode */}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-[9px] font-bold uppercase tracking-wider text-[#52525b] mb-1">Type</label>
                <div className="grid grid-cols-2 gap-1.5">
                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    type="button"
                    onClick={() => setAdminIsPremium(false)}
                    className={`py-2 rounded-lg text-[10px] font-bold uppercase transition-all cursor-pointer ${
                      !adminIsPremium ? 'bg-white text-black' : 'bg-white/[0.02] text-[#52525b] border border-white/[0.05]'
                    }`}
                  >
                    Free
                  </motion.button>
                  <motion.button
                    whileTap={{ scale: 0.95 }}
                    type="button"
                    onClick={() => setAdminIsPremium(true)}
                    className={`py-2 rounded-lg text-[10px] font-bold uppercase transition-all cursor-pointer ${
                      adminIsPremium ? 'bg-accent-cyan text-black' : 'bg-white/[0.02] text-[#52525b] border border-white/[0.05]'
                    }`}
                  >
                    Premium
                  </motion.button>
                </div>
              </div>
              {adminIsPremium && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                >
                  <label className="block text-[9px] font-bold uppercase tracking-wider text-[#52525b] mb-1">Price (INR)</label>
                  <input
                    type="number"
                    value={adminPrice}
                    onChange={(e) => setAdminPrice(e.target.value)}
                    className="w-full px-3 py-2 glass-input text-xs"
                  />
                </motion.div>
              )}
            </div>

            {/* Action Buttons */}
            <div className="flex gap-2 pt-3 border-t border-white/[0.06]">
              <button
                type="button"
                onClick={() => setShowUploadModal(false)}
                className="flex-1 py-2.5 bg-white/[0.02] text-[#52525b] hover:text-white rounded-xl text-xs font-bold uppercase tracking-wider border border-white/[0.05] transition-colors cursor-pointer"
              >
                Cancel
              </button>
              <motion.button
                whileHover={{ y: -1 }}
                whileTap={{ scale: 0.97 }}
                type="submit"
                disabled={uploadingAdmin || adminFiles.length === 0}
                className="btn-shine flex-1 py-2.5 bg-accent-cyan text-black hover:opacity-90 rounded-xl text-xs font-bold uppercase tracking-wider disabled:opacity-40 flex items-center justify-center gap-2 cursor-pointer"
              >
                {uploadingAdmin ? <Loader2 className="w-4 h-4 animate-spin" /> : <Upload className="w-4 h-4" />}
                <span>{uploadingAdmin ? 'Uploading...' : `Upload ${adminFiles.length} Assets`}</span>
              </motion.button>
            </div>
          </form>
        </div>
      </AnimatedModal>
    </div>
  );
}
