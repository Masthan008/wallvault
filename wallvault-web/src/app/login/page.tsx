'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/components/AuthProvider';
import { Globe, Lock, Mail, User as UserIcon, Shield, CheckCircle, ShieldAlert, ArrowRight } from 'lucide-react';
import { motion, AnimatePresence, useReducedMotion } from 'framer-motion';
import { GradientButton } from '@/components/motion/GradientButton';
import { Magnetic } from '@/components/motion/Magnetic';
import { LiveDot } from '@/components/motion/LiveDot';

const EASE = [0.16, 1, 0.3, 1] as const;

export default function LoginPage() {
  const router = useRouter();
  const { loginWithEmail, loginWithGoogle } = useAuth();
  const reduce = useReducedMotion();

  const [role, setRole] = useState<'creator' | 'admin'>('creator');
  const [mode, setMode] = useState<'login' | 'register'>('login');

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [inviteCode, setInviteCode] = useState('');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      if (role === 'admin' && mode === 'register') {
        if (inviteCode.trim() !== 'adhiya@2008@') {
          throw new Error('Invalid Admin Invite Code. Registration denied.');
        }

        const { createUserWithEmailAndPassword } = await import('firebase/auth');
        const { doc, setDoc } = await import('firebase/firestore');
        const { auth, db } = await import('@/lib/firebase');

        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        await setDoc(doc(db, 'users', userCredential.user.uid), {
          name: name || 'Administrator',
          email: email,
          isAdmin: true,
          isCreator: false,
          createdAt: new Date(),
        });

        setSuccess('Admin account created successfully! Logging you in...');
        setTimeout(() => {
          router.push('/admin/overview');
        }, 1500);
      } else {
        await loginWithEmail(email, password);
        setTimeout(() => {
          if (role === 'admin') {
            router.push('/admin/overview');
          } else {
            router.push('/creator/dashboard');
          }
        }, 800);
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please verify credentials.');
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

  const accent = role === 'admin' ? '#06b6d4' : '#a855f7';

  return (
    <div className="relative min-h-screen w-full bg-bg-primary overflow-hidden flex items-center justify-center px-4 py-10">
      {/* Ambient blobs */}
      <div className="absolute top-[-15%] right-[-10%] w-[34rem] h-[34rem] rounded-full bg-accent-purple/8 blur-[130px] animate-drift pointer-events-none" />
      <div className="absolute bottom-[-15%] left-[-8%] w-[30rem] h-[30rem] rounded-full bg-accent-cyan/8 blur-[130px] animate-drift-slow pointer-events-none" />

      <motion.div
        initial={reduce ? { opacity: 0 } : { opacity: 0, y: 24, scale: 0.97 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.5, ease: EASE }}
        className="w-full max-w-4xl grid grid-cols-1 lg:grid-cols-2 rounded-3xl overflow-hidden relative z-10 border border-white/[0.07] shadow-[0_24px_80px_-24px_rgba(0,0,0,0.6)]"
      >
        {/* ── Brand Panel ─────────────────────────────────────── */}
        <div className="relative hidden lg:flex flex-col justify-between p-10 bg-gradient-to-br from-[#0d0d12] via-[#0a0a0f] to-[#050508] border-r border-white/[0.05] overflow-hidden">
          <div className="absolute top-0 right-0 w-72 h-72 rounded-full animate-aurora pointer-events-none" style={{ background: `radial-gradient(circle, ${accent}22, transparent 70%)` }} />

          <motion.div
            initial={reduce ? false : { opacity: 0, y: -14 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.5, ease: EASE }}
            className="flex items-center gap-3"
          >
            <motion.div
              whileHover={{ rotate: [0, -8, 8, 0] }}
              transition={{ duration: 0.5 }}
              className="p-2.5 rounded-xl border border-white/[0.08]"
              style={{ background: `${accent}12` }}
            >
              <svg width="22" height="22" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke={accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M12 16L15 19L20 13" stroke={accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </motion.div>
            <div>
              <p className="text-sm font-bold text-white tracking-tight">WallVault</p>
              <p className="text-[9px] uppercase tracking-[0.25em] font-semibold" style={{ color: accent }}>
                Console Access
              </p>
            </div>
          </motion.div>

          <div className="space-y-5">
            <motion.h2
              initial={reduce ? false : { opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.35, duration: 0.6, ease: EASE }}
              className="text-3xl font-extrabold tracking-tight text-white leading-tight"
            >
              Your marketplace, <br />
              <span className="text-gradient-animated">fully commanded.</span>
            </motion.h2>
            <motion.p
              initial={reduce ? false : { opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.45, duration: 0.6, ease: EASE }}
              className="text-xs text-[#71717a] leading-relaxed font-medium max-w-xs"
            >
              Real-time moderation, creator payouts, download analytics and revenue audits — all from one secure console.
            </motion.p>
          </div>

          <motion.div
            initial={reduce ? false : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6, duration: 0.6 }}
            className="space-y-3"
          >
            {[
              { label: 'Live Firestore sync across all dashboards', color: '#10b981' },
              { label: '70% creator revenue share payouts', color: '#f59e0b' },
              { label: 'Moderation queue with instant approvals', color: '#06b6d4' },
            ].map((f, i) => (
              <motion.div
                key={i}
                initial={reduce ? false : { opacity: 0, x: -12 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.7 + i * 0.1, duration: 0.4, ease: EASE }}
                className="flex items-center gap-2.5"
              >
                <LiveDot color={f.color} size={6} />
                <span className="text-[10px] font-semibold text-[#a1a1aa] tracking-wide">{f.label}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>

        {/* ── Form Panel ──────────────────────────────────────── */}
        <div className="p-8 md:p-10 bg-bg-card/80 backdrop-blur-xl space-y-6">
          {/* Mobile brand */}
          <div className="lg:hidden flex flex-col items-center text-center space-y-3">
            <div className="p-3 rounded-xl bg-white/[0.02] border border-white/[0.08]">
              <svg width="28" height="28" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke={accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M12 16L15 19L20 13" stroke={accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
            <h2 className="text-2xl font-extrabold tracking-tight text-white">WallVault</h2>
            <p className="text-[10px] uppercase tracking-widest text-text-muted font-bold">Console Sign-In</p>
          </div>

          {/* Tab Selection */}
          <div className="grid grid-cols-2 p-1 bg-white/[0.02] rounded-lg border border-white/[0.05] relative">
            <button
              onClick={() => { setRole('creator'); setMode('login'); }}
              className={`relative flex items-center justify-center py-2.5 rounded-md font-bold text-xs uppercase tracking-wider transition-colors duration-200 z-10 cursor-pointer ${
                role === 'creator' ? 'text-white' : 'text-text-muted hover:text-text-secondary'
              }`}
            >
              Creator Hub
            </button>
            <button
              onClick={() => { setRole('admin'); setMode('login'); }}
              className={`relative flex items-center justify-center py-2.5 rounded-md font-bold text-xs uppercase tracking-wider transition-colors duration-200 z-10 cursor-pointer ${
                role === 'admin' ? 'text-white' : 'text-text-muted hover:text-text-secondary'
              }`}
            >
              Admin Console
            </button>

            <motion.div
              className="absolute top-1 bottom-1 rounded-md"
              layout
              style={{
                left: role === 'creator' ? '4px' : '50%',
                right: role === 'creator' ? '50%' : '4px',
                background: `linear-gradient(135deg, ${accent}18, ${accent}08)`,
                border: `1px solid ${accent}30`,
                boxShadow: `0 0 20px ${accent}15`,
              }}
              transition={{ type: 'spring', stiffness: 320, damping: 24 }}
            />
          </div>

          {/* Mode Selector for Admin Registration */}
          <AnimatePresence>
            {role === 'admin' && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="flex justify-center gap-6 text-[10px] border-b border-white/[0.04] pb-2.5 overflow-hidden"
              >
                <button
                  type="button"
                  onClick={() => setMode('login')}
                  className={`pb-1 font-bold uppercase tracking-wider transition-colors cursor-pointer ${mode === 'login' ? 'text-white border-b border-white' : 'text-text-muted hover:text-text-secondary'}`}
                >
                  Sign In
                </button>
                <button
                  type="button"
                  onClick={() => setMode('register')}
                  className={`pb-1 font-bold uppercase tracking-wider transition-colors cursor-pointer ${mode === 'register' ? 'text-white border-b border-white' : 'text-text-muted hover:text-text-secondary'}`}
                >
                  Create Account
                </button>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Success Alert */}
          <AnimatePresence>
            {success && (
              <motion.div
                initial={{ opacity: 0, y: -8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8 }}
                className="p-3 bg-accent-success/5 border border-accent-success/15 rounded-lg text-accent-success text-xs font-medium flex items-center gap-2"
              >
                <CheckCircle className="w-4 h-4 shrink-0 animate-pulse" />
                <span>{success}</span>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Error Alert */}
          <AnimatePresence>
            {error && (
              <motion.div
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                className="p-3 bg-accent-error/5 border border-accent-error/15 rounded-lg text-accent-error text-xs font-medium flex items-center gap-2"
              >
                <ShieldAlert className="w-4 h-4 shrink-0" />
                <span>{error}</span>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Forms */}
          <form onSubmit={handleAuth} className="space-y-4">
            <AnimatePresence>
              {role === 'admin' && mode === 'register' && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  className="space-y-1 overflow-hidden"
                >
                  <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Administrator Name</label>
                  <div className="relative group">
                    <UserIcon className="absolute left-3 top-3 w-4 h-4 text-text-muted transition-colors group-focus-within:text-accent-purple" />
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder="Master Admin"
                      required
                      className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                    />
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Email Address</label>
              <div className="relative group">
                <Mail className="absolute left-3 top-3 w-4 h-4 text-text-muted transition-colors group-focus-within:text-accent-purple" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@wallvault.com"
                  required
                  className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Password</label>
              <div className="relative group">
                <Lock className="absolute left-3 top-3 w-4 h-4 text-text-muted transition-colors group-focus-within:text-accent-purple" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                />
              </div>
            </div>

            <AnimatePresence>
              {role === 'admin' && mode === 'register' && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  className="space-y-1 overflow-hidden"
                >
                  <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Invite Code</label>
                  <div className="relative group">
                    <Shield className="absolute left-3 top-3 w-4 h-4 text-text-muted transition-colors group-focus-within:text-accent-purple" />
                    <input
                      type="password"
                      value={inviteCode}
                      onChange={(e) => setInviteCode(e.target.value)}
                      placeholder="Enter secret invite key"
                      required
                      className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                    />
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            <GradientButton
              type="submit"
              disabled={loading}
              variant={role === 'admin' ? 'cyan' : 'purple'}
              size="lg"
              className="w-full mt-4"
            >
              {loading ? (
                <motion.span
                  animate={{ rotate: 360 }}
                  transition={{ duration: 0.8, repeat: Infinity, ease: 'linear' }}
                  className="inline-block w-3.5 h-3.5 border-2 border-black/40 border-t-black rounded-full"
                />
              ) : (
                <Globe className="w-4 h-4" />
              )}
              <span>{loading ? 'Processing...' : mode === 'register' ? 'Register Account' : `Enter Portal`}</span>
              {!loading && <ArrowRight className="w-3.5 h-3.5" />}
            </GradientButton>
          </form>

          {/* Google sign-in (Creator only) */}
          <AnimatePresence>
            {role === 'creator' && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="space-y-3 pt-3 border-t border-white/[0.05] overflow-hidden"
              >
                <Magnetic strength={0.15}>
                  <button
                    onClick={handleGoogleLogin}
                    disabled={loading}
                    className="w-full flex items-center justify-center py-2.5 bg-[#0e0e11] border border-white/[0.06] hover:bg-[#16161c] rounded-lg transition-all duration-200 font-bold uppercase tracking-wider text-[10px] text-white cursor-pointer group"
                  >
                    <svg className="w-3.5 h-3.5 mr-2 group-hover:rotate-180 transition-transform duration-500" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                      <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                      <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.85z" fill="#FBBC05"/>
                      <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.85c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                    </svg>
                    Sign in with Google
                  </button>
                </Magnetic>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </motion.div>
    </div>
  );
}
