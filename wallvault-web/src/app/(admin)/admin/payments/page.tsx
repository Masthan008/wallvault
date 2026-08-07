'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { CreditCard, Wallet, CheckCircle2, Hourglass, TrendingUp, IndianRupee } from 'lucide-react';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { PageHeader } from '@/components/motion/PageHeader';
import { KPICard } from '@/components/KPICard';
import { AnimatedNumber } from '@/components/motion/AnimatedNumber';
import { motion } from 'framer-motion';

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

const statusColor: Record<string, string> = {
  completed: '#22c55e',
  approved: '#06b6d4',
  processing: '#eab308',
  pending: '#eab308',
  failed: '#ef4444',
  rejected: '#ef4444',
  suspended: '#f97316',
};

export default function AdminPayments() {
  const [transactions, setTransactions] = useState<TransactionItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
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

  const stats = useMemo(() => {
    const total = transactions.reduce((sum, t) => sum + (t.amount || 0), 0);
    const completed = transactions.filter((t) => t.status === 'completed' || t.status === 'approved').reduce((sum, t) => sum + (t.amount || 0), 0);
    const pending = transactions.filter((t) => t.status === 'pending' || t.status === 'processing').reduce((sum, t) => sum + (t.amount || 0), 0);
    const failed = transactions.filter((t) => t.status === 'failed' || t.status === 'rejected').length;
    return { total, completed, pending, failed, count: transactions.length };
  }, [transactions]);

  const columns = [
    {
      header: 'Transaction ID',
      accessor: (row: TransactionItem) => (
        <div className="flex flex-col">
          <span className="font-mono text-text-secondary text-xs">{row.id.slice(0, 18)}</span>
          <span className="text-[9px] font-mono text-text-muted mt-0.5 uppercase tracking-wider">TXN</span>
        </div>
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
        <span className="text-text-secondary text-xs uppercase tracking-wider font-bold flex items-center space-x-1.5">
          <Wallet className="w-3.5 h-3.5 text-text-muted" />
          <span>{row.type}</span>
        </span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: TransactionItem) => (
        <span className="font-extrabold text-white font-mono text-sm flex items-center space-x-1">
          <IndianRupee className="w-3.5 h-3.5" />
          <span>{row.amount}</span>
        </span>
      ),
    },
    {
      header: 'Razorpay Reference',
      accessor: (row: TransactionItem) => (
        <div className="flex items-center space-x-1.5 font-mono text-xs text-text-secondary">
          <CreditCard className="w-3.5 h-3.5 text-text-muted" />
          <span>{row.gatewayId.length > 20 ? row.gatewayId.slice(0, 20) + '…' : row.gatewayId}</span>
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
      <PageHeader
        title="Payment Transactions"
        subtitle="Track platform orders, subscription upgrades, tips, and gateway callbacks in real-time."
        badge="Payments Ledger"
        badgeColor="#06b6d4"
      />

      {/* Revenue summary strip */}
      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15, duration: 0.4 }}
        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
      >
        <KPICard
          label="Total Volume"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.total} format={(n) => n.toLocaleString()} /></>}
          icon={<TrendingUp className="w-4 h-4" />}
          accentColor="#06b6d4"
          delay={0.2}
        />
        <KPICard
          label="Settled Volume"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.completed} format={(n) => n.toLocaleString()} /></>}
          icon={<CheckCircle2 className="w-4 h-4" />}
          accentColor="#22c55e"
          delay={0.28}
        />
        <KPICard
          label="In-Flight Volume"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.pending} format={(n) => n.toLocaleString()} /></>}
          icon={<Hourglass className="w-4 h-4" />}
          accentColor="#eab308"
          delay={0.36}
        />
        <KPICard
          label="Failed / Rejected"
          value={<AnimatedNumber value={stats.failed} format={(n) => n.toLocaleString()} />}
          icon={<span className="w-1.5 h-1.5 rounded-full" style={{ background: statusColor.failed }} />}
          accentColor="#ef4444"
          delay={0.44}
        />
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.25, duration: 0.4 }}
        className="space-y-4"
      >
        <h2 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#52525b]">Transactions Ledger — {stats.count} records</h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable columns={columns} data={transactions} emptyMessage="No transactions registered yet." />
        )}
      </motion.div>
    </div>
  );
}
