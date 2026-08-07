'use client';

import React from 'react';
import { motion } from 'framer-motion';

interface StatusBadgeProps {
  status: 'pending' | 'approved' | 'rejected' | 'suspended' | 'failed' | 'completed' | 'processing';
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const styles = {
    pending: 'bg-accent-warning/10 text-accent-warning border-accent-warning/20',
    approved: 'bg-accent-success/10 text-accent-success border-accent-success/20',
    completed: 'bg-accent-success/10 text-accent-success border-accent-success/20',
    processing: 'bg-accent-cyan/10 text-accent-cyan border-accent-cyan/20',
    rejected: 'bg-accent-error/10 text-accent-error border-accent-error/20',
    failed: 'bg-accent-error/10 text-accent-error border-accent-error/20',
    suspended: 'bg-accent-error/10 text-accent-error border-accent-error/20',
  };

  const dots = {
    pending: 'bg-accent-warning',
    approved: 'bg-accent-success',
    completed: 'bg-accent-success',
    processing: 'bg-accent-cyan',
    rejected: 'bg-accent-error',
    failed: 'bg-accent-error',
    suspended: 'bg-accent-error',
  };

  const labels = {
    pending: 'Pending',
    approved: 'Approved',
    completed: 'Completed',
    processing: 'Processing',
    rejected: 'Rejected',
    failed: 'Failed',
    suspended: 'Suspended',
  };

  return (
    <motion.span
      initial={{ opacity: 0, scale: 0.85 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ type: 'spring', stiffness: 380, damping: 22 }}
      whileHover={{ scale: 1.06 }}
      className={`inline-flex items-center gap-1.5 px-3 py-1 text-[10px] font-bold border rounded-full uppercase tracking-wider ${styles[status]}`}
    >
      <span className={`relative flex w-1.5 h-1.5`}>
        <span
          className={`absolute inline-flex h-full w-full rounded-full opacity-60 ${status === 'pending' || status === 'processing' ? 'animate-ping' : ''} ${dots[status]}`}
        />
        <span className={`relative inline-flex rounded-full w-1.5 h-1.5 ${dots[status]}`} />
      </span>
      {labels[status]}
    </motion.span>
  );
};
