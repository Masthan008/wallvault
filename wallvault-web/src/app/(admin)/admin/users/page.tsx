'use client';

import React, { useState, useEffect } from 'react';
import { User, Search } from 'lucide-react';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { SkeletonLoader } from '@/components/SkeletonLoader';

interface UserItem {
  id: string;
  name: string;
  phone: string;
  email: string;
  plan: string;
  streak: number;
}

export default function AdminUsers() {
  const [users, setUsers] = useState<UserItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'users'), orderBy('createdAt', 'desc'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: UserItem[] = [];
      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        const isAdmin = data.isAdmin === true;
        const isCreator = data.isCreator === true || data.role === 'creator';
        
        let planTier = 'Free';
        if (isAdmin) {
          planTier = 'Platform Admin';
        } else if (isCreator) {
          planTier = 'Art Creator';
        } else if (data.subscriptionTier) {
          planTier = data.subscriptionTier;
        } else if (data.plan) {
          planTier = data.plan;
        }

        items.push({
          id: docSnap.id,
          name: data.name || data.displayName || 'Unknown User',
          phone: data.phone || data.phoneNumber || 'N/A',
          email: data.email || 'N/A',
          plan: planTier,
          streak: data.streak || 0,
        });
      });
      setUsers(items);
      setLoading(false);
    }, (error) => {
      console.error('Error fetching users:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  // Filter users by search query
  const filteredUsers = users.filter((user) => {
    const queryLower = searchQuery.toLowerCase();
    return (
      user.name.toLowerCase().includes(queryLower) ||
      user.email.toLowerCase().includes(queryLower) ||
      user.phone.toLowerCase().includes(queryLower) ||
      user.plan.toLowerCase().includes(queryLower)
    );
  });

  const columns = [
    {
      header: 'User ID',
      accessor: (row: UserItem) => (
        <span className="font-mono text-text-secondary text-xs">{row.id}</span>
      ),
    },
    {
      header: 'Name',
      accessor: (row: UserItem) => (
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded-full bg-white/[0.04] flex items-center justify-center border border-white/[0.05]">
            <User className="w-4 h-4 text-text-muted" />
          </div>
          <span className="font-bold text-text-primary text-sm">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Contact Details',
      accessor: (row: UserItem) => (
        <div className="flex flex-col text-xs font-mono">
          <span className="text-text-primary">{row.phone}</span>
          <span className="text-text-muted">{row.email}</span>
        </div>
      ),
    },
    {
      header: 'Subscription / Role',
      accessor: (row: UserItem) => {
        const isHighlight = row.plan.includes('Pro') || row.plan.includes('Admin') || row.plan.includes('Creator');
        return (
          <span className={`font-bold text-xs uppercase tracking-wider ${
            isHighlight ? 'text-accent-gold' : 'text-text-secondary'
          }`}>
            {row.plan}
          </span>
        );
      },
    },
    {
      header: 'Daily Streak',
      accessor: (row: UserItem) => (
        <span className="text-accent-purple font-extrabold text-xs">
          🔥 {row.streak} {row.streak === 1 ? 'Day' : 'Days'}
        </span>
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-extrabold tracking-tight bg-gradient-to-r from-white to-text-secondary bg-clip-text text-transparent">
          User Directory
        </h1>
        <p className="mt-1 text-sm text-text-secondary">
          View user accounts, streak history, subscription tiers, and developer roles in real-time.
        </p>
      </div>

      <div className="flex items-center max-w-md bg-white/[0.01] border border-white/[0.05] rounded-xl px-4 py-2.5 focus-within:border-accent-purple transition-colors duration-300">
        <Search className="w-5 h-5 text-text-muted mr-3" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search by name, phone, email, or role..."
          className="w-full bg-transparent focus:outline-none text-sm text-text-primary placeholder-text-muted"
        />
      </div>

      <div className="space-y-4">
        <h2 className="text-xl font-bold text-text-primary uppercase tracking-wider text-xs text-text-muted">
          Users Registry
        </h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable columns={columns} data={filteredUsers} emptyMessage="No users found matching query." />
        )}
      </div>
    </div>
  );
}

