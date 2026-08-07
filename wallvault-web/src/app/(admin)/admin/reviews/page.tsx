'use client';

import React, { useEffect, useState } from 'react';
import { collection, onSnapshot, query, orderBy, deleteDoc, doc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { MessageSquare, Trash2, Search, Star, ShieldAlert, CheckCircle2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';

interface ReviewItem {
  id: string;
  wallpaperId: string;
  userId: string;
  userName: string;
  userAvatar: string;
  rating: number;
  comment: string;
  parentId?: string;
  createdAt: any;
}

export default function AdminReviewsPage() {
  const [reviews, setReviews] = useState<ReviewItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  useEffect(() => {
    const q = query(collection(db, 'reviews'), orderBy('createdAt', 'desc'));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list: ReviewItem[] = [];
        snapshot.forEach((docSnap) => {
          list.push({
            id: docSnap.id,
            ...docSnap.data(),
          } as ReviewItem);
        });
        setReviews(list);
        setLoading(false);
      },
      (err) => {
        console.error('Failed to load reviews:', err);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  const handleDeleteReview = async (reviewId: string) => {
    if (!confirm('Are you sure you want to remove this review/comment? It will be deleted from the platform and mobile app immediately.')) {
      return;
    }

    setDeletingId(reviewId);
    try {
      await deleteDoc(doc(db, 'reviews', reviewId));
      setSuccessMessage('Review removed successfully.');
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err) {
      console.error('Failed to delete review:', err);
      alert('Failed to delete review');
    } finally {
      setDeletingId(null);
    }
  };

  const filteredReviews = reviews.filter((r) =>
    r.comment.toLowerCase().includes(searchQuery.toLowerCase()) ||
    r.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    r.wallpaperId.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-8">
      {/* ── Top Header ─────────────────────────────────────── */}
      <PageHeader
        title="Review & Comment Moderation"
        subtitle="Monitor, moderate, and remove misbehaving user comments or inappropriate reviews across all wallpapers."
        badge="Moderation Queue"
        badgeColor="#06b6d4"
      />

      {/* ── Notification Banner ────────────────────────────── */}
      <AnimatePresence>
        {successMessage && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="flex items-center space-x-2 px-4 py-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold"
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>{successMessage}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Controls & Search ───────────────────────────────── */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.12, duration: 0.4 }}
        className="flex flex-col sm:flex-row gap-4 justify-between items-center bg-white/[0.02] p-4 rounded-2xl border border-white/[0.06]"
      >
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-[#71717a]" />
          <input
            type="text"
            placeholder="Search by comment, user, wallpaper ID..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-cyan-500/50 focus:shadow-[0_0_20px_rgba(6,182,212,0.06)] transition-all"
          />
        </div>
        <div className="text-xs text-[#71717a] font-medium">
          Total Reviews: <span className="text-white font-bold">{reviews.length}</span>
        </div>
      </motion.div>

      {/* ── Reviews Data List ──────────────────────────────── */}
      {loading ? (
        <div className="flex items-center justify-center py-20 text-xs text-[#71717a]">
          <div className="relative">
            <MessageSquare className="w-6 h-6 text-cyan-400 animate-pulse" />
            <span className="absolute inset-0 rounded-full animate-ping bg-cyan-400/20" />
          </div>
        </div>
      ) : filteredReviews.length === 0 ? (
        <motion.div
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="flex flex-col items-center justify-center py-20 bg-white/[0.01] rounded-2xl border border-white/[0.05]"
        >
          <ShieldAlert className="w-10 h-10 text-[#52525b] mb-3 animate-float" />
          <p className="text-sm font-semibold text-[#a1a1aa]">No reviews found</p>
          <p className="text-xs text-[#52525b] mt-1">There are no reviews matching your search criteria.</p>
        </motion.div>
      ) : (
        <div className="grid gap-4">
          <AnimatePresence mode="popLayout">
            {filteredReviews.map((item) => (
              <motion.div
                key={item.id}
                layout
                initial={{ opacity: 0, y: 16, scale: 0.98 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, x: -40, scale: 0.95 }}
                transition={{ type: 'spring', stiffness: 280, damping: 26 }}
                whileHover={{ y: -2 }}
                className="p-5 rounded-2xl glass-morphism border border-white/[0.06] flex flex-col md:flex-row items-start md:items-center justify-between gap-4 hover:border-white/[0.12] transition-colors"
              >
                <div className="flex items-start space-x-3.5 flex-1 min-w-0">
                  <motion.div
                    whileHover={{ scale: 1.1, rotate: -4 }}
                    className="w-10 h-10 rounded-full bg-cyan-500/10 border border-cyan-500/20 overflow-hidden shrink-0 flex items-center justify-center text-cyan-400 font-bold text-sm"
                  >
                    {item.userAvatar ? (
                      <img src={item.userAvatar} alt="Avatar" className="w-full h-full object-cover" />
                    ) : (
                      item.userName?.[0]?.toUpperCase() || 'U'
                    )}
                  </motion.div>
                  <div className="flex-1 min-w-0 space-y-1">
                    <div className="flex items-center space-x-2 flex-wrap">
                      <span className="text-xs font-bold text-white">{item.userName}</span>
                      {item.rating > 0 && (
                        <motion.span
                          initial={{ scale: 0.7 }}
                          animate={{ scale: 1 }}
                          transition={{ type: 'spring', stiffness: 400, damping: 15 }}
                          className="inline-flex items-center text-[10px] font-bold text-amber-400 bg-amber-400/10 px-2 py-0.5 rounded-full border border-amber-400/20"
                        >
                          <Star className="w-2.5 h-2.5 mr-1 fill-amber-400" />
                          {item.rating} Stars
                        </motion.span>
                      )}
                      {item.parentId && (
                        <span className="text-[9px] uppercase font-bold text-purple-400 bg-purple-500/10 px-2 py-0.5 rounded-full border border-purple-500/20">
                          Reply
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-[#d4d4d8] leading-relaxed break-words">{item.comment}</p>
                    <div className="flex items-center space-x-3 text-[10px] text-[#71717a]">
                      <span>Wallpaper ID: <code className="text-cyan-400/80">{item.wallpaperId.slice(0, 16)}</code></span>
                      <span>•</span>
                      <span>{item.createdAt?.toDate ? new Date(item.createdAt.toDate()).toLocaleString() : 'Recently'}</span>
                    </div>
                  </div>
                </div>

                {/* Moderate Action */}
                <div className="shrink-0">
                  <motion.button
                    whileHover={{ scale: 1.05, y: -1 }}
                    whileTap={{ scale: 0.93 }}
                    onClick={() => handleDeleteReview(item.id)}
                    disabled={deletingId === item.id}
                    className="flex items-center space-x-1.5 px-3.5 py-2 rounded-xl text-xs font-bold text-rose-400 bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/20 transition-all cursor-pointer disabled:opacity-50"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>{deletingId === item.id ? 'Deleting...' : 'Remove Review'}</span>
                  </motion.button>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      )}
    </div>
  );
}
