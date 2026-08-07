'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Users, UsersRound, Image as ImageIcon, Wallet, Activity, TrendingUp } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, BarChart, Bar } from 'recharts';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { LiveDot } from '@/components/motion/LiveDot';
import { StaggerGroup } from '@/components/motion/Reveal';

interface ChartPoint {
  name: string;
  revenue: number;
}

const EASE = [0.16, 1, 0.3, 1] as const;

export default function AdminOverview() {
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [totalDownloads, setTotalDownloads] = useState(0);
  const [activeUsers, setActiveUsers] = useState(0);
  const [registeredCreators, setRegisteredCreators] = useState(0);
  const [totalWallpapers, setTotalWallpapers] = useState(0);
  const [pendingPayouts, setPendingPayouts] = useState(0);
  const [chartData, setChartData] = useState<ChartPoint[]>([]);
  const [downloadsChartData, setDownloadsChartData] = useState<{ name: string; downloads: number }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // 1. Listen to wallpapers
    const unsubWallpapers = onSnapshot(collection(db, 'wallpapers'), (snapshot) => {
      let downloadsSum = 0;
      const catMap: Record<string, number> = {};
      snapshot.forEach((doc) => {
        const data = doc.data();
        const d = data.downloads || 0;
        downloadsSum += d;
        const cat = data.category || 'other';
        catMap[cat] = (catMap[cat] || 0) + d;
      });
      setTotalWallpapers(snapshot.size);
      setTotalDownloads(downloadsSum);
      setDownloadsChartData(
        Object.entries(catMap)
          .map(([name, downloads]) => ({ name: name.charAt(0).toUpperCase() + name.slice(1), downloads }))
          .sort((a, b) => b.downloads - a.downloads)
          .slice(0, 8)
      );
    });

    // 2. Listen to users
    const unsubUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      let creatorsCount = 0;
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.isCreator === true || data.role === 'creator') creatorsCount++;
      });
      setActiveUsers(snapshot.size);
      setRegisteredCreators(creatorsCount || 1);
    });

    // 3. Listen to payouts
    const unsubPayouts = onSnapshot(collection(db, 'payouts'), (snapshot) => {
      let pendingSum = 0;
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.status === 'pending') pendingSum += (data.amount || 0);
      });
      setPendingPayouts(pendingSum);
    });

    // 4. Listen to transactions
    const unsubTransactions = onSnapshot(collection(db, 'transactions'), (snapshot) => {
      let revenueSum = 0;
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const revenueByDay: Record<string, number> = {
        'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0
      };
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.status === 'completed' || data.status === 'success' || !data.status) {
          const amt = data.amount || 0;
          revenueSum += amt;
          const date = data.createdAt ? new Date(data.createdAt.seconds * 1000) : new Date();
          const dayName = days[date.getDay()];
          if (dayName in revenueByDay) revenueByDay[dayName] += amt;
        }
      });
      setTotalRevenue(revenueSum);
      const orderedWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      setChartData(orderedWeek.map((day) => ({ name: day, revenue: revenueByDay[day] || 0 })));
      setLoading(false);
    }, () => setLoading(false));

    return () => { unsubWallpapers(); unsubUsers(); unsubPayouts(); unsubTransactions(); };
  }, []);

  if (loading) {
    return (
      <div className="space-y-6">
        <SkeletonLoader variant="card" count={3} />
        <SkeletonLoader variant="table" />
      </div>
    );
  }

  const tooltipStyle = {
    backgroundColor: 'rgba(9,9,11,0.92)',
    border: '1px solid #27272a',
    borderRadius: 12,
    fontSize: 12,
    backdropFilter: 'blur(8px)',
  };

  return (
    <div className="space-y-8">
      {/* ── Header ─────────────────────────────────────────── */}
      <PageHeader
        badge="Live"
        badgeColor="#10b981"
        title="Admin Control Center"
        subtitle="Platform-wide metrics, moderation, and real-time analytics."
        actions={
          <div className="flex items-center gap-2 px-3 py-2 rounded-xl border border-white/[0.06] bg-white/[0.02]">
            <LiveDot color="#10b981" size={7} />
            <span className="text-[9px] font-bold uppercase tracking-[0.15em] text-[#10b981]">
              Real-time sync
            </span>
          </div>
        }
      />

      {/* ── KPI Grid ───────────────────────────────────────── */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <KPICard label="Platform Revenue" value={`₹${totalRevenue}`} icon={DollarSign} glowColor="gold" index={0} />
        <KPICard label="Total Downloads" value={totalDownloads} icon={Download} glowColor="purple" index={1} />
        <KPICard label="Active Users" value={activeUsers} icon={Users} glowColor="cyan" index={2} />
        <KPICard label="Creators" value={registeredCreators} icon={UsersRound} glowColor="purple" index={3} />
        <KPICard label="Wallpapers" value={totalWallpapers} icon={ImageIcon} glowColor="gold" index={4} />
        <KPICard label="Pending Payouts" value={`₹${pendingPayouts}`} icon={Wallet} glowColor="cyan" index={5} />
      </div>

      {/* ── Charts Row ─────────────────────────────────────── */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Revenue Chart */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.6, ease: EASE }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              Weekly Revenue
              <LiveDot color="#a855f7" size={5} />
            </h3>
            <div className="flex items-center gap-1.5 text-[9px] font-bold uppercase tracking-wider text-[#52525b]">
              <TrendingUp className="w-3 h-3" />
              INR
            </div>
          </div>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="colorAdminRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#a855f7" stopOpacity={0.25}/>
                    <stop offset="95%" stopColor="#a855f7" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#18181b" />
                <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} axisLine={false} width={40} />
                <Tooltip
                  contentStyle={tooltipStyle}
                  labelStyle={{ color: '#fff', fontWeight: 700 }}
                  formatter={(val) => [`₹${val}`, 'Revenue']}
                />
                <Area
                  type="monotone"
                  dataKey="revenue"
                  stroke="#a855f7"
                  strokeWidth={2.5}
                  fillOpacity={1}
                  fill="url(#colorAdminRev)"
                  animationDuration={1200}
                  animationEasing="ease-out"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Downloads by Category Chart */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5, duration: 0.6, ease: EASE }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              Downloads by Category
              <LiveDot color="#06b6d4" size={5} />
            </h3>
            <div className="flex items-center gap-1.5 text-[9px] font-bold uppercase tracking-wider text-[#52525b]">
              <Activity className="w-3 h-3" />
              Live
            </div>
          </div>
          <div className="h-64 w-full">
            {downloadsChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={downloadsChartData}>
                  <defs>
                    <linearGradient id="colorCatBar" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#06b6d4" stopOpacity={1} />
                      <stop offset="100%" stopColor="#06b6d4" stopOpacity={0.5} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#18181b" />
                  <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} axisLine={false} />
                  <YAxis stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} axisLine={false} width={40} />
                  <Tooltip
                    contentStyle={tooltipStyle}
                    labelStyle={{ color: '#fff', fontWeight: 700 }}
                  />
                  <Bar
                    dataKey="downloads"
                    radius={[6, 6, 0, 0]}
                    fill="url(#colorCatBar)"
                    animationDuration={1200}
                    animationEasing="ease-out"
                  />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex items-center justify-center h-full text-[#3f3f46] text-xs font-semibold">
                No category data yet
              </div>
            )}
          </div>
        </motion.div>
      </div>

      {/* ── Bottom marquee strip ───────────────────────────── */}
      <StaggerGroup stagger={0.08} direction="up">
        {[
          { label: 'Total Wallpapers', value: totalWallpapers },
          { label: 'Total Downloads', value: totalDownloads },
          { label: 'Registered Creators', value: registeredCreators },
          { label: 'Active Users', value: activeUsers },
        ].map((s) => (
          <div key={s.label} className="flex items-center justify-between px-5 py-3.5 rounded-xl border border-white/[0.05] bg-white/[0.015]">
            <span className="text-[9px] font-bold uppercase tracking-[0.15em] text-[#52525b]">{s.label}</span>
            <span className="text-sm font-black text-white font-mono">{s.value}</span>
          </div>
        ))}
      </StaggerGroup>
    </div>
  );
}
