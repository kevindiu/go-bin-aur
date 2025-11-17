#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PKGBUILD="${ROOT_DIR}/PKGBUILD"
SRCINFO="${ROOT_DIR}/.SRCINFO"

if [[ ! -f ${PKGBUILD} ]]; then
  echo "PKGBUILD not found at ${PKGBUILD}" >&2
  exit 1
fi

if [[ ! -f ${SRCINFO} ]]; then
  echo ".SRCINFO not found at ${SRCINFO}" >&2
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
  exit 0
fi

echo "Updating Go from ${CURRENT_VERSION:-unknown} to ${LATEST_VERSION}"

sed -i "s/^pkgver=.*/pkgver=${LATEST_VERSION}/" "${PKGBUILD}"
sed -i "s/^pkgrel=.*/pkgrel=1/" "${PKGBUILD}"

perl -0pi -e "s/(\\tpkgver = ).*/\${1}${LATEST_VERSION}/" "${SRCINFO}"
perl -0pi -e "s/(\\tpkgrel = ).*/\${1}1/" "${SRCINFO}"

echo "PKGBUILD and .SRCINFO updated."
