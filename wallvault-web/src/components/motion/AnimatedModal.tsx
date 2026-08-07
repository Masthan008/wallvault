'use client';

import React from 'react';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';

interface AnimatedModalProps {
  open: boolean;
  onClose?: () => void;
  children: React.ReactNode;
  className?: string;
  /** Close when clicking the backdrop */
  backdropClose?: boolean;
  maxWidthClass?: string;
}

const EASE = [0.16, 1, 0.3, 1] as const;

/**
 * Spring-pop modal with blurred backdrop, used across all dashboards.
 * Handle clicks on backdrop + close button via onClose.
 */
export const AnimatedModal: React.FC<AnimatedModalProps> = ({
  open,
  onClose,
  children,
  className,
  backdropClose = true,
  maxWidthClass = 'max-w-2xl',
}) => {
  const reduce = useReducedMotion();

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: reduce ? 0 : 0.25 }}
          className="modal-backdrop fixed inset-0 z-50 flex items-center justify-center p-4"
          onClick={(e) => {
            if (backdropClose && e.target === e.currentTarget) onClose?.();
          }}
        >
          <motion.div
            initial={reduce ? { opacity: 0 } : { opacity: 0, y: 28, scale: 0.92 }}
            animate={reduce ? { opacity: 1 } : { opacity: 1, y: 0, scale: 1 }}
            exit={reduce ? { opacity: 0 } : { opacity: 0, y: 16, scale: 0.94 }}
            transition={reduce ? { duration: 0 } : { type: 'spring', stiffness: 320, damping: 28, mass: 0.8 }}
            className={`relative w-full ${maxWidthClass} ${className ?? ''}`}
          >
            {children}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
