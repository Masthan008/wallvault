'use client';

import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';

const mockDailyDownloads = [
  { name: 'Mon', downloads: 140 },
  { name: 'Tue', downloads: 220 },
  { name: 'Wed', downloads: 180 },
  { name: 'Thu', downloads: 260 },
  { name: 'Fri', downloads: 290 },
  { name: 'Sat', downloads: 380 },
  { name: 'Sun', downloads: 310 },
];

const mockEarnings = [
  { name: 'May', earnings: 2400 },
  { name: 'Jun', earnings: 4800 },
  { name: 'Jul', earnings: 12450 },
];

export default function CreatorAnalytics() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Analytics</h1>
        <p className="mt-1 text-sm text-text-secondary">Analyze your portfolio traffic, download stats, and revenue trends.</p>
      </div>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
        {/* Downloads Chart */}
        <div className="bg-bg-card border border-bg-elevated p-6 rounded-2xl space-y-4">
          <h3 className="text-lg font-bold text-text-primary">Downloads this Week</h3>
          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={mockDailyDownloads}>
                <CartesianGrid strokeDasharray="3 3" stroke="#22222e" />
                <XAxis dataKey="name" stroke="#8b8b9e" />
                <YAxis stroke="#8b8b9e" />
                <Tooltip
                  contentStyle={{ backgroundColor: '#1a1a24', border: '1px solid #22222e', borderRadius: 8 }}
                  labelStyle={{ color: '#fff' }}
                />
                <Bar dataKey="downloads" fill="#b829dd" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Revenue Chart */}
        <div className="bg-bg-card border border-bg-elevated p-6 rounded-2xl space-y-4">
          <h3 className="text-lg font-bold text-text-primary">Monthly Revenue (INR)</h3>
          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={mockEarnings}>
                <defs>
                  <linearGradient id="colorEarnings" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00d4ff" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="#00d4ff" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#22222e" />
                <XAxis dataKey="name" stroke="#8b8b9e" />
                <YAxis stroke="#8b8b9e" />
                <Tooltip
                  contentStyle={{ backgroundColor: '#1a1a24', border: '1px solid #22222e', borderRadius: 8 }}
                  labelStyle={{ color: '#fff' }}
                />
                <Area type="monotone" dataKey="earnings" stroke="#00d4ff" fillOpacity={1} fill="url(#colorEarnings)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}
