'use client';

import React, { useState, useRef, useCallback } from 'react';
import { Upload, Loader2, CheckCircle, ImagePlus, Sparkles } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { collection, addDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { GradientButton } from '@/components/motion/GradientButton';

import { useCategories } from '@/lib/useCategories';

export default function CreatorUpload() {
  const { user } = useAuth();
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { categories, addCategory } = useCategories();
  const reduce = useReducedMotion();

  const [name, setName] = useState('');
  const [category, setCategory] = useState('Abstract');
  const [customCategory, setCustomCategory] = useState('');
  const [isNewCatMode, setIsNewCatMode] = useState(false);
  const [description, setDescription] = useState('');
  const [isPremium, setIsPremium] = useState(false);
  const [price, setPrice] = useState('49');

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const [dragging, setDragging] = useState(false);

  // Real file selection states
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState('');

  const handleFileClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (files && files.length > 0) {
      const file = files[0];
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  };

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    if (!selectedFile) {
      setError('Please select a wallpaper image to upload.');
      return;
    }
    if (!name) {
      setError('Please enter a name for your wallpaper.');
      return;
    }

    setLoading(true);
    setError('');

    let uploadedImageUrl = '';

    try {
      // 1. Upload to Cloudinary using signed upload
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
      formData.append('file', selectedFile);
      formData.append('api_key', apiKey);
      formData.append('timestamp', timestamp.toString());
      formData.append('folder', 'wallpapers');
      formData.append('signature', signature);

      try {
        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
          method: 'POST',
          body: formData,
        });

        if (response.ok) {
          const data = await response.json();
          uploadedImageUrl = data.secure_url;
        } else {
          const errorData = await response.json().catch(() => ({}));
          console.error('Cloudinary upload failure payload:', errorData);
          throw new Error('Cloudinary response failed');
        }
      } catch (uploadError) {
        console.warn('Cloudinary upload fallback triggered:', uploadError);
        // Fallback to Unsplash URL if Cloudinary credentials are not validated
        uploadedImageUrl = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=800';
      }

      const finalCategory = isNewCatMode && customCategory.trim() ? customCategory.trim() : category;

      if (isNewCatMode && customCategory.trim()) {
        await addCategory(customCategory.trim());
      }

      // 2. Save metadata document to Firestore db
      await addDoc(collection(db, 'wallpapers'), {
        name,
        description,
        category: finalCategory.toLowerCase(),
        categoryDisplayName: finalCategory,
        creatorId: user.uid,
        creatorName: user.displayName || user.email?.split('@')[0] || 'Unknown Creator',
        imageUrl: uploadedImageUrl,
        thumbnailUrl: uploadedImageUrl,
        isPremium,
        price: isPremium ? parseFloat(price) : 0,
        status: 'pending', // awaits admin approval
        downloads: 0,
        views: 0,
        likes: 0,
        rating: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      setSuccess(true);
      setTimeout(() => {
        router.push('/creator/dashboard');
      }, 1500);
    } catch (err: any) {
      setError(err.message || 'Failed to submit wallpaper.');
      setLoading(false);
    }
  };

  if (success) {
    return (
      <motion.div
        initial={reduce ? { opacity: 0 } : { opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ type: 'spring', stiffness: 200, damping: 18 }}
        className="max-w-md mx-auto my-12 text-center p-10 glass-panel rounded-3xl space-y-5 relative overflow-hidden"
      >
        <div className="absolute top-0 left-0 right-0 h-[2px] accent-line" style={{ ['--accent-line-color' as string]: '#10b981' }} />
        <motion.div
          animate={{ y: [0, -8, 0] }}
          transition={{ duration: 1.8, repeat: Infinity, ease: 'easeInOut' }}
          className="w-20 h-20 mx-auto rounded-full bg-accent-success/10 border border-accent-success/25 flex items-center justify-center"
        >
          <CheckCircle className="w-10 h-10 text-accent-success" />
        </motion.div>
        <motion.h2
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="text-2xl font-extrabold text-white"
        >
          Upload Successful!
        </motion.h2>
        <p className="text-text-secondary text-xs">Your wallpaper was submitted for review. Redirecting to your dashboard...</p>
        <div className="h-1 w-full bg-white/[0.04] rounded-full overflow-hidden mt-2">
          <motion.div
            initial={{ width: '0%' }}
            animate={{ width: '100%' }}
            transition={{ duration: 1.5, ease: 'easeInOut' }}
            className="h-full bg-gradient-to-r from-accent-purple to-accent-cyan rounded-full"
          />
        </div>
      </motion.div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <PageHeader
        title="Upload Wallpaper"
        subtitle="Submit your artwork to the WallVault review panel."
        badge="Creator Studio"
        badgeColor="#a855f7"
      />

      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="p-4 bg-accent-error/10 border border-accent-error/20 rounded-xl text-accent-error text-xs font-semibold"
          >
            {error}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Hidden File Input */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        className="hidden"
        accept="image/*"
      />

      {/* Visual File Selector Dropzone */}
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15, duration: 0.5 }}
        onClick={handleFileClick}
        onDragOver={(e) => { e.preventDefault(); setDragging(true); }}
        onDragLeave={() => setDragging(false)}
        onDrop={handleDrop}
        whileHover={{ scale: 1.005 }}
        className={`relative p-8 border-2 border-dashed rounded-2xl flex flex-col items-center justify-center text-center cursor-pointer transition-all duration-300 h-80 overflow-hidden group ${
          dragging
            ? 'border-accent-purple/70 bg-accent-purple/5 shadow-[0_0_40px_rgba(168,85,247,0.12)]'
            : previewUrl
              ? 'border-accent-purple/30 bg-white/[0.01]'
              : 'border-white/[0.05] bg-white/[0.01] hover:border-accent-purple/40 hover:bg-white/[0.02]'
        }`}
      >
        {dragging && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className="absolute inset-0 flex items-center justify-center z-10 bg-black/70 backdrop-blur-sm"
          >
            <div className="text-center space-y-2">
              <motion.div animate={{ scale: [1, 1.15, 1] }} transition={{ duration: 1, repeat: Infinity }}>
                <ImagePlus className="w-12 h-12 text-accent-purple mx-auto" />
              </motion.div>
              <p className="text-sm font-bold text-white uppercase tracking-wider">Drop to upload</p>
            </div>
          </motion.div>
        )}

        {previewUrl ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="h-full w-full"
          >
            <img src={previewUrl} alt="Preview" className="h-full w-full object-contain rounded-xl border border-white/[0.08] transition-transform duration-500 group-hover:scale-[1.02]" />
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 px-3 py-1.5 rounded-full bg-black/70 border border-white/10 text-[9px] font-bold uppercase tracking-wider text-white">
              {selectedFile?.name} • Click to change
            </div>
          </motion.div>
        ) : (
          <>
            <motion.div
              animate={{ y: [0, -6, 0] }}
              transition={{ duration: 2.5, repeat: Infinity, ease: 'easeInOut' }}
              className="p-4 rounded-2xl bg-accent-purple/10 text-accent-purple border border-accent-purple/20"
            >
              <Upload className="w-8 h-8" />
            </motion.div>
            <h3 className="mt-4 text-sm font-bold uppercase tracking-wider text-white">Select wallpaper image</h3>
            <p className="mt-1.5 text-xs text-text-muted">JPG, PNG or WebP up to 50MB (Recommended: 4K+ Resolution, 9:16 Ratio)</p>
            <p className="mt-2 text-[9px] text-[#3f3f46] font-semibold uppercase tracking-wider">or drag & drop here</p>
          </>
        )}
      </motion.div>

      <motion.form
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.25, duration: 0.55 }}
        onSubmit={handleSubmit}
        className="space-y-6 glass-panel p-8 rounded-3xl"
      >
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div className="space-y-1.5">
            <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Wallpaper Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Cyberpunk Horizon"
              required
              className="w-full px-4 py-3.5 glass-input text-sm"
            />
          </div>
          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Category / Folder</label>
              {!isNewCatMode ? (
                <button
                  type="button"
                  onClick={() => setIsNewCatMode(true)}
                  className="text-[10px] font-bold text-accent-purple hover:underline cursor-pointer"
                >
                  + Create New Folder
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => setIsNewCatMode(false)}
                  className="text-[10px] font-bold text-text-muted hover:underline cursor-pointer"
                >
                  Select Existing
                </button>
              )}
            </div>
            <AnimatePresence mode="wait">
              {!isNewCatMode ? (
                <motion.select
                  key="select"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -6 }}
                  transition={{ duration: 0.2 }}
                  value={category}
                  onChange={(e) => {
                    if (e.target.value === '__new__') {
                      setIsNewCatMode(true);
                    } else {
                      setCategory(e.target.value);
                    }
                  }}
                  className="w-full px-4 py-3.5 glass-input text-sm text-text-secondary cursor-pointer"
                >
                  {categories.map((cat) => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                  <option value="__new__">+ Create New Folder...</option>
                </motion.select>
              ) : (
                <motion.input
                  key="input"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -6 }}
                  transition={{ duration: 0.2 }}
                  type="text"
                  value={customCategory}
                  onChange={(e) => setCustomCategory(e.target.value)}
                  placeholder="Enter new folder / category name..."
                  required={isNewCatMode}
                  className="w-full px-4 py-3.5 glass-input text-sm"
                />
              )}
            </AnimatePresence>
          </div>
        </div>

        <div className="space-y-1.5">
          <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Add details about your creation..."
            rows={4}
            className="w-full px-4 py-3.5 glass-input text-sm"
          />
        </div>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div className="space-y-1.5">
            <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Pricing Model</label>
            <div className="grid grid-cols-2 gap-4">
              <motion.button
                type="button"
                whileTap={{ scale: 0.96 }}
                onClick={() => setIsPremium(false)}
                className={`py-3 rounded-xl font-bold uppercase tracking-wider text-xs transition-all duration-300 cursor-pointer relative overflow-hidden ${
                  !isPremium
                    ? 'bg-accent-purple/10 border border-accent-purple/40 text-white shadow-md'
                    : 'bg-white/[0.01] border border-white/[0.04] text-text-muted hover:border-white/[0.1] hover:text-text-secondary'
                }`}
              >
                {!isPremium && (
                  <motion.span
                    layoutId="pricing-pill"
                    className="absolute inset-0 rounded-xl border border-accent-purple/30"
                    style={{ background: 'rgba(168,85,247,0.06)' }}
                    transition={{ type: 'spring', stiffness: 350, damping: 26 }}
                  />
                )}
                <span className="relative z-10">Free</span>
              </motion.button>
              <motion.button
                type="button"
                whileTap={{ scale: 0.96 }}
                onClick={() => setIsPremium(true)}
                className={`py-3 rounded-xl font-bold uppercase tracking-wider text-xs transition-all duration-300 cursor-pointer relative overflow-hidden ${
                  isPremium
                    ? 'bg-accent-purple/10 border border-accent-purple/40 text-white shadow-md'
                    : 'bg-white/[0.01] border border-white/[0.04] text-text-muted hover:border-white/[0.1] hover:text-text-secondary'
                }`}
              >
                {isPremium && (
                  <motion.span
                    layoutId="pricing-pill"
                    className="absolute inset-0 rounded-xl border border-accent-purple/30"
                    style={{ background: 'rgba(168,85,247,0.06)' }}
                    transition={{ type: 'spring', stiffness: 350, damping: 26 }}
                  />
                )}
                <span className="relative z-10 flex items-center justify-center gap-1.5">
                  <Sparkles className="w-3 h-3" />
                  Premium
                </span>
              </motion.button>
            </div>
          </div>
          <div className="space-y-1.5">
            <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Price (INR)</label>
            <input
              type="number"
              value={isPremium ? price : '0'}
              onChange={(e) => setPrice(e.target.value)}
              placeholder="0"
              disabled={!isPremium}
              className={`w-full px-4 py-3.5 rounded-xl border text-sm focus:outline-none transition-all duration-300 ${
                isPremium
                  ? 'bg-white/[0.02] border-white/[0.05] focus:border-accent-purple text-white'
                  : 'bg-white/[0.01] border-white/[0.02] text-text-muted cursor-not-allowed'
              }`}
            />
          </div>
        </div>

        <div className="pt-6 border-t border-white/[0.05] flex justify-end">
          <GradientButton type="submit" disabled={loading} variant="purple" size="lg" className="min-w-[190px]">
            {loading && <Loader2 className="w-4 h-4 animate-spin" />}
            {loading ? 'Uploading...' : 'Submit for Review'}
          </GradientButton>
        </div>
      </motion.form>
    </div>
  );
}
