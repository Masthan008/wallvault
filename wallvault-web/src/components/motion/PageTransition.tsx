'use client';

import React from 'react';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';

interface PageTransitionProps {
  children: React.ReactNode;
  /** Unique key to trigger exit/enter animations on change */
  transitionKey?: string | number;
}

const EASE = [0.16, 1, 0.3, 1] as const;

/**
 * Advanced page transition: blur + fade + slide + scale on enter,
 * with a smooth exit before the next page mounts.
 */
export const PageTransition: React.FC<PageTransitionProps> = ({ children, transitionKey }) => {
  const reduce = useReducedMotion();

  if (reduce) {
    return <>{children}</>;
  }

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={transitionKey}
        initial={{ opacity: 0, y: 24, scale: 0.985, filter: 'blur(8px)' }}
        animate={{ opacity: 1, y: 0, scale: 1, filter: 'blur(0px)' }}
        exit={{ opacity: 0, y: -16, scale: 0.99, filter: 'blur(6px)' }}
        transition={{ duration: 0.45, ease: EASE }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
};
