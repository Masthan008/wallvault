'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Users, UsersRound, Image as ImageIcon, Wallet, Loader2 } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { SkeletonLoader } from '@/components/SkeletonLoader';

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
  
  // Real chart data state
  const [chartData, setChartData] = useState<ChartPoint[]>([
    { name: 'Mon', revenue: 0 },
    { name: 'Tue', revenue: 0 },
    { name: 'Wed', revenue: 0 },
    { name: 'Thu', revenue: 0 },
    { name: 'Fri', revenue: 0 },
    { name: 'Sat', revenue: 0 },
    { name: 'Sun', revenue: 0 },
  ]);

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // 1. Listen to wallpapers for downloads count, wallpapers count
    const unsubWallpapers = onSnapshot(collection(db, 'wallpapers'), (snapshot) => {
      let downloadsSum = 0;
      snapshot.forEach((doc) => {
        const data = doc.data();
        downloadsSum += (data.downloads || 0);
      });
      setTotalWallpapers(snapshot.size);
      setTotalDownloads(downloadsSum);
    });

    // 2. Listen to users count and creators count
    const unsubUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      let creatorsCount = 0;
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.isCreator === true || data.role === 'creator') {
          creatorsCount++;
        }
      });
      setActiveUsers(snapshot.size);
      setRegisteredCreators(creatorsCount || 1); // fallback
    });

    // 3. Listen to payouts collection for pending payouts
    const unsubPayouts = onSnapshot(collection(db, 'payouts'), (snapshot) => {
      let pendingSum = 0;
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.status === 'pending') {
          pendingSum += (data.amount || 0);
        }
      });
      setPendingPayouts(pendingSum);
    });

    // 4. Listen to transactions to calculate total revenue and weekly chart data
    const unsubTransactions = onSnapshot(collection(db, 'transactions'), (snapshot) => {
      let revenueSum = 0;
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const revenueByDay: { [key: string]: number } = {
        'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0
      };

      snapshot.forEach((doc) => {
        const data = doc.data();
        // Sum only completed or successful purchases
        if (data.status === 'completed' || data.status === 'success' || !data.status) {
          const amt = data.amount || 0;
          revenueSum += amt;

          const date = data.createdAt ? new Date(data.createdAt.seconds * 1000) : new Date();
          const dayName = days[date.getDay()];
          if (dayName in revenueByDay) {
            revenueByDay[dayName] += amt;
          }
        }
      });

      setTotalRevenue(revenueSum);

      const orderedWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const chartPoints = orderedWeek.map((day) => ({
        name: day,
        revenue: revenueByDay[day] || 0
      }));

      setChartData(chartPoints);
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => {
      unsubWallpapers();
      unsubUsers();
      unsubPayouts();
      unsubTransactions();
    };
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
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-white">Admin Control Center</h1>
        <p className="mt-1 text-xs text-text-secondary">Overview of platform traffic, moderations, payouts, and revenue metrics in real-time.</p>
      </div>

      {/* 6 KPIs Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <KPICard
          label="Total Platform Revenue"
          value={`₹${totalRevenue}`}
          icon={DollarSign}
          glowColor="gold"
        />
        <KPICard
          label="Total Downloads"
          value={totalDownloads.toString()}
          icon={Download}
          glowColor="purple"
        />
        <KPICard
          label="Total Active Users"
          value={activeUsers.toString()}
          icon={Users}
          glowColor="cyan"
        />
        <KPICard
          label="Registered Creators"
          value={registeredCreators.toString()}
          icon={UsersRound}
        />
        <KPICard
          label="Total Wallpapers"
          value={totalWallpapers.toString()}
          icon={ImageIcon}
        />
        <KPICard
          label="Pending Payouts"
          value={`₹${pendingPayouts}`}
          icon={Wallet}
        />
      </div>

      {/* Revenue chart */}
      <div className="glass-panel p-6 rounded-2xl space-y-4">
        <h3 className="text-xs font-bold uppercase tracking-wider text-text-secondary">Weekly Revenue Growth (INR)</h3>
        <div className="h-80 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="colorAdminRev" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#a855f7" stopOpacity={0.2}/>
                  <stop offset="95%" stopColor="#a855f7" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.02)" />
              <XAxis dataKey="name" stroke="#52525b" fontSize={11} tickLine={false} />
              <YAxis stroke="#52525b" fontSize={11} tickLine={false} />
              <Tooltip
                contentStyle={{ 
                  backgroundColor: '#09090b', 
                  border: '1px solid #27272a', 
                  borderRadius: 12,
                  backdropFilter: 'blur(20px)'
                }}
                labelStyle={{ color: '#fff', fontWeight: 'bold' }}
              />
              <Area type="monotone" dataKey="revenue" stroke="#a855f7" strokeWidth={2} fillOpacity={1} fill="url(#colorAdminRev)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}


