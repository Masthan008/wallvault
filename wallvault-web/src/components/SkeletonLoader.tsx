'use client';

import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';

interface SkeletonLoaderProps {
  className?: string;
  variant?: 'card' | 'table' | 'line' | 'circle';
  count?: number;
}

export const SkeletonLoader: React.FC<SkeletonLoaderProps> = ({
  className = '',
  variant = 'line',
  count = 1,
}) => {
  const reduce = useReducedMotion();
  const baseClasses = 'skeleton-shimmer bg-white/[0.03] rounded-xl';

  const renderSkeleton = (idx: number) => {
    switch (variant) {
      case 'card':
        return (
          <motion.div
            key={idx}
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.08, duration: 0.4 }}
            className={`p-6 border border-white/[0.05] bg-white/[0.02] rounded-2xl flex flex-col justify-between ${className}`}
            style={{ height: '160px' }}
          >
            <div className="flex items-center justify-between">
              <div className={`${baseClasses} h-4 w-24`} />
              <div className={`${baseClasses} h-9 w-9 rounded-xl`} />
            </div>
            <div className="space-y-2 mt-4">
              <div className={`${baseClasses} h-8 w-32`} />
              <div className={`${baseClasses} h-3 w-20`} />
            </div>
          </motion.div>
        );
      case 'table':
        return (
          <motion.div
            key={idx}
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.08, duration: 0.4 }}
            className="w-full space-y-4 border border-white/[0.05] p-4 rounded-2xl bg-white/[0.01]"
          >
            <div className="flex justify-between items-center pb-2 border-b border-white/[0.05]">
              <div className={`${baseClasses} h-4 w-1/4`} />
              <div className={`${baseClasses} h-4 w-1/6`} />
              <div className={`${baseClasses} h-4 w-1/6`} />
              <div className={`${baseClasses} h-4 w-1/8`} />
            </div>
            {Array.from({ length: 4 }).map((_, rIdx) => (
              <div key={rIdx} className="flex justify-between items-center py-1">
                <div className={`${baseClasses} h-5 w-1/3`} />
                <div className={`${baseClasses} h-5 w-1/6`} />
                <div className={`${baseClasses} h-5 w-1/5`} />
                <div className={`${baseClasses} h-6 w-16 rounded-full`} />
              </div>
            ))}
          </motion.div>
        );
      case 'circle':
        return <div key={idx} className={`${baseClasses} rounded-full ${className}`} />;
      case 'line':
      default:
        return <div key={idx} className={`${baseClasses} h-4 ${className}`} />;
    }
  };

  if (count > 1) {
    return (
      <div className="space-y-4 w-full">
        {Array.from({ length: count }).map((_, idx) => renderSkeleton(idx))}
      </div>
    );
  }

  return renderSkeleton(0);
};
