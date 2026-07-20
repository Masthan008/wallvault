'use client';

import React from 'react';
import { LucideIcon } from 'lucide-react';
import { motion } from 'framer-motion';

interface KPICardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  glowColor?: 'purple' | 'cyan' | 'gold';
}

export const KPICard: React.FC<KPICardProps> = ({
  label,
  value,
  icon: Icon,
  trend,
  glowColor,
}) => {
  const glowClasses = {
    purple: 'glow-purple-hover hover:border-accent-purple/30',
    cyan: 'glow-cyan-hover hover:border-accent-cyan/30',
    gold: 'glow-gold-hover hover:border-accent-gold/30',
  };

  const borderAccentColor = glowColor 
    ? {
        purple: 'text-accent-purple bg-accent-purple/10',
        cyan: 'text-accent-cyan bg-accent-cyan/10',
        gold: 'text-accent-gold bg-accent-gold/10'
      }[glowColor]
    : 'text-text-primary bg-white/[0.05]';

  return (
    <motion.div
      whileHover={{ y: -4 }}
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className={`p-6 glass-panel rounded-2xl flex flex-col justify-between ${
        glowColor ? glowClasses[glowColor] : 'hover:border-white/[0.15]'
      }`}
    >
      <div>
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold uppercase tracking-wider text-text-secondary">{label}</span>
          <div className={`p-2.5 rounded-xl ${borderAccentColor} border border-white/[0.05]`}>
            <Icon className="w-4 h-4" />
          </div>
        </div>
        <div className="mt-6">
          <h3 className="text-3xl font-extrabold text-text-primary tracking-tight font-mono">
            {value}
          </h3>
        </div>
      </div>
      
      {trend && (
        <div className="flex items-center mt-4 space-x-2">
          <span
            className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
              trend.isPositive
                ? 'bg-accent-success/10 text-accent-success border-accent-success/20'
                : 'bg-accent-error/10 text-accent-error border-accent-error/20'
            }`}
          >
            {trend.isPositive ? '+' : '-'}{Math.abs(trend.value)}%
          </span>
          <span className="text-[10px] text-text-muted uppercase tracking-wider font-semibold">vs last month</span>
        </div>
      )}
    </motion.div>
  );
};

