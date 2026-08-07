'use client';

import React, { useState, useEffect, useRef } from 'react';
import { User, Loader2, CheckCircle, Upload, AlertCircle, Camera } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { doc, getDoc, updateDoc, collection, query, where, getDocs, writeBatch } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { motion, AnimatePresence } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';

export default function CreatorProfileSettings() {
  const { user } = useAuth();

  const [displayName, setDisplayName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');
  const [bio, setBio] = useState('');

  // Public vs Private Profile Visibility Settings
  const [isPublicProfile, setIsPublicProfile] = useState(true);
  const [showBio, setShowBio] = useState(true);

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
          setBio(data.bio || '');
          setIsPublicProfile(data.isPublicProfile !== false);
          setShowBio(data.showBio !== false);
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

      // 2. Update user profile in Firestore (public visibility toggles & bio)
      await updateDoc(doc(db, 'users', user.uid), {
        displayName: displayName.trim(),
        name: displayName.trim(),
        avatarUrl: finalAvatarUrl,
        phone: phone.trim(),
        bio: bio.trim(),
        isPublicProfile,
        showBio,
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
      setTimeout(() => setSuccess(false), 4000);
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
        <div className="relative">
          <Loader2 className="w-8 h-8 animate-spin text-accent-purple" />
          <span className="absolute inset-0 rounded-full animate-ping bg-accent-purple/20" />
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <PageHeader
        title="Profile Settings"
        subtitle="Update your creator profile info, upload avatar, and configure details."
        badge="Identity"
        badgeColor="#a855f7"
      />

      <AnimatePresence>
        {success && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="p-4 bg-accent-success/10 border border-accent-success/20 rounded-xl flex items-center space-x-3 text-accent-success text-sm"
          >
            <CheckCircle className="w-5 h-5 flex-shrink-0" />
            <span>Profile settings updated successfully! Changes will reflect in admin and mobile applications.</span>
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="p-4 bg-accent-error/10 border border-accent-error/20 rounded-xl flex items-center space-x-3 text-accent-error text-sm"
          >
            <AlertCircle className="w-5 h-5 flex-shrink-0" />
            <span>{error}</span>
          </motion.div>
        )}
      </AnimatePresence>

      <motion.form
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        onSubmit={handleSubmit}
        className="bg-white/[0.02] border border-border-glass rounded-2xl p-8 space-y-6 relative overflow-hidden backdrop-blur-md"
      >
        {/* Glow */}
        <div className="absolute top-0 right-0 w-32 h-32 rounded-full bg-accent-purple/5 blur-3xl pointer-events-none animate-float-slow" />

        {/* Avatar Section */}
        <div className="flex flex-col items-center space-y-4">
          <motion.div
            className="relative group cursor-pointer"
            onClick={handleAvatarClick}
            whileHover={{ scale: 1.04 }}
            whileTap={{ scale: 0.96 }}
          >
            <motion.div
              animate={{ boxShadow: ['0 0 0px rgba(168,85,247,0)', '0 0 24px rgba(168,85,247,0.2)', '0 0 0px rgba(168,85,247,0)'] }}
              transition={{ duration: 3, repeat: Infinity }}
              className="w-24 h-24 rounded-full overflow-hidden border-2 border-border-glass bg-white/[0.04] flex items-center justify-center transition-all duration-300 group-hover:border-accent-purple/50"
            >
              {previewUrl ? (
                <img src={previewUrl} alt="Avatar Preview" className="w-full h-full object-cover" />
              ) : avatarUrl ? (
                <img src={avatarUrl} alt="Profile Avatar" className="w-full h-full object-cover" />
              ) : (
                <User className="w-8 h-8 text-text-muted" />
              )}
            </motion.div>
            <div className="absolute inset-0 rounded-full bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <Camera className="w-6 h-6 text-white" />
            </div>
          </motion.div>
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

          {/* Bio Description */}
          <div className="space-y-2 md:col-span-2">
            <label className="text-xs font-bold uppercase tracking-wider text-text-secondary">Public Bio / Description</label>
            <textarea
              rows={3}
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              className="w-full px-4 py-3 rounded-xl bg-white/[0.02] border border-border-glass text-white text-sm focus:outline-none focus:border-accent-purple focus:ring-1 focus:ring-accent-purple transition-all duration-200"
              placeholder="Tell your fans about your art style, tools, and inspirations..."
            />
          </div>

          {/* Email (Read-only) */}
          <div className="space-y-2 md:col-span-2">
            <label className="text-xs font-bold uppercase tracking-wider text-text-muted">Registered Email Address (Private — Never Shared Publicly)</label>
            <input
              type="email"
              value={email}
              readOnly
              className="w-full px-4 py-3 rounded-xl bg-white/[0.01] border border-white/[0.03] text-text-muted text-sm cursor-not-allowed"
            />
          </div>
        </div>

        {/* ── Public vs Private Visibility Controls ───────────────────────── */}
        <div className="pt-4 border-t border-white/[0.06] space-y-4">
          <h3 className="text-sm font-bold uppercase tracking-wider text-white">Public Profile Visibility Controls</h3>
          <p className="text-xs text-text-muted">Choose which details are displayed publicly on your mobile app creator profile card. Private details like email, phone, and earnings are always protected.</p>

          <div className="space-y-3 pt-2">
            <motion.label
              whileHover={{ x: 3 }}
              className="flex items-center justify-between p-3.5 bg-white/[0.02] border border-border-glass rounded-xl cursor-pointer group"
            >
              <div className="flex flex-col">
                <span className="text-xs font-bold text-white">Enable Public Creator Profile</span>
                <span className="text-[11px] text-text-muted">Allow app users to view your public creator card, wallpapers, and wallpaper counts.</span>
              </div>
              <div className="relative">
                <input
                  type="checkbox"
                  checked={isPublicProfile}
                  onChange={(e) => setIsPublicProfile(e.target.checked)}
                  className="peer sr-only"
                />
                <motion.div
                  animate={{ backgroundColor: isPublicProfile ? '#a855f7' : '#27272a' }}
                  className="w-11 h-6 rounded-full relative transition-colors"
                >
                  <motion.div
                    animate={{ x: isPublicProfile ? 22 : 2 }}
                    transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                    className="absolute top-1 w-4 h-4 rounded-full bg-white shadow-md"
                  />
                </motion.div>
              </div>
            </motion.label>

            <motion.label
              whileHover={{ x: 3 }}
              className="flex items-center justify-between p-3.5 bg-white/[0.02] border border-border-glass rounded-xl cursor-pointer group"
            >
              <div className="flex flex-col">
                <span className="text-xs font-bold text-white">Show Bio in Mobile App</span>
                <span className="text-[11px] text-text-muted">Display your public bio text under your creator avatar in the app.</span>
              </div>
              <div className="relative">
                <input
                  type="checkbox"
                  checked={showBio}
                  onChange={(e) => setShowBio(e.target.checked)}
                  className="peer sr-only"
                />
                <motion.div
                  animate={{ backgroundColor: showBio ? '#a855f7' : '#27272a' }}
                  className="w-11 h-6 rounded-full relative transition-colors"
                >
                  <motion.div
                    animate={{ x: showBio ? 22 : 2 }}
                    transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                    className="absolute top-1 w-4 h-4 rounded-full bg-white shadow-md"
                  />
                </motion.div>
              </div>
            </motion.label>
          </div>
        </div>

        {/* Action Button */}
        <div className="pt-4 flex justify-end">
          <motion.button
            whileHover={{ y: -1.5 }}
            whileTap={{ scale: 0.96 }}
            type="submit"
            disabled={saving}
            className="btn-shine px-6 py-3 bg-white text-black font-bold text-xs uppercase tracking-wider rounded-xl hover:bg-white/90 disabled:opacity-50 transition-all duration-200 flex items-center space-x-2 cursor-pointer shadow-md"
          >
            {saving ? (
              <>
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                <span>Saving...</span>
              </>
            ) : (
              <span>Save Profile Settings</span>
            )}
          </motion.button>
        </div>
      </motion.form>
    </div>
  );
}
