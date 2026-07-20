'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/components/AuthProvider';
import { Image as ImageIcon, Palette, Shield, Chrome } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const { loginWithEmail, loginWithGoogle, isAdmin, isCreator, user } = useAuth();
  const [role, setRole] = useState<'creator' | 'admin'>('creator');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    setError('');

    try {
      await loginWithEmail(email, password);
      // Wait a brief moment to allow AuthProvider to fetch role
      setTimeout(() => {
        if (role === 'admin') {
          router.push('/admin/overview');
        } else {
          router.push('/creator/dashboard');
        }
      }, 800);
    } catch (err: any) {
      setError(err.message || 'Failed to authenticate. Please check your credentials.');
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    setError('');
    try {
      await loginWithGoogle();
      setTimeout(() => {
        router.push('/creator/dashboard');
      }, 800);
    } catch (err: any) {
      setError(err.message || 'Google authentication failed.');
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-[#0A0A0F] text-white px-4">
      <div className="max-w-md w-full p-8 bg-[#12121A] border border-[#1A1A24] rounded-2xl shadow-2xl space-y-6">
        
        {/* App Logo */}
        <div className="flex flex-col items-center text-center space-y-2">
          <div className="p-3 rounded-2xl bg-gradient-to-tr from-[#B829DD] to-[#00D4FF] shadow-[0_0_20px_rgba(184,41,221,0.3)]">
            <ImageIcon className="w-8 h-8 text-white" />
          </div>
          <h2 className="text-3xl font-extrabold tracking-tight bg-gradient-to-r from-white to-[#8B8B9E] bg-clip-text text-transparent">
            WallVault
          </h2>
          <p className="text-xs text-[#8B8B9E]">Marketplace Control Console</p>
        </div>

        {/* Tab Selection */}
        <div className="grid grid-cols-2 p-1 bg-[#0A0A0F] rounded-xl border border-[#1A1A24]">
          <button
            onClick={() => setRole('creator')}
            className={`flex items-center justify-center py-2.5 rounded-lg font-bold text-sm transition-all duration-300 ${
              role === 'creator'
                ? 'bg-[#1A1A24] text-white shadow-md'
                : 'text-[#8B8B9E] hover:text-white'
            }`}
          >
            <Palette className="w-4 h-4 mr-2" />
            Creator Hub
          </button>
          <button
            onClick={() => setRole('admin')}
            className={`flex items-center justify-center py-2.5 rounded-lg font-bold text-sm transition-all duration-300 ${
              role === 'admin'
                ? 'bg-[#1A1A24] text-white shadow-md'
                : 'text-[#8B8B9E] hover:text-white'
            }`}
          >
            <Shield className="w-4 h-4 mr-2" />
            Admin Console
          </button>
        </div>

        {/* Error Callout */}
        {error && (
          <div className="p-4 bg-red-950/20 border border-red-500/50 rounded-xl text-red-400 text-sm">
            {error}
          </div>
        )}

        {/* Forms */}
        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="name@wallvault.com"
              className="mt-2 w-full px-4 py-3 bg-[#0A0A0F] border border-[#1A1A24] rounded-xl text-white focus:border-[#B829DD] focus:outline-none transition-colors"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#8B8B9E]">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="mt-2 w-full px-4 py-3 bg-[#0A0A0F] border border-[#1A1A24] rounded-xl text-white focus:border-[#B829DD] focus:outline-none transition-colors"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3.5 bg-gradient-to-r from-[#B829DD] to-[#00D4FF] hover:opacity-90 transition-opacity font-bold rounded-xl shadow-lg mt-6"
          >
            {loading ? 'Authenticating...' : `Enter ${role === 'admin' ? 'Admin Panel' : 'Creator Panel'}`}
          </button>
        </form>

        {/* Google sign-in (Creator only) */}
        {role === 'creator' && (
          <div className="space-y-4 pt-4 border-t border-[#1A1A24]">
            <button
              onClick={handleGoogleLogin}
              disabled={loading}
              className="w-full flex items-center justify-center py-3 bg-[#1A1A24] border border-[#1A1A24] hover:bg-[#20202D] rounded-xl transition-colors font-semibold text-sm"
            >
              <Chrome className="w-4 h-4 mr-2 text-[#00D4FF]" />
              Sign in with Google
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
