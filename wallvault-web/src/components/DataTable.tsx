'use client';

import React from 'react';

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
    <div className="w-full overflow-hidden border border-white/[0.05] rounded-2xl bg-white/[0.01] backdrop-blur-xl shadow-xl">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-white/[0.05] bg-white/[0.02] text-text-secondary text-[10px] font-bold uppercase tracking-wider">
              {columns.map((col, idx) => (
                <th key={idx} className="px-6 py-4.5 font-bold text-text-secondary">
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-white/[0.03] text-sm text-text-primary">
            {data.length > 0 ? (
              data.map((row, rowIdx) => (
                <tr 
                  key={rowIdx} 
                  className="hover:bg-white/[0.02] transition-colors duration-200"
                >
                  {columns.map((col, colIdx) => (
                    <td key={colIdx} className="px-6 py-4 font-normal text-text-primary/90">
                      {col.accessor(row)}
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={columns.length} className="px-6 py-12 text-center text-text-muted">
                  <div className="flex flex-col items-center justify-center space-y-2">
                    <p className="text-sm font-semibold">{emptyMessage}</p>
                    <p className="text-xs text-text-muted font-normal">Active collection is empty or filters returned no matches.</p>
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

