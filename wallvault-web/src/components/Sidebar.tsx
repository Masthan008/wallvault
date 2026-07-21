'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { LucideIcon, LogOut, User as UserIcon, ChevronRight } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { motion, AnimatePresence } from 'framer-motion';

interface SidebarItem {
  label: string;
  href: string;
  icon: LucideIcon;
}

interface SidebarProps {
  title: string;
  items: SidebarItem[];
  portalType: 'creator' | 'admin';
}

export const Sidebar: React.FC<SidebarProps> = ({ title, items, portalType }) => {
  const pathname = usePathname();
  const router = useRouter();
  const { user, profile, logout } = useAuth();

  const handleSignOut = async () => {
    try {
      await logout();
      router.push('/login');
    } catch (err) {
      console.error('Failed to logout', err);
    }
  };

  const accentColor = portalType === 'admin' ? '#06b6d4' : '#a855f7';

  return (
    <aside className="fixed inset-y-0 left-0 z-20 flex flex-col w-64 glass-morphism-strong">
      {/* ── Brand Header ─────────────────────────────────────── */}
      <div className="flex items-center h-[72px] px-5 border-b border-white/[0.06]">
        <Link href="/" className="flex items-center space-x-3 group">
          <motion.div
            whileHover={{ rotate: [0, -8, 8, 0], scale: 1.08 }}
            transition={{ duration: 0.5 }}
            className="relative p-2 rounded-xl border border-white/[0.08]"
            style={{ background: `${accentColor}10` }}
          >
            <svg width="20" height="20" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke={accentColor} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 16L15 19L20 13" stroke={accentColor} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            {/* Ambient glow dot */}
            <div
              className="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full animate-pulse"
              style={{ background: accentColor, boxShadow: `0 0 8px ${accentColor}` }}
            />
          </motion.div>
          <div className="flex flex-col">
            <span className="text-[13px] font-bold tracking-tight text-white">
              {title}
            </span>
            <span className="text-[9px] uppercase tracking-[0.2em] font-semibold"
              style={{ color: accentColor }}>
              {portalType} console
            </span>
          </div>
        </Link>
      </div>

      {/* ── Navigation Items ─────────────────────────────────── */}
      <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto">
        {items.map((item, idx) => {
          const isActive = pathname === item.href;
          return (
            <motion.div
              key={item.href}
              initial={{ opacity: 0, x: -12 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.04, duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
            >
              <Link
                href={item.href}
                className={`group relative flex items-center px-3.5 py-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] rounded-xl transition-all duration-250 overflow-hidden ${
                  isActive
                    ? 'text-white'
                    : 'text-[#71717a] hover:text-[#a1a1aa] hover:bg-white/[0.02]'
                }`}
              >
                {/* Active Background Fill */}
                {isActive && (
                  <motion.div
                    layoutId="sidebar-active-bg"
                    className="absolute inset-0 rounded-xl"
                    style={{
                      background: `linear-gradient(135deg, ${accentColor}12, ${accentColor}06)`,
                      border: `1px solid ${accentColor}25`,
                    }}
                    transition={{ type: 'spring', stiffness: 350, damping: 30 }}
                  />
                )}

                {/* Active Left Accent Bar */}
                {isActive && (
                  <motion.div
                    layoutId="sidebar-accent-bar"
                    className="absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-4 rounded-r-full"
                    style={{ background: accentColor, boxShadow: `0 0 10px ${accentColor}80` }}
                    transition={{ type: 'spring', stiffness: 350, damping: 30 }}
                  />
                )}

                <item.icon className={`relative z-10 w-4 h-4 mr-3 transition-all duration-200 ${
                  isActive ? 'text-white' : 'text-[#52525b] group-hover:text-[#71717a]'
                }`}
                  style={isActive ? { filter: `drop-shadow(0 0 4px ${accentColor}60)` } : {}}
                />
                <span className="relative z-10">{item.label}</span>
                
                {isActive && (
                  <ChevronRight className="relative z-10 w-3 h-3 ml-auto" style={{ color: accentColor }} />
                )}
              </Link>
            </motion.div>
          );
        })}
      </nav>

      {/* ── Profile Section ──────────────────────────────────── */}
      {user && (
        <div className="px-4 py-3.5 border-t border-white/[0.05]">
          <div className="flex items-center space-x-3">
            <div className="relative">
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
              {/* Online Indicator */}
              <div
                className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-[#09090b]"
                style={{ background: '#10b981' }}
              />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-bold text-white truncate">
                {profile?.displayName || profile?.name || user.displayName || (portalType === 'admin' ? 'Admin' : 'Creator')}
              </p>
              <p className="text-[10px] text-[#52525b] truncate font-medium">
                {user.email}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* ── Sign Out ─────────────────────────────────────────── */}
      <div className="p-3 border-t border-white/[0.05]">
        <motion.button
          whileHover={{ x: 2 }}
          whileTap={{ scale: 0.97 }}
          onClick={handleSignOut}
          className="flex items-center w-full px-3.5 py-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-[#ef4444]/80 rounded-xl border border-white/[0.04] hover:bg-[#ef4444]/5 hover:border-[#ef4444]/15 transition-all duration-250 cursor-pointer"
        >
          <LogOut className="w-4 h-4 mr-3" />
          Sign Out
        </motion.button>
      </div>
    </aside>
  );
};
