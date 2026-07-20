'use client';

import React, { useEffect, useState } from 'react';
import { Check, X, Image as ImageIcon, Loader2 } from 'lucide-react';
import { DataTable } from '@/components/DataTable';
import { collection, query, where, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

interface PendingWallpaper {
  id: string;
  name: string;
  creator: string;
  category: string;
  date: string;
  imageUrl: string;
}

export default function AdminWallpapers() {
  const [wallpapers, setWallpapers] = useState<PendingWallpaper[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Query wallpapers with 'pending' status
    const q = query(
      collection(db, 'wallpapers'),
      where('status', '==', 'pending')
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: PendingWallpaper[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        items.push({
          id: doc.id,
          name: data.name || 'Untitled',
          creator: data.creatorName || 'Unknown',
          category: data.category || 'abstract',
          date: data.createdAt ? new Date(data.createdAt.seconds * 1000).toLocaleDateString() : 'N/A',
          imageUrl: data.imageUrl || '',
        });
      });
      setWallpapers(items);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleApprove = async (id: string) => {
    try {
      await updateDoc(doc(db, 'wallpapers', id), {
        status: 'approved',
        updatedAt: new Date(),
      });
    } catch (e) {
      console.error("Approve failed: ", e);
    }
  };

  const handleReject = async (id: string) => {
    try {
      await updateDoc(doc(db, 'wallpapers', id), {
        status: 'rejected',
        updatedAt: new Date(),
      });
    } catch (e) {
      console.error("Reject failed: ", e);
    }
  };

  const columns = [
    {
      header: 'Preview',
      accessor: (row: PendingWallpaper) => (
        <div className="w-16 h-20 rounded bg-[#1A1A24] overflow-hidden flex items-center justify-center border border-[#22222e]">
          {row.imageUrl ? (
            <img src={row.imageUrl} alt={row.name} className="w-full h-full object-cover" />
          ) : (
            <ImageIcon className="w-6 h-6 text-[#5A5A6E]" />
          )}
        </div>
      ),
    },
    {
      header: 'Wallpaper details',
      accessor: (row: PendingWallpaper) => (
        <div>
          <h4 className="font-semibold text-white">{row.name}</h4>
          <span className="text-xs text-[#8B8B9E] uppercase font-bold tracking-wider">Category: {row.category}</span>
        </div>
      ),
    },
    {
      header: 'Creator',
      accessor: (row: PendingWallpaper) => (
        <span className="text-[#00D4FF] font-medium">{row.creator}</span>
      ),
    },
    {
      header: 'Submitted Date',
      accessor: (row: PendingWallpaper) => (
        <span className="text-[#8B8B9E] font-mono">{row.date}</span>
      ),
    },
    {
      header: 'Actions',
      accessor: (row: PendingWallpaper) => (
        <div className="flex space-x-2">
          <button 
            onClick={() => handleApprove(row.id)}
            className="p-2 bg-[#00E676]/10 text-[#00E676] hover:bg-[#00E676]/20 rounded-lg transition-colors"
          >
            <Check className="w-4 h-4" />
          </button>
          <button 
            onClick={() => handleReject(row.id)}
            className="p-2 bg-[#FF1744]/10 text-[#FF1744] hover:bg-[#FF1744]/20 rounded-lg transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
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
        <h1 className="text-4xl font-bold tracking-tight text-white">Wallpaper Moderation</h1>
        <p className="mt-1 text-sm text-[#8B8B9E]">Review, approve, or reject new wallpaper submissions in real-time.</p>
      </div>

      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-white">Pending Reviews</h2>
        <DataTable columns={columns} data={wallpapers} emptyMessage="All wallpapers reviewed!" />
      </div>
    </div>
  );
}
