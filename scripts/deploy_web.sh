#!/usr/bin/env bash
# Build the web app and publish it to Vercel (project "cyberrakshak").
# Live at https://cyberrakshak-iiitbh.vercel.app
# Needs: flutter on PATH, and `vercel login` done once.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

(cd "$ROOT/app" && flutter build web --release)
cp -R "$ROOT/app/build/web/." "$OUT/"
rm -f "$OUT"/*.map
cat > "$OUT/vercel.json" <<'JSON'
{
  "framework": null,
  "buildCommand": "",
  "outputDirectory": ".",
  "headers": [
    { "source": "/(index.html|flutter_service_worker.js|flutter_bootstrap.js|version.json)?",
      "headers": [{ "key": "Cache-Control", "value": "no-cache" }] }
  ]
}
JSON
printf '.env*\n.vercel\n' > "$OUT/.vercelignore"

cd "$OUT"
vercel link --yes --project cyberrakshak >/dev/null
rm -f .env.local
vercel deploy --prod --yes
