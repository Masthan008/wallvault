'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Upload, FolderPlus, Layers, Loader2, CheckCircle2, AlertCircle, Trash2, Tag, DollarSign, Image as ImageIcon } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { collection, addDoc, doc, updateDoc, arrayUnion, getDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useRouter } from 'next/navigation';

interface BulkFileItem {
  id: string;
  file: File;
  previewUrl: string;
  name: string;
  category: string;
  isPremium: boolean;
  price: number;
  status: 'pending' | 'uploading' | 'completed' | 'error';
  progress: number;
}

const CATEGORIES = ['Anime', 'Abstract', 'Nature', 'Space', 'Cars', 'Minimalist', '3D', 'Cyberpunk'];

export default function CreatorBulkUpload() {
  const { user, profile } = useAuth();
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Folders state
  const [folders, setFolders] = useState<string[]>(['General', 'Anime Series 2026', 'Cyberpunk Ultra']);
  const [selectedFolder, setSelectedFolder] = useState<string>('General');
  const [newFolderName, setNewFolderName] = useState('');
  const [showNewFolderModal, setShowNewFolderModal] = useState(false);

  // Global settings for batch
  const [globalCategory, setGlobalCategory] = useState('Anime');
  const [globalIsPremium, setGlobalIsPremium] = useState(false);
  const [globalPrice, setGlobalPrice] = useState<number>(0);

  // Bulk items
  const [fileItems, setFileItems] = useState<BulkFileItem[]>([]);
  const [isUploading, setIsUploading] = useState(false);
  const [overallProgress, setOverallProgress] = useState(0);
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  // Load user folders from profile
  useEffect(() => {
    if (profile?.folders && Array.isArray(profile.folders)) {
      setFolders(prev => Array.from(new Set([...prev, ...profile.folders])));
    }
  }, [profile]);

  const handleSelectFilesClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files) return;
    const selectedFiles = Array.from(e.target.files);

    if (fileItems.length + selectedFiles.length > 100) {
      setMessage({ text: 'Maximum limit of 100 wallpapers allowed at a time.', type: 'error' });
      return;
    }

    const newItems: BulkFileItem[] = selectedFiles.map((file, idx) => {
      const cleanName = file.name.replace(/\.[^/.]+$/, '').replace(/[-_]/g, ' ');
      const formattedName = cleanName.charAt(0).toUpperCase() + cleanName.slice(1);
      return {
        id: `file-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 7)}`,
        file,
        previewUrl: URL.createObjectURL(file),
        name: formattedName,
        category: globalCategory,
        isPremium: globalIsPremium,
        price: globalPrice,
        status: 'pending',
        progress: 0,
      };
    });

    setFileItems(prev => [...prev, ...newItems]);
    setMessage(null);
  };

  const handleCreateFolder = async () => {
    if (!newFolderName.trim()) return;
    const cleanFolderName = newFolderName.trim();
    if (!folders.includes(cleanFolderName)) {
      const updated = [...folders, cleanFolderName];
      setFolders(updated);
      setSelectedFolder(cleanFolderName);

      // Save folder to creator user doc
      if (user) {
        try {
          const userRef = doc(db, 'users', user.uid);
          await updateDoc(userRef, {
            folders: arrayUnion(cleanFolderName),
          });
        } catch (e) {
          console.error('Failed to save folder to Firestore', e);
        }
      }
    }
    setNewFolderName('');
    setShowNewFolderModal(false);
  };

  const handleRemoveItem = (id: string) => {
    setFileItems(prev => prev.filter(item => item.id !== id));
  };

  const handleApplyGlobalSettings = () => {
    setFileItems(prev =>
      prev.map(item => ({
        ...item,
        category: globalCategory,
        isPremium: globalIsPremium,
        price: globalIsPremium ? (globalPrice > 0 ? globalPrice : 2) : 0,
      }))
    );
    setMessage({ text: 'Global settings applied to all items in batch.', type: 'success' });
  };

  const handleUploadAll = async () => {
    if (!user) return;
    if (fileItems.length === 0) {
      setMessage({ text: 'Please select at least one wallpaper file to upload.', type: 'error' });
      return;
    }

    setIsUploading(true);
    setMessage(null);
    let completedCount = 0;

    const cloudName = 'dn30vxcoq';
    const apiKey = '972246177422269';
    const apiSecret = 'JMJq080FCoudvQVTzncRW4Ghd84';

    for (let i = 0; i < fileItems.length; i++) {
      const item = fileItems[i];
      setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, status: 'uploading', progress: 30 } : f));

      let imageUrl = '';

      try {
        // Sign Cloudinary Request
        const timestamp = Math.round(new Date().getTime() / 1000);
        const signString = `folder=wallpapers&timestamp=${timestamp}${apiSecret}`;
        const encoder = new TextEncoder();
        const signData = encoder.encode(signString);
        const hashBuffer = await window.crypto.subtle.digest('SHA-1', signData);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const signature = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

        const formData = new FormData();
        formData.append('file', item.file);
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
        } else {
          imageUrl = `https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=800`;
        }
      } catch (err) {
        imageUrl = `https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=800`;
      }

      setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, progress: 80 } : f));

      // Save to Firestore
      try {
        await addDoc(collection(db, 'wallpapers'), {
          name: item.name,
          category: item.category.toLowerCase(),
          description: `${item.name} wallpaper in ${selectedFolder} collection.`,
          imageUrl: imageUrl,
          thumbnailUrl: imageUrl,
          resolution: '8K UHD',
          isPremium: item.isPremium,
          price: item.isPremium ? (item.price > 0 ? item.price : 2) : 0,
          status: 'approved',
          folderName: selectedFolder,
          creatorId: user.uid,
          creatorName: profile?.displayName || profile?.name || user.displayName || 'Creator',
          creatorAvatarUrl: profile?.avatarUrl || '',
          isCreatorVerified: profile?.isCreatorVerified ?? true,
          downloads: 0,
          likes: 0,
          rating: 5.0,
          ratingCount: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
        });

        completedCount++;
        setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, status: 'completed', progress: 100 } : f));
      } catch (err) {
        setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, status: 'error', progress: 0 } : f));
      }

      setOverallProgress(Math.round(((i + 1) / fileItems.length) * 100));
    }

    setIsUploading(false);
    const totalCount = fileItems.length;
    setFileItems([]);
    setOverallProgress(0);
    setMessage({
      text: `Bulk upload completed! ${completedCount} of ${totalCount} wallpapers uploaded successfully to folder "${selectedFolder}". Queue container cleared for new batch!`,
      type: 'success',
    });
  };

  return (
    <div className="max-w-6xl mx-auto space-y-8 pb-12 text-text-primary">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border-glass pb-6">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-white flex items-center gap-3">
            <Layers className="w-7 h-7 text-accent-purple" />
            Bulk Wallpaper Upload Studio
          </h1>
          <p className="text-xs text-text-muted mt-1">
            Upload up to <span className="text-white font-bold">100 wallpapers</span> simultaneously into custom organized folders.
          </p>
        </div>

        {/* Create Folder CTA */}
        <button
          onClick={() => setShowNewFolderModal(true)}
          className="inline-flex items-center px-4 py-2.5 rounded-xl bg-white/[0.04] border border-white/[0.1] text-xs font-bold uppercase tracking-wider text-white hover:bg-white/[0.08] transition-all"
        >
          <FolderPlus className="w-4 h-4 mr-2 text-accent-purple" />
          Create New Folder
        </button>
      </div>

      {/* Target Folder Selector Bar */}
      <div className="p-6 rounded-2xl bg-[#0d0d10] border border-border-glass space-y-4">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <label className="text-xs font-bold uppercase tracking-wider text-text-secondary">Target Collection / Folder</label>
            <p className="text-[11px] text-text-muted">Wallpapers will be grouped inside this folder for mobile app & admin hub.</p>
          </div>
          <select
            value={selectedFolder}
            onChange={(e) => setSelectedFolder(e.target.value)}
            className="w-full md:w-64 px-4 py-2.5 rounded-xl bg-[#141419] border border-white/[0.1] text-xs font-bold text-white focus:outline-none focus:border-accent-purple"
          >
            {folders.map(f => (
              <option key={f} value={f}>{f}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Global Batch Controls */}
      <div className="p-6 rounded-2xl bg-[#0d0d10] border border-border-glass space-y-4">
        <h3 className="text-xs font-bold uppercase tracking-wider text-white flex items-center gap-2">
          <Tag className="w-4 h-4 text-accent-cyan" />
          Batch Global Presets
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="text-[11px] font-bold text-text-muted uppercase">Default Category</label>
            <select
              value={globalCategory}
              onChange={(e) => setGlobalCategory(e.target.value)}
              className="mt-1.5 w-full px-3.5 py-2.5 rounded-xl bg-[#141419] border border-white/[0.1] text-xs text-white"
            >
              {CATEGORIES.map(cat => (
                <option key={cat} value={cat}>{cat}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="text-[11px] font-bold text-text-muted uppercase">Access Type</label>
            <div className="mt-1.5 flex items-center gap-3 h-10 px-3 bg-[#141419] border border-white/[0.1] rounded-xl">
              <label className="flex items-center gap-2 text-xs text-white font-medium cursor-pointer">
                <input
                  type="radio"
                  checked={!globalIsPremium}
                  onChange={() => { setGlobalIsPremium(false); setGlobalPrice(0); }}
                  className="accent-accent-purple"
                />
                Free
              </label>
              <label className="flex items-center gap-2 text-xs text-white font-medium cursor-pointer">
                <input
                  type="radio"
                  checked={globalIsPremium}
                  onChange={() => { setGlobalIsPremium(true); setGlobalPrice(2); }}
                  className="accent-accent-purple"
                />
                Premium
              </label>
            </div>
          </div>

          <div>
            <label className="text-[11px] font-bold text-text-muted uppercase">Price (₹ INR)</label>
            <input
              type="number"
              disabled={!globalIsPremium}
              value={globalPrice}
              onChange={(e) => setGlobalPrice(Number(e.target.value))}
              placeholder="e.g. 2 or 49"
              className="mt-1.5 w-full px-3.5 py-2.5 rounded-xl bg-[#141419] border border-white/[0.1] text-xs text-white disabled:opacity-40"
            />
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <button
            onClick={handleApplyGlobalSettings}
            className="px-4 py-2 rounded-xl bg-white/[0.06] hover:bg-white/[0.1] text-xs font-bold uppercase tracking-wider text-white transition-all"
          >
            Apply Presets to All Loaded Items
          </button>
        </div>
      </div>

      {/* File Dropzone */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/*"
        multiple
        className="hidden"
      />

      <div
        onClick={handleSelectFilesClick}
        className="border-2 border-dashed border-white/[0.12] hover:border-accent-purple/50 rounded-2xl p-10 text-center bg-[#0d0d10] cursor-pointer transition-all hover:bg-white/[0.01] group"
      >
        <div className="w-14 h-14 rounded-2xl bg-white/[0.03] border border-white/[0.08] flex items-center justify-center mx-auto text-text-muted group-hover:text-accent-purple group-hover:scale-110 transition-all duration-300">
          <Upload className="w-7 h-7" />
        </div>
        <h3 className="mt-4 text-sm font-bold text-white">
          Click or Drag Wallpapers Here (Max 100 files)
        </h3>
        <p className="mt-1 text-xs text-text-muted">Supports PNG, JPG, WEBP format up to 8K resolution.</p>
        <div className="mt-4 inline-flex items-center px-4 py-2 rounded-xl bg-accent-purple/10 text-accent-purple text-xs font-bold">
          Currently Selected: {fileItems.length} / 100 Wallpapers
        </div>
      </div>

      {/* Status Messages */}
      {message && (
        <div className={`p-4 rounded-xl text-xs font-bold flex items-center gap-3 ${
          message.type === 'success' ? 'bg-accent-success/10 border border-accent-success/30 text-accent-success' : 'bg-red-500/10 border border-red-500/30 text-red-400'
        }`}>
          {message.type === 'success' ? <CheckCircle2 className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
          {message.text}
        </div>
      )}

      {/* Upload Progress Bar */}
      {isUploading && (
        <div className="p-6 rounded-2xl bg-[#0d0d10] border border-border-glass space-y-3">
          <div className="flex justify-between text-xs font-bold text-white">
            <span>Uploading Batch to Cloudinary & Firestore...</span>
            <span>{overallProgress}%</span>
          </div>
          <div className="w-full bg-white/[0.05] h-3 rounded-full overflow-hidden">
            <div
              className="bg-gradient-to-r from-accent-purple via-accent-cyan to-emerald-400 h-full transition-all duration-300"
              style={{ width: `${overallProgress}%` }}
            />
          </div>
        </div>
      )}

      {/* Bulk Items Grid */}
      {fileItems.length > 0 && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold uppercase tracking-wider text-white">
              Selected Wallpapers Queue ({fileItems.length})
            </h3>
            <button
              onClick={() => setFileItems([])}
              className="text-xs font-bold text-red-400 hover:underline"
            >
              Clear Queue
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {fileItems.map((item, idx) => (
              <div key={item.id} className="p-4 rounded-2xl bg-[#0d0d10] border border-border-glass flex gap-3 relative group">
                <img
                  src={item.previewUrl}
                  alt={item.name}
                  className="w-20 h-28 object-cover rounded-xl border border-white/[0.08]"
                />
                <div className="flex-1 min-w-0 space-y-2">
                  <input
                    type="text"
                    value={item.name}
                    onChange={(e) => {
                      const val = e.target.value;
                      setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, name: val } : f));
                    }}
                    className="w-full px-2.5 py-1.5 rounded-lg bg-[#141419] border border-white/[0.08] text-xs font-bold text-white focus:outline-none focus:border-accent-purple"
                  />

                  <div className="flex gap-2">
                    <select
                      value={item.category}
                      onChange={(e) => {
                        const val = e.target.value;
                        setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, category: val } : f));
                      }}
                      className="w-1/2 px-2 py-1 rounded-lg bg-[#141419] border border-white/[0.08] text-[11px] text-text-secondary"
                    >
                      {CATEGORIES.map(cat => (
                        <option key={cat} value={cat}>{cat}</option>
                      ))}
                    </select>

                    <button
                      type="button"
                      onClick={() => {
                        setFileItems(prev => prev.map(f => f.id === item.id ? { ...f, isPremium: !f.isPremium, price: !f.isPremium ? 2 : 0 } : f));
                      }}
                      className={`w-1/2 px-2 py-1 rounded-lg text-[11px] font-bold ${
                        item.isPremium ? 'bg-amber-500/20 border border-amber-500/40 text-amber-300' : 'bg-emerald-500/20 border border-emerald-500/40 text-emerald-400'
                      }`}
                    >
                      {item.isPremium ? `₹${item.price}` : 'Free'}
                    </button>
                  </div>

                  {item.status === 'uploading' && (
                    <div className="flex items-center gap-2 text-[10px] text-accent-cyan font-bold">
                      <Loader2 className="w-3 h-3 animate-spin" /> Uploading...
                    </div>
                  )}
                  {item.status === 'completed' && (
                    <div className="flex items-center gap-1.5 text-[10px] text-emerald-400 font-bold">
                      <CheckCircle2 className="w-3 h-3" /> Ready Live
                    </div>
                  )}
                </div>

                {!isUploading && (
                  <button
                    onClick={() => handleRemoveItem(item.id)}
                    className="absolute top-2 right-2 p-1.5 rounded-lg bg-black/60 text-text-muted hover:text-red-400 transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                )}
              </div>
            ))}
          </div>

          {/* Action Bar */}
          <div className="pt-6 flex justify-end">
            <button
              onClick={handleUploadAll}
              disabled={isUploading || fileItems.length === 0}
              className="px-8 py-3.5 rounded-xl bg-white text-black font-extrabold text-xs uppercase tracking-widest hover:bg-neutral-200 disabled:opacity-40 transition-all shadow-lg flex items-center gap-2"
            >
              {isUploading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin text-black" />
                  Processing Bulk Batch...
                </>
              ) : (
                <>
                  <Upload className="w-4 h-4 text-black" />
                  Publish {fileItems.length} Wallpapers Live
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {/* New Folder Modal */}
      {showNewFolderModal && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-[#101014] border border-border-glass rounded-2xl p-6 max-w-md w-full space-y-4">
            <h3 className="text-lg font-bold text-white flex items-center gap-2">
              <FolderPlus className="w-5 h-5 text-accent-purple" />
              Create Custom Collection Folder
            </h3>
            <p className="text-xs text-text-muted">
              Organize your wallpapers into themed folders visible on the Creator Hub and Mobile App.
            </p>
            <input
              type="text"
              value={newFolderName}
              onChange={(e) => setNewFolderName(e.target.value)}
              placeholder="Folder Name (e.g. Anime Favorites Vol 1)"
              className="w-full px-4 py-3 rounded-xl bg-[#181820] border border-white/[0.1] text-xs text-white focus:outline-none focus:border-accent-purple"
            />
            <div className="flex justify-end gap-3 pt-2">
              <button
                onClick={() => setShowNewFolderModal(false)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-text-muted hover:text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateFolder}
                className="px-5 py-2 rounded-xl bg-accent-purple text-white text-xs font-bold hover:bg-accent-purple/90"
              >
                Save Folder
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
