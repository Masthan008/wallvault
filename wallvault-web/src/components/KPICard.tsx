'use client';

import React, { useEffect, useState } from 'react';
import { LucideIcon } from 'lucide-react';
import { motion, useMotionValue, useTransform, animate } from 'framer-motion';

interface KPICardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  glowColor?: 'purple' | 'cyan' | 'gold';
  index?: number;
}

// Animated counter component
function AnimatedNumber({ value }: { value: number }) {
  const motionVal = useMotionValue(0);
  const rounded = useTransform(motionVal, (latest) => {
    if (latest >= 1000) return `${(latest / 1000).toFixed(1)}k`;
    return Math.round(latest).toLocaleString();
  });

  useEffect(() => {
    const controls = animate(motionVal, value, {
      duration: 1.2,
      ease: [0.16, 1, 0.3, 1],
    });
    return controls.stop;
  }, [value, motionVal]);

  return <motion.span>{rounded}</motion.span>;
}

export const KPICard: React.FC<KPICardProps> = ({
  label,
  value,
  icon: Icon,
  trend,
  glowColor,
  index = 0,
}) => {
  const glowClasses = {
    purple: 'glow-purple-hover',
    cyan: 'glow-cyan-hover',
    gold: 'glow-gold-hover',
  };

  const accentColors = {
    purple: { text: '#a855f7', bg: 'rgba(168,85,247,0.08)', border: 'rgba(168,85,247,0.15)' },
    cyan: { text: '#06b6d4', bg: 'rgba(6,182,212,0.08)', border: 'rgba(6,182,212,0.15)' },
    gold: { text: '#f59e0b', bg: 'rgba(245,158,11,0.08)', border: 'rgba(245,158,11,0.15)' },
  };

  const accent = glowColor ? accentColors[glowColor] : { text: '#fafafa', bg: 'rgba(255,255,255,0.03)', border: 'rgba(255,255,255,0.06)' };

  const numericValue = typeof value === 'string' ? parseFloat(value.replace(/[₹,k%]/g, '')) || 0 : value;
  const isNumeric = typeof value === 'number' || /^[\d₹,k.%]+$/.test(String(value));
  const prefix = typeof value === 'string' && value.startsWith('₹') ? '₹' : '';

  return (
    <motion.div
      whileHover={{ y: -3, scale: 1.01 }}
      initial={{ opacity: 0, y: 20, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ delay: index * 0.08, duration: 0.45, ease: [0.16, 1, 0.3, 1] }}
      className={`relative p-5 glass-panel rounded-2xl flex flex-col justify-between overflow-hidden ${
        glowColor ? glowClasses[glowColor] : 'hover:border-white/[0.12]'
      }`}
    >
      {/* Top accent gradient line */}
      <div
        className="absolute top-0 left-0 right-0 h-[2px] opacity-60"
        style={{ background: `linear-gradient(90deg, transparent, ${accent.text}, transparent)` }}
      />

      <div>
        <div className="flex items-center justify-between">
          <span className="text-[10px] font-bold uppercase tracking-[0.12em] text-[#71717a]">{label}</span>
          <motion.div
            whileHover={{ rotate: 12, scale: 1.1 }}
            className="p-2 rounded-xl"
            style={{ background: accent.bg, border: `1px solid ${accent.border}` }}
          >
            <Icon className="w-4 h-4" style={{ color: accent.text }} />
          </motion.div>
        </div>
        <div className="mt-4">
          <h3 className="text-2xl font-black text-white tracking-tight font-mono">
            {isNumeric ? (
              <>
                {prefix}<AnimatedNumber value={numericValue} />
              </>
            ) : (
              value
            )}
          </h3>
        </div>
      </div>
      
      {trend && (
        <div className="flex items-center mt-3 space-x-2">
          <span
            className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
              trend.isPositive
                ? 'bg-[#10b981]/8 text-[#10b981] border-[#10b981]/15'
                : 'bg-[#ef4444]/8 text-[#ef4444] border-[#ef4444]/15'
            }`}
          >
            {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
          </span>
          <span className="text-[9px] text-[#52525b] uppercase tracking-wider font-bold">vs last month</span>
        </div>
      )}
    </motion.div>
  );
};
