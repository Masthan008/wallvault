'use client';

import React from 'react';
import { Check, X, Image as ImageIcon } from 'lucide-react';
import { DataTable } from '@/components/DataTable';

const mockModerations = [
  { id: '1', name: 'Cyberpunk Skyline', creator: 'Artist X', category: 'Abstract', date: '2026-07-20' },
  { id: '2', name: 'OLED Darkness', creator: 'Dev Y', category: 'OLED', date: '2026-07-20' },
  { id: '3', name: 'Desert Dune Sunset', creator: 'Crea Z', category: 'Nature', date: '2026-07-19' },
];

export default function AdminWallpapers() {
  const columns = [
    {
      header: 'Preview',
      accessor: (row: typeof mockModerations[0]) => (
        <div className="w-16 h-20 rounded bg-bg-elevated flex items-center justify-center border border-bg-elevated">
          <ImageIcon className="w-6 h-6 text-text-muted" />
        </div>
      ),
    },
    {
      header: 'Wallpaper details',
      accessor: (row: typeof mockModerations[0]) => (
        <div>
          <h4 className="font-semibold text-text-primary">{row.name}</h4>
          <span className="text-xs text-text-secondary">Category: {row.category}</span>
        </div>
      ),
    },
    {
      header: 'Creator',
      accessor: (row: typeof mockModerations[0]) => (
        <span className="text-accent-cyan font-medium">{row.creator}</span>
      ),
    },
    {
      header: 'Submitted Date',
      accessor: (row: typeof mockModerations[0]) => (
        <span className="text-text-secondary font-mono">{row.date}</span>
      ),
    },
    {
      header: 'Actions',
      accessor: (row: typeof mockModerations[0]) => (
        <div className="flex space-x-2">
          <button className="p-2 bg-accent-success/10 text-accent-success hover:bg-accent-success/20 rounded-lg transition-colors">
            <Check className="w-4 h-4" />
          </button>
          <button className="p-2 bg-accent-error/10 text-accent-error hover:bg-accent-error/20 rounded-lg transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Wallpaper Moderation</h1>
        <p className="mt-1 text-sm text-text-secondary">Review, approve, or reject new wallpaper submissions.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Pending Reviews</h2>
        <DataTable columns={columns} data={mockModerations} emptyMessage="All wallpapers reviewed!" />
      </div>
    </div>
  );
}
