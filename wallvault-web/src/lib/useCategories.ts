import { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, setDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

const DEFAULT_CATEGORIES = [
  'Abstract',
  'Anime',
  'Cars',
  'Nature',
  'Space',
  'Dark',
  'Cyberpunk',
  '3D',
  'Minimalist'
];

export function useCategories() {
  const [categories, setCategories] = useState<string[]>(DEFAULT_CATEGORIES);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'categories'),
      (snapshot) => {
        const firestoreCats: string[] = [];
        snapshot.forEach((docSnap) => {
          const data = docSnap.data();
          if (data.name) {
            firestoreCats.push(data.name);
          }
        });

        // Combine default categories with custom firestore categories (case insensitive unique)
        const combined = Array.from(new Set([...DEFAULT_CATEGORIES, ...firestoreCats]));
        setCategories(combined);
        setLoading(false);
      },
      (error) => {
        console.error('Failed to load categories:', error);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  const addCategory = async (name: string) => {
    const trimmed = name.trim();
    if (!trimmed) return;
    try {
      const docId = trimmed.toLowerCase().replace(/[^a-z0-9]/g, '-');
      await setDoc(doc(db, 'categories', docId), {
        name: trimmed,
        createdAt: new Date(),
      }, { merge: true });

      if (!categories.some(c => c.toLowerCase() === trimmed.toLowerCase())) {
        setCategories(prev => [...prev, trimmed]);
      }
    } catch (err) {
      console.error('Failed to add category:', err);
    }
  };

  return { categories, addCategory, loading };
}
