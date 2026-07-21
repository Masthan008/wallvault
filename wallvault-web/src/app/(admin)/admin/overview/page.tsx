'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Users, UsersRound, Image as ImageIcon, Wallet, Activity, TrendingUp } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, BarChart, Bar } from 'recharts';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';
import { motion } from 'framer-motion';

interface ChartPoint {
  name: string;
  revenue: number;
}

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

  return (
    <div className="space-y-8">
      {/* ── Header ─────────────────────────────────────────── */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <div className="flex items-center gap-3 mb-1">
          <div className="w-2 h-2 rounded-full bg-[#10b981] animate-pulse" />
          <span className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#10b981]">Live</span>
        </div>
        <h1 className="text-3xl font-black tracking-tight text-white">Admin Control Center</h1>
        <p className="mt-1 text-xs text-[#52525b] font-medium">
          Platform-wide metrics, moderation, and real-time analytics.
        </p>
      </motion.div>

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
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.45 }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white">Weekly Revenue</h3>
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
                <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} />
                <YAxis stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#09090b', border: '1px solid #27272a', borderRadius: 12, fontSize: 12 }}
                  labelStyle={{ color: '#fff', fontWeight: 700 }}
                  formatter={(val) => [`₹${val}`, 'Revenue']}
                />
                <Area type="monotone" dataKey="revenue" stroke="#a855f7" strokeWidth={2} fillOpacity={1} fill="url(#colorAdminRev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Downloads by Category Chart */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5, duration: 0.45 }}
          className="glass-panel p-5 rounded-2xl space-y-4"
        >
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white">Downloads by Category</h3>
            <div className="flex items-center gap-1.5 text-[9px] font-bold uppercase tracking-wider text-[#52525b]">
              <Activity className="w-3 h-3" />
              Live
            </div>
          </div>
          <div className="h-64 w-full">
            {downloadsChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={downloadsChartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#18181b" />
                  <XAxis dataKey="name" stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} />
                  <YAxis stroke="#52525b" tick={{ fontSize: 10 }} tickLine={false} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#09090b', border: '1px solid #27272a', borderRadius: 12, fontSize: 12 }}
                    labelStyle={{ color: '#fff', fontWeight: 700 }}
                  />
                  <Bar dataKey="downloads" fill="#06b6d4" radius={[6, 6, 0, 0]} />
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
    </div>
  );
}
