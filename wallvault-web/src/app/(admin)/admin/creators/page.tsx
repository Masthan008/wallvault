'use client';

import React, { useEffect, useState } from 'react';
import { ShieldCheck, User, X, Mail, Phone, Landmark, Calendar, Award, BadgeCheck } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { collection, query, where, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { AnimatedModal } from '@/components/motion/AnimatedModal';

interface CreatorRow {
  id: string;
  name: string;
  email?: string;
  phone?: string;
  level: string;
  balance: string;
  totalSales: number;
  status: string;
  upi?: string;
  payeeName?: string;
  bankName?: string;
  accountNo?: string;
  ifsc?: string;
  createdAt?: string;
  avatarUrl?: string;
}

export default function AdminCreators() {
  const [creators, setCreators] = useState<CreatorRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCreator, setSelectedCreator] = useState<CreatorRow | null>(null);

  useEffect(() => {
    // Query users who are creators or have requested enrollment
    const q = query(
      collection(db, 'users'),
      where('isCreator', '==', true)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: CreatorRow[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        items.push({
          id: doc.id,
          name: data.displayName || data.name || data.email?.split('@')[0] || 'Unknown User',
          email: data.email || '',
          phone: data.phoneNumber || data.phone || 'N/A',
          level: `Level ${data.level || 1} — Seedling`,
          balance: `₹${data.balance || 0}`,
          totalSales: data.totalSales || 0,
          status: data.creatorStatus || 'approved',
          upi: data.upi || '',
          payeeName: data.payeeName || '',
          bankName: data.bankName || '',
          accountNo: data.accountNo || '',
          ifsc: data.ifsc || '',
          createdAt: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          avatarUrl: data.avatarUrl || data.photoURL || '',
        });
      });
      setCreators(items);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleApprove = async (id: string) => {
    try {
      await updateDoc(doc(db, 'users', id), {
        creatorStatus: 'approved',
        isCreator: true,
        updatedAt: new Date(),
      });
    } catch (e) {
      console.error("Creator approve failed: ", e);
    }
  };

  const columns = [
    {
      header: 'Creator Name',
      accessor: (row: CreatorRow) => (
        <div
          onClick={() => setSelectedCreator(row)}
          className="flex items-center space-x-3 cursor-pointer group"
        >
          <div className="w-8 h-8 rounded-full bg-white/[0.04] flex items-center justify-center border border-white/[0.05] overflow-hidden transition-all duration-300 group-hover:border-accent-purple/40">
            {row.avatarUrl ? (
              <img src={row.avatarUrl} alt={row.name} className="w-full h-full object-cover" />
            ) : (
              <User className="w-4 h-4 text-text-muted" />
            )}
          </div>
          <div>
            <span className="font-bold text-white text-sm hover:underline group-hover:text-accent-purple transition-colors">{row.name}</span>
            {row.email && <p className="text-[10px] text-text-muted mt-0.5">{row.email}</p>}
          </div>
        </div>
      ),
    },
    {
      header: 'Tier Level',
      accessor: (row: CreatorRow) => (
        <span className="text-accent-cyan font-bold text-xs uppercase tracking-wider">{row.level}</span>
      ),
    },
    {
      header: 'Balance',
      accessor: (row: CreatorRow) => (
        <span className="font-mono text-text-secondary text-xs">{row.balance}</span>
      ),
    },
    {
      header: 'Total Sales',
      accessor: (row: CreatorRow) => (
        <span className="font-mono text-text-secondary text-xs">{row.totalSales}</span>
      ),
    },
    {
      header: 'Status',
      accessor: (row: CreatorRow) => (
        <StatusBadge status={row.status as any} />
      ),
    },
    {
      header: 'Review Application',
      accessor: (row: CreatorRow) => (
        row.status === 'pending' ? (
          <motion.button
            whileHover={{ y: -1, scale: 1.04 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => handleApprove(row.id)}
            className="px-3 py-1.5 bg-accent-purple text-white text-xs font-bold rounded-lg hover:opacity-90 transition-opacity flex items-center space-x-1 cursor-pointer btn-shine"
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Approve</span>
          </motion.button>
        ) : (
          <span
            onClick={() => setSelectedCreator(row)}
            className="text-xs text-text-secondary hover:text-white font-bold uppercase tracking-wider cursor-pointer group-hover:text-accent-purple transition-colors"
          >
            View profile &rarr;
          </span>
        )
      ),
    },
  ];

  if (loading) {
    return (
      <div className="space-y-6">
        <SkeletonLoader variant="table" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <PageHeader
        title="Creator Accounts"
        subtitle="Approve enrollments, manage levels, and monitor earnings in real-time."
        badge="Creator Network"
        badgeColor="#a855f7"
      />

      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15, duration: 0.4 }}
        className="space-y-4"
      >
        <h2 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#52525b]">Creators Portfolio</h2>
        <DataTable columns={columns} data={creators} emptyMessage="No registered creators found." />
      </motion.div>

      {/* Creator Detail Profile Modal */}
      <AnimatedModal open={!!selectedCreator} onClose={() => setSelectedCreator(null)} maxWidthClass="max-w-lg">
        {selectedCreator && (
          <div className="bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col p-6 space-y-6">
            <div className="flex items-start justify-between pb-3 border-b border-white/[0.04]">
              <div className="flex items-center space-x-3">
                <motion.div
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ type: 'spring', stiffness: 300, damping: 18 }}
                  className="w-10 h-10 rounded-full bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-white overflow-hidden"
                >
                  {selectedCreator.avatarUrl ? (
                    <img src={selectedCreator.avatarUrl} alt={selectedCreator.name} className="w-full h-full object-cover" />
                  ) : (
                    <User className="w-5 h-5" />
                  )}
                </motion.div>
                <div>
                  <h3 className="text-base font-bold text-white flex items-center gap-1.5">
                    {selectedCreator.name}
                    <BadgeCheck className="w-4 h-4 text-accent-cyan" />
                  </h3>
                  <p className="text-[10px] text-text-muted uppercase font-bold tracking-wider font-mono">ID: {selectedCreator.id.slice(0, 12)}</p>
                </div>
              </div>
              <motion.button
                whileHover={{ rotate: 90 }}
                whileTap={{ scale: 0.85 }}
                onClick={() => setSelectedCreator(null)}
                className="p-1 text-text-muted hover:text-white rounded transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </motion.button>
            </div>

            {/* Creator details */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="space-y-3">
                <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Contact Details</h4>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.15 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Mail className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Email</p>
                    <p className="font-semibold text-white">{selectedCreator.email || 'N/A'}</p>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.2 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Phone className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Phone</p>
                    <p className="font-semibold text-white">{selectedCreator.phone || 'N/A'}</p>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.25 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Calendar className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Joined</p>
                    <p className="font-semibold text-white">{selectedCreator.createdAt}</p>
                  </div>
                </motion.div>
              </div>

              <div className="space-y-3">
                <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Portfolio Metrics</h4>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Award className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Tier Status</p>
                    <p className="font-semibold text-accent-cyan">{selectedCreator.level}</p>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.35 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Landmark className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Available Balance</p>
                    <p className="font-semibold text-white font-mono">{selectedCreator.balance}</p>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.4 }}
                  className="flex items-center gap-2 text-text-secondary"
                >
                  <Landmark className="w-4 h-4 text-text-muted" />
                  <div>
                    <p className="text-[8px] uppercase text-text-muted">Total Sales</p>
                    <p className="font-semibold text-white font-mono">{selectedCreator.totalSales} items</p>
                  </div>
                </motion.div>
              </div>
            </div>

            {/* Billing Info */}
            <div className="pt-4 border-t border-white/[0.04] space-y-3">
              <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Billing & Payment Configuration</h4>

              {selectedCreator.upi || selectedCreator.accountNo ? (
                <motion.div
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.45 }}
                  className="bg-white/[0.01] border border-white/[0.04] rounded-xl p-4 space-y-2 text-xs"
                >
                  <p><span className="text-text-muted uppercase font-bold text-[9px] mr-2">Legal Payee:</span> <span className="font-semibold text-white">{selectedCreator.payeeName || selectedCreator.name}</span></p>
                  {selectedCreator.upi && (
                    <p><span className="text-text-muted uppercase font-bold text-[9px] mr-2">UPI ID:</span> <span className="font-mono text-accent-cyan font-bold">{selectedCreator.upi}</span></p>
                  )}
                  {selectedCreator.accountNo && (
                    <div className="pt-1.5 border-t border-white/[0.02] space-y-1">
                      <p><span className="text-text-muted uppercase font-bold text-[9px] mr-2">Bank:</span> <span className="font-semibold text-white">{selectedCreator.bankName || 'N/A'}</span></p>
                      <p><span className="text-text-muted uppercase font-bold text-[9px] mr-2">A/C No:</span> <span className="font-semibold text-white font-mono">{selectedCreator.accountNo}</span></p>
                      <p><span className="text-text-muted uppercase font-bold text-[9px] mr-2">IFSC:</span> <span className="font-semibold text-white font-mono">{selectedCreator.ifsc}</span></p>
                    </div>
                  )}
                </motion.div>
              ) : (
                <p className="text-xs text-text-muted italic">No payment configurations saved by the creator yet.</p>
              )}
            </div>

            <div className="pt-2 flex justify-end">
              <motion.button
                whileHover={{ y: -1 }}
                whileTap={{ scale: 0.96 }}
                onClick={() => setSelectedCreator(null)}
                className="btn-shine px-4 py-2 bg-white text-black font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors cursor-pointer"
              >
                Close Profile
              </motion.button>
            </div>
          </div>
        )}
      </AnimatedModal>
    </div>
  );
}
