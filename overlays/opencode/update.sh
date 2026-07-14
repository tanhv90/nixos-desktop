#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="$(dirname "$0")/default.nix"

die() { echo "ERROR: $*" >&2; exit 1; }

# --- parse args ---
VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  VERSION="$(grep 'version = ' "$DEFAULT_NIX" | sed -E 's/.*"(.*)".*/\1/')"
  echo "No version given; using current version from overlay: $VERSION"
fi

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
echo "Nix flake root: $ROOT"

# --- fetch source hash ---
echo "Fetching source hash for opencode v$VERSION..."
# prefer nix-prefetch-github: .hash is already base64 SRI (works with sha256- prefix)
SRC_HASH=$(nix-prefetch-github anomalyco opencode --rev "v$VERSION" 2>/dev/null | jq -r '.hash' 2>/dev/null) || true

if [[ -z "$SRC_HASH" ]]; then
  # fallback: nix-prefetch-url returns base32, convert to SRI base64
  echo "nix-prefetch-github failed, trying nix-prefetch-url..."
  BASE32_HASH=$(nix-prefetch-url --unpack "https://github.com/anomalyco/opencode/archive/refs/tags/v$VERSION.tar.gz" 2>/dev/null) || true
  if [[ -n "$BASE32_HASH" ]]; then
    SRC_HASH=$(nix hash to-sri --type sha256 "$BASE32_HASH" 2>/dev/null | sed 's/^sha256-//') || true
  fi
fi

if [[ -z "$SRC_HASH" ]]; then
  die "Could not prefetch source hash for v$VERSION"
fi

SRC_HASH="sha256-$SRC_HASH"

# --- inject dummy node_modules hash, then build to discover real one ---
echo "Updating $DEFAULT_NIX with version=$VERSION, src_hash=$SRC_HASH..."
sed -i -E "s/version = \"[^\"]+\";/version = \"$VERSION\";/" "$DEFAULT_NIX"
sed -i -E "s/hash = \"sha256-[^\"]+\";/hash = \"$SRC_HASH\";/" "$DEFAULT_NIX"
# set a dummy node_modules hash so the build will fail and tell us the real one
sed -i -E 's/outputHash = "sha256-[^"]+";/outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";/' "$DEFAULT_NIX"

echo "Building to discover node_modules hash..."
cd "$ROOT"
BUILD_LOG=$(mktemp)
set +e
nix build '.#homeConfigurations."kbb@Desktop".activationPackage' 2>&1 | tee "$BUILD_LOG"
set -e

# extract the "got" hash from the mismatch error
GOT_HASH=$(grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+' "$BUILD_LOG" | tail -1 || true)

if [[ -n "$GOT_HASH" ]]; then
  echo "Found node_modules hash: $GOT_HASH"
  sed -i -E "s|outputHash = \"sha256-[^\"]+\";|outputHash = \"$GOT_HASH\";|" "$DEFAULT_NIX"
else
  echo "Could not auto-detect node_modules hash. Check $BUILD_LOG."
  rm -f "$BUILD_LOG"
  exit 1
fi
rm -f "$BUILD_LOG"

# --- verify ---
echo "Verifying full build..."
cd "$ROOT"
nix build '.#homeConfigurations."kbb@Desktop".activationPackage'

echo
echo "Done. opencode v$VERSION updated in $DEFAULT_NIX"
