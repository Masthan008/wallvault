'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Palette } from 'lucide-react';

export default function CreatorIndexPage() {
  const router = useRouter();

  useEffect(() => {
    const t = setTimeout(() => router.replace('/creator/dashboard'), 600);
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
          <span className="absolute inset-0 rounded-full bg-purple-400/20 animate-ping" />
          <div className="relative w-12 h-12 rounded-full bg-purple-400/10 border border-purple-400/30 flex items-center justify-center">
            <Palette className="w-5 h-5 text-purple-400" />
          </div>
        </div>
        <div className="text-center">
          <p className="text-xs font-bold uppercase tracking-[0.2em] text-text-muted">Loading Creator Hub</p>
          <p className="text-[10px] text-text-muted/60 mt-1">Redirecting to dashboard…</p>
        </div>
      </motion.div>
    </div>
  );
}
