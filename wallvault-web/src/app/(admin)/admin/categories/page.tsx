'use client';

import React, { useState } from 'react';
import { useCategories, CategoryItem } from '@/lib/useCategories';
import { Trash2, Tag, CheckCircle2, Layers, FolderPlus, Palette, X, AlertTriangle } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { PageHeader } from '@/components/motion/PageHeader';
import { GradientButton } from '@/components/motion/GradientButton';
import { AnimatedModal } from '@/components/motion/AnimatedModal';
import { LiveDot } from '@/components/motion/LiveDot';

const EASE = [0.16, 1, 0.3, 1] as const;

const inputCls =
  'w-full mt-1.5 px-3.5 py-2.5 bg-black/40 border border-white/10 rounded-xl text-xs text-white placeholder-[#71717a] focus:outline-none focus:border-accent-cyan/50 transition-colors duration-300 glass-input';

export default function AdminCategoriesPage() {
  const { categoryItems, addCategory, addSubCategory, removeSubCategory, deleteCategory, loading } = useCategories();

  const [newCatName, setNewCatName] = useState('');
  const [newCatDesc, setNewCatDesc] = useState('');
  const [newCatColor, setNewCatColor] = useState('#a855f7');
  const [newCatSubInput, setNewCatSubInput] = useState('');

  const [selectedCatIdForSub, setSelectedCatIdForSub] = useState<string>('');
  const [subNameInput, setSubNameInput] = useState('');

  const [saving, setSaving] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<CategoryItem | null>(null);

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
    setDeleteTarget(null);
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
      <PageHeader
        title="Category Management"
        subtitle="Create, update, and manage categories and sub-categories. Changes automatically sync to the Mobile App & Creator Hub in real time."
        badge="Taxonomy Control"
        badgeColor="#06b6d4"
      />

      {/* ── Notification Banner ────────────────────────────── */}
      <AnimatePresence>
        {successMessage && (
          <motion.div
            initial={{ opacity: 0, y: -14, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -14, scale: 0.97 }}
            transition={{ duration: 0.35, ease: EASE }}
            className="flex items-center space-x-2 px-4 py-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold"
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>{successMessage}</span>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* ── Form Column ──────────────────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15, duration: 0.5, ease: EASE }}
          className="space-y-6"
        >
          {/* Create Main Category */}
          <div className="p-6 rounded-2xl glass-panel border border-white/[0.08] space-y-4">
            <h2 className="text-sm font-bold uppercase tracking-wider text-white flex items-center gap-2">
              <FolderPlus className="w-4 h-4 text-accent-purple" />
              Create Main Category
            </h2>

            <form onSubmit={handleCreateCategory} className="space-y-4">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted">Category Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Arabic Qalb, Anime, Cars"
                  value={newCatName}
                  onChange={(e) => setNewCatName(e.target.value)}
                  className={inputCls}
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted">Description</label>
                <input
                  type="text"
                  placeholder="Brief category summary..."
                  value={newCatDesc}
                  onChange={(e) => setNewCatDesc(e.target.value)}
                  className={inputCls}
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted">Sub-Categories (Comma Separated)</label>
                <input
                  type="text"
                  placeholder="e.g. Calligraphy, Geometric, Sufi Art"
                  value={newCatSubInput}
                  onChange={(e) => setNewCatSubInput(e.target.value)}
                  className={inputCls}
                />
              </div>

              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted flex items-center gap-1.5">
                  <Palette className="w-3 h-3 text-accent-purple" />
                  Accent Color
                </label>
                <div className="flex items-center gap-3 mt-1.5">
                  <div
                    className="relative w-10 h-10 rounded-xl overflow-hidden"
                    style={{ boxShadow: `0 0 16px -2px ${newCatColor}66`, border: '1px solid rgba(255,255,255,0.12)' }}
                  >
                    <input
                      type="color"
                      value={newCatColor}
                      onChange={(e) => setNewCatColor(e.target.value)}
                      className="absolute inset-0 w-full h-full cursor-pointer"
                    />
                  </div>
                  <span className="text-xs font-mono text-white/80">{newCatColor}</span>
                </div>
              </div>

              <GradientButton
                type="submit"
                variant="purple"
                size="md"
                disabled={saving}
                className="w-full"
              >
                <PlusIcon />
                <span>Create Category</span>
              </GradientButton>
            </form>
          </div>

          {/* Add Sub-Category */}
          <div className="p-6 rounded-2xl glass-panel border border-white/[0.08] space-y-4">
            <h2 className="text-sm font-bold uppercase tracking-wider text-white flex items-center gap-2">
              <Layers className="w-4 h-4 text-accent-cyan" />
              Add Sub-Category
            </h2>

            <form onSubmit={handleAddSubCategory} className="space-y-4">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted">Select Main Category</label>
                <select
                  required
                  value={selectedCatIdForSub}
                  onChange={(e) => setSelectedCatIdForSub(e.target.value)}
                  className={`${inputCls} cursor-pointer`}
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
                <label className="text-[11px] font-bold uppercase tracking-wider text-text-muted">New Sub-Category Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Cyberpunk Anime"
                  value={subNameInput}
                  onChange={(e) => setSubNameInput(e.target.value)}
                  className={inputCls}
                />
              </div>

              <GradientButton
                type="submit"
                variant="cyan"
                size="md"
                disabled={saving}
                className="w-full"
              >
                <PlusIcon />
                <span>Add Sub-Category</span>
              </GradientButton>
            </form>
          </div>
        </motion.div>

        {/* ── Active Categories List ────────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25, duration: 0.5, ease: EASE }}
          className="lg:col-span-2 space-y-4"
        >
          <div className="flex items-center justify-between">
            <h2 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[#52525b]">Active Categories ({categoryItems.length})</h2>
            <span className="text-xs text-text-muted flex items-center gap-2">
              <LiveDot color="#22c55e" />
              Real-Time Sync Active
            </span>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-20">
              <div className="w-8 h-8 border-2 border-accent-cyan/30 border-t-accent-cyan rounded-full animate-spin" />
            </div>
          ) : categoryItems.length === 0 ? (
            <div className="glass-panel p-12 text-center text-xs text-text-muted italic border border-white/[0.05] rounded-2xl">
              No categories yet. Create your first category to populate the mobile app taxonomy.
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {categoryItems.map((item, i) => (
                <motion.div
                  key={item.id}
                  layout
                  initial={{ opacity: 0, scale: 0.94, y: 12 }}
                  animate={{ opacity: 1, scale: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.92, y: -8 }}
                  transition={{ delay: i * 0.05, duration: 0.45, ease: EASE }}
                  className="p-5 rounded-2xl glass-panel border border-white/[0.06] flex flex-col justify-between space-y-4 relative overflow-hidden group hover:border-white/[0.12] transition-colors duration-300"
                >
                  <div
                    className="pointer-events-none absolute -top-16 -right-16 w-40 h-40 rounded-full opacity-[0.08] blur-2xl group-hover:opacity-[0.16] transition-opacity duration-500"
                    style={{ background: item.color || '#a855f7' }}
                  />

                  <div className="flex items-start justify-between">
                    <div className="flex items-center space-x-3">
                      <motion.div
                        whileHover={{ scale: 1.25 }}
                        className="w-4 h-4 rounded-full border border-white/20 shrink-0"
                        style={{ background: item.color || '#a855f7', boxShadow: `0 0 12px ${item.color || '#a855f7'}` }}
                      />
                      <div>
                        <h3 className="text-sm font-bold text-white">{item.name}</h3>
                        <p className="text-[10px] text-text-muted font-mono">ID: {item.id.slice(0, 12)}</p>
                      </div>
                    </div>

                    <motion.button
                      whileHover={{ scale: 1.1, rotate: 4 }}
                      whileTap={{ scale: 0.9 }}
                      onClick={() => setDeleteTarget(item)}
                      className="p-1.5 rounded-lg text-rose-400/70 hover:text-rose-400 hover:bg-rose-500/10 transition-colors cursor-pointer"
                      title="Delete Category"
                    >
                      <Trash2 className="w-4 h-4" />
                    </motion.button>
                  </div>

                  {item.description && (
                    <p className="text-xs text-text-secondary leading-relaxed">{item.description}</p>
                  )}

                  <div className="space-y-2 pt-2 border-t border-white/[0.05]">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-text-muted flex items-center gap-1">
                      <Tag className="w-3 h-3" />
                      Sub-Categories ({item.subCategories.length})
                    </span>

                    {item.subCategories.length === 0 ? (
                      <p className="text-[11px] text-[#52525b] italic">No sub-categories added.</p>
                    ) : (
                      <div className="flex flex-wrap gap-1.5">
                        <AnimatePresence>
                          {item.subCategories.map((sub) => (
                            <motion.span
                              key={sub}
                              layout
                              initial={{ opacity: 0, scale: 0.85 }}
                              animate={{ opacity: 1, scale: 1 }}
                              exit={{ opacity: 0, scale: 0.7, transition: { duration: 0.15 } }}
                              className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[10px] font-medium bg-white/[0.04] border border-white/[0.08] text-white/90 group/sub hover:border-rose-500/40 hover:bg-rose-500/5 transition-colors"
                            >
                              <span>{sub}</span>
                              <motion.button
                                whileTap={{ scale: 0.7 }}
                                onClick={() => handleRemoveSub(item.id, sub)}
                                className="text-[#71717a] hover:text-rose-400 transition-colors cursor-pointer"
                                title={`Remove "${sub}"`}
                              >
                                <X className="w-3 h-3" />
                              </motion.button>
                            </motion.span>
                          ))}
                        </AnimatePresence>
                      </div>
                    )}
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </motion.div>
      </div>

      {/* ── Delete Confirmation Modal ───────────────────────── */}
      <AnimatedModal open={!!deleteTarget} onClose={() => setDeleteTarget(null)} maxWidthClass="max-w-sm">
        {deleteTarget && (
          <div className="bg-bg-card border border-border-glass rounded-2xl shadow-2xl p-6 space-y-4">
            <div className="flex items-start justify-between">
              <div className="w-10 h-10 rounded-xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <motion.button
                whileHover={{ rotate: 90 }}
                whileTap={{ scale: 0.85 }}
                onClick={() => setDeleteTarget(null)}
                className="p-1 text-text-muted hover:text-white rounded transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </motion.button>
            </div>

            <div>
              <h3 className="text-base font-bold text-white">Delete "{deleteTarget.name}"?</h3>
              <p className="text-xs text-text-secondary mt-1.5 leading-relaxed">
                This will permanently remove the category and all its sub-categories from the mobile app and creator hub instantly.
              </p>
            </div>

            <div className="flex gap-3 pt-1">
              <motion.button
                whileHover={{ y: -1 }}
                whileTap={{ scale: 0.96 }}
                onClick={() => setDeleteTarget(null)}
                className="flex-1 py-2.5 rounded-xl bg-white/[0.05] border border-white/10 text-white text-[10px] font-bold uppercase tracking-wider transition-colors hover:bg-white/[0.1] cursor-pointer"
              >
                Cancel
              </motion.button>
              <motion.button
                whileHover={{ y: -1, scale: 1.02 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => handleDeleteCategory(deleteTarget.id, deleteTarget.name)}
                className="flex-1 py-2.5 rounded-xl bg-rose-500 text-white text-[10px] font-bold uppercase tracking-wider shadow-lg shadow-rose-500/25 transition-opacity hover:opacity-90 cursor-pointer"
              >
                Delete
              </motion.button>
            </div>
          </div>
        )}
      </AnimatedModal>
    </div>
  );
}

function PlusIcon() {
  return (
    <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 5v14M5 12h14" />
    </svg>
  );
}
