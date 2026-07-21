'use client';

import React, { useState, useEffect } from 'react';
import { User, Search } from 'lucide-react';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion } from 'framer-motion';

interface UserItem {
  id: string;
  name: string;
  phone: string;
  email: string;
  plan: string;
  streak: number;
  avatarUrl?: string;
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
          name: data.displayName || data.name || 'Unknown User',
          phone: data.phone || data.phoneNumber || 'N/A',
          email: data.email || 'N/A',
          plan: planTier,
          streak: data.streak || 0,
          avatarUrl: data.avatarUrl || data.photoURL || '',
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
          <div className="w-8 h-8 rounded-full bg-white/[0.04] flex items-center justify-center border border-white/[0.05] overflow-hidden">
            {row.avatarUrl ? (
              <img src={row.avatarUrl} alt={row.name} className="w-full h-full object-cover" />
            ) : (
              <User className="w-4 h-4 text-text-muted" />
            )}
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
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <h1 className="text-3xl font-black tracking-tight text-white">
          User Directory
        </h1>
        <p className="mt-1 text-xs text-[#52525b] font-medium">
          User accounts, streaks, subscriptions, and roles — live from Firebase.
        </p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1, duration: 0.35 }}
        className="flex items-center max-w-md bg-white/[0.015] border border-white/[0.06] rounded-xl px-4 py-2.5 focus-within:border-[#a855f7]/40 transition-all duration-300"
      >
        <Search className="w-4 h-4 text-[#52525b] mr-3" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search by name, phone, email, or role..."
          className="w-full bg-transparent focus:outline-none text-xs text-white placeholder-[#3f3f46] font-medium"
        />
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.4 }}
        className="space-y-4"
      >
        <h2 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#52525b]">
          Users Registry ({filteredUsers.length})
        </h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable columns={columns} data={filteredUsers} emptyMessage="No users found matching query." />
        )}
      </motion.div>
    </div>
  );
}

