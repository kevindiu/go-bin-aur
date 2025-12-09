# go-bin AUR Package

[![Update AUR package](https://github.com/kevindiu/go-bin-aur/actions/workflows/update-aur.yml/badge.svg)](https://github.com/kevindiu/go-bin-aur/actions/workflows/update-aur.yml)

This repository contains the source for the [go-bin](https://aur.archlinux.org/packages/go-bin) Arch Linux User Repository (AUR) package.

It packages the official binary release of the [Go programming language](https://go.dev/) from Google.

## Automation

This package is automatically updated via GitHub Actions.
- **Check Frequency**: Daily at 03:00 UTC.
- **Logic**: 
    1. Checks `https://go.dev/VERSION` for the latest release.
    2. Updates `PKGBUILD` version.
    3. Runs `updpkgsums` to download sources and calculate SHA256 checksums.
    4. Generates `.SRCINFO` with `makepkg`.
    5. Pushes changes to AUR if a new version is detected.

## Manual Usage

To update manually:

```bash
./scripts/update-go-bin.sh
```

## Contributing

Pull requests are welcome. Please ensure changes follow Arch Linux packaging standards.
