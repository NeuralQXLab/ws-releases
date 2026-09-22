#!/bin/sh
# Installs `ws` from the latest GitHub Release of NeuralQXLab/ws-releases.
# No sudo, no auth, no dependencies beyond curl. Safe to re-run to reinstall.
#
#   curl -fsSL https://neuralqxlab.github.io/ws-releases/install.sh | sh
set -eu

REPO="NeuralQXLab/ws-releases"
INSTALL_DIR="${WS_INSTALL_DIR:-$HOME/.local/bin}"

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
  Darwin)
    case "$arch" in
      arm64)  target="aarch64-apple-darwin" ;;
      x86_64) target="x86_64-apple-darwin" ;;
      *) echo "install.sh: unsupported mac architecture: $arch" >&2; exit 1 ;;
    esac
    ;;
  Linux)
    case "$arch" in
      x86_64|amd64)   target="x86_64-unknown-linux-gnu" ;;
      aarch64|arm64)  target="aarch64-unknown-linux-gnu" ;;
      *) echo "install.sh: unsupported linux architecture: $arch" >&2; exit 1 ;;
    esac
    ;;
  *)
    echo "install.sh: unsupported OS: $os (mac and linux only for now)" >&2
    exit 1
    ;;
esac

asset="ws-${target}"
url="https://github.com/${REPO}/releases/latest/download/${asset}"
checksum_url="${url}.sha256"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "downloading ${asset}..."
curl -fsSL "$url" -o "$tmp"

if curl -fsSL "$checksum_url" -o "${tmp}.sha256" 2>/dev/null; then
  expected="$(awk '{print $1}' "${tmp}.sha256")"
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$tmp" | awk '{print $1}')"
  else
    actual="$(shasum -a 256 "$tmp" | awk '{print $1}')"
  fi
  if [ "$expected" != "$actual" ]; then
    echo "install.sh: checksum mismatch! expected $expected, got $actual" >&2
    exit 1
  fi
  rm -f "${tmp}.sha256"
else
  echo "install.sh: no checksum published for this release, skipping verification" >&2
fi

mkdir -p "$INSTALL_DIR"
chmod +x "$tmp"
mv "$tmp" "$INSTALL_DIR/ws"
trap - EXIT

echo "installed ws to $INSTALL_DIR/ws"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo ""
    echo "note: $INSTALL_DIR isn't on your PATH yet. Add this to your shell rc file:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

echo ""
echo "next: run \`ws init <the link your professor sent you>\`"
