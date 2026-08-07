'use client';

import React, { useRef } from 'react';
import { motion } from 'framer-motion';

interface SpotlightCardProps {
  children: React.ReactNode;
  className?: string;
  /** Spotlight color */
  color?: string;
  style?: React.CSSProperties;
}

/**
 * Card with a radial spotlight that follows the cursor,
 * driven by CSS custom properties (see .spotlight-card in globals.css).
 */
export const SpotlightCard: React.FC<SpotlightCardProps> = ({
  children,
  className,
  color = 'rgba(255,255,255,0.07)',
  style,
}) => {
  const ref = useRef<HTMLDivElement>(null);

  const handleMove = (e: React.MouseEvent) => {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    ref.current?.style.setProperty('--spot-x', `${x}px`);
    ref.current?.style.setProperty('--spot-y', `${y}px`);
  };

  return (
    <motion.div
      ref={ref}
      className={`spotlight-card ${className ?? ''}`}
      style={{ ...style, ['--spot-color' as string]: color }}
      onMouseMove={handleMove}
    >
      <div className="spotlight-overlay" style={{ background: `radial-gradient(500px circle at var(--spot-x, 50%) var(--spot-y, 50%), var(--spot-color), transparent 40%)` }} />
      {children}
    </motion.div>
  );
};
