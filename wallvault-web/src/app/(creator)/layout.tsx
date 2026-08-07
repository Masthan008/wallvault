'use client';

import React, { useEffect, useState } from 'react';
import { LayoutDashboard, CloudUpload, Layers, BarChart3, Wallet, Loader2, User } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';

const creatorNavItems = [
  { label: 'Dashboard', href: '/creator/dashboard', icon: LayoutDashboard },
  { label: 'Upload Wallpaper', href: '/creator/upload', icon: CloudUpload },
  { label: 'Bulk Upload (100)', href: '/creator/bulk-upload', icon: Layers },
  { label: 'Analytics', href: '/creator/analytics', icon: BarChart3 },
  { label: 'Payouts', href: '/creator/payouts', icon: Wallet },
  { label: 'Profile Settings', href: '/creator/profile', icon: User },
];

export default function CreatorLayout({ children }: { children: React.ReactNode }) {
  const { user, loading, isCreator } = useAuth();
  const router = useRouter();
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    if (!loading && (!user || !isCreator)) {
      router.push('/login');
    }
  }, [user, loading, isCreator, router]);

  if (loading) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-bg-primary text-white">
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="flex flex-col items-center space-y-5"
        >
          <div className="relative">
            <Loader2 className="w-8 h-8 animate-spin text-accent-purple" />
            <span className="absolute inset-0 rounded-full animate-ping bg-accent-purple/20" />
          </div>
          <motion.span
            animate={{ opacity: [0.4, 1, 0.4] }}
            transition={{ duration: 1.6, repeat: Infinity }}
            className="text-xs uppercase tracking-widest font-extrabold text-text-muted"
          >
            Loading Creator Hub
          </motion.span>
        </motion.div>
      </div>
    );
  }

  if (!user || !isCreator) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-bg-primary text-text-primary relative overflow-hidden">
      {/* Ambient accent blobs */}
      <div className="absolute top-[-10%] right-[-8%] w-[36rem] h-[36rem] rounded-full bg-accent-purple/6 blur-[130px] animate-float-slow pointer-events-none" />
      <div className="absolute bottom-[-15%] left-[15%] w-[30rem] h-[30rem] rounded-full bg-accent-cyan/6 blur-[130px] animate-float-slow pointer-events-none" style={{ animationDelay: '-4s' }} />

      <Sidebar
        title="Creator Hub"
        items={creatorNavItems}
        portalType="creator"
        collapsed={collapsed}
        onToggle={() => setCollapsed(!collapsed)}
      />

      <motion.div
        animate={{ paddingLeft: collapsed ? 72 : 256 }}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
        className="min-h-screen"
      >
        <main className="min-h-screen p-8 relative z-10">
          {children}
        </main>
      </motion.div>
    </div>
  );
}
