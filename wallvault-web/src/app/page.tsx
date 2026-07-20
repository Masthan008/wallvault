'use client';

import React from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { Shield, Palette } from 'lucide-react';


export default function Home() {
  return (
    <div className="relative min-h-screen w-full bg-bg-primary overflow-hidden flex flex-col items-center justify-center px-6">
      <div className="max-w-3xl w-full text-center space-y-10 z-10">
        {/* App Logo */}
        <motion.div 
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: 'spring', stiffness: 100, damping: 15 }}
          className="flex justify-center"
        >
          <div className="p-4 rounded-xl text-white bg-white/[0.02] border border-white/[0.08] shadow-[0_4px_20px_rgba(0,0,0,0.3)]">
            <svg width="36" height="36" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke="#fafafa" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 16L15 19L20 13" stroke="#fafafa" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
        </motion.div>

        {/* Title */}
        <div className="space-y-4">
          <motion.h1 
            initial={{ y: 15, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.4, delay: 0.1 }}
            className="text-5xl font-extrabold tracking-tight text-white"
          >
            WallVault
          </motion.h1>
          <motion.p 
            initial={{ y: 15, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.4, delay: 0.2 }}
            className="text-text-secondary text-sm max-w-md mx-auto leading-relaxed font-medium"
          >
            Premium Wallpaper Marketplace Web Console. Manage administrative audits & designer hubs.
          </motion.p>
        </div>

        {/* Portals Selector */}
        <motion.div 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="grid grid-cols-1 gap-6 sm:grid-cols-2 pt-4"
        >
          {/* Creator Portal Card */}
          <Link
            href="/creator/dashboard"
            className="group flex flex-col p-8 glass-panel rounded-2xl text-left border border-white/[0.04] glow-purple-hover relative overflow-hidden"
          >
            <div className="p-2.5 bg-white/[0.02] border border-white/[0.06] text-white rounded-lg w-fit group-hover:scale-102 transition-transform duration-200">
              <Palette className="w-5 h-5" />
            </div>
            <h3 className="mt-5 text-lg font-bold text-white tracking-tight">Creator Hub</h3>
            <p className="mt-2 text-xs text-text-secondary leading-relaxed flex-grow">
              Upload art assets, customize pricing models, view real-time download analytics, and manage payouts.
            </p>
            <span className="mt-6 text-[10px] font-bold uppercase tracking-wider text-text-secondary group-hover:text-white transition-colors">
              Enter Hub &rarr;
            </span>
          </Link>

          {/* Admin Control Card */}
          <Link
            href="/admin/overview"
            className="group flex flex-col p-8 glass-panel rounded-2xl text-left border border-white/[0.04] glow-cyan-hover relative overflow-hidden"
          >
            <div className="p-2.5 bg-white/[0.02] border border-white/[0.06] text-white rounded-lg w-fit group-hover:scale-102 transition-transform duration-200">
              <Shield className="w-5 h-5" />
            </div>
            <h3 className="mt-5 text-lg font-bold text-white tracking-tight">Admin Console</h3>
            <p className="mt-2 text-xs text-text-secondary leading-relaxed flex-grow">
              Moderate wallpaper submissions, approve pending creators, process payouts, and audit revenue.
            </p>
            <span className="mt-6 text-[10px] font-bold uppercase tracking-wider text-text-secondary group-hover:text-white transition-colors">
              Open Console &rarr;
            </span>
          </Link>
        </motion.div>
      </div>
    </div>
  );
}


