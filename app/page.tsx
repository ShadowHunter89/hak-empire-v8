import Link from 'next/link'
export default function Home() {
  return (
    <main style={{padding:'2rem',fontFamily:'sans-serif'}}>
      <h1>🔥 HAK Empire v8.1</h1>
      <p>Welcome to the fully‑automated empire platform.</p>
      <p><Link href="/api/health">Health check</Link></p>
    </main>
  )
}
