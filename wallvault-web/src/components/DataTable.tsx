'use client';

import React from 'react';
import { motion } from 'framer-motion';

interface Column<T> {
  header: string;
  accessor: (row: T) => React.ReactNode;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  emptyMessage?: string;
}

export function DataTable<T>({ columns, data, emptyMessage = 'No records found.' }: DataTableProps<T>) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className="w-full overflow-hidden border border-white/[0.05] rounded-2xl bg-white/[0.01] backdrop-blur-xl"
    >
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-white/[0.06] bg-white/[0.015] text-[10px] font-bold uppercase tracking-[0.1em] text-[#52525b]">
              {columns.map((col, idx) => (
                <th key={idx} className="px-5 py-3.5 font-bold">
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-white/[0.03] text-sm text-text-primary">
            {data.length > 0 ? (
              data.map((row, rowIdx) => (
                <motion.tr
                  key={rowIdx}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: rowIdx * 0.03, duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
                  className="hover:bg-white/[0.02] transition-all duration-200 group"
                >
                  {columns.map((col, colIdx) => (
                    <td key={colIdx} className="px-5 py-3.5 font-normal text-[#a1a1aa] group-hover:text-white transition-colors duration-200">
                      {col.accessor(row)}
                    </td>
                  ))}
                </motion.tr>
              ))
            ) : (
              <tr>
                <td colSpan={columns.length} className="px-6 py-16 text-center">
                  <div className="flex flex-col items-center justify-center space-y-2">
                    <div className="w-10 h-10 rounded-full bg-white/[0.02] border border-white/[0.06] flex items-center justify-center mb-2">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#52525b" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z" />
                        <polyline points="13 2 13 9 20 9" />
                      </svg>
                    </div>
                    <p className="text-xs font-bold text-[#52525b]">{emptyMessage}</p>
                    <p className="text-[10px] text-[#3f3f46]">Active collection is empty or filters returned no matches.</p>
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </motion.div>
  );
}
