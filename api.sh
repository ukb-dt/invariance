#!/usr/bin/env bash
set -e

echo "=== GitHub Pages Hard Bootstrap ==="

read -p "GitHub username: " GH_USER
read -p "Repository name: " GH_REPO
read -s -p "GitHub Personal Access Token: " GH_TOKEN
echo

API="https://api.github.com"
REPO_API="$API/repos/$GH_USER/$GH_REPO"

# ---- create repo if missing ----
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $GH_TOKEN" \
  "$REPO_API" | grep -q 200 || \
curl -s -X POST "$API/user/repos" \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "{
    \"name\": \"$GH_REPO\",
    \"private\": false,
    \"auto_init\": false
  }" >/dev/null

# ---- local setup ----
mkdir -p "$GH_REPO"
cd "$GH_REPO"

git init
git checkout -B ukhona

# ---- content ----
cat <<EOF > index.md
# GitHub Pages is live

Bootstrap successful.

EOF

git add index.md
git commit -m "bootstrap gh-pages"

# ---- remote ----
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GH_USER:$GH_TOKEN@github.com/$GH_USER/$GH_REPO.git"

# ---- FORCE ALIGN (intentional) ----
git push -f origin ukhona

# ---- enable Pages ----
curl -s -X POST "$REPO_API/pages" \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{
    "source": { "branch": "ukhona", "path": "/" }
  }' >/dev/null || true

echo
echo "======================================"
echo "LIVE (may take ~30s):"
echo "https://$GH_USER.github.io/$GH_REPO/"
echo "======================================"