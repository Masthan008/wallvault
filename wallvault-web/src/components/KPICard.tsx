import React from 'react';
import { LucideIcon } from 'lucide-react';

interface KPICardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  glowColor?: 'purple' | 'cyan' | 'gold';
}

export const KPICard: React.FC<KPICardProps> = ({
  label,
  value,
  icon: Icon,
  trend,
  glowColor,
}) => {
  const glowClasses = {
    purple: 'hover:shadow-[0_0_20px_rgba(184,41,221,0.2)] border-accent-purple/20',
    cyan: 'hover:shadow-[0_0_20px_rgba(0,212,255,0.2)] border-accent-cyan/20',
    gold: 'hover:shadow-[0_0_20px_rgba(255,215,0,0.2)] border-accent-gold/20',
  };

  return (
    <div
      className={`p-6 bg-bg-card rounded-2xl border border-bg-elevated transition-all duration-300 ${
        glowColor ? glowClasses[glowColor] : 'hover:border-text-muted'
      }`}
    >
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-text-secondary">{label}</span>
        <div className={`p-2.5 rounded-xl bg-bg-elevated text-text-primary`}>
          <Icon className="w-5 h-5" />
        </div>
      </div>
      <div className="mt-4">
        <h3 className="text-3xl font-bold text-text-primary tracking-tight">{value}</h3>
        {trend && (
          <div className="flex items-center mt-2 space-x-1.5">
            <span
              className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
                trend.isPositive
                  ? 'bg-accent-success/15 text-accent-success'
                  : 'bg-accent-error/15 text-accent-error'
              }`}
            >
              {trend.isPositive ? '+' : '-'}{Math.abs(trend.value)}%
            </span>
            <span className="text-xs text-text-muted">vs last month</span>
          </div>
        )}
      </div>
    </div>
  );
};
