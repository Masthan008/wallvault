'use client';

import React from 'react';

interface LiveDotProps {
  color?: string;
  size?: number;
  className?: string;
}

/**
 * Pulsing "live" indicator dot with expanding rings.
 */
export const LiveDot: React.FC<LiveDotProps> = ({ color = '#10b981', size = 8, className }) => {
  return (
    <span
      className={`live-dot inline-block ${className ?? ''}`}
      style={{
        width: size,
        height: size,
        background: color,
        boxShadow: `0 0 8px ${color}`,
      }}
      aria-hidden
    />
  );
};
