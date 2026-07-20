'use client';

import React, { useEffect, useState } from 'react';
import { ShieldCheck, User, Loader2 } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { StatusBadge } from '@/components/StatusBadge';
import { collection, query, where, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

interface CreatorRow {
  id: string;
  name: string;
  level: string;
  balance: string;
  totalSales: number;
  status: string;
}

export default function AdminCreators() {
  const [creators, setCreators] = useState<CreatorRow[]>([]);
  const [loading, setLoading] = useState(true);

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
          name: data.name || data.email?.split('@')[0] || 'Unknown User',
          level: `Level ${data.level || 1} — Seedling`,
          balance: `₹${data.balance || 0}`,
          totalSales: data.totalSales || 0,
          status: data.creatorStatus || 'approved',
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
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded-full bg-[#1A1A24] flex items-center justify-center border border-[#22222e]">
            <User className="w-4 h-4 text-text-muted" />
          </div>
          <span className="font-semibold text-white">{row.name}</span>
        </div>
      ),
    },
    {
      header: 'Tier Level',
      accessor: (row: CreatorRow) => (
        <span className="text-[#00D4FF] font-medium">{row.level}</span>
      ),
    },
    {
      header: 'Balance',
      accessor: (row: CreatorRow) => (
        <span className="font-mono text-[#8B8B9E]">{row.balance}</span>
      ),
    },
    {
      header: 'Total Sales',
      accessor: (row: CreatorRow) => (
        <span className="font-mono text-[#8B8B9E]">{row.totalSales}</span>
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
            className="px-3 py-1.5 bg-[#B829DD] text-white text-xs font-semibold rounded-lg hover:opacity-90 transition-opacity flex items-center space-x-1"
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Approve</span>
          </button>
        ) : (
          <span className="text-xs text-text-muted">Reviewed</span>
        )
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-[#00D4FF]" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-white">Creator Accounts</h1>
        <p className="mt-1 text-sm text-[#8B8B9E]">Approve creator enrollments, manage levels, and monitor earnings in real-time.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-white">Creators Portfolio</h2>
        <DataTable columns={columns} data={creators} />
      </div>
    </div>
  );
}
