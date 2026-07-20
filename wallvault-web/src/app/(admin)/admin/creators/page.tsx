'use client';

import React, { useEffect, useState } from 'react';
import { ShieldCheck, User, X, Mail, Phone, Landmark, Calendar, Award } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { collection, query, where, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion, AnimatePresence } from 'framer-motion';

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
          className="flex items-center space-x-3 cursor-pointer"
        >
          <div className="w-8 h-8 rounded-full bg-white/[0.04] flex items-center justify-center border border-white/[0.05] overflow-hidden">
            {row.avatarUrl ? (
              <img src={row.avatarUrl} alt={row.name} className="w-full h-full object-cover" />
            ) : (
              <User className="w-4 h-4 text-text-muted" />
            )}
          </div>
          <div>
            <span className="font-bold text-white text-sm hover:underline">{row.name}</span>
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
          <button 
            onClick={() => handleApprove(row.id)}
            className="px-3 py-1.5 bg-accent-purple text-white text-xs font-bold rounded-lg hover:opacity-90 transition-opacity flex items-center space-x-1 cursor-pointer"
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Approve</span>
          </button>
        ) : (
          <span 
            onClick={() => setSelectedCreator(row)}
            className="text-xs text-text-secondary hover:text-white font-bold uppercase tracking-wider cursor-pointer"
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
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-white">
          Creator Accounts
        </h1>
        <p className="mt-1 text-xs text-text-secondary">Approve creator enrollments, manage levels, and monitor earnings in real-time.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-xs font-bold uppercase tracking-wider text-text-muted">Creators Portfolio</h2>
        <DataTable columns={columns} data={creators} emptyMessage="No registered creators found." />
      </div>

      {/* Creator Detail Profile Modal */}
      <AnimatePresence>
        {selectedCreator && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.2 }}
              className="w-full max-w-lg bg-bg-card border border-border-glass rounded-2xl overflow-hidden shadow-2xl flex flex-col p-6 space-y-6"
            >
              <div className="flex items-start justify-between pb-3 border-b border-white/[0.04]">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 rounded-full bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-white">
                    <User className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-white">{selectedCreator.name}</h3>
                    <p className="text-[10px] text-text-muted uppercase font-bold tracking-wider">ID: {selectedCreator.id}</p>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedCreator(null)}
                  className="p-1 text-text-muted hover:text-white rounded transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Creator details */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                <div className="space-y-3">
                  <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Contact Details</h4>
                  
                  <div className="flex items-center gap-2 text-text-secondary">
                    <Mail className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Email</p>
                      <p className="font-semibold text-white">{selectedCreator.email || 'N/A'}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-text-secondary">
                    <Phone className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Phone</p>
                      <p className="font-semibold text-white">{selectedCreator.phone || 'N/A'}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-text-secondary">
                    <Calendar className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Joined</p>
                      <p className="font-semibold text-white">{selectedCreator.createdAt}</p>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Portfolio Metrics</h4>

                  <div className="flex items-center gap-2 text-text-secondary">
                    <Award className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Tier Status</p>
                      <p className="font-semibold text-accent-cyan">{selectedCreator.level}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-text-secondary">
                    <Landmark className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Available Balance</p>
                      <p className="font-semibold text-white font-mono">{selectedCreator.balance}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-text-secondary">
                    <Landmark className="w-4 h-4 text-text-muted" />
                    <div>
                      <p className="text-[8px] uppercase text-text-muted">Total Sales</p>
                      <p className="font-semibold text-white font-mono">{selectedCreator.totalSales} items</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Billing Info */}
              <div className="pt-4 border-t border-white/[0.04] space-y-3">
                <h4 className="text-[10px] uppercase font-bold text-text-muted tracking-wider">Billing & Payment Configuration</h4>
                
                {selectedCreator.upi || selectedCreator.accountNo ? (
                  <div className="bg-white/[0.01] border border-white/[0.04] rounded-xl p-4 space-y-2 text-xs">
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
                  </div>
                ) : (
                  <p className="text-xs text-text-muted italic">No payment configurations saved by the creator yet.</p>
                )}
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => setSelectedCreator(null)}
                  className="px-4 py-2 bg-white text-black font-bold uppercase tracking-wider text-[10px] rounded-lg transition-colors cursor-pointer"
                >
                  Close Profile
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}


