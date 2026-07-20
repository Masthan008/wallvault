'use client';

import React from 'react';
import { DollarSign, Download, Image as ImageIcon, Users } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';

const mockUploads = [
  { id: '1', name: 'Cyberpunk Neon City', downloads: 342, status: 'approved', price: '₹49' },
  { id: '2', name: 'Minimalist Sand Dunes', downloads: 1205, status: 'approved', price: 'Free' },
  { id: '3', name: 'OLED Cosmic Galaxy', downloads: 54, status: 'pending', price: '₹99' },
  { id: '4', name: 'Dark Cyber Samurai', downloads: 0, status: 'rejected', price: '₹149' },
];

export default function CreatorDashboard() {
  const columns = [
    {
      header: 'Wallpaper',
      accessor: (row: typeof mockUploads[0]) => (
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded bg-bg-elevated flex items-center justify-center">
            <ImageIcon className="w-5 h-5 text-text-muted" />
          </div>
          <span className="font-semibold">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Type / Price',
      accessor: (row: typeof mockUploads[0]) => (
        <span className="text-text-secondary">{row.price}</span>
      ),
    },
    {
      header: 'Downloads',
      accessor: (row: typeof mockUploads[0]) => (
        <span className="font-mono text-text-secondary">{row.downloads}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: typeof mockUploads[0]) => (
        <StatusBadge status={row.status as any} />
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-bold tracking-tight text-text-primary">Dashboard</h1>
          <p className="mt-1 text-sm text-text-secondary">Welcome back! Here is how your portfolio is doing.</p>
        </div>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard
          label="Total Earnings"
          value="₹12,450"
          icon={DollarSign}
          trend={{ value: 24.3, isPositive: true }}
          glowColor="gold"
        />
        <KPICard
          label="Downloads"
          value="1,601"
          icon={Download}
          trend={{ value: 12.5, isPositive: true }}
          glowColor="purple"
        />
        <KPICard
          label="Wallpapers"
          value="4"
          icon={ImageIcon}
          glowColor="cyan"
        />
        <KPICard
          label="Followers"
          value="342"
          icon={Users}
          trend={{ value: 5.2, isPositive: true }}
        />
      </div>

      {/* Recent uploads */}
      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Recent Uploads</h2>
        <DataTable columns={columns} data={mockUploads} />
      </div>
    </div>
  );
}
