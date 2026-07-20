'use client';

import React from 'react';
import { DollarSign, Download, Users, UsersRound, Image as ImageIcon, Wallet } from 'lucide-react';
import { KPICard } from '@/components/KPICard';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';

const mockWeeklyRevenue = [
  { name: 'Mon', revenue: 12000 },
  { name: 'Tue', revenue: 15400 },
  { name: 'Wed', revenue: 11200 },
  { name: 'Thu', revenue: 18900 },
  { name: 'Fri', revenue: 22400 },
  { name: 'Sat', revenue: 31000 },
  { name: 'Sun', revenue: 27500 },
];

export default function AdminOverview() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Admin Control Center</h1>
        <p className="mt-1 text-sm text-text-secondary">Overview of platform traffic, moderations, payouts, and revenue metrics.</p>
      </div>

      {/* 6 KPIs Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <KPICard
          label="Platform Revenue"
          value="₹1,24,500"
          icon={DollarSign}
          trend={{ value: 18.2, isPositive: true }}
          glowColor="gold"
        />
        <KPICard
          label="Total Downloads"
          value="3,45,200"
          icon={Download}
          trend={{ value: 9.4, isPositive: true }}
          glowColor="purple"
        />
        <KPICard
          label="Active Users"
          value="45,820"
          icon={Users}
          trend={{ value: 14.8, isPositive: true }}
          glowColor="cyan"
        />
        <KPICard
          label="Registered Creators"
          value="1,240"
          icon={UsersRound}
          trend={{ value: 4.5, isPositive: true }}
        />
        <KPICard
          label="Total Wallpapers"
          value="18,920"
          icon={ImageIcon}
        />
        <KPICard
          label="Pending Payouts"
          value="₹12,450"
          icon={Wallet}
          trend={{ value: 2.1, isPositive: false }}
        />
      </div>

      {/* Revenue chart */}
      <div className="bg-bg-card border border-bg-elevated p-6 rounded-2xl space-y-4">
        <h3 className="text-lg font-bold text-text-primary">Weekly Revenue Growth (INR)</h3>
        <div className="h-80 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={mockWeeklyRevenue}>
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
