'use client';

import React, { useState, useEffect } from 'react';
import { CreditCard } from 'lucide-react';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { SkeletonLoader } from '@/components/SkeletonLoader';

interface TransactionItem {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  type: string;
  amount: number;
  gatewayId: string;
  date: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended' | 'failed' | 'completed' | 'processing';
}

export default function AdminPayments() {
  const [transactions, setTransactions] = useState<TransactionItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // 1. Listen to users to create a mapping of userId to name/email
    const usersMap: Record<string, { name: string; email: string }> = {};
    const unsubUsers = onSnapshot(collection(db, 'users'), (usersSnap) => {
      usersSnap.forEach((docSnap) => {
        const data = docSnap.data();
        usersMap[docSnap.id] = {
          name: data.name || data.displayName || 'Unknown User',
          email: data.email || 'N/A',
        };
      });
    });

    // 2. Listen to transactions
    const q = query(collection(db, 'transactions'), orderBy('createdAt', 'desc'));
    const unsubTx = onSnapshot(q, (snapshot) => {
      const items: TransactionItem[] = [];
      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        const uId = data.userId || '';
        const userDetails = usersMap[uId] || { name: 'User (' + uId.substring(0, 5) + ')', email: 'N/A' };

        items.push({
          id: docSnap.id,
          userId: uId,
          userName: userDetails.name,
          userEmail: userDetails.email,
          type: data.type || 'Purchase',
          amount: data.amount || 0,
          gatewayId: data.razorpayPaymentId || data.razorpayOrderId || 'N/A',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          status: data.status || 'pending',
        });
      });
      setTransactions(items);
      setLoading(false);
    }, (error) => {
      console.error('Error fetching transactions:', error);
      setLoading(false);
    });

    return () => {
      unsubUsers();
      unsubTx();
    };
  }, []);

  const columns = [
    {
      header: 'Transaction ID / Order ID',
      accessor: (row: TransactionItem) => (
        <span className="font-mono text-text-secondary text-xs">{row.id}</span>
      ),
    },
    {
      header: 'User / Buyer',
      accessor: (row: TransactionItem) => (
        <div className="flex flex-col">
          <span className="font-bold text-text-primary text-sm">{row.userName}</span>
          <span className="text-text-muted text-[10px] font-mono">{row.userEmail}</span>
        </div>
      ),
    },
    {
      header: 'Transaction Type',
      accessor: (row: TransactionItem) => (
        <span className="text-text-secondary text-xs uppercase tracking-wider font-bold">{row.type}</span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: TransactionItem) => (
        <span className="font-extrabold text-text-primary font-mono text-sm">₹{row.amount}</span>
      ),
    },
    {
      header: 'Razorpay Reference ID',
      accessor: (row: TransactionItem) => (
        <div className="flex items-center space-x-1.5 font-mono text-xs text-text-secondary">
          <CreditCard className="w-3.5 h-3.5 text-text-muted" />
          <span>{row.gatewayId}</span>
        </div>
      ),
    },
    {
      header: 'Date',
      accessor: (row: TransactionItem) => (
        <span className="text-text-secondary font-mono text-xs">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: TransactionItem) => (
        <StatusBadge status={row.status} />
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-extrabold tracking-tight bg-gradient-to-r from-white to-text-secondary bg-clip-text text-transparent">
          Payment Transactions
        </h1>
        <p className="mt-1 text-sm text-text-secondary">
          Track platform orders, subscription upgrades, tips, and gateway callbacks in real-time.
        </p>
      </div>

      <div className="space-y-4">
        <h2 className="text-xl font-bold text-text-primary uppercase tracking-wider text-xs text-text-muted">
          Transactions Ledger
        </h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable columns={columns} data={transactions} emptyMessage="No transactions registered yet." />
        )}
      </div>
    </div>
  );
}

