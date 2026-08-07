'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { ShieldCheck } from 'lucide-react';

export default function AdminIndexPage() {
  const router = useRouter();

  useEffect(() => {
    const t = setTimeout(() => router.replace('/admin/overview'), 600);
    return () => clearTimeout(t);
  }, [router]);

  return (
    <div className="min-h-[60vh] flex items-center justify-center">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.4 }}
        className="flex flex-col items-center gap-4"
      >
        <div className="relative">
          <span className="absolute inset-0 rounded-full bg-cyan-400/20 animate-ping" />
          <div className="relative w-12 h-12 rounded-full bg-cyan-400/10 border border-cyan-400/30 flex items-center justify-center">
            <ShieldCheck className="w-5 h-5 text-cyan-400" />
          </div>
        </div>
        <div className="text-center">
          <p className="text-xs font-bold uppercase tracking-[0.2em] text-text-muted">Loading Admin Portal</p>
          <p className="text-[10px] text-text-muted/60 mt-1">Redirecting to overview…</p>
        </div>
      </motion.div>
    </div>
  );
}
