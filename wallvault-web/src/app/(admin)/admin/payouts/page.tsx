'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { Landmark, Check, X, AlertCircle, Banknote, Loader2, Hourglass, CircleDollarSign } from 'lucide-react';
import { collection, onSnapshot, query, doc, updateDoc, getDoc, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { KPICard } from '@/components/KPICard';
import { AnimatedNumber } from '@/components/motion/AnimatedNumber';

interface PayoutRequest {
  id: string;
  creatorId: string;
  creatorName: string;
  amount: number;
  method: string;
  upiId?: string;
  payeeName?: string;
  bankName?: string;
  accountNo?: string;
  ifscCode?: string;
  date: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended' | 'failed' | 'completed' | 'processing';
  rawDate: any;
}

export default function AdminPayouts() {
  const [payouts, setPayouts] = useState<PayoutRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  useEffect(() => {
    const q = query(collection(db, 'payouts'), orderBy('createdAt', 'desc'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: PayoutRequest[] = [];
      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        items.push({
          id: docSnap.id,
          creatorId: data.creatorId || '',
          creatorName: data.creatorName || 'Unknown Creator',
          amount: data.amount || 0,
          method: data.method || 'UPI',
          upiId: data.upiId || '',
          payeeName: data.payeeName || '',
          bankName: data.bankName || '',
          accountNo: data.accountNo || '',
          ifscCode: data.ifscCode || '',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          status: data.status || 'pending',
          rawDate: data.createdAt,
        });
      });
      setPayouts(items);
      setLoading(false);
    }, (error) => {
      console.error('Error fetching payouts:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const stats = useMemo(() => {
    const pending = payouts.filter((p) => p.status === 'pending');
    const pendingAmount = pending.reduce((sum, p) => sum + p.amount, 0);
    const settled = payouts.filter((p) => p.status === 'completed').reduce((sum, p) => sum + p.amount, 0);
    const total = payouts.reduce((sum, p) => sum + p.amount, 0);
    return { pendingCount: pending.length, pendingAmount, settled, total };
  }, [payouts]);

  const handleAction = async (id: string, action: 'completed' | 'rejected', creatorId: string, amount: number) => {
    setActionLoading(id);
    setMessage(null);
    try {
      await updateDoc(doc(db, 'payouts', id), {
        status: action,
        updatedAt: new Date(),
      });

      if (action === 'rejected') {
        const userRef = doc(db, 'users', creatorId);
        const userSnap = await getDoc(userRef);
        if (userSnap.exists()) {
          const currentBalance = userSnap.data().balance || 0;
          await updateDoc(userRef, {
            balance: currentBalance + amount,
            updatedAt: new Date(),
          });
        }
      }

      setMessage({
        text: `Payout request ${action === 'completed' ? 'processed' : 'rejected'} successfully! ${action === 'rejected' ? `₹${amount} refunded to creator balance.` : ''}`,
        type: 'success',
      });
    } catch (err: any) {
      console.error('Error processing payout action:', err);
      setMessage({
        text: err.message || 'Failed to update payout request.',
        type: 'error',
      });
    } finally {
      setActionLoading(null);
    }
  };

  const columns = [
    {
      header: 'Request ID',
      accessor: (row: PayoutRequest) => (
        <div className="flex flex-col">
          <span className="font-mono text-text-secondary text-xs">{row.id.slice(0, 16)}</span>
          <span className="text-[9px] font-mono text-text-muted mt-0.5 uppercase tracking-wider">Payout</span>
        </div>
      ),
    },
    {
      header: 'Creator Name',
      accessor: (row: PayoutRequest) => (
        <div>
          <span className="font-bold text-white text-sm">{row.creatorName}</span>
          {row.payeeName && row.payeeName !== row.creatorName && (
            <p className="text-[10px] text-text-muted mt-0.5 font-medium">Payee: {row.payeeName}</p>
          )}
        </div>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: PayoutRequest) => (
        <motion.span
          key={row.id + row.status}
          initial={{ scale: 1.15, opacity: 0.4 }}
          animate={{ scale: 1, opacity: 1 }}
          className="font-black text-white font-mono flex items-center gap-1"
        >
          <span className="text-text-muted">₹</span>{row.amount}
        </motion.span>
      ),
    },
    {
      header: 'Billing Details',
      accessor: (row: PayoutRequest) => (
        <div className="space-y-1 py-1">
          <div className="flex items-center space-x-1.5 text-text-secondary">
            <Landmark className="w-3.5 h-3.5 text-text-muted" />
            <span className="text-xs uppercase font-extrabold tracking-wider">{row.method}</span>
          </div>
          {row.method === 'UPI' && row.upiId ? (
            <p className="text-[11px] font-mono text-accent-cyan font-bold">{row.upiId}</p>
          ) : (
            <div className="text-[10px] font-mono text-text-secondary leading-relaxed bg-white/[0.02] p-2 border border-white/[0.04] rounded-lg">
              <p><span className="text-text-muted">Bank:</span> {row.bankName || 'N/A'}</p>
              <p><span className="text-text-muted">A/C:</span> {row.accountNo || 'N/A'}</p>
              <p><span className="text-text-muted">IFSC:</span> {row.ifscCode || 'N/A'}</p>
            </div>
          )}
        </div>
      ),
    },
    {
      header: 'Requested',
      accessor: (row: PayoutRequest) => (
        <span className="text-text-secondary font-mono text-xs">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: PayoutRequest) => (
        <StatusBadge status={row.status} />
      ),
    },
    {
      header: 'Action',
      accessor: (row: PayoutRequest) => (
        <div className="flex space-x-2">
          {row.status === 'pending' ? (
            <>
              <motion.button
                whileHover={{ y: -1, scale: 1.04 }}
                whileTap={{ scale: 0.94 }}
                disabled={actionLoading !== null}
                onClick={() => handleAction(row.id, 'completed', row.creatorId, row.amount)}
                className="btn-shine px-3 py-1.5 bg-white text-black text-xs font-bold rounded-lg hover:opacity-90 transition-all flex items-center space-x-1 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {actionLoading === row.id ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  <Check className="w-3.5 h-3.5 stroke-[3px]" />
                )}
                <span>Process</span>
              </motion.button>
              <motion.button
                whileHover={{ y: -1, scale: 1.04 }}
                whileTap={{ scale: 0.94 }}
                disabled={actionLoading !== null}
                onClick={() => handleAction(row.id, 'rejected', row.creatorId, row.amount)}
                className="px-3 py-1.5 bg-accent-error/10 text-accent-error border border-accent-error/20 text-xs font-bold rounded-lg hover:bg-accent-error/20 transition-all flex items-center space-x-1 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <X className="w-3.5 h-3.5 stroke-[3px]" />
                <span>Reject</span>
              </motion.button>
            </>
          ) : (
            <span className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Settled</span>
          )}
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-8">
      <PageHeader
        title="Payout Processing"
        subtitle="Approve and verify creator payout requests, with automatic creator balance refund on rejection."
        badge="Creator Payments"
        badgeColor="#06b6d4"
      />

      <AnimatePresence>
        {message && (
          <motion.div
            initial={{ opacity: 0, y: -14, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -14, scale: 0.97 }}
            className={`p-4 rounded-xl flex items-center gap-3 border text-xs font-semibold ${
              message.type === 'success'
                ? 'bg-accent-success/5 border-accent-success/15 text-accent-success'
                : 'bg-accent-error/5 border-accent-error/15 text-accent-error'
            }`}
          >
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{message.text}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Payout summary strip */}
      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15, duration: 0.4 }}
        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
      >
        <KPICard
          label="Pending Requests"
          value={<AnimatedNumber value={stats.pendingCount} format={(n) => n.toLocaleString()} />}
          icon={<Hourglass className="w-4 h-4" />}
          accentColor="#eab308"
          delay={0.2}
        />
        <KPICard
          label="Pending Amount"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.pendingAmount} format={(n) => n.toLocaleString()} /></>}
          icon={<Banknote className="w-4 h-4" />}
          accentColor="#a855f7"
          delay={0.28}
        />
        <KPICard
          label="Settled Amount"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.settled} format={(n) => n.toLocaleString()} /></>}
          icon={<CircleDollarSign className="w-4 h-4" />}
          accentColor="#22c55e"
          delay={0.36}
        />
        <KPICard
          label="Total Volume"
          value={<><span className="text-text-muted text-lg mr-0.5">₹</span><AnimatedNumber value={stats.total} format={(n) => n.toLocaleString()} /></>}
          icon={<Banknote className="w-4 h-4" />}
          accentColor="#06b6d4"
          delay={0.44}
        />
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.25, duration: 0.4 }}
        className="space-y-4"
      >
        <h2 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#52525b]">All Payout Requests</h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable
            columns={columns}
            data={payouts}
            emptyMessage="No payout requests found in database."
          />
        )}
      </motion.div>
    </div>
  );
}
