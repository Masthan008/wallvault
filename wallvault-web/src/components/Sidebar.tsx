'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { LucideIcon, LogOut, User as UserIcon, ChevronRight, ChevronsLeft, ChevronsRight } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';

interface SidebarItem {
  label: string;
  href: string;
  icon: LucideIcon;
}

interface SidebarProps {
  title: string;
  items: SidebarItem[];
  portalType: 'creator' | 'admin';
  collapsed?: boolean;
  onToggle?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ title, items, portalType, collapsed = false, onToggle }) => {
  const pathname = usePathname();
  const router = useRouter();
  const { user, profile, logout } = useAuth();
  const reduce = useReducedMotion();

  const handleSignOut = async () => {
    try {
      await logout();
      router.push('/login');
    } catch (err) {
      console.error('Failed to logout', err);
    }
  };

  const accentColor = portalType === 'admin' ? '#06b6d4' : '#a855f7';
  const width = collapsed ? 'w-[72px]' : 'w-64';

  return (
    <motion.aside
      initial={{ x: -280, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      transition={{ type: 'spring', stiffness: 200, damping: 26 }}
      className={`fixed inset-y-0 left-0 z-20 flex flex-col glass-morphism-strong border-r border-white/[0.06] ${width} transition-[width] duration-300`}
    >
      {/* ── Brand Header ─────────────────────────────────────── */}
      <div className={`flex items-center h-[72px] px-4 border-b border-white/[0.06] ${collapsed ? 'justify-center' : ''}`}>
        <Link href="/" className="flex items-center space-x-3 group">
          <motion.div
            whileHover={{ rotate: [0, -10, 10, 0], scale: 1.1 }}
            transition={{ duration: 0.6 }}
            className="relative p-2 rounded-xl border border-white/[0.08] shrink-0"
            style={{ background: `${accentColor}10` }}
          >
            <svg width="20" height="20" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke={accentColor} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 16L15 19L20 13" stroke={accentColor} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span
              className="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full"
              style={{ background: accentColor, boxShadow: `0 0 8px ${accentColor}` }}
            />
          </motion.div>
          <AnimatePresence>
            {!collapsed && (
              <motion.div
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -8 }}
                transition={{ duration: 0.2 }}
                className="flex flex-col"
              >
                <span className="text-[13px] font-bold tracking-tight text-white">
                  {title}
                </span>
                <span className="text-[9px] uppercase tracking-[0.2em] font-semibold"
                  style={{ color: accentColor }}>
                  {portalType} console
                </span>
              </motion.div>
            )}
          </AnimatePresence>
        </Link>

        {/* Collapse toggle */}
        <button
          onClick={onToggle}
          className={`p-1.5 rounded-lg text-[#52525b] hover:text-white hover:bg-white/[0.04] transition-colors cursor-pointer ${collapsed ? 'ml-auto' : 'ml-2'}`}
          title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {collapsed ? (
            <ChevronsRight className="w-4 h-4" />
          ) : (
            <ChevronsLeft className="w-4 h-4" />
          )}
        </button>
      </div>

      {/* ── Navigation Items ─────────────────────────────────── */}
      <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto overflow-x-hidden">
        {items.map((item, idx) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <motion.div
              key={item.href}
              initial={reduce ? false : { opacity: 0, x: -14 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.05 + idx * 0.05, duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
            >
              <Link
                href={item.href}
                title={collapsed ? item.label : undefined}
                className={`group relative flex items-center px-3.5 py-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] rounded-xl overflow-hidden ${
                  collapsed ? 'justify-center' : ''
                } ${
                  isActive
                    ? 'text-white'
                    : 'text-[#71717a] hover:text-[#a1a1aa] hover:bg-white/[0.02]'
                }`}
              >
                {/* Active Background Fill */}
                {isActive && (
                  <motion.div
                    layoutId={`sidebar-active-bg-${portalType}`}
                    className="absolute inset-0 rounded-xl"
                    style={{
                      background: `linear-gradient(135deg, ${accentColor}14, ${accentColor}05)`,
                      border: `1px solid ${accentColor}28`,
                      boxShadow: `0 0 24px ${accentColor}10`,
                    }}
                    transition={{ type: 'spring', stiffness: 350, damping: 30 }}
                  />
                )}

                {/* Active Left Accent Bar */}
                {isActive && (
                  <motion.div
                    layoutId={`sidebar-accent-bar-${portalType}`}
                    className="absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-4 rounded-r-full"
                    style={{ background: accentColor, boxShadow: `0 0 10px ${accentColor}80` }}
                    transition={{ type: 'spring', stiffness: 350, damping: 30 }}
                  />
                )}

                <motion.span
                  className="relative z-10 shrink-0"
                  whileHover={reduce ? undefined : { scale: 1.15, rotate: -4 }}
                  whileTap={{ scale: 0.9 }}
                  style={isActive ? { filter: `drop-shadow(0 0 4px ${accentColor}60)` } : {}}
                >
                  <Icon className={`w-4 h-4 ${collapsed ? '' : 'mr-3'} ${isActive ? 'text-white' : 'text-[#52525b] group-hover:text-[#71717a]'}`} />
                </motion.span>

                <AnimatePresence>
                  {!collapsed && (
                    <motion.span
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      exit={{ opacity: 0 }}
                      transition={{ duration: 0.15 }}
                      className="relative z-10 whitespace-nowrap"
                    >
                      {item.label}
                    </motion.span>
                  )}
                </AnimatePresence>

                {isActive && !collapsed && (
                  <ChevronRight
                    className="relative z-10 w-3 h-3 ml-auto shrink-0"
                    style={{ color: accentColor }}
                  />
                )}
              </Link>
            </motion.div>
          );
        })}
      </nav>

      {/* ── Profile Section ──────────────────────────────────── */}
      {user && (
        <div className="px-4 py-3.5 border-t border-white/[0.05]">
          <div className={`flex items-center ${collapsed ? 'justify-center' : 'space-x-3'}`}>
            <div className="relative shrink-0">
              <div className="w-9 h-9 rounded-full overflow-hidden border-2 transition-all duration-300"
                style={{ borderColor: `${accentColor}40` }}>
                {profile?.avatarUrl || user.photoURL ? (
                  <img src={profile?.avatarUrl || user.photoURL!} alt="Avatar" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-white/[0.03]">
                    <UserIcon className="w-4 h-4 text-[#52525b]" />
                  </div>
                )}
              </div>
              <span
                className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-[#09090b]"
                style={{ background: '#10b981' }}
              />
            </div>
            <AnimatePresence>
              {!collapsed && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.2 }}
                  className="flex-1 min-w-0"
                >
                  <p className="text-xs font-bold text-white truncate">
                    {profile?.displayName || profile?.name || user.displayName || (portalType === 'admin' ? 'Admin' : 'Creator')}
                  </p>
                  <p className="text-[10px] text-[#52525b] truncate font-medium">
                    {user.email}
                  </p>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>
      )}

      {/* ── Sign Out ─────────────────────────────────────────── */}
      <div className="p-3 border-t border-white/[0.05]">
        <motion.button
          whileHover={reduce ? undefined : { x: 2 }}
          whileTap={{ scale: 0.97 }}
          onClick={handleSignOut}
          className={`flex items-center w-full px-3.5 py-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-[#ef4444]/80 rounded-xl border border-white/[0.04] hover:bg-[#ef4444]/5 hover:border-[#ef4444]/15 transition-all duration-250 cursor-pointer ${collapsed ? 'justify-center' : ''}`}
          title={collapsed ? 'Sign Out' : undefined}
        >
          <LogOut className={`w-4 h-4 shrink-0 ${collapsed ? '' : 'mr-3'}`} />
          {!collapsed && <span>Sign Out</span>}
        </motion.button>
      </div>
    </motion.aside>
  );
};
