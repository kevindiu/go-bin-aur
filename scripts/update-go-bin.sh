#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PKGBUILD="${ROOT_DIR}/PKGBUILD"

# Cleanup function to be run on exit
cleanup() {
  rm -f "${ROOT_DIR}"/*.tar.gz
}
trap cleanup EXIT

if [[ ! -f ${PKGBUILD} ]]; then
  echo "PKGBUILD not found at ${PKGBUILD}" >&2
  exit 1
fi

LATEST_VERSION="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1 | tr -d '\r\n')"
if [[ -z ${LATEST_VERSION} ]]; then
  echo "Failed to fetch latest Go version" >&2
  exit 1
fi
LATEST_VERSION="${LATEST_VERSION#go}"

CURRENT_VERSION="$(grep -E '^pkgver=' "${PKGBUILD}" | head -n1 | cut -d= -f2-)"
CURRENT_VERSION="${CURRENT_VERSION//[[:space:]]/}"

if [[ ${LATEST_VERSION} == "${CURRENT_VERSION}" ]]; then
  echo "Go ${LATEST_VERSION} already packaged. Nothing to do."
  # Ensure .SRCINFO is up to date even if version matches (idempotency)
  cd "${ROOT_DIR}"
  makepkg --printsrcinfo > .SRCINFO
  exit 0
fi

echo "Updating Go from ${CURRENT_VERSION:-unknown} to ${LATEST_VERSION}"

# Update pkgver and reset pkgrel
sed -i "s/^pkgver=.*/pkgver=${LATEST_VERSION}/" "${PKGBUILD}"
sed -i "s/^pkgrel=.*/pkgrel=1/" "${PKGBUILD}"

# Update checksums
cd "${ROOT_DIR}"
updpkgsums

# Update .SRCINFO
makepkg --printsrcinfo > .SRCINFO

echo "PKGBUILD and .SRCINFO updated."
