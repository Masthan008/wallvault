'use client';

import React, { useEffect } from 'react';
import { LayoutDashboard, CloudUpload, BarChart3, Wallet, Loader2, User } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';

const creatorNavItems = [
  { label: 'Dashboard', href: '/creator/dashboard', icon: LayoutDashboard },
  { label: 'Upload Wallpaper', href: '/creator/upload', icon: CloudUpload },
  { label: 'Analytics', href: '/creator/analytics', icon: BarChart3 },
  { label: 'Payouts', href: '/creator/payouts', icon: Wallet },
  { label: 'Profile Settings', href: '/creator/profile', icon: User },
];

export default function CreatorLayout({ children }: { children: React.ReactNode }) {
  const { user, loading, isCreator } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && (!user || !isCreator)) {
      router.push('/login');
    }
  }, [user, loading, isCreator, router]);

  if (loading) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-bg-primary text-white">
        <div className="flex flex-col items-center space-y-4">
          <Loader2 className="w-8 h-8 animate-spin text-accent-purple" />
          <span className="text-xs uppercase tracking-widest font-extrabold text-text-muted">Loading Creator Hub</span>
        </div>
      </div>
    );
  }

  if (!user || !isCreator) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-bg-primary text-text-primary relative overflow-hidden">
      {/* Background blurs */}
      <div className="absolute top-0 right-0 w-[40rem] h-[40rem] rounded-full bg-accent-purple/5 blur-[140px] pointer-events-none" />

      <Sidebar
        title="Creator Hub"
        items={creatorNavItems}
        portalType="creator"
      />
      
      <div className="pl-64">
        <main className="min-h-screen p-8 relative z-10">
          <AnimatePresence mode="wait">
            <motion.div
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 15 }}
              transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
}

