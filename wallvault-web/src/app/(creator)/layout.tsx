'use client';

import React from 'react';
import { LayoutDashboard, CloudUpload, BarChart3, Wallet } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';

const creatorNavItems = [
  { label: 'Dashboard', href: '/creator/dashboard', icon: LayoutDashboard },
  { label: 'Upload Wallpaper', href: '/creator/upload', icon: CloudUpload },
  { label: 'Analytics', href: '/creator/analytics', icon: BarChart3 },
  { label: 'Payouts', href: '/creator/payouts', icon: Wallet },
];

export default function CreatorLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-bg-primary text-text-primary">
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
