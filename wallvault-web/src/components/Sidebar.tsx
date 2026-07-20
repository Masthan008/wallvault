'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LucideIcon, Image as ImageIcon, LogOut } from 'lucide-react';

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

  const activeColor = portalType === 'admin' 
    ? 'text-accent-cyan bg-accent-cyan/10 border-accent-cyan' 
    : 'text-accent-purple bg-accent-purple/10 border-accent-purple';

  return (
    <aside className="fixed inset-y-0 left-0 z-20 flex flex-col w-64 border-r border-bg-elevated bg-bg-secondary text-text-primary">
      {/* Brand Header */}
      <div className="flex items-center h-16 px-6 border-b border-bg-elevated">
        <Link href="/" className="flex items-center space-x-2.5">
          <div className={`p-1.5 rounded-lg text-white bg-gradient-to-tr ${
            portalType === 'admin' 
              ? 'from-accent-cyan to-accent-success' 
              : 'from-accent-purple to-accent-cyan'
          }`}>
            <ImageIcon className="w-5 h-5" />
          </div>
          <span className="text-lg font-bold tracking-tight text-text-primary">
            {title}
          </span>
        </Link>
      </div>

      {/* Nav Items */}
      <nav className="flex-1 px-4 py-6 space-y-1.5 overflow-y-auto">
        {items.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center px-4 py-3 text-sm font-medium border-l-2 rounded-r-xl transition-all duration-200 ${
                isActive
                  ? activeColor
                  : 'border-transparent text-text-secondary hover:text-text-primary hover:bg-bg-elevated/40'
              }`}
            >
              <item.icon className="w-5 h-5 mr-3" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-bg-elevated">
        <button
          onClick={() => {
            // TODO: Sign out
          }}
          className="flex items-center w-full px-4 py-3 text-sm font-medium text-accent-error rounded-xl hover:bg-accent-error/10 transition-colors"
        >
          <LogOut className="w-5 h-5 mr-3" />
          Sign Out
        </button>
      </div>
    </aside>
  );
};
