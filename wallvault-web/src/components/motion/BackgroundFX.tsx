'use client';

import React from 'react';
import { motion, useMotionValue, useSpring, useTransform, useScroll, useReducedMotion } from 'framer-motion';

interface BackgroundFXProps {
  variant?: 'purple' | 'cyan' | 'both';
  intensity?: 'subtle' | 'medium' | 'bold';
}

const palette = {
  purple: { primary: '#a855f7', secondary: '#7c3aed' },
  cyan: { primary: '#06b6d4', secondary: '#0e7490' },
  both: { primary: '#a855f7', secondary: '#06b6d4' },
};

const opacityMap = { subtle: 0.16, medium: 0.28, bold: 0.42 } as const;

/**
 * Fixed, full-viewport ambient aurora background.
 * Renders drifting blurred blobs behind all content (z-index 0).
 */
export const BackgroundFX: React.FC<BackgroundFXProps> = ({ variant = 'both', intensity = 'medium' }) => {
  const c = palette[variant];
  const opacity = opacityMap[intensity];

  return (
    <div className="aurora-bg" aria-hidden>
      <div
        className="aurora-blob animate-drift"
        style={{
          width: '38rem',
          height: '38rem',
          top: '-12%',
          left: '-8%',
          background: `radial-gradient(circle, ${c.primary} 0%, transparent 65%)`,
          opacity,
        }}
      />
      <div
        className="aurora-blob animate-drift-slow"
        style={{
          width: '44rem',
          height: '44rem',
          top: '30%',
          right: '-14%',
          background: `radial-gradient(circle, ${c.secondary} 0%, transparent 65%)`,
          opacity: opacity * 0.8,
        }}
      />
      <div
        className="aurora-blob animate-aurora"
        style={{
          width: '32rem',
          height: '32rem',
          bottom: '-18%',
          left: '28%',
          background: `radial-gradient(circle, ${c.primary} 0%, transparent 60%)`,
          opacity: opacity * 0.6,
        }}
      />
    </div>
  );
};

/**
 * Soft radial glow that follows the cursor.
 * Only renders on devices with a fine pointer.
 */
export const CursorGlow: React.FC = () => {
  const reduce = useReducedMotion();
  const mx = useMotionValue(-400);
  const my = useMotionValue(-400);
  const sx = useSpring(mx, { stiffness: 60, damping: 20, mass: 0.6 });
  const sy = useSpring(my, { stiffness: 60, damping: 20, mass: 0.6 });
  const x = useTransform(sx, (v) => v - 250);
  const y = useTransform(sy, (v) => v - 250);

  React.useEffect(() => {
    const onMove = (e: PointerEvent) => {
      if (e.pointerType === 'mouse') {
        mx.set(e.clientX);
        my.set(e.clientY);
      }
    };
    window.addEventListener('pointermove', onMove);
    return () => window.removeEventListener('pointermove', onMove);
  }, [mx, my]);

  if (reduce) return null;

  return (
    <motion.div
      aria-hidden
      className="pointer-events-none fixed z-[2] hidden md:block rounded-full"
      style={{
        width: 500,
        height: 500,
        x,
        y,
        background:
          'radial-gradient(circle, rgba(168,85,247,0.05) 0%, rgba(6,182,212,0.03) 40%, transparent 70%)',
      }}
    />
  );
};

/**
 * Fixed thin gradient progress bar at the top of the viewport.
 */
export const ScrollProgress: React.FC = () => {
  const { scrollYProgress } = useScroll();
  return (
    <motion.div
      className="scroll-progress"
      style={{ scaleX: scrollYProgress }}
      aria-hidden
    />
  );
};
