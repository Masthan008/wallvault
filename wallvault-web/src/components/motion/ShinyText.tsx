'use client';

import React from 'react';

interface ShinyTextProps {
  children: React.ReactNode;
  className?: string;
  duration?: number;
  style?: React.CSSProperties;
}

/**
 * Text with a continuous light shimmer sweeping across it.
 */
export const ShinyText: React.FC<ShinyTextProps> = ({ children, className, duration = 2.5, style }) => {
  return (
    <span
      className={`relative inline-block overflow-hidden ${className ?? ''}`}
      style={style}
    >
      {children}
      <span
        aria-hidden
        className="absolute inset-y-0 left-0 w-1/3"
        style={{
          background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.35), transparent)',
          animation: `shine ${duration}s ease-in-out infinite`,
        }}
      />
    </span>
  );
};
