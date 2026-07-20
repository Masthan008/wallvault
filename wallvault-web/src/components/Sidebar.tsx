'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { LucideIcon, Image as ImageIcon, LogOut, User as UserIcon } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';

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

  const activeColor = portalType === 'admin' 
    ? 'text-white bg-white/[0.04] border-white shadow-sm' 
    : 'text-white bg-white/[0.04] border-white shadow-sm';

  return (
    <aside className="fixed inset-y-0 left-0 z-20 flex flex-col w-64 border-r border-border-glass bg-[#09090b] text-text-primary">
      {/* Brand Header */}
      <div className="flex items-center h-20 px-6 border-b border-border-glass">
        <Link href="/" className="flex items-center space-x-3 group">
          <div className="p-2.5 rounded-lg bg-white/[0.02] border border-white/[0.08] text-white">
            <svg width="18" height="18" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke="#fafafa" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 16L15 19L20 13" stroke="#fafafa" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <div className="flex flex-col">
            <span className="text-sm font-bold tracking-tight text-white">
              {title}
            </span>
            <span className="text-[9px] uppercase tracking-widest text-text-muted font-bold">
              {portalType} console
            </span>
          </div>
        </Link>
      </div>


      {/* Nav Items */}
      <nav className="flex-1 px-4 py-8 space-y-2 overflow-y-auto">
        {items.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center px-4 py-3.5 text-xs font-bold uppercase tracking-wider transition-all duration-200 border-l-2 rounded-r-lg relative overflow-hidden group ${
                isActive
                  ? 'border-white text-white bg-white/[0.03]'
                  : 'border-transparent text-text-secondary hover:text-text-primary hover:bg-white/[0.01]'
              }`}
            >
              <item.icon className={`w-4 h-4 mr-3 transition-transform duration-200 group-hover:scale-105 ${
                isActive ? 'text-white' : 'text-text-muted'
              }`} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Profile details */}
      {user && (
        <div className="px-6 py-4 border-t border-border-glass flex items-center space-x-3 bg-white/[0.01]">
          <div className="w-8 h-8 rounded-full bg-white/[0.03] border border-white/[0.08] flex items-center justify-center text-text-secondary overflow-hidden">
            {profile?.avatarUrl || user.photoURL ? (
              <img src={profile?.avatarUrl || user.photoURL} alt="Avatar" className="w-full h-full object-cover" />
            ) : (
              <UserIcon className="w-3.5 h-3.5 text-text-muted" />
            )}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-bold text-text-primary truncate">
              {profile?.displayName || profile?.name || user.displayName || (portalType === 'admin' ? 'Admin' : 'Creator')}
            </p>
            <p className="text-[10px] text-text-muted truncate">
              {user.email}
            </p>
          </div>
        </div>
      )}

      {/* Footer */}
      <div className="p-4 border-t border-border-glass">
        <button
          onClick={handleSignOut}
          className="flex items-center w-full px-4 py-3 text-xs font-bold uppercase tracking-wider text-accent-error/95 rounded-lg border border-border-glass hover:bg-accent-error/5 transition-all duration-200 cursor-pointer"
        >
          <LogOut className="w-4 h-4 mr-3" />
          Sign Out
        </button>
      </div>
    </aside>
  );
};


