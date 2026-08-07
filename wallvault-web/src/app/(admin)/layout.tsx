'use client';

import React, { useEffect, useState } from 'react';
import { Shield, ImageIcon, Users, CheckSquare, IndianRupee, UsersRound, Loader2, MessageSquare, Grid } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';

const adminNavItems = [
  { label: 'Overview', href: '/admin/overview', icon: Shield },
  { label: 'Categories', href: '/admin/categories', icon: Grid },
  { label: 'Moderation', href: '/admin/wallpapers', icon: ImageIcon },
  { label: 'Reviews & Comments', href: '/admin/reviews', icon: MessageSquare },
  { label: 'Creators', href: '/admin/creators', icon: UsersRound },
  { label: 'Payout Requests', href: '/admin/payouts', icon: CheckSquare },
  { label: 'User Directory', href: '/admin/users', icon: Users },
  { label: 'Transactions', href: '/admin/payments', icon: IndianRupee },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, loading, isAdmin } = useAuth();
  const router = useRouter();
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    if (!loading && (!user || !isAdmin)) {
      router.push('/login');
    }
  }, [user, loading, isAdmin, router]);

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
            <Loader2 className="w-8 h-8 animate-spin text-accent-cyan" />
            <span className="absolute inset-0 rounded-full animate-ping bg-accent-cyan/20" />
          </div>
          <motion.span
            animate={{ opacity: [0.4, 1, 0.4] }}
            transition={{ duration: 1.6, repeat: Infinity }}
            className="text-xs uppercase tracking-widest font-extrabold text-text-muted"
          >
            Loading Admin Portal
          </motion.span>
        </motion.div>
      </div>
    );
  }

  if (!user || !isAdmin) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-bg-primary text-text-primary relative overflow-hidden">
      {/* Ambient accent blobs */}
      <div className="absolute top-[-10%] right-[-8%] w-[36rem] h-[36rem] rounded-full bg-accent-cyan/6 blur-[130px] animate-float-slow pointer-events-none" />
      <div className="absolute bottom-[-15%] left-[15%] w-[30rem] h-[30rem] rounded-full bg-accent-purple/6 blur-[130px] animate-float-slow pointer-events-none" style={{ animationDelay: '-4s' }} />

      <Sidebar
        title="Admin Control"
        items={adminNavItems}
        portalType="admin"
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
