'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/components/AuthProvider';
import { Globe, Lock, Mail, User as UserIcon, Shield, CheckCircle, ShieldAlert } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LoginPage() {
  const router = useRouter();
  const { loginWithEmail, loginWithGoogle } = useAuth();
  
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

  return (
    <div className="relative min-h-screen w-full bg-bg-primary overflow-hidden flex items-center justify-center px-4">
      <motion.div 
        initial={{ opacity: 0, y: 15 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
        className="max-w-md w-full p-8 glass-panel rounded-2xl space-y-6 relative z-10"
      >
        {/* SVG Vector Logo Brand */}
        <div className="flex flex-col items-center text-center space-y-3">
          <div className="p-3 rounded-xl bg-white/[0.02] border border-white/[0.08] shadow-[0_4px_20px_rgba(0,0,0,0.3)]">
            <svg width="28" height="28" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 2L4 7V15C4 22.18 9.13 28.82 16 30C22.87 28.82 28 22.18 28 15V7L16 2Z" stroke="#fafafa" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 16L15 19L20 13" stroke="#fafafa" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <h2 className="text-2xl font-extrabold tracking-tight text-white">
            WallVault
          </h2>
          <p className="text-[10px] uppercase tracking-widest text-text-muted font-bold">Console Sign-In</p>
        </div>

        {/* Tab Selection */}
        <div className="grid grid-cols-2 p-1 bg-white/[0.02] rounded-lg border border-white/[0.05] relative">
          <button
            onClick={() => { setRole('creator'); setMode('login'); }}
            className={`flex items-center justify-center py-2 rounded-md font-bold text-xs uppercase tracking-wider transition-all duration-200 z-10 ${
              role === 'creator' ? 'text-white' : 'text-text-muted hover:text-text-secondary'
            }`}
          >
            Creator Hub
          </button>
          <button
            onClick={() => { setRole('admin'); setMode('login'); }}
            className={`flex items-center justify-center py-2 rounded-md font-bold text-xs uppercase tracking-wider transition-all duration-200 z-10 ${
              role === 'admin' ? 'text-white' : 'text-text-muted hover:text-text-secondary'
            }`}
          >
            Admin Console
          </button>
          
          <motion.div
            className="absolute top-1 bottom-1 rounded-md bg-white/[0.04] border border-white/[0.06]"
            layout
            animate={{
              left: role === 'creator' ? '4px' : '50%',
              right: role === 'creator' ? '50%' : '4px',
            }}
            transition={{ type: 'spring', stiffness: 350, damping: 25 }}
          />
        </div>

        {/* Mode Selector for Admin Registration */}
        {role === 'admin' && (
          <div className="flex justify-center gap-6 text-[10px] border-b border-white/[0.04] pb-2.5">
            <button 
              type="button"
              onClick={() => setMode('login')}
              className={`pb-1 font-bold uppercase tracking-wider transition-colors ${mode === 'login' ? 'text-white border-b border-white' : 'text-text-muted hover:text-text-secondary'}`}
            >
              Sign In
            </button>
            <button 
              type="button"
              onClick={() => setMode('register')}
              className={`pb-1 font-bold uppercase tracking-wider transition-colors ${mode === 'register' ? 'text-white border-b border-white' : 'text-text-muted hover:text-text-secondary'}`}
            >
              Create Account
            </button>
          </div>
        )}

        {/* Success Alert */}
        <AnimatePresence>
          {success && (
            <motion.div 
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="p-3 bg-accent-success/5 border border-accent-success/15 rounded-lg text-accent-success text-xs font-medium flex items-center gap-2"
            >
              <CheckCircle className="w-4 h-4 shrink-0" />
              <span>{success}</span>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Error Alert */}
        <AnimatePresence>
          {error && (
            <motion.div 
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="p-3 bg-accent-error/5 border border-accent-error/15 rounded-lg text-accent-error text-xs font-medium flex items-center gap-2"
            >
              <ShieldAlert className="w-4 h-4 shrink-0" />
              <span>{error}</span>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Forms */}
        <form onSubmit={handleAuth} className="space-y-4">
          {role === 'admin' && mode === 'register' && (
            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Administrator Name</label>
              <div className="relative">
                <UserIcon className="absolute left-3 top-3 w-4 h-4 text-text-muted" />
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Master Admin"
                  required
                  className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                />
              </div>
            </div>
          )}

          <div className="space-y-1">
            <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Email Address</label>
            <div className="relative">
              <Mail className="absolute left-3 top-3 w-4 h-4 text-text-muted" />
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
            <div className="relative">
              <Lock className="absolute left-3 top-3 w-4 h-4 text-text-muted" />
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

          {role === 'admin' && mode === 'register' && (
            <div className="space-y-1">
              <label className="block text-[9px] font-bold uppercase tracking-wider text-text-muted">Invite Code</label>
              <div className="relative">
                <Shield className="absolute left-3 top-3 w-4 h-4 text-text-muted" />
                <input
                  type="password"
                  value={inviteCode}
                  onChange={(e) => setInviteCode(e.target.value)}
                  placeholder="Enter secret invite key"
                  required
                  className="w-full pl-10 pr-3 py-2.5 glass-input text-xs"
                />
              </div>
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className={`w-full py-3 bg-white text-black hover:bg-white/90 font-bold uppercase tracking-wider text-xs rounded-lg shadow mt-4 transition-all duration-200 ${
              loading ? 'opacity-50 cursor-not-allowed' : 'active:scale-98 cursor-pointer'
            }`}
          >
            {loading ? 'Processing...' : mode === 'register' ? 'Register Account' : `Enter Portal`}
          </button>
        </form>

        {/* Google sign-in (Creator only) */}
        {role === 'creator' && (
          <div className="space-y-3 pt-3 border-t border-white/[0.05]">
            <button
              onClick={handleGoogleLogin}
              disabled={loading}
              className="w-full flex items-center justify-center py-2.5 bg-[#0e0e11] border border-white/[0.06] hover:bg-[#16161c] rounded-lg transition-all duration-200 font-bold uppercase tracking-wider text-[10px] text-white cursor-pointer"
            >
              {/* Google official SVG vector icon */}
              <svg className="w-3.5 h-3.5 mr-2" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.85z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.85c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
              Sign in with Google
            </button>
          </div>
        )}
      </motion.div>
    </div>
  );
}
