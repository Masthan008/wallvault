'use client';

import React, { useEffect, useState } from 'react';
import { DollarSign, Download, Users, UsersRound, Image as ImageIcon, Wallet, Loader2 } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';

const weeklyRevenue = [
  { name: 'Mon', revenue: 1200 },
  { name: 'Tue', revenue: 1500 },
  { name: 'Wed', revenue: 2200 },
  { name: 'Thu', revenue: 1800 },
  { name: 'Fri', revenue: 3200 },
  { name: 'Sat', revenue: 4100 },
  { name: 'Sun', revenue: 3700 },
];

export default function AdminOverview() {
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [totalDownloads, setTotalDownloads] = useState(0);
  const [activeUsers, setActiveUsers] = useState(0);
  const [registeredCreators, setRegisteredCreators] = useState(0);
  const [totalWallpapers, setTotalWallpapers] = useState(0);
  const [pendingPayouts, setPendingPayouts] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // 1. Listen to wallpapers for downloads count, wallpapers count, and revenue
    const unsubWallpapers = onSnapshot(collection(db, 'wallpapers'), (snapshot) => {
      let downloadsSum = 0;
      let revenueSum = 0;
      
      snapshot.forEach((doc) => {
        const data = doc.data();
        const downloadsNum = data.downloads || 0;
        const priceNum = data.price || 0;
        downloadsSum += downloadsNum;
        revenueSum += (downloadsNum * priceNum);
      });

      setTotalWallpapers(snapshot.size);
      setTotalDownloads(downloadsSum);
      setTotalRevenue(revenueSum);
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
      setRegisteredCreators(creatorsCount || 1); // default fallback
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
      setLoading(false);
    }, (error) => {
      console.error(error);
      setLoading(false);
    });

    return () => {
      unsubWallpapers();
      unsubUsers();
      unsubPayouts();
    };
  }, []);

  if (loading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-[#00D4FF]" />
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-white">Admin Control Center</h1>
        <p className="mt-1 text-sm text-[#8B8B9E]">Overview of platform traffic, moderations, payouts, and revenue metrics in real-time.</p>
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
      <div className="bg-[#12121A] border border-[#1A1A24] p-6 rounded-2xl space-y-4">
        <h3 className="text-lg font-bold text-white">Weekly Revenue Growth (INR)</h3>
        <div className="h-80 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={weeklyRevenue}>
              <defs>
                <linearGradient id="colorAdminRev" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#b829dd" stopOpacity={0.4}/>
                  <stop offset="95%" stopColor="#b829dd" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#22222e" />
              <XAxis dataKey="name" stroke="#8b8b9e" />
              <YAxis stroke="#8b8b9e" />
              <Tooltip
                contentStyle={{ backgroundColor: '#1a1a24', border: '1px solid #22222e', borderRadius: 8 }}
                labelStyle={{ color: '#fff' }}
              />
              <Area type="monotone" dataKey="revenue" stroke="#b829dd" fillOpacity={1} fill="url(#colorAdminRev)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
