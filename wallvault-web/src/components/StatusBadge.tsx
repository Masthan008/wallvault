import React from 'react';

interface StatusBadgeProps {
  status: 'pending' | 'approved' | 'rejected' | 'suspended' | 'failed' | 'completed' | 'processing';
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const styles = {
    pending: 'bg-accent-warning/15 text-accent-warning border-accent-warning/30',
    approved: 'bg-accent-success/15 text-accent-success border-accent-success/30',
    completed: 'bg-accent-success/15 text-accent-success border-accent-success/30',
    processing: 'bg-accent-cyan/15 text-accent-cyan border-accent-cyan/30',
    rejected: 'bg-accent-error/15 text-accent-error border-accent-error/30',
    failed: 'bg-accent-error/15 text-accent-error border-accent-error/30',
    suspended: 'bg-accent-error/15 text-accent-error border-accent-error/30',
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
      className={`inline-flex items-center px-2.5 py-1 text-xs font-semibold border rounded-full ${styles[status]}`}
    >
      {labels[status]}
    </span>
  );
};
