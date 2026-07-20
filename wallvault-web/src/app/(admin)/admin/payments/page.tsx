'use client';

import React from 'react';
import { CreditCard } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';

const mockTransactions = [
  { id: 'TXN-908123', user: 'John Doe', type: 'Subscription (Yearly)', amount: '₹799', gatewayId: 'pay_RPZ891230', date: '2026-07-20', status: 'completed' },
  { id: 'TXN-908124', user: 'Jane Smith', type: 'Wallpaper Purchase', amount: '₹49', gatewayId: 'pay_RPZ891231', date: '2026-07-20', status: 'completed' },
  { id: 'TXN-908125', user: 'Alex Johnson', type: 'Creator Tip', amount: '₹100', gatewayId: 'pay_RPZ891232', date: '2026-07-19', status: 'failed' },
];

export default function AdminPayments() {
  const columns = [
    {
      header: 'Transaction ID',
      accessor: (row: typeof mockTransactions[0]) => (
        <span className="font-mono text-text-secondary">{row.id}</span>
      ),
    },
    {
      header: 'User / Buyer',
      accessor: (row: typeof mockTransactions[0]) => (
        <span className="font-semibold">{row.user}</span>
      ),
    },
    {
      header: 'Transaction Type',
      accessor: (row: typeof mockTransactions[0]) => (
        <span className="text-text-secondary font-medium">{row.type}</span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: typeof mockTransactions[0]) => (
        <span className="font-bold text-text-primary">{row.amount}</span>
      ),
    },
    {
      header: 'Razorpay Payment ID',
      accessor: (row: typeof mockTransactions[0]) => (
        <div className="flex items-center space-x-2 font-mono text-xs text-text-secondary">
          <CreditCard className="w-3.5 h-3.5" />
          <span>{row.gatewayId}</span>
        </div>
      ),
    },
    {
      header: 'Date',
      accessor: (row: typeof mockTransactions[0]) => (
        <span className="text-text-secondary font-mono">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: typeof mockTransactions[0]) => (
        <StatusBadge status={row.status as any} />
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Payment Transactions</h1>
        <p className="mt-1 text-sm text-text-secondary">Track platform orders, tips, and gateway event callbacks.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Transactions Ledger</h2>
        <DataTable columns={columns} data={mockTransactions} />
      </div>
    </div>
  );
}
