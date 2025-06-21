// app/layout.tsx
import './globals.css';           // optional, if you add global styles
import type { ReactNode } from 'react';

export const metadata = {
  title: 'HAK Empire v8.1',
  description: 'Fully‑automated empire platform',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'sans-serif' }}>{children}</body>
    </html>
  );
}
