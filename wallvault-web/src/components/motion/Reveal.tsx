'use client';

import React from 'react';
import { motion, useReducedMotion, Variants } from 'framer-motion';

const EASE = [0.16, 1, 0.3, 1] as const;

interface RevealProps {
  children: React.ReactNode;
  className?: string;
  /** Direction the element enters from */
  direction?: 'up' | 'down' | 'left' | 'right' | 'none';
  delay?: number;
  duration?: number;
  once?: boolean;
  style?: React.CSSProperties;
}

const offsets: Record<string, { x: number; y: number }> = {
  up: { x: 0, y: 28 },
  down: { x: 0, y: -28 },
  left: { x: 28, y: 0 },
  right: { x: -28, y: 0 },
  none: { x: 0, y: 0 },
};

/**
 * Spring-powered reveal entrance with configurable direction.
 */
export const Reveal: React.FC<RevealProps> = ({
  children,
  className,
  direction = 'up',
  delay = 0,
  duration = 0.6,
  once = true,
  style,
}) => {
  const reduce = useReducedMotion();
  const { x, y } = offsets[direction];

  return (
    <motion.div
      className={className}
      style={style}
      initial={reduce ? { opacity: 0 } : { opacity: 0, x, y }}
      whileInView={reduce ? { opacity: 1 } : { opacity: 1, x: 0, y: 0 }}
      viewport={{ once, margin: '-40px' }}
      transition={{ duration, delay, ease: EASE }}
    >
      {children}
    </motion.div>
  );
};

interface StaggerGroupProps {
  children: React.ReactNode;
  className?: string;
  /** Seconds between each child's animation */
  stagger?: number;
  delay?: number;
  direction?: 'up' | 'down' | 'left' | 'right' | 'none';
}

const staggerOffsets: Record<string, { x: number; y: number }> = {
  up: { x: 0, y: 24 },
  down: { x: 0, y: -24 },
  left: { x: 24, y: 0 },
  right: { x: -24, y: 0 },
  none: { x: 0, y: 0 },
};

/**
 * Container that staggers the entrance of its direct StaggerItem children.
 */
export const StaggerGroup: React.FC<StaggerGroupProps> = ({
  children,
  className,
  stagger = 0.07,
  delay = 0,
  direction = 'up',
}) => {
  const { x, y } = staggerOffsets[direction];

  const container: Variants = {
    hidden: {},
    show: {
      transition: { staggerChildren: stagger, delayChildren: delay },
    },
  };

  const item: Variants = {
    hidden: { opacity: 0, x, y },
    show: { opacity: 1, x: 0, y: 0, transition: { duration: 0.55, ease: EASE } },
  };

  return (
    <motion.div
      className={className}
      variants={container}
      initial="hidden"
      whileInView="show"
      viewport={{ once: true, margin: '-40px' }}
    >
      {React.Children.map(children, (child) => (
        <motion.div variants={item} style={{ height: '100%' }}>
          {child}
        </motion.div>
      ))}
    </motion.div>
  );
};
