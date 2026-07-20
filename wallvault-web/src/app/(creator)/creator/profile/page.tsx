'use client';

import React, { useState, useEffect, useRef } from 'react';
import { User, Loader2, CheckCircle, Upload, AlertCircle, Camera } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { doc, getDoc, updateDoc, collection, query, where, getDocs, writeBatch } from 'firebase/firestore';
import { db } from '@/lib/firebase';

export default function CreatorProfileSettings() {
  const { user } = useAuth();
  
  const [displayName, setDisplayName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');
  
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    async function loadProfile() {
      if (!user) return;
      try {
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          const data = userDoc.data();
          setDisplayName(data.displayName || data.name || '');
          setEmail(data.email || user.email || '');
          setPhone(data.phone || data.phoneNumber || '');
          setAvatarUrl(data.avatarUrl || data.photoURL || '');
        }
      } catch (err) {
        console.error("Error loading profile:", err);
        setError("Failed to load profile data.");
      } finally {
        setLoading(false);
      }
    }
    loadProfile();
  }, [user]);

  const handleAvatarClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    if (!displayName.trim()) {
      setError('Display name is required.');
      return;
    }

    setSaving(true);
    setError('');
    setSuccess(false);

    try {
      let finalAvatarUrl = avatarUrl;

      // 1. Upload to Cloudinary if new image selected
      if (selectedFile) {
        const timestamp = Math.round(new Date().getTime() / 1000);
        const apiSecret = 'JMJq080FCoudvQVTzncRW4Ghd84';
        const apiKey = '972246177422269';
        const cloudName = 'dn30vxcoq';

        const signString = `folder=avatars&timestamp=${timestamp}${apiSecret}`;
        const encoder = new TextEncoder();
        const signData = encoder.encode(signString);
        const hashBuffer = await window.crypto.subtle.digest('SHA-1', signData);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const signature = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

        const formData = new FormData();
        formData.append('file', selectedFile);
        formData.append('api_key', apiKey);
        formData.append('timestamp', timestamp.toString());
        formData.append('folder', 'avatars');
        formData.append('signature', signature);

        const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
          method: 'POST',
          body: formData,
        });

        if (response.ok) {
          const uploadResult = await response.json();
          finalAvatarUrl = uploadResult.secure_url;
          setAvatarUrl(finalAvatarUrl);
          setSelectedFile(null);
        } else {
          throw new Error('Avatar image upload failed.');
        }
      }

      // 2. Update user profile in Firestore
      await updateDoc(doc(db, 'users', user.uid), {
        displayName: displayName.trim(),
        name: displayName.trim(), // sync both fields for safety
        avatarUrl: finalAvatarUrl,
        phone: phone.trim(),
        updatedAt: new Date(),
      });

      // 3. Propagate updates to all wallpapers uploaded by this creator
      const wallpapersQuery = query(
        collection(db, 'wallpapers'),
        where('creatorId', '==', user.uid)
      );
      const wallpapersSnap = await getDocs(wallpapersQuery);

      if (!wallpapersSnap.empty) {
        const batch = writeBatch(db);
        wallpapersSnap.forEach((wallpaperDoc) => {
          batch.update(doc(db, 'wallpapers', wallpaperDoc.id), {
            creatorName: displayName.trim(),
            creatorAvatarUrl: finalAvatarUrl,
          });
        });
        await batch.commit();
      }

      setSuccess(true);
    } catch (err: any) {
      console.error(err);
      setError(err.message || 'An error occurred while updating profile.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh] text-white">
        <Loader2 className="w-8 h-8 animate-spin text-accent-purple" />
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-white">Profile Settings</h1>
        <p className="text-sm text-text-muted mt-2">Update your creator profile info, upload avatar, and configure details.</p>
      </div>

      {success && (
        <div className="p-4 bg-accent-success/10 border border-accent-success/20 rounded-xl flex items-center space-x-3 text-accent-success text-sm">
          <CheckCircle className="w-5 h-5 flex-shrink-0" />
          <span>Profile settings updated successfully! Changes will reflect in admin and mobile applications.</span>
        </div>
      )}

      {error && (
        <div className="p-4 bg-accent-error/10 border border-accent-error/20 rounded-xl flex items-center space-x-3 text-accent-error text-sm">
          <AlertCircle className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      <form onSubmit={handleSubmit} className="bg-white/[0.02] border border-border-glass rounded-2xl p-8 space-y-6 relative overflow-hidden backdrop-blur-md">
        {/* Glow */}
        <div className="absolute top-0 right-0 w-32 h-32 rounded-full bg-accent-purple/5 blur-3xl pointer-events-none" />

        {/* Avatar Section */}
        <div className="flex flex-col items-center space-y-4">
          <div className="relative group cursor-pointer" onClick={handleAvatarClick}>
            <div className="w-24 h-24 rounded-full overflow-hidden border-2 border-border-glass bg-white/[0.04] flex items-center justify-center transition-all duration-300 group-hover:border-accent-purple/50">
              {previewUrl ? (
                <img src={previewUrl} alt="Avatar Preview" className="w-full h-full object-cover" />
              ) : avatarUrl ? (
                <img src={avatarUrl} alt="Profile Avatar" className="w-full h-full object-cover" />
              ) : (
                <User className="w-8 h-8 text-text-muted" />
              )}
            </div>
            <div className="absolute inset-0 rounded-full bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <Camera className="w-6 h-6 text-white" />
            </div>
          </div>
          <input 
            type="file" 
            ref={fileInputRef} 
            onChange={handleFileChange} 
            className="hidden" 
            accept="image/*" 
          />
          <button 
            type="button" 
            onClick={handleAvatarClick} 
            className="text-xs font-bold text-accent-purple uppercase tracking-wider hover:underline"
          >
            Change Profile Picture
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Display Name */}
          <div className="space-y-2">
            <label className="text-xs font-bold uppercase tracking-wider text-text-secondary">Display Name</label>
            <input
              type="text"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              className="w-full px-4 py-3 rounded-xl bg-white/[0.02] border border-border-glass text-white text-sm focus:outline-none focus:border-accent-purple focus:ring-1 focus:ring-accent-purple transition-all duration-200"
              placeholder="e.g. Satoshi"
            />
          </div>

          {/* Phone Number */}
          <div className="space-y-2">
            <label className="text-xs font-bold uppercase tracking-wider text-text-secondary">Phone Number</label>
            <input
              type="text"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full px-4 py-3 rounded-xl bg-white/[0.02] border border-border-glass text-white text-sm focus:outline-none focus:border-accent-purple focus:ring-1 focus:ring-accent-purple transition-all duration-200"
              placeholder="e.g. +91 9999999999"
            />
          </div>

          {/* Email (Read-only) */}
          <div className="space-y-2 md:col-span-2">
            <label className="text-xs font-bold uppercase tracking-wider text-text-muted">Registered Email Address (Read-only)</label>
            <input
              type="email"
              value={email}
              readOnly
              className="w-full px-4 py-3 rounded-xl bg-white/[0.01] border border-white/[0.03] text-text-muted text-sm cursor-not-allowed"
            />
          </div>
        </div>

        {/* Action Button */}
        <div className="pt-4 flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="px-6 py-3 bg-white text-black font-bold text-xs uppercase tracking-wider rounded-xl hover:bg-white/90 disabled:opacity-50 transition-all duration-200 flex items-center space-x-2 cursor-pointer shadow-md"
          >
            {saving ? (
              <>
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                <span>Saving...</span>
              </>
            ) : (
              <span>Save Profile Settings</span>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
