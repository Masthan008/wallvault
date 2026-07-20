import React from 'react';

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
    pending: 'bg-accent-warning animate-pulse',
    approved: 'bg-accent-success',
    completed: 'bg-accent-success',
    processing: 'bg-accent-cyan animate-pulse',
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
    <span
      className={`inline-flex items-center gap-1.5 px-3 py-1 text-[10px] font-bold border rounded-full uppercase tracking-wider ${styles[status]}`}
    >
      <span className={`w-1.5 h-1.5 rounded-full ${dots[status]}`} />
      {labels[status]}
    </span>
  );
};

