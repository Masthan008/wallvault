'use client';

import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';

interface GradientButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: 'button' | 'submit';
  disabled?: boolean;
  className?: string;
  /** Gradient variant */
  variant?: 'purple' | 'cyan' | 'gold' | 'white';
  size?: 'sm' | 'md' | 'lg';
  style?: React.CSSProperties;
}

const gradients = {
  purple: 'linear-gradient(135deg, #a855f7 0%, #7c3aed 55%, #06b6d4 120%)',
  cyan: 'linear-gradient(135deg, #06b6d4 0%, #0ea5e9 60%, #8b5cf6 120%)',
  gold: 'linear-gradient(135deg, #f59e0b 0%, #f97316 60%, #e11d48 120%)',
  white: 'linear-gradient(180deg, #ffffff, #e4e4e7)',
};

const sizes = {
  sm: 'px-3.5 py-2 text-[10px]',
  md: 'px-5 py-2.5 text-[11px]',
  lg: 'px-6 py-3 text-xs',
};

/**
 * Gradient button with hover sheen sweep, lift and press physics.
 */
export const GradientButton: React.FC<GradientButtonProps> = ({
  children,
  onClick,
  type = 'button',
  disabled,
  className = '',
  variant = 'purple',
  size = 'md',
  style,
}) => {
  const reduce = useReducedMotion();

  return (
    <motion.button
      type={type}
      onClick={onClick}
      disabled={disabled}
      whileHover={reduce ? undefined : { y: -1.5 }}
      whileTap={reduce ? undefined : { scale: 0.96 }}
      transition={{ type: 'spring', stiffness: 400, damping: 22 }}
      className={`btn-shine group relative inline-flex items-center justify-center gap-2 font-bold uppercase tracking-wider rounded-xl text-black disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer ${sizes[size]} ${className}`}
      style={{ background: gradients[variant], boxShadow: '0 4px 20px -4px rgba(0,0,0,0.5)', ...style }}
    >
      {children}
    </motion.button>
  );
};
