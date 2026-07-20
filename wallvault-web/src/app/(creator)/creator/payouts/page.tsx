'use client';

import React from 'react';
import { Landmark, CheckCircle, Clock } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';

const mockPayouts = [
  { id: 'PAY-001', amount: '₹4,500', method: 'UPI (creator@upi)', date: '2026-07-15', status: 'completed' },
  { id: 'PAY-002', amount: '₹8,000', method: 'UPI (creator@upi)', date: '2026-07-02', status: 'completed' },
  { id: 'PAY-003', amount: '₹2,450', method: 'UPI (creator@upi)', date: '2026-07-20', status: 'processing' },
];

export default function CreatorPayouts() {
  const columns = [
    {
      header: 'Payout ID',
      accessor: (row: typeof mockPayouts[0]) => (
        <span className="font-mono text-text-secondary">{row.id}</span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: typeof mockPayouts[0]) => (
        <span className="font-bold text-text-primary">{row.amount}</span>
      ),
    },
    {
      header: 'Method',
      accessor: (row: typeof mockPayouts[0]) => (
        <span className="text-text-secondary">{row.method}</span>
      ),
    },
    {
      header: 'Requested Date',
      accessor: (row: typeof mockPayouts[0]) => (
        <span className="text-text-secondary">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: typeof mockPayouts[0]) => (
        <StatusBadge status={row.status as any} />
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Payouts</h1>
        <p className="mt-1 text-sm text-text-secondary">Withdraw your portfolio earnings and configure payout methods.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        <div className="p-6 bg-bg-card border border-bg-elevated rounded-2xl md:col-span-2 flex items-center justify-between">
          <div className="space-y-1">
            <span className="text-sm font-medium text-text-secondary">Available Balance</span>
            <h3 className="text-3xl font-bold text-accent-gold">₹2,450</h3>
            <p className="text-xs text-text-muted">Minimum payout threshold: ₹500</p>
          </div>
          <button className="px-5 py-3 bg-accent-gold text-bg-primary font-bold rounded-xl hover:opacity-90 transition-opacity">
            Request Payout
          </button>
        </div>

        <div className="p-6 bg-bg-card border border-bg-elevated rounded-2xl flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-text-secondary">Payout Option</span>
            <Landmark className="w-5 h-5 text-accent-purple" />
          </div>
          <div className="mt-4">
            <h4 className="text-sm font-semibold">UPI Account Active</h4>
            <p className="text-xs text-text-secondary mt-1 font-mono">creator@upi</p>
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Payout History</h2>
        <DataTable columns={columns} data={mockPayouts} />
      </div>
    </div>
  );
}
