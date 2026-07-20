'use client';

import React from 'react';
import { User, Search } from 'lucide-react';
import { DataTable } from '@/components/DataTable';

const mockUsers = [
  { id: 'usr-1002', name: 'John Doe', phone: '+91 9988776655', email: 'john@example.com', plan: 'Lifetime Pro', streak: '12 Days' },
  { id: 'usr-1023', name: 'Jane Smith', phone: '+91 9944332211', email: 'jane@example.com', plan: 'Free', streak: '0 Days' },
  { id: 'usr-2034', name: 'Alex Johnson', phone: '+91 8877665544', email: 'alex@example.com', plan: 'Monthly Pro', streak: '7 Days' },
];

export default function AdminUsers() {
  const columns = [
    {
      header: 'User ID',
      accessor: (row: typeof mockUsers[0]) => (
        <span className="font-mono text-text-secondary">{row.id}</span>
      ),
    },
    {
      header: 'Name',
      accessor: (row: typeof mockUsers[0]) => (
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded-full bg-bg-elevated flex items-center justify-center border border-bg-elevated">
            <User className="w-4 h-4 text-text-muted" />
          </div>
          <span className="font-semibold">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Contact Details',
      accessor: (row: typeof mockUsers[0]) => (
        <div className="flex flex-col text-xs">
          <span className="text-text-primary">{row.phone}</span>
          <span className="text-text-secondary">{row.email}</span>
        </div>
      ),
    },
    {
      header: 'Subscription Tier',
      accessor: (row: typeof mockUsers[0]) => (
        <span className={`font-semibold ${row.plan.includes('Pro') ? 'text-accent-gold' : 'text-text-secondary'}`}>
          {row.plan}
        </span>
      ),
    },
    {
      header: 'Daily Streak',
      accessor: (row: typeof mockUsers[0]) => (
        <span className="text-accent-purple font-medium">🔥 {row.streak}</span>
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">User Directory</h1>
        <p className="mt-1 text-sm text-text-secondary">View user accounts, streak history, subscriptions, and logs.</p>
      </div>

      <div className="flex items-center max-w-md bg-bg-card border border-bg-elevated rounded-xl px-4 py-2 focus-within:border-accent-purple transition-colors">
        <Search className="w-5 h-5 text-text-muted mr-3" />
        <input
          type="text"
          placeholder="Search by name, phone or email..."
          className="w-full bg-transparent focus:outline-none text-sm text-text-primary"
        />
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-text-primary">Users Registry</h2>
        <DataTable columns={columns} data={mockUsers} />
      </div>
    </div>
  );
}
