'use client';

import React, { useState, useEffect } from 'react';
import { Landmark, Check, X, AlertCircle } from 'lucide-react';
import { collection, onSnapshot, query, doc, updateDoc, getDoc, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';

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

  const handleAction = async (id: string, action: 'completed' | 'rejected', creatorId: string, amount: number) => {
    setActionLoading(id);
    setMessage(null);
    try {
      // 1. Update payout status in payouts collection
      await updateDoc(doc(db, 'payouts', id), {
        status: action,
        updatedAt: new Date(),
      });

      // 2. If rejected, refund the amount back to the creator's balance
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
        text: `Payout request ${action === 'completed' ? 'processed' : 'rejected'} successfully!`,
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
        <span className="font-mono text-text-secondary text-xs">{row.id}</span>
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
        <span className="font-black text-white font-mono">₹{row.amount}</span>
      ),
    },
    {
      header: 'Billing details / Payment credentials',
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
              <button
                disabled={actionLoading !== null}
                onClick={() => handleAction(row.id, 'completed', row.creatorId, row.amount)}
                className="px-3 py-1.5 bg-white text-black text-xs font-bold rounded-lg hover:opacity-90 active:scale-95 transition-all flex items-center space-x-1 cursor-pointer disabled:opacity-50"
              >
                <Check className="w-3.5 h-3.5 stroke-[3px]" />
                <span>Process</span>
              </button>
              <button
                disabled={actionLoading !== null}
                onClick={() => handleAction(row.id, 'rejected', row.creatorId, row.amount)}
                className="px-3 py-1.5 bg-accent-error/10 text-accent-error border border-accent-error/20 text-xs font-bold rounded-lg hover:bg-accent-error/20 active:scale-95 transition-all flex items-center space-x-1 cursor-pointer disabled:opacity-50"
              >
                <X className="w-3.5 h-3.5 stroke-[3px]" />
                <span>Reject</span>
              </button>
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
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-white">
          Payout Processing
        </h1>
        <p className="mt-1 text-xs text-text-secondary">
          Approve and verify creator payout requests, with automatic creator balance refund on rejection.
        </p>
      </div>

      <AnimatePresence>
        {message && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
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

      <div className="space-y-4">
        <h2 className="text-xs font-bold text-text-muted uppercase tracking-wider">
          All Payout Requests
        </h2>
        {loading ? (
          <SkeletonLoader variant="table" />
        ) : (
          <DataTable 
            columns={columns} 
            data={payouts} 
            emptyMessage="No payout requests found in database." 
          />
        )}
      </div>
    </div>
  );
}


