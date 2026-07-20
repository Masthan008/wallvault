'use client';

import React, { useState } from 'react';
import { Upload, Loader2, CheckCircle } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { collection, addDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { useRouter } from 'next/navigation';

export default function CreatorUpload() {
  const { user } = useAuth();
  const router = useRouter();
  
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Abstract');
  const [description, setDescription] = useState('');
  const [isPremium, setIsPremium] = useState(false);
  const [price, setPrice] = useState('0');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  // Drag and drop mock file name
  const [fileName, setFileName] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    if (!name) {
      setError('Please provide a name for the wallpaper.');
      return;
    }

    setLoading(true);
    setError('');

    try {
      // Mock Cloudinary URL for web upload demo
      const mockCloudinaryUrls = [
        'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=600',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=600'
      ];
      const randomUrl = mockCloudinaryUrls[Math.floor(Math.random() * mockCloudinaryUrls.length)];

      await addDoc(collection(db, 'wallpapers'), {
        name,
        description,
        category: category.toLowerCase(),
        creatorId: user.uid,
        creatorName: user.displayName || user.email?.split('@')[0] || 'Unknown Creator',
        imageUrl: randomUrl,
        thumbnailUrl: randomUrl,
        isPremium,
        price: isPremium ? parseFloat(price) : 0,
        status: 'pending', // pending approval by admin
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
      <div className="max-w-md mx-auto my-12 text-center p-8 bg-[#12121A] border border-[#1A1A24] rounded-2xl shadow-2xl space-y-4">
        <CheckCircle className="w-16 h-16 text-[#00E676] mx-auto animate-bounce" />
        <h2 className="text-2xl font-bold">Upload Successful!</h2>
        <p className="text-[#8B8B9E] text-sm">Your wallpaper was submitted for review. Redirecting to your dashboard...</p>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-white">Upload Wallpaper</h1>
        <p className="mt-1 text-sm text-[#8B8B9E]">Submit your artwork to the WallVault review panel.</p>
      </div>

      {error && (
        <div className="p-4 bg-red-950/20 border border-red-500/50 rounded-xl text-red-400 text-sm">
          {error}
        </div>
      )}

      {/* Drag & Drop Frame */}
      <div 
        onClick={() => setFileName('wallpaper_art_file.png')}
        className="p-8 border-2 border-dashed rounded-2xl border-[#1A1A24] bg-[#12121A]/50 flex flex-col items-center justify-center text-center cursor-pointer hover:border-[#B829DD]/50 transition-colors h-80"
      >
        <div className="p-4 rounded-full bg-[#B829DD]/10 text-[#B829DD]">
          <Upload className="w-8 h-8" />
        </div>
        <h3 className="mt-4 text-lg font-semibold">
          {fileName ? `Selected: ${fileName}` : 'Select wallpaper image'}
        </h3>
        <p className="mt-1 text-xs text-[#5A5A6E]">JPG, PNG or WebP up to 50MB (Recommended: 4K+ Resolution, 9:16 Ratio)</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6 bg-[#12121A] p-6 rounded-2xl border border-[#1A1A24]">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Cyberpunk Horizon"
              className="mt-2 w-full px-4 py-3 bg-[#0A0A0F] border border-[#1A1A24] rounded-xl focus:border-[#B829DD] focus:outline-none"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Category</label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="mt-2 w-full px-4 py-3 bg-[#0A0A0F] border border-[#1A1A24] rounded-xl focus:border-[#B829DD] focus:outline-none text-[#8B8B9E]"
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

        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Add details about your creation..."
            rows={4}
            className="mt-2 w-full px-4 py-3 bg-[#0A0A0F] border border-[#1A1A24] rounded-xl focus:border-[#B829DD] focus:outline-none"
          />
        </div>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Pricing Model</label>
            <div className="mt-2 grid grid-cols-2 gap-4">
              <button
                type="button"
                onClick={() => setIsPremium(false)}
                className={`py-3 rounded-xl font-semibold text-sm transition-colors ${
                  !isPremium 
                    ? 'bg-[#B829DD]/10 border border-[#B829DD] text-[#B829DD]'
                    : 'bg-[#0A0A0F] border border-[#1A1A24] text-[#8B8B9E] hover:border-[#5A5A6E]'
                }`}
              >
                Free
              </button>
              <button
                type="button"
                onClick={() => setIsPremium(true)}
                className={`py-3 rounded-xl font-semibold text-sm transition-colors ${
                  isPremium 
                    ? 'bg-[#B829DD]/10 border border-[#B829DD] text-[#B829DD]'
                    : 'bg-[#0A0A0F] border border-[#1A1A24] text-[#8B8B9E] hover:border-[#5A5A6E]'
                }`}
              >
                Premium
              </button>
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Price (INR)</label>
            <input
              type="number"
              value={isPremium ? price : '0'}
              onChange={(e) => setPrice(e.target.value)}
              placeholder="0"
              disabled={!isPremium}
              className={`mt-2 w-full px-4 py-3 border rounded-xl focus:outline-none transition-colors ${
                isPremium
                  ? 'bg-[#0A0A0F] border-[#1A1A24] focus:border-[#B829DD] text-white'
                  : 'bg-[#0A0A0F]/50 border-[#1A1A24] text-[#5A5A6E]'
              }`}
            />
          </div>
        </div>

        <div className="pt-4 border-t border-[#1A1A24] flex justify-end">
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-3 bg-gradient-to-r from-[#B829DD] to-[#00D4FF] text-white font-bold rounded-xl shadow-lg hover:opacity-90 transition-opacity flex items-center"
          >
            {loading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
            Submit for Review
          </button>
        </div>
      </form>
    </div>
  );
}
