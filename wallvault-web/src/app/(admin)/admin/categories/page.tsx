'use client';

import React, { useState } from 'react';
import { useCategories, CategoryItem } from '@/lib/useCategories';
import { Grid, Plus, Trash2, Tag, CheckCircle2, AlertCircle, Layers, FolderPlus, Palette } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function AdminCategoriesPage() {
  const { categoryItems, addCategory, addSubCategory, removeSubCategory, deleteCategory, loading } = useCategories();

  // Create Category Modal / Form State
  const [newCatName, setNewCatName] = useState('');
  const [newCatDesc, setNewCatDesc] = useState('');
  const [newCatColor, setNewCatColor] = useState('#a855f7');
  const [newCatSubInput, setNewCatSubInput] = useState('');
  
  // Add Sub-Category State
  const [selectedCatIdForSub, setSelectedCatIdForSub] = useState<string>('');
  const [subNameInput, setSubNameInput] = useState('');

  const [saving, setSaving] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleCreateCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCatName.trim()) return;

    setSaving(true);
    try {
      const subs = newCatSubInput
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);

      await addCategory(newCatName, subs, '', newCatDesc, newCatColor);

      setNewCatName('');
      setNewCatDesc('');
      setNewCatSubInput('');
      setSuccessMessage(`Category "${newCatName}" created and synced in real time!`);
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err) {
      console.error('Failed to create category:', err);
    } finally {
      setSaving(false);
    }
  };

  const handleAddSubCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCatIdForSub || !subNameInput.trim()) return;

    setSaving(true);
    try {
      await addSubCategory(selectedCatIdForSub, subNameInput.trim());
      setSubNameInput('');
      setSuccessMessage(`Sub-category "${subNameInput.trim()}" added successfully!`);
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err) {
      console.error('Failed to add sub category:', err);
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteCategory = async (catId: string, name: string) => {
    if (!confirm(`Are you sure you want to delete category "${name}"? It will be removed from the mobile app and creator hub instantly.`)) {
      return;
    }
    try {
      await deleteCategory(catId);
      setSuccessMessage(`Category "${name}" deleted.`);
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err) {
      console.error('Failed to delete category:', err);
    }
  };

  const handleRemoveSub = async (catId: string, subName: string) => {
    try {
      await removeSubCategory(catId, subName);
      setSuccessMessage(`Sub-category "${subName}" removed.`);
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err) {
      console.error('Failed to remove sub category:', err);
    }
  };

  return (
    <div className="space-y-8">
      {/* ── Top Header ─────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-white flex items-center gap-3">
            <Grid className="w-6 h-6 text-cyan-400" />
            Category & Sub-Category Management
          </h1>
          <p className="text-xs text-[#a1a1aa] mt-1">
            Create, update, and manage categories and sub-categories. Changes automatically sync to the Mobile App & Creator Hub in real time.
          </p>
        </div>
      </div>

      {/* ── Notification Banner ────────────────────────────── */}
      <AnimatePresence>
        {successMessage && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="flex items-center space-x-2 px-4 py-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold"
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>{successMessage}</span>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* ── Form Column: Add Category & Add Sub-Category ──── */}
        <div className="space-y-6">
          {/* Create Main Category */}
          <div className="p-6 rounded-2xl glass-morphism border border-white/[0.08] space-y-4">
            <h2 className="text-sm font-bold uppercase tracking-wider text-white flex items-center gap-2">
              <FolderPlus className="w-4 h-4 text-purple-400" />
              Create Main Category
            </h2>

            <form onSubmit={handleCreateCategory} className="space-y-4">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa]">Category Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Arabic Qalb, Anime, Cars"
                  value={newCatName}
                  onChange={(e) => setNewCatName(e.target.value)}
                  className="w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-purple-500/50"
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa]">Description</label>
                <input
                  type="text"
                  placeholder="Brief category summary..."
                  value={newCatDesc}
                  onChange={(e) => setNewCatDesc(e.target.value)}
                  className="w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-purple-500/50"
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa]">Sub-Categories (Comma Separated)</label>
                <input
                  type="text"
                  placeholder="e.g. Calligraphy, Geometric, Sufi Art"
                  value={newCatSubInput}
                  onChange={(e) => setNewCatSubInput(e.target.value)}
                  className="w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-purple-500/50"
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa] flex items-center gap-1.5">
                  <Palette className="w-3 h-3 text-purple-400" />
                  Accent Color
                </label>
                <div className="flex items-center gap-3 mt-1.5">
                  <input
                    type="color"
                    value={newCatColor}
                    onChange={(e) => setNewCatColor(e.target.value)}
                    className="w-9 h-9 rounded-lg bg-transparent border-0 cursor-pointer"
                  />
                  <span className="text-xs font-mono text-white/80">{newCatColor}</span>
                </div>
              </div>

              <button
                type="submit"
                disabled={saving}
                className="w-full py-2.5 bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs uppercase tracking-wider rounded-xl transition-all shadow-md disabled:opacity-50 cursor-pointer flex items-center justify-center gap-2"
              >
                <Plus className="w-4 h-4" />
                <span>Create Category</span>
              </button>
            </form>
          </div>

          {/* Add Sub-Category under Existing Main Category */}
          <div className="p-6 rounded-2xl glass-morphism border border-white/[0.08] space-y-4">
            <h2 className="text-sm font-bold uppercase tracking-wider text-white flex items-center gap-2">
              <Layers className="w-4 h-4 text-cyan-400" />
              Add Sub-Category
            </h2>

            <form onSubmit={handleAddSubCategory} className="space-y-4">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa]">Select Main Category</label>
                <select
                  required
                  value={selectedCatIdForSub}
                  onChange={(e) => setSelectedCatIdForSub(e.target.value)}
                  className="w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white focus:outline-none focus:border-cyan-500/50 cursor-pointer"
                >
                  <option value="">Select Category...</option>
                  {categoryItems.map((cat) => (
                    <option key={cat.id} value={cat.id}>
                      {cat.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-[#a1a1aa]">New Sub-Category Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Cyberpunk Anime"
                  value={subNameInput}
                  onChange={(e) => setSubNameInput(e.target.value)}
                  className="w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-cyan-500/50"
                />
              </div>

              <button
                type="submit"
                disabled={saving}
                className="w-full py-2.5 bg-gradient-to-r from-cyan-600 to-teal-600 hover:from-cyan-500 hover:to-teal-500 text-white font-bold text-xs uppercase tracking-wider rounded-xl transition-all shadow-md disabled:opacity-50 cursor-pointer flex items-center justify-center gap-2"
              >
                <Plus className="w-4 h-4" />
                <span>Add Sub-Category</span>
              </button>
            </form>
          </div>
        </div>

        {/* ── Active Categories List ────────────────────────── */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold uppercase tracking-wider text-white">Active Categories ({categoryItems.length})</h2>
            <span className="text-xs text-[#71717a]">Real-Time Sync Active</span>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-20 text-xs text-[#71717a]">
              Loading categories...
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {categoryItems.map((item) => (
                <motion.div
                  key={item.id}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="p-5 rounded-2xl glass-morphism border border-white/[0.06] flex flex-col justify-between space-y-4 relative overflow-hidden"
                >
                  {/* Top Header */}
                  <div className="flex items-start justify-between">
                    <div className="flex items-center space-x-3">
                      <div
                        className="w-4 h-4 rounded-full border border-white/20 shrink-0"
                        style={{ background: item.color || '#a855f7', boxShadow: `0 0 10px ${item.color || '#a855f7'}` }}
                      />
                      <div>
                        <h3 className="text-sm font-bold text-white">{item.name}</h3>
                        <p className="text-[10px] text-[#71717a] font-mono">ID: {item.id}</p>
                      </div>
                    </div>

                    <button
                      onClick={() => handleDeleteCategory(item.id, item.name)}
                      className="p-1.5 rounded-lg text-rose-400/70 hover:text-rose-400 hover:bg-rose-500/10 transition-colors cursor-pointer"
                      title="Delete Category"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>

                  {item.description && (
                    <p className="text-xs text-[#a1a1aa] leading-relaxed">{item.description}</p>
                  )}

                  {/* Sub-Categories Chips */}
                  <div className="space-y-2 pt-2 border-t border-white/[0.05]">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-[#71717a] flex items-center gap-1">
                      <Tag className="w-3 h-3" />
                      Sub-Categories ({item.subCategories.length})
                    </span>

                    {item.subCategories.length === 0 ? (
                      <p className="text-[11px] text-[#52525b] italic">No sub-categories added.</p>
                    ) : (
                      <div className="flex flex-wrap gap-1.5">
                        {item.subCategories.map((sub) => (
                          <span
                            key={sub}
                            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[10px] font-medium bg-white/[0.04] border border-white/[0.08] text-white/90 group hover:border-rose-500/40 transition-colors"
                          >
                            <span>{sub}</span>
                            <button
                              onClick={() => handleRemoveSub(item.id, sub)}
                              className="text-[#71717a] hover:text-rose-400 transition-colors cursor-pointer"
                            >
                              ×
                            </button>
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
