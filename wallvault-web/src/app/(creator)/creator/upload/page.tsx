'use client';

import React from 'react';
import { Upload } from 'lucide-react';

export default function CreatorUpload() {
  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div>
        <h1 className="text-4xl font-bold tracking-tight text-text-primary">Upload Wallpaper</h1>
        <p className="mt-1 text-sm text-text-secondary">Submit your artwork to the WallVault review panel.</p>
      </div>

      <div className="p-8 border-2 border-dashed rounded-2xl border-bg-elevated bg-bg-card/50 flex flex-col items-center justify-center text-center cursor-pointer hover:border-accent-purple/50 transition-colors h-80">
        <div className="p-4 rounded-full bg-accent-purple/10 text-accent-purple">
          <Upload className="w-8 h-8" />
        </div>
        <h3 className="mt-4 text-lg font-semibold">Select wallpaper image</h3>
        <p className="mt-1 text-xs text-text-muted">JPG, PNG or WebP up to 50MB (Recommended: 4K+ Resolution, 9:16 Ratio)</p>
      </div>

      <form className="space-y-6 bg-bg-card p-6 rounded-2xl border border-bg-elevated">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-text-secondary">Name</label>
            <input
              type="text"
              placeholder="e.g. Cyberpunk Horizon"
              className="mt-2 w-full px-4 py-3 bg-bg-primary border border-bg-elevated rounded-xl focus:border-accent-purple focus:outline-none"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-text-secondary">Category</label>
            <select
              className="mt-2 w-full px-4 py-3 bg-bg-primary border border-bg-elevated rounded-xl focus:border-accent-purple focus:outline-none text-text-secondary"
            >
              <option>Abstract</option>
              <option>Cyberpunk</option>
              <option>Minimalist</option>
              <option>Space</option>
              <option>OLED</option>
            </select>
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold uppercase tracking-wider text-text-secondary">Description</label>
          <textarea
            placeholder="Add details about your creation..."
            rows={4}
            className="mt-2 w-full px-4 py-3 bg-bg-primary border border-bg-elevated rounded-xl focus:border-accent-purple focus:outline-none"
          />
        </div>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-text-secondary">Pricing Model</label>
            <div className="mt-2 grid grid-cols-2 gap-4">
              <button
                type="button"
                className="py-3 bg-accent-purple/10 border border-accent-purple text-accent-purple rounded-xl font-semibold text-sm"
              >
                Free
              </button>
              <button
                type="button"
                className="py-3 bg-bg-primary border border-bg-elevated text-text-secondary rounded-xl font-semibold text-sm hover:border-text-muted"
              >
                Premium
              </button>
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-text-secondary">Price (INR)</label>
            <input
              type="number"
              placeholder="0"
              disabled
              className="mt-2 w-full px-4 py-3 bg-bg-primary/50 border border-bg-elevated rounded-xl focus:outline-none text-text-muted"
            />
          </div>
        </div>

        <div className="pt-4 border-t border-bg-elevated flex justify-end">
          <button
            type="submit"
            className="px-6 py-3 bg-gradient-to-r from-accent-purple to-accent-cyan text-white font-bold rounded-xl shadow-lg hover:opacity-90 transition-opacity"
          >
            Submit for Review
          </button>
        </div>
      </form>
    </div>
  );
}
