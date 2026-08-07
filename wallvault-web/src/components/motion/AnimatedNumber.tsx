'use client';

import React, { useEffect, useState } from 'react';
import { animate, useMotionValue, useTransform, useReducedMotion } from 'framer-motion';

interface AnimatedNumberProps {
  value: number;
  duration?: number;
  /** Format the value, e.g. prefix ₹ or compact notation */
  format?: (v: number) => string;
  className?: string;
}

const defaultFormat = (v: number) => {
  if (v >= 1000) return `${(v / 1000).toFixed(1)}k`;
  return Math.round(v).toLocaleString();
};

/**
 * Animated counter with eased interpolation and custom formatting.
 */
export const AnimatedNumber: React.FC<AnimatedNumberProps> = ({
  value,
  duration = 1.4,
  format = defaultFormat,
  className,
}) => {
  const reduce = useReducedMotion();
  const motionVal = useMotionValue(reduce ? value : 0);
  const [display, setDisplay] = useState(() => format(value));
  const rounded = useTransform(motionVal, (latest) => format(latest));

  useEffect(() => {
    const unsub = rounded.on('change', setDisplay);
    return unsub;
  }, [rounded]);

  useEffect(() => {
    if (reduce) {
      motionVal.set(value);
      return;
    }
    const controls = animate(motionVal, value, {
      duration,
      ease: [0.16, 1, 0.3, 1],
    });
    return controls.stop;
  }, [value, duration, motionVal, reduce]);

  return <span className={className}>{display}</span>;
};
