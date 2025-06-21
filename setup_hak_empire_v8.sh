#!/usr/bin/env bash
# --------------------------------------------
# HAK Empire Architecture v8.0 bootstrap
# --------------------------------------------
set -e

APP_ROOT="$HOME/hak-empire"
REPO_NAME="hak-empire-v8"

echo "▶ Creating project folder…"
mkdir -p "$APP_ROOT"
cd "$APP_ROOT"

echo "▶ Initialising git repo…"
git init -q

# ---------- 1. Next.js starter ----------
echo "▶ Creating Next.js 14 + TS app…"
pnpm dlx --yes create-next-app@latest $REPO_NAME \
  --typescript --tailwind --eslint --src-dir --app --import-alias "@/*"

cd "$REPO_NAME"

# ---------- 2. Sector & Lab scaffolding ----------
echo "▶ Generating sector & lab directories…"
SECTORS=(agriculture art economic space legal technology health education content business defense governance)
LABS=(ai-design dark-ops financial space artistries agricultural legal innovation auto-evolution content-creation bioengineering cognitive-ai surveillance)

for S in "${SECTORS[@]}"; do
  mkdir -p "src/empire/sectors/$S"
done

for L in "${LABS[@]}"; do
  mkdir -p "src/empire/labs/$L"
done

# ---------- 3. Install backend deps ----------
echo "▶ Installing core packages…"
pnpm add @prisma/client next-auth openai stripe
pnpm add -D prisma typescript ts-node nodemon

# ---------- 4. Prisma setup ----------
cat > prisma/schema.prisma <<'EOF'
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql" url = env("DATABASE_URL") }

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?
  hashedPw  String
  role      String   @default("user")
  createdAt DateTime @default(now())
}
EOF

pnpm dlx prisma generate

# ---------- 5. Env example ----------
cat > .env.example <<'EOF'
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/hak_empire"
AUTH_SECRET="change_me"
OPENAI_API_KEY="sk-..."
PINECONE_API_KEY=""
POSTHOG_KEY=""
NEXT_PUBLIC_BASE_URL="http://localhost:3000"
EOF

# ---------- 6. Docker compose ----------
cat > docker-compose.yml <<'EOF'
version: "3.9"
services:
  web:
    build: .
    ports: [ "3000:3000" ]
    env_file: .env
    depends_on: [db]
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: hak
      POSTGRES_PASSWORD: hak
      POSTGRES_DB: hak_empire
    volumes: [ "db_data:/var/lib/postgresql/data" ]
  n8n:
    image: n8nio/n8n
    ports: [ "5678:5678" ]
    volumes: [ "n8n_data:/home/node/.n8n" ]
volumes:
  db_data:
  n8n_data:
EOF

# ---------- 7. GitHub Actions ----------
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with: { version: 8 }
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm test --if-present
EOF

cat > .github/workflows/cd.yml <<'EOF'
name: CD
on:
  push:
    tags: ['v*.*.*']
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with: { version: 8 }
      - run: pnpm install --frozen-lockfile
      - run: npx prisma generate
      - run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
EOF

# ---------- 8. README kick‑off ----------
cat > README.md <<'EOF'
# HAK Empire Architecture v8.0

## Sectors (12)
Agriculture • Art • Economic • Space • Legal • Technology • Health • Education • Content • Business • Defense • Governance

## Labs (13)
AI Design • Dark Ops • Financial • Space • Artistry • Agricultural • Legal • Innovation • Auto Evolution • Content Creation • Bioengineering • Cognitive AI • Surveillance

### Quick start
```bash
pnpm install
cp .env.example .env
docker-compose up -d db
pnpm dlx prisma migrate deploy
pnpm dev
```
EOF

echo "▶ Committing initial code…"
git add .
git commit -m "feat: bootstrap HAK Empire v8.0 architecture" -q

echo "🎉  Bootstrap complete!  Repo at: $APP_ROOT/$REPO_NAME"
