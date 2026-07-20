'use client';

import React, { useEffect } from 'react';
import { Shield, ImageIcon, Users, CheckSquare, IndianRupee, UsersRound, Loader2 } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';

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
      <div className="flex h-screen items-center justify-center bg-[#0A0A0F] text-white">
        <Loader2 className="w-8 h-8 animate-spin text-[#00D4FF]" />
      </div>
    );
  }

  if (!user || !isAdmin) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-white">
      <Sidebar
        title="Admin Control"
        items={adminNavItems}
        portalType="admin"
      />
      <div className="pl-64">
        <main className="min-h-[calc(100vh-4rem)] p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
