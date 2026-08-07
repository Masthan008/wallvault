'use client';

import React from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { Shield, Palette, ArrowRight } from 'lucide-react';
import { Magnetic } from '@/components/motion/Magnetic';
import { TiltCard } from '@/components/motion/TiltCard';
import { LiveDot } from '@/components/motion/LiveDot';
import { ShinyText } from '@/components/motion/ShinyText';

const EASE = [0.16, 1, 0.3, 1] as const;

const floatingPreviews = [
  { src: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=60&w=300', x: '-12%', y: '18%', rot: -8, delay: 0.9 },
  { src: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=60&w=300', x: '84%', y: '14%', rot: 7, delay: 1.1 },
  { src: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=60&w=300', x: '-6%', y: '68%', rot: 6, delay: 1.3 },
  { src: 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?q=60&w=300', x: '80%', y: '62%', rot: -6, delay: 1.5 },
];

export default function Home() {
  return (
    <div className="relative min-h-screen w-full bg-bg-primary overflow-hidden flex flex-col items-center justify-center px-6">
      {/* Floating wallpaper previews */}
      {floatingPreviews.map((fp, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, scale: 0.6 }}
          animate={{ opacity: 0.35, scale: 1 }}
          transition={{ delay: fp.delay, duration: 1, ease: EASE }}
          className="absolute hidden lg:block pointer-events-none"
          style={{ left: fp.x, top: fp.y }}
        >
          <motion.div
            animate={{ y: [0, -16, 0], rotate: [fp.rot, fp.rot + 2, fp.rot] }}
            transition={{ duration: 7 + i, repeat: Infinity, ease: 'easeInOut' }}
            className="rounded-2xl overflow-hidden border border-white/[0.08] shadow-2xl"
            style={{ transform: `rotate(${fp.rot}deg)`, width: 170, height: 300 }}
          >
            <img src={fp.src} alt="" className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
          </motion.div>
        </motion.div>
      ))}

      <div className="max-w-3xl w-full text-center space-y-10 z-10">
        {/* App Logo with ring pulse */}
        <div className="flex justify-center">
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ type: 'spring', stiffness: 120, damping: 12, delay: 0.1 }}
            className="relative"
          >
            <motion.div
              className="absolute inset-0 rounded-2xl bg-accent-purple/20 blur-2xl"
              animate={{ opacity: [0.3, 0.7, 0.3], scale: [0.9, 1.08, 0.9] }}
              transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
            />
            <motion.div
              whileHover={{ rotate: [0, -10, 10, 0], scale: 1.08 }}
              transition={{ duration: 0.6 }}
              className="relative p-4 rounded-2xl text-white bg-white/[0.03] border border-white/[0.1] shadow-[0_4px_24px_rgba(0,0,0,0.4)] backdrop-blur-md"
            >
              <svg width="36" height="36" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke="#a855f7" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M12 16L15 19L20 13" stroke="#06b6d4" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </motion.div>
          </motion.div>
        </div>

        {/* Title */}
        <div className="space-y-5">
          <motion.div
            initial={{ y: 18, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.25, ease: EASE }}
            className="flex items-center justify-center gap-2.5"
          >
            <LiveDot color="#10b981" size={7} />
            <span className="text-[10px] font-bold uppercase tracking-[0.25em] text-[#71717a]">
              Premium Wallpaper Marketplace
            </span>
          </motion.div>

          <motion.h1
            initial={{ y: 24, opacity: 0, filter: 'blur(8px)' }}
            animate={{ y: 0, opacity: 1, filter: 'blur(0px)' }}
            transition={{ duration: 0.7, delay: 0.35, ease: EASE }}
            className="text-6xl md:text-7xl font-extrabold tracking-tight text-white"
          >
            Wall<span className="text-gradient-animated">Vault</span>
          </motion.h1>

          <motion.p
            initial={{ y: 18, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.5, ease: EASE }}
            className="text-text-secondary text-sm max-w-md mx-auto leading-relaxed font-medium"
          >
            <ShinyText duration={4}>Command center</ShinyText> for premium creators & platform
            administrators. Moderate, monetize & monitor everything in real-time.
          </motion.p>
        </div>

        {/* Portals Selector */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 pt-4">
          {/* Creator Portal Card */}
          <Magnetic strength={0.25}>
            <Link href="/creator/dashboard" className="group block h-full">
              <TiltCard maxTilt={7} className="h-full">
                <div className="conic-border glass-panel p-8 rounded-2xl h-full text-left border border-white/[0.04] glow-purple-hover relative">
                  <motion.div
                    whileHover={{ rotate: 12, scale: 1.1 }}
                    transition={{ type: 'spring', stiffness: 300, damping: 12 }}
                    className="p-2.5 rounded-lg w-fit relative"
                    style={{ background: 'rgba(168,85,247,0.08)', border: '1px solid rgba(168,85,247,0.2)' }}
                  >
                    <Palette className="w-5 h-5" style={{ color: '#a855f7' }} />
                  </motion.div>
                  <h3 className="mt-5 text-lg font-bold text-white tracking-tight">Creator Hub</h3>
                  <p className="mt-2 text-xs text-text-secondary leading-relaxed flex-grow">
                    Upload art assets, customize pricing models, view real-time download analytics, and manage payouts.
                  </p>
                  <span className="mt-6 inline-flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-text-secondary group-hover:text-accent-purple transition-colors">
                    Enter Hub
                    <motion.span
                      animate={{ x: [0, 4, 0] }}
                      transition={{ duration: 1.4, repeat: Infinity, ease: 'easeInOut' }}
                    >
                      <ArrowRight className="w-3 h-3" />
                    </motion.span>
                  </span>
                </div>
              </TiltCard>
            </Link>
          </Magnetic>

          {/* Admin Control Card */}
          <Magnetic strength={0.25}>
            <Link href="/admin/overview" className="group block h-full">
              <TiltCard maxTilt={7} className="h-full">
                <div className="conic-border glass-panel p-8 rounded-2xl h-full text-left border border-white/[0.04] glow-cyan-hover relative" style={{ ['--conic-color' as string]: '#06b6d4', ['--conic-color-2' as string]: '#a855f7' }}>
                  <motion.div
                    whileHover={{ rotate: -12, scale: 1.1 }}
                    transition={{ type: 'spring', stiffness: 300, damping: 12 }}
                    className="p-2.5 rounded-lg w-fit relative"
                    style={{ background: 'rgba(6,182,212,0.08)', border: '1px solid rgba(6,182,212,0.2)' }}
                  >
                    <Shield className="w-5 h-5" style={{ color: '#06b6d4' }} />
                  </motion.div>
                  <h3 className="mt-5 text-lg font-bold text-white tracking-tight">Admin Console</h3>
                  <p className="mt-2 text-xs text-text-secondary leading-relaxed flex-grow">
                    Moderate wallpaper submissions, approve pending creators, process payouts, and audit revenue.
                  </p>
                  <span className="mt-6 inline-flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-text-secondary group-hover:text-accent-cyan transition-colors">
                    Open Console
                    <motion.span
                      animate={{ x: [0, 4, 0] }}
                      transition={{ duration: 1.4, repeat: Infinity, ease: 'easeInOut', delay: 0.7 }}
                    >
                      <ArrowRight className="w-3 h-3" />
                    </motion.span>
                  </span>
                </div>
              </TiltCard>
            </Link>
          </Magnetic>
        </div>

        {/* Feature chips */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1, duration: 0.8 }}
          className="flex flex-wrap items-center justify-center gap-2 pt-2"
        >
          {['Real-time Sync', '70% Creator Revenue', 'Instant Moderation', 'Secure Payouts'].map((f) => (
            <span
              key={f}
              className="px-3 py-1.5 rounded-full text-[9px] font-bold uppercase tracking-[0.15em] text-[#52525b] border border-white/[0.05] bg-white/[0.015] hover:text-[#a1a1aa] hover:border-white/[0.1] transition-colors cursor-default"
            >
              {f}
            </span>
          ))}
        </motion.div>
      </div>
    </div>
  );
}
