'use client';

import React from 'react';
import { Shield, ImageIcon, Users, CheckSquare, IndianRupee, UsersRound } from 'lucide-react';
import { Sidebar } from '@/components/Sidebar';

const adminNavItems = [
  { label: 'Overview', href: '/admin/overview', icon: Shield },
  { label: 'Moderation', href: '/admin/wallpapers', icon: ImageIcon },
  { label: 'Creators', href: '/admin/creators', icon: UsersRound },
  { label: 'Payout Requests', href: '/admin/payouts', icon: CheckSquare },
  { label: 'User Directory', href: '/admin/users', icon: Users },
  { label: 'Transactions', href: '/admin/payments', icon: IndianRupee },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-bg-primary text-text-primary">
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
