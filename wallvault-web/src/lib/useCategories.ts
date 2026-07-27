import { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, setDoc, deleteDoc, updateDoc, arrayUnion, arrayRemove } from 'firebase/firestore';
import { db } from '@/lib/firebase';

export interface CategoryItem {
  id: string;
  name: string;
  slug: string;
  subCategories: string[];
  coverUrl?: string;
  description?: string;
  color?: string;
  createdAt?: any;
}

const DEFAULT_CATEGORIES: CategoryItem[] = [
  { id: 'abstract', name: 'Abstract', slug: 'abstract', subCategories: ['3D Shapes', 'Fluid Art', 'Geometric', 'Neon Lines'], color: '#a855f7' },
  { id: 'anime', name: 'Anime', slug: 'anime', subCategories: ['Cyberpunk Anime', 'Dark Fantasy', 'Chibi', 'Mecha'], color: '#ec4899' },
  { id: 'cars', name: 'Cars', slug: 'cars', subCategories: ['Supercars', 'Hypercars', 'JDM', 'Classic Vintage'], color: '#ef4444' },
  { id: 'nature', name: 'Nature', slug: 'nature', subCategories: ['Mountains', 'Forests', 'Oceans & Waves', 'Sunsets'], color: '#10b981' },
  { id: 'space', name: 'Space', slug: 'space', subCategories: ['Galaxies & Nebulas', 'Astronauts', 'Planets', 'Sci-Fi'], color: '#06b6d4' },
  { id: 'dark', name: 'Dark', slug: 'dark', subCategories: ['Amoled Black', 'Gothic', 'Shadows', 'Minimalist Dark'], color: '#64748b' },
  { id: 'cyberpunk', name: 'Cyberpunk', slug: 'cyberpunk', subCategories: ['Neon City', 'Futuristic', 'Retrowave', 'Synthwave'], color: '#f59e0b' },
  { id: '3d', name: '3D', slug: '3d', subCategories: ['CGI Render', 'Isometric', 'Voxel', 'Low Poly'], color: '#8b5cf6' },
  { id: 'minimalist', name: 'Minimalist', slug: 'minimalist', subCategories: ['Line Art', 'Flat Design', 'Monochrome'], color: '#6366f1' },
];

export function useCategories() {
  const [categoryItems, setCategoryItems] = useState<CategoryItem[]>(DEFAULT_CATEGORIES);
  const [categories, setCategories] = useState<string[]>(DEFAULT_CATEGORIES.map(c => c.name));
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'categories'),
      (snapshot) => {
        const firestoreMap = new Map<string, CategoryItem>();

        snapshot.forEach((docSnap) => {
          const data = docSnap.data();
          if (data.name) {
            const catId = docSnap.id;
            firestoreMap.set(catId, {
              id: catId,
              name: data.name,
              slug: data.slug || catId,
              subCategories: Array.isArray(data.subCategories) ? data.subCategories : [],
              coverUrl: data.coverUrl || '',
              description: data.description || '',
              color: data.color || '#a855f7',
              createdAt: data.createdAt,
            });
          }
        });

        // Merge defaults with firestore items
        const mergedList: CategoryItem[] = [...DEFAULT_CATEGORIES];
        firestoreMap.forEach((fsItem, fsId) => {
          const existingIdx = mergedList.findIndex(c => c.id === fsId || c.name.toLowerCase() === fsItem.name.toLowerCase());
          if (existingIdx >= 0) {
            mergedList[existingIdx] = {
              ...mergedList[existingIdx],
              ...fsItem,
              subCategories: Array.from(new Set([...mergedList[existingIdx].subCategories, ...fsItem.subCategories])),
            };
          } else {
            mergedList.push(fsItem);
          }
        });

        setCategoryItems(mergedList);
        setCategories(mergedList.map(c => c.name));
        setLoading(false);
      },
      (error) => {
        console.error('Failed to load categories:', error);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  const addCategory = async (name: string, subCategories: string[] = [], coverUrl = '', description = '', color = '#a855f7') => {
    const trimmed = name.trim();
    if (!trimmed) return;
    try {
      const docId = trimmed.toLowerCase().replace(/[^a-z0-9]/g, '-');
      await setDoc(doc(db, 'categories', docId), {
        name: trimmed,
        slug: docId,
        subCategories: subCategories.map(s => s.trim()).filter(Boolean),
        coverUrl,
        description,
        color,
        createdAt: new Date(),
      }, { merge: true });
    } catch (err) {
      console.error('Failed to add category:', err);
    }
  };

  const addSubCategory = async (categoryId: string, subCategoryName: string) => {
    const trimmed = subCategoryName.trim();
    if (!trimmed) return;
    try {
      await updateDoc(doc(db, 'categories', categoryId), {
        subCategories: arrayUnion(trimmed),
      });
    } catch (err) {
      console.error('Failed to add sub-category:', err);
      // Fallback setDoc
      await setDoc(doc(db, 'categories', categoryId), {
        subCategories: [trimmed],
      }, { merge: true });
    }
  };

  const removeSubCategory = async (categoryId: string, subCategoryName: string) => {
    try {
      await updateDoc(doc(db, 'categories', categoryId), {
        subCategories: arrayRemove(subCategoryName),
      });
    } catch (err) {
      console.error('Failed to remove sub-category:', err);
    }
  };

  const deleteCategory = async (categoryId: string) => {
    try {
      await deleteDoc(doc(db, 'categories', categoryId));
    } catch (err) {
      console.error('Failed to delete category:', err);
    }
  };

  return { categoryItems, categories, addCategory, addSubCategory, removeSubCategory, deleteCategory, loading };
}
