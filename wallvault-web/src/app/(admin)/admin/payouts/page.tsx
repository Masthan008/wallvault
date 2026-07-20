'use client';

import React from 'react';
import { Landmark, Check, X } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';

const mockPayoutRequests = [
  { id: 'PAY-003', creator: 'Elite Artist X', amount: '₹2,450', details: 'UPI (creator@upi)', date: '2026-07-20', status: 'processing' },
  { id: 'PAY-004', creator: 'Design Maestro Y', amount: '₹12,800', details: 'UPI (maestro@upi)', date: '2026-07-20', status: 'pending' },
];

export default function AdminPayouts() {
  const columns = [
    {
      header: 'Request ID',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <span className="font-mono text-text-secondary">{row.id}</span>
      ),
    },
    {
      header: 'Creator',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <span className="font-semibold text-text-primary">{row.creator}</span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <span className="font-bold text-accent-gold">{row.amount}</span>
      ),
    },
    {
      header: 'Payment Method',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <div className="flex items-center space-x-2">
          <Landmark className="w-4 h-4 text-text-muted" />
          <span className="text-text-secondary">{row.details}</span>
        </div>
      ),
    },
    {
      header: 'Requested Date',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <span className="text-text-secondary font-mono">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <StatusBadge status={row.status as any} />
      ),
    },
    {
      header: 'Action',
      accessor: (row: typeof mockPayoutRequests[0]) => (
        <div className="flex space-x-2">
          <button className="px-3 py-1.5 bg-accent-success text-bg-primary text-xs font-bold rounded-lg hover:opacity-90 transition-opacity flex items-center space-x-1">
            <Check className="w-3.5 h-3.5" />
            <span>Process</span>
          </button>
          <button className="px-3 py-1.5 bg-accent-error/10 text-accent-error border border-accent-error/30 text-xs font-bold rounded-lg hover:bg-accent-error/20 transition-colors">
            <X className="w-3.5 h-3.5" />
            <span>Reject</span>
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Payout Processing</h1>
        <p className="mt-1 text-sm text-text-secondary">Approve and verify creator payout requests using RazorpayX backend triggers.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Pending Payout Requests</h2>
        <DataTable columns={columns} data={mockPayoutRequests} emptyMessage="No pending payouts requests." />
      </div>
    </div>
  );
}
