'use client';

import React from 'react';
import { ShieldCheck, User } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';

const mockCreators = [
  { id: 'C-001', name: 'Elite Artist X', level: 'Level 4 — Star', balance: '₹4,500', totalSales: 342, status: 'approved' },
  { id: 'C-002', name: 'Design Maestro Y', level: 'Level 5 — Legend', balance: '₹12,450', totalSales: 1205, status: 'approved' },
  { id: 'C-003', name: 'Fresh Designer Z', level: 'Level 1 — Seedling', balance: '₹0', totalSales: 0, status: 'pending' },
];

export default function AdminCreators() {
  const columns = [
    {
      header: 'Creator Name',
      accessor: (row: typeof mockCreators[0]) => (
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded-full bg-bg-elevated flex items-center justify-center border border-bg-elevated">
            <User className="w-4 h-4 text-text-muted" />
          </div>
          <span className="font-semibold">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Tier Level',
      accessor: (row: typeof mockCreators[0]) => (
        <span className="text-accent-cyan font-medium">{row.level}</span>
      ),
    },
    {
      header: 'Balance',
      accessor: (row: typeof mockCreators[0]) => (
        <span className="font-mono text-text-secondary">{row.balance}</span>
      ),
    },
    {
      header: 'Total Sales',
      accessor: (row: typeof mockCreators[0]) => (
        <span className="font-mono text-text-secondary">{row.totalSales}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: typeof mockCreators[0]) => (
        <StatusBadge status={row.status as any} />
      ),
    },
    {
      header: 'Review Application',
      accessor: (row: typeof mockCreators[0]) => (
        row.status === 'pending' ? (
          <button className="px-3 py-1.5 bg-accent-purple text-white text-xs font-semibold rounded-lg hover:opacity-90 transition-opacity flex items-center space-x-1">
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Approve</span>
          </button>
        ) : (
          <span className="text-xs text-text-muted">Reviewed</span>
        )
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Creator Accounts</h1>
        <p className="mt-1 text-sm text-text-secondary">Approve creator enrollments, manage levels, and monitor earnings.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Creators Portfolio</h2>
        <DataTable columns={columns} data={mockCreators} />
      </div>
    </div>
  );
}
