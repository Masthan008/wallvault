'use client';

import React, { useEffect, useState, useMemo } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area, PieChart, Pie, Cell } from 'recharts';
import { Loader2, Download, TrendingUp, Image as ImageIcon, Star, Calendar } from 'lucide-react';
import { useAuth } from '@/components/AuthProvider';
import { KPICard } from '@/components/KPICard';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { motion, AnimatePresence } from 'framer-motion';

type DateRange = '7d' | '30d' | 'all';

interface WallpaperDoc {
  id: string;
  name: string;
  downloads: number;
  price: number;
  isPremium: boolean;
  category: string;
  rating: number;
  createdAt: { seconds: number } | null;
}

const CHART_COLORS = ['#a855f7', '#06b6d4', '#f59e0b', '#10b981', '#ef4444', '#8b5cf6'];

export default function CreatorAnalytics() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [wallpapers, setWallpapers] = useState<WallpaperDoc[]>([]);
  const [dateRange, setDateRange] = useState<DateRange>('all');

  useEffect(() => {
    if (!user) return;

    const q = query(
      collection(db, 'wallpapers'),
      where('creatorId', '==', user.uid)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items: WallpaperDoc[] = [];
      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        items.push({
          id: docSnap.id,
          name: data.name || 'Untitled',
          downloads: data.downloads || 0,
          price: data.price || 0,
          isPremium: data.isPremium || false,
          category: data.category || 'other',
          rating: data.rating || 0,
          createdAt: data.createdAt || null,
        });
      });
      setWallpapers(items);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  // ── Computed real analytics from Firebase ──────────────────
  const analytics = useMemo(() => {
    const now = Date.now();
    const msInDay = 86400000;
    const rangeMs = dateRange === '7d' ? 7 * msInDay : dateRange === '30d' ? 30 * msInDay : Infinity;

    const filtered = wallpapers.filter((w) => {
      if (!w.createdAt || rangeMs === Infinity) return true;
      return (now - w.createdAt.seconds * 1000) <= rangeMs;
    });

    const totalDownloads = filtered.reduce((sum, w) => sum + w.downloads, 0);
    const totalRevenue = filtered.reduce((sum, w) => sum + (w.isPremium ? w.downloads * w.price * 0.7 : 0), 0);
    const totalWallpapers = filtered.length;
    const avgRating = filtered.length > 0
      ? filtered.reduce((sum, w) => sum + w.rating, 0) / filtered.length
      : 0;

    // Real downloads by category (pie chart)
    const categoryMap: Record<string, number> = {};
    filtered.forEach((w) => {
      categoryMap[w.category] = (categoryMap[w.category] || 0) + w.downloads;
    });
    const categoryData = Object.entries(categoryMap)
      .map(([name, value]) => ({ name: name.charAt(0).toUpperCase() + name.slice(1), value }))
      .sort((a, b) => b.value - a.value)
      .slice(0, 6);

    // Real downloads grouped by wallpaper (bar chart - top 7)
    const topWallpapers = [...filtered]
      .sort((a, b) => b.downloads - a.downloads)
      .slice(0, 7)
      .map((w) => ({
        name: w.name.length > 12 ? w.name.slice(0, 12) + '…' : w.name,
        downloads: w.downloads,
      }));

    // Revenue by month from createdAt timestamps
    const monthlyMap: Record<string, number> = {};
    filtered.forEach((w) => {
      if (w.createdAt && w.isPremium) {
        const date = new Date(w.createdAt.seconds * 1000);
        const key = `${date.toLocaleString('default', { month: 'short' })} ${date.getFullYear()}`;
        monthlyMap[key] = (monthlyMap[key] || 0) + (w.downloads * w.price * 0.7);
      }
    });
    const revenueData = Object.entries(monthlyMap)
      .map(([name, earnings]) => ({ name, earnings: Math.round(earnings) }))
      .slice(-6);

    return { totalDownloads, totalRevenue, totalWallpapers, avgRating, categoryData, topWallpapers, revenueData };
  }, [wallpapers, dateRange]);

  if (loading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-[#a855f7]" />
      </div>
    );
  }

  const dateRangeOptions: { key: DateRange; label: string }[] = [
    { key: '7d', label: 'Last 7 days' },
    { key: '30d', label: 'Last 30 days' },
    { key: 'all', label: 'All time' },
  ];

  return (
    <div className="space-y-8">
      {/* ── Header ─────────────────────────────────────────── */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        className="flex flex-col sm:flex-row sm:items-end justify-between gap-4"
      >
        <div>
          <h1 className="text-3xl font-black tracking-tight text-white">Analytics</h1>
          <p className="mt-1 text-xs text-[#52525b] font-medium">
            Real-time portfolio insights from your uploaded wallpapers.
          </p>
        </div>
        {/* Date Range Filter */}
        <div className="flex gap-1.5 p-1 bg-white/[0.02] border border-white/[0.06] rounded-xl">
          {dateRangeOptions.map((opt) => (
            <button
              key={opt.key}
              onClick={() => setDateRange(opt.key)}
              className={`px-3 py-1.5 text-[10px] font-bold uppercase tracking-wider rounded-lg transition-all duration-200 cursor-pointer ${
                dateRange === opt.key
                  ? 'bg-[#a855f7]/12 text-[#a855f7] border border-[#a855f7]/20'
                  : 'text-[#52525b] hover:text-[#a1a1aa] border border-transparent'
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </motion.div>

      {/* ── KPI Cards ──────────────────────────────────────── */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <KPICard label="Total Downloads" value={analytics.totalDownloads} icon={Download} glowColor="purple" index={0} />
        <KPICard label="Revenue (INR)" value={`₹${Math.round(analytics.totalRevenue)}`} icon={TrendingUp} glowColor="cyan" index={1} />
        <KPICard label="Wallpapers" value={analytics.totalWallpapers} icon={ImageIcon} glowColor="gold" index={2} />
        <KPICard label="Avg Rating" value={analytics.avgRating.toFixed(1)} icon={Star} glowColor="purple" index={3} />
      </div>

      {/* ── Charts Row ─────────────────────────────────────── */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Top Wallpapers Bar Chart */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.45 }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white">Top Wallpapers by Downloads</h3>
            <span className="text-[9px] font-bold uppercase tracking-wider text-[#52525b]">
              {analytics.topWallpapers.length} items
            </span>
          </div>
          <div className="h-64 w-full">
            {analytics.topWallpapers.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analytics.topWallpapers}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#18181b" />
                  <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} />
                  <YAxis stroke="#52525b" tick={{ fontSize: 10 }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#09090b', border: '1px solid #27272a', borderRadius: 12, fontSize: 12 }}
                    labelStyle={{ color: '#fff', fontWeight: 700 }}
                    itemStyle={{ color: '#a1a1aa' }}
                  />
                  <Bar dataKey="downloads" fill="#a855f7" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex items-center justify-center h-full text-[#3f3f46] text-xs font-semibold">
                No download data yet
              </div>
            )}
          </div>
        </motion.div>

        {/* Revenue Area Chart */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.45 }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white">Monthly Revenue (70% Share)</h3>
            <span className="text-[9px] font-bold uppercase tracking-wider text-[#52525b]">INR</span>
          </div>
          <div className="h-64 w-full">
            {analytics.revenueData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={analytics.revenueData}>
                  <defs>
                    <linearGradient id="colorEarnings" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#06b6d4" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#06b6d4" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#18181b" />
                  <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} />
                  <YAxis stroke="#52525b" tick={{ fontSize: 10 }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#09090b', border: '1px solid #27272a', borderRadius: 12, fontSize: 12 }}
                    labelStyle={{ color: '#fff', fontWeight: 700 }}
                    formatter={(val) => [`₹${val}`, 'Revenue']}
                  />
                  <Area type="monotone" dataKey="earnings" stroke="#06b6d4" strokeWidth={2} fillOpacity={1} fill="url(#colorEarnings)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex items-center justify-center h-full text-[#3f3f46] text-xs font-semibold">
                No revenue data yet — upload premium wallpapers!
              </div>
            )}
          </div>
        </motion.div>

        {/* Category Distribution Pie Chart */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5, duration: 0.45 }}
          className="glass-panel p-5 rounded-2xl space-y-4 lg:col-span-2"
        >
          <h3 className="text-sm font-bold text-white">Downloads by Category</h3>
          <div className="flex flex-col sm:flex-row items-center gap-6">
            <div className="h-56 w-56">
              {analytics.categoryData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={analytics.categoryData}
                      cx="50%"
                      cy="50%"
                      innerRadius={50}
                      outerRadius={80}
                      dataKey="value"
                      stroke="none"
                    >
                      {analytics.categoryData.map((_, idx) => (
                        <Cell key={idx} fill={CHART_COLORS[idx % CHART_COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip
                      contentStyle={{ backgroundColor: '#09090b', border: '1px solid #27272a', borderRadius: 12, fontSize: 12 }}
                      labelStyle={{ color: '#fff' }}
                    />
                  </PieChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex items-center justify-center h-full text-[#3f3f46] text-xs font-semibold">
                  No category data
                </div>
              )}
            </div>
            <div className="flex flex-wrap gap-3">
              {analytics.categoryData.map((cat, idx) => (
                <div key={cat.name} className="flex items-center gap-2 px-3 py-1.5 bg-white/[0.02] border border-white/[0.05] rounded-lg">
                  <div className="w-2.5 h-2.5 rounded-full" style={{ background: CHART_COLORS[idx % CHART_COLORS.length] }} />
                  <span className="text-[11px] font-semibold text-[#a1a1aa]">{cat.name}</span>
                  <span className="text-[10px] font-bold text-white">{cat.value}</span>
                </div>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
