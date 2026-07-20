'use client';

import React, { useEffect } from 'react';
import { LayoutDashboard, CloudUpload, BarChart3, Wallet, Loader2 } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';

const creatorNavItems = [
  { label: 'Dashboard', href: '/creator/dashboard', icon: LayoutDashboard },
  { label: 'Upload Wallpaper', href: '/creator/upload', icon: CloudUpload },
  { label: 'Analytics', href: '/creator/analytics', icon: BarChart3 },
  { label: 'Payouts', href: '/creator/payouts', icon: Wallet },
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
      <div className="flex h-screen items-center justify-center bg-[#0A0A0F] text-white">
        <Loader2 className="w-8 h-8 animate-spin text-[#B829DD]" />
      </div>
    );
  }

  if (!user || !isCreator) {
    return null; // Route redirect in progress
  }

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-white">
      <Sidebar
        title="Creator Hub"
        items={creatorNavItems}
        portalType="creator"
      />
      <div className="pl-64">
        <main className="min-h-[calc(100vh-4rem)] p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
