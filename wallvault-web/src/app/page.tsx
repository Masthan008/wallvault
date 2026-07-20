import Link from "next/link";
import { Image as ImageIcon, Shield, Palette } from "lucide-react";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen items-center justify-center bg-bg-primary font-sans text-text-primary px-6">
      <div className="max-w-xl w-full text-center space-y-8">
        {/* App Logo */}
        <div className="flex justify-center">
          <div className="p-4 rounded-3xl text-white bg-gradient-to-tr from-accent-purple to-accent-cyan shadow-[0_0_30px_rgba(184,41,221,0.4)]">
            <ImageIcon className="w-12 h-12" />
          </div>
        </div>

        {/* Title */}
        <div className="space-y-3">
          <h1 className="text-5xl font-bold tracking-tight bg-gradient-to-r from-white via-text-secondary to-text-muted bg-clip-text text-transparent">
            WallVault
          </h1>
          <p className="text-text-secondary text-lg">
            Premium Wallpaper Marketplace Web Console
          </p>
        </div>

        {/* Portals Selector */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 pt-6">
          {/* Creator Portal Card */}
          <Link
            href="/creator/dashboard"
            className="group flex flex-col p-6 bg-bg-card border border-bg-elevated rounded-2xl hover:border-accent-purple/50 hover:shadow-[0_0_24px_rgba(184,41,221,0.15)] transition-all duration-300 text-left"
          >
            <div className="p-3 bg-accent-purple/10 text-accent-purple rounded-xl w-fit group-hover:bg-accent-purple/20 transition-colors">
              <Palette className="w-6 h-6" />
            </div>
            <h3 className="mt-4 text-lg font-bold">Creator Hub</h3>
            <p className="mt-2 text-sm text-text-secondary">
              Upload art, customize pricing models, view download analytics, and manage UPI payouts.
            </p>
            <span className="mt-6 text-xs font-bold text-accent-purple group-hover:underline">
              Enter Hub &rarr;
            </span>
          </Link>

          {/* Admin Control Card */}
          <Link
            href="/admin/overview"
            className="group flex flex-col p-6 bg-bg-card border border-bg-elevated rounded-2xl hover:border-accent-cyan/50 hover:shadow-[0_0_24px_rgba(0,212,255,0.15)] transition-all duration-300 text-left"
          >
            <div className="p-3 bg-accent-cyan/10 text-accent-cyan rounded-xl w-fit group-hover:bg-accent-cyan/20 transition-colors">
              <Shield className="w-6 h-6" />
            </div>
            <h3 className="mt-4 text-lg font-bold">Admin Console</h3>
            <p className="mt-2 text-sm text-text-secondary">
              Moderate wallpaper submissions, approve pending creators, process payouts, and audit revenue.
            </p>
            <span className="mt-6 text-xs font-bold text-accent-cyan group-hover:underline">
              Open Console &rarr;
            </span>
          </Link>
        </div>
      </div>
    </div>
  );
}
