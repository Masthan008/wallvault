'use client';

import React, { useEffect } from 'react';
import { Shield, ImageIcon, Users, CheckSquare, IndianRupee, UsersRound, Loader2 } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';

const adminNavItems = [
  { label: 'Overview', href: '/admin/overview', icon: Shield },
  { label: 'Moderation', href: '/admin/wallpapers', icon: ImageIcon },
  { label: 'Creators', href: '/admin/creators', icon: UsersRound },
  { label: 'Payout Requests', href: '/admin/payouts', icon: CheckSquare },
  { label: 'User Directory', href: '/admin/users', icon: Users },
  { label: 'Transactions', href: '/admin/payments', icon: IndianRupee },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, loading, isAdmin } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && (!user || !isAdmin)) {
      router.push('/login');
    }
  }, [user, loading, isAdmin, router]);

  if (loading) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-bg-primary text-white">
        <div className="flex flex-col items-center space-y-4">
          <Loader2 className="w-8 h-8 animate-spin text-accent-cyan" />
          <span className="text-xs uppercase tracking-widest font-extrabold text-text-muted">Loading Admin Portal</span>
        </div>
      </div>
    );
  }

  if (!user || !isAdmin) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-bg-primary text-text-primary relative overflow-hidden">
      {/* Background blurs */}
      <div className="absolute top-0 right-0 w-[40rem] h-[40rem] rounded-full bg-accent-cyan/5 blur-[140px] pointer-events-none" />

      <Sidebar
        title="Admin Control"
        items={adminNavItems}
        portalType="admin"
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

