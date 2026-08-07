'use client';

import React, { useEffect, useState } from 'react';
import { Landmark, CreditCard, Save, Wallet, ArrowUpRight } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { useAuth } from '@/components/AuthProvider';
import { collection, query, where, onSnapshot, doc, updateDoc, addDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { AnimatedNumber } from '@/components/motion/AnimatedNumber';

interface PayoutRow {
  id: string;
  amount: string;
  method: string;
  date: string;
  status: string;
}

export default function CreatorPayouts() {
  const { user } = useAuth();
  const [payouts, setPayouts] = useState<PayoutRow[]>([]);
  const [balance, setBalance] = useState(0);

  // Payout Method Fields stored in user doc
  const [upi, setUpi] = useState('');
  const [payeeName, setPayeeName] = useState('');
  const [bankName, setBankName] = useState('');
  const [accountNo, setAccountNo] = useState('');
  const [ifsc, setIfsc] = useState('');

  const [loading, setLoading] = useState(true);
  const [requesting, setRequesting] = useState(false);
  const [savingDetails, setSavingDetails] = useState(false);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState<'success' | 'error'>('success');

  useEffect(() => {
    if (!user) return;

    // 1. Fetch available balance and bank details from user doc
    const unsubUser = onSnapshot(doc(db, 'users', user.uid), (docSnap) => {
      if (docSnap.exists()) {
        const data = docSnap.data();
        setBalance(data.balance || 0);

        // Payout configuration fields
        setUpi(data.upi || '');
        setPayeeName(data.payeeName || data.name || '');
        setBankName(data.bankName || '');
        setAccountNo(data.accountNo || '');
        setIfsc(data.ifsc || '');
      }
    });

    // 2. Fetch payouts list
    const q = query(
      collection(db, 'payouts'),
      where('creatorId', '==', user.uid)
    );

    const unsubPayouts = onSnapshot(q, (snapshot) => {
      const items: PayoutRow[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        items.push({
          id: doc.id,
          amount: `₹${data.amount || 0}`,
          method: data.method || 'UPI',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          status: data.status || 'pending',
        });
      });
      setPayouts(items);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => {
      unsubUser();
      unsubPayouts();
    };
  }, [user]);

  const handleSaveDetails = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    setSavingDetails(true);
    setMessage('');
    try {
      await updateDoc(doc(db, 'users', user.uid), {
        upi: upi.trim(),
        payeeName: payeeName.trim(),
        bankName: bankName.trim(),
        accountNo: accountNo.trim(),
        ifsc: ifsc.trim().toUpperCase(),
        updatedAt: new Date()
      });
      setMessage('Payout configuration saved successfully!');
      setMessageType('success');
    } catch (err: any) {
      setMessage(err.message || 'Failed to save payout profile.');
      setMessageType('error');
    } finally {
      setSavingDetails(false);
    }
  };

  const handleRequestPayout = async () => {
    if (!user || balance < 500) {
      setMessage('Minimum payout balance is ₹500.');
      setMessageType('error');
      return;
    }

    if (!upi && !accountNo) {
      setMessage('Please save your payout details configuration first.');
      setMessageType('error');
      return;
    }

    setRequesting(true);
    setMessage('');

    try {
      const payoutAmount = balance;

      // 1. Create a payout request doc with comprehensive details
      await addDoc(collection(db, 'payouts'), {
        amount: payoutAmount,
        creatorId: user.uid,
        creatorName: payeeName || user.displayName || user.email?.split('@')[0] || 'Unknown',
        method: upi ? 'UPI' : 'Bank Transfer',
        upiId: upi.trim(),
        payeeName: payeeName.trim(),
        bankName: bankName.trim(),
        accountNo: accountNo.trim(),
        ifscCode: ifsc.trim().toUpperCase(),
        status: 'pending',
        createdAt: new Date(),
      });

      // 2. Deduct user's balance
      await updateDoc(doc(db, 'users', user.uid), {
        balance: 0,
        updatedAt: new Date(),
      });

      setMessage('Payout request submitted successfully!');
      setMessageType('success');
    } catch (e: any) {
      setMessage(e.message || 'Failed to submit payout.');
      setMessageType('error');
    } finally {
      setRequesting(false);
    }
  };

  const columns = [
    {
      header: 'Payout ID',
      accessor: (row: PayoutRow) => (
        <span className="font-mono text-text-secondary text-xs">{row.id.slice(0, 14)}</span>
      ),
    },
    {
      header: 'Amount',
      accessor: (row: PayoutRow) => (
        <span className="font-extrabold text-white font-mono">{row.amount}</span>
      ),
    },
    {
      header: 'Method',
      accessor: (row: PayoutRow) => (
        <span className="text-text-secondary text-xs font-mono">{row.method}</span>
      ),
    },
    {
      header: 'Requested Date',
      accessor: (row: PayoutRow) => (
        <span className="text-text-secondary text-xs font-mono">{row.date}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: PayoutRow) => (
        <StatusBadge status={row.status as any} />
      ),
    },
  ];

  if (loading) {
    return (
      <div className="space-y-6">
        <SkeletonLoader variant="card" count={3} />
        <SkeletonLoader variant="table" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <PageHeader
        title="Payouts & Earnings"
        subtitle="Withdraw your portfolio earnings and configure payout accounts."
        badge="Wallet"
        badgeColor="#f59e0b"
      />

      <AnimatePresence>
        {message && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className={`p-3.5 rounded-xl text-xs font-semibold border ${
              messageType === 'success'
                ? 'bg-accent-success/5 border-accent-success/15 text-accent-success'
                : 'bg-accent-error/5 border-accent-error/15 text-accent-error'
            }`}
          >
            {message}
          </motion.div>
        )}
      </AnimatePresence>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {/* Balance Card */}
        <motion.div
          initial={{ opacity: 0, y: 18 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="p-6 glass-panel rounded-2xl md:col-span-2 relative overflow-hidden"
        >
          <div className="absolute top-0 right-0 w-56 h-56 rounded-full bg-accent-gold/10 blur-3xl pointer-events-none animate-float-slow" />
          <div className="flex items-center justify-between relative">
            <div className="space-y-1.5">
              <span className="text-[10px] uppercase tracking-wider font-bold text-text-muted flex items-center gap-1.5">
                <Wallet className="w-3.5 h-3.5" />
                Available Balance
              </span>
              <h3 className="text-4xl font-black text-white font-mono">
                ₹<AnimatedNumber value={balance} format={(v) => v >= 100000 ? `${(v / 100000).toFixed(1)}L` : Math.round(v).toLocaleString()} />
              </h3>
              <p className="text-[9px] font-bold text-text-muted">Minimum withdrawal threshold: ₹500</p>
            </div>
            <motion.button
              whileHover={{ y: -2, scale: 1.02 }}
              whileTap={{ scale: 0.95 }}
              onClick={handleRequestPayout}
              disabled={requesting || balance < 500}
              className={`btn-shine px-5 py-3 font-bold uppercase tracking-wider text-[10px] rounded-xl transition-all duration-200 flex items-center gap-2 ${
                balance >= 500
                  ? 'bg-gradient-to-r from-accent-gold to-orange-500 text-black hover:opacity-90 cursor-pointer shadow-lg'
                  : 'bg-white/[0.02] text-text-muted cursor-not-allowed border border-white/[0.04]'
              }`}
            >
              {requesting ? 'Submitting...' : 'Request Payout'}
              {!requesting && <ArrowUpRight className="w-3.5 h-3.5" />}
            </motion.button>
          </div>
        </motion.div>

        {/* Billing Option Card */}
        <motion.div
          initial={{ opacity: 0, y: 18 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1, duration: 0.5 }}
          className="p-6 glass-panel rounded-2xl flex flex-col justify-between relative overflow-hidden"
        >
          <div className="flex items-center justify-between">
            <span className="text-[10px] uppercase tracking-wider font-bold text-text-muted">Active Option</span>
            <motion.div
              animate={{ y: [0, -3, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
            >
              <Landmark className="w-4 h-4 text-accent-gold" />
            </motion.div>
          </div>
          <div className="mt-4">
            <h4 className="text-xs font-bold text-white">Billing Settings</h4>
            <p className="text-[10px] text-text-secondary mt-1 font-mono">
              {upi ? `UPI: ${upi}` : accountNo ? `Bank: *${accountNo.slice(-4)}` : 'None Configured'}
            </p>
          </div>
        </motion.div>
      </div>

      {/* Payout Billing Details configuration form */}
      <motion.form
        initial={{ opacity: 0, y: 18 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        onSubmit={handleSaveDetails}
        className="p-6 glass-panel rounded-2xl space-y-4"
      >
        <div className="flex items-center gap-2 pb-2 border-b border-white/[0.04]">
          <CreditCard className="w-4 h-4 text-text-muted" />
          <h3 className="text-xs font-bold uppercase tracking-wider text-white">Billing & Payment Configuration</h3>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div className="space-y-1">
            <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Legal Payee Name</label>
            <input
              type="text"
              value={payeeName}
              onChange={(e) => setPayeeName(e.target.value)}
              placeholder="e.g. Masthan Adhiya"
              required
              className="w-full px-3 py-2.5 glass-input text-xs"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">UPI ID (Preferred)</label>
            <input
              type="text"
              value={upi}
              onChange={(e) => setUpi(e.target.value)}
              placeholder="e.g. masthan@okaxis"
              className="w-full px-3 py-2.5 glass-input text-xs"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Bank Name</label>
            <input
              type="text"
              value={bankName}
              onChange={(e) => setBankName(e.target.value)}
              placeholder="e.g. State Bank of India"
              className="w-full px-3 py-2.5 glass-input text-xs"
            />
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Account Number</label>
              <input
                type="text"
                value={accountNo}
                onChange={(e) => setAccountNo(e.target.value)}
                placeholder="Bank account number"
                className="w-full px-3 py-2.5 glass-input text-xs"
              />
            </div>
            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">IFSC Code</label>
              <input
                type="text"
                value={ifsc}
                onChange={(e) => setIfsc(e.target.value)}
                placeholder="SBIN0012345"
                className="w-full px-3 py-2.5 glass-input text-xs"
              />
            </div>
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <motion.button
            whileHover={{ y: -1 }}
            whileTap={{ scale: 0.96 }}
            type="submit"
            disabled={savingDetails}
            className="btn-shine px-4 py-2 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-[9px] rounded-lg transition-all duration-200 cursor-pointer disabled:opacity-50 flex items-center gap-1.5"
          >
            <Save className="w-3.5 h-3.5" />
            {savingDetails ? 'Saving...' : 'Save billing configuration'}
          </motion.button>
        </div>
      </motion.form>

      <div className="space-y-4">
        <h2 className="text-xs font-bold uppercase tracking-wider text-text-muted">Payout Transaction History</h2>
        {payouts.length === 0 ? (
          <div className="p-12 text-center text-text-muted border border-white/[0.05] rounded-2xl bg-white/[0.01]">
            <div className="w-12 h-12 rounded-full bg-white/[0.02] border border-white/[0.06] flex items-center justify-center mx-auto mb-3 animate-float">
              <Wallet className="w-5 h-5 text-text-muted" />
            </div>
            <p className="text-sm font-semibold">No payouts requested yet.</p>
            <p className="text-xs text-text-muted mt-1 font-normal">Initiate payout requests from your balance card above.</p>
          </div>
        ) : (
          <DataTable columns={columns} data={payouts} />
        )}
      </div>
    </div>
  );
}
