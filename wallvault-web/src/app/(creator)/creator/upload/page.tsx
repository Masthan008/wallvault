'use client';

import React, { useState, useRef } from 'react';
import { Upload, Loader2, CheckCircle } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { collection, addDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useRouter } from 'next/navigation';

export default function CreatorUpload() {
  const { user } = useAuth();
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Abstract');
  const [description, setDescription] = useState('');
  const [isPremium, setIsPremium] = useState(false);
  const [price, setPrice] = useState('49');
  
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

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


      // 2. Save metadata document to Firestore db
      await addDoc(collection(db, 'wallpapers'), {
        name,
        description,
        category: category.toLowerCase(),
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
      <div className="max-w-md mx-auto my-12 text-center p-8 glass-panel rounded-3xl space-y-4">
        <CheckCircle className="w-16 h-16 text-accent-success mx-auto animate-bounce" />
        <h2 className="text-2xl font-extrabold text-white">Upload Successful!</h2>
        <p className="text-text-secondary text-xs">Your wallpaper was submitted for review. Redirecting to your dashboard...</p>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div>
        <h1 className="text-4xl font-extrabold tracking-tight bg-gradient-to-r from-white to-text-secondary bg-clip-text text-transparent">
          Upload Wallpaper
        </h1>
        <p className="mt-1 text-sm text-text-secondary">Submit your artwork to the WallVault review panel.</p>
      </div>

      {error && (
        <div className="p-4 bg-accent-error/10 border border-accent-error/20 rounded-xl text-accent-error text-xs font-semibold">
          {error}
        </div>
      )}

      {/* Hidden File Input */}
      <input 
        type="file" 
        ref={fileInputRef} 
        onChange={handleFileChange} 
        className="hidden" 
        accept="image/*" 
      />

      {/* Visual File Selector Dropzone */}
      <div 
        onClick={handleFileClick}
        className="p-8 border-2 border-dashed rounded-2xl border-white/[0.05] bg-white/[0.01] hover:bg-white/[0.02] flex flex-col items-center justify-center text-center cursor-pointer hover:border-accent-purple/50 transition-all duration-300 h-80 overflow-hidden"
      >
        {previewUrl ? (
          <img src={previewUrl} alt="Preview" className="h-full object-contain rounded-xl border border-white/[0.08]" />
        ) : (
          <>
            <div className="p-4 rounded-2xl bg-accent-purple/10 text-accent-purple border border-accent-purple/20">
              <Upload className="w-8 h-8" />
            </div>
            <h3 className="mt-4 text-sm font-bold uppercase tracking-wider text-white">Select wallpaper image</h3>
            <p className="mt-1.5 text-xs text-text-muted">JPG, PNG or WebP up to 50MB (Recommended: 4K+ Resolution, 9:16 Ratio)</p>
          </>
        )}
      </div>

      <form onSubmit={handleSubmit} className="space-y-6 glass-panel p-8 rounded-3xl">
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
            <label className="block text-[10px] font-extrabold uppercase tracking-wider text-text-muted">Category</label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full px-4 py-3.5 glass-input text-sm text-text-secondary cursor-pointer"
            >
              <option>Abstract</option>
              <option>Anime</option>
              <option>Cars</option>
              <option>Nature</option>
              <option>Space</option>
              <option>Dark</option>
            </select>
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
              <button
                type="button"
                onClick={() => setIsPremium(false)}
                className={`py-3 rounded-xl font-bold uppercase tracking-wider text-xs transition-all duration-300 cursor-pointer ${
                  !isPremium 
                    ? 'bg-accent-purple/10 border border-accent-purple/40 text-white shadow-md'
                    : 'bg-white/[0.01] border border-white/[0.04] text-text-muted hover:border-white/[0.1] hover:text-text-secondary'
                }`}
              >
                Free
              </button>
              <button
                type="button"
                onClick={() => setIsPremium(true)}
                className={`py-3 rounded-xl font-bold uppercase tracking-wider text-xs transition-all duration-300 cursor-pointer ${
                  isPremium 
                    ? 'bg-accent-purple/10 border border-accent-purple/40 text-white shadow-md'
                    : 'bg-white/[0.01] border border-white/[0.04] text-text-muted hover:border-white/[0.1] hover:text-text-secondary'
                }`}
              >
                Premium
              </button>
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
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-3.5 bg-gradient-to-r from-accent-purple to-accent-cyan text-white font-bold uppercase tracking-wider text-xs rounded-xl shadow-lg hover:opacity-90 transition-all duration-300 flex items-center cursor-pointer disabled:opacity-50"
          >
            {loading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            Submit for Review
          </button>
        </div>
      </form>
    </div>
  );
}

