# Building LinkCoin Qt GUI with Depends System

This guide explains how to build the LinkCoin Qt GUI (linkcoin-qt) using the depends build system for deterministic, reproducible, cross-platform builds.

## Overview

The `build-qt-with-depends.sh` script automates the process of building LinkCoin Qt GUI with all dependencies statically linked using the Bitcoin/altcoin depends build system.

## Features

- ✅ **Deterministic builds** - Same source produces identical binaries
- ✅ **Cross-platform** - Build for Linux, Windows, and macOS from Linux
- ✅ **Static linking** - All dependencies (Qt, Boost, OpenSSL, BerkeleyDB) statically linked
- ✅ **Portable binaries** - No external library dependencies (except system libraries)
- ✅ **Reproducible** - Anyone can verify the build produces the same binary
- ✅ **Configurable** - Enable/disable features like QR codes, UPnP, IPv6

## Supported Platforms

| Platform | Target Triple | Output Binary |
|----------|---------------|---------------|
| Linux 64-bit | x86_64-pc-linux-gnu | linkcoin-qt |
| Linux 32-bit | i686-pc-linux-gnu | linkcoin-qt |
| Windows 64-bit | x86_64-w64-mingw32 | linkcoin-qt.exe |
| Windows 32-bit | i686-w64-mingw32 | linkcoin-qt.exe |
| macOS 64-bit | x86_64-apple-darwin | Linkcoin-Qt.app |

## Prerequisites

### For Linux Builds

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    bsdmainutils \
    curl \
    git \
    python3
```

### For Windows Cross-Compilation

```bash
sudo apt-get install -y \
    g++-mingw-w64-x86-64 \
    mingw-w64-tools
```

### For macOS Cross-Compilation

```bash
# Requires macOS SDK (not covered here)
# See Bitcoin documentation for details
```

## Quick Start

### Build for Linux (Native)

```bash
# Full build with all dependencies
./build-qt-with-depends.sh

# Or with specific number of jobs
./build-qt-with-depends.sh --jobs 4
```

### Build for Windows (Cross-Compilation)

```bash
# Build for Windows 64-bit
./build-qt-with-depends.sh --target x86_64-w64-mingw32 --jobs 4

# Build for Windows 32-bit
./build-qt-with-depends.sh --target i686-w64-mingw32 --jobs 4
```

## Command Line Options

```
Usage: ./build-qt-with-depends.sh [OPTIONS]

OPTIONS:
    -h, --help              Show help message
    -t, --target TARGET     Target platform (default: x86_64-pc-linux-gnu)
    -j, --jobs N            Number of parallel jobs (default: nproc)
    -c, --clean             Clean build (remove previous artifacts)
    -s, --skip-depends      Skip building dependencies (use existing)
    --no-qrcode             Disable QR code support
    --enable-upnp           Enable UPnP support (default: disabled)
    --no-ipv6               Disable IPv6 support
```

## Build Process

The script performs the following steps:

### 1. Dependency Building (30-60 minutes first time)

The depends system builds all required libraries from source:

- **Qt 5.7.1** - GUI framework (Qt5Core, Qt5Gui, Qt5Widgets, Qt5Network)
- **Boost 1.63.0** - C++ libraries (system, filesystem, program_options, thread, chrono)
- **OpenSSL 1.0.2u** - Cryptography (ssl, crypto)
- **BerkeleyDB 4.8.30** - Wallet database
- **libqrencode 3.4.4** - QR code generation (optional)
- **miniupnpc** - UPnP support (optional)
- **LevelDB** - Blockchain database

For Linux, additional dependencies:
- **freetype** - Font rendering
- **fontconfig** - Font configuration
- **libxcb** - X11 protocol
- **libX11** - X11 client library
- **libXext** - X11 extensions
- **libxkbcommon** - Keyboard handling
- **expat** - XML parsing
- **dbus** - Inter-process communication
- **zlib** - Compression

### 2. Qt GUI Compilation (10-20 minutes)

The script uses qmake to generate a Makefile and then compiles:

- All Qt GUI source files (src/qt/*.cpp)
- All core LinkCoin source files (src/*.cpp)
- Qt UI forms (src/qt/forms/*.ui)
- Qt resources (src/qt/bitcoin.qrc)
- LevelDB library

### 3. Linking

All libraries are statically linked into the final binary:

- **Linux**: Only system libraries (libc, libpthread, libdl, librt, libX11, etc.) are dynamically linked
- **Windows**: Only Windows system DLLs (KERNEL32.dll, USER32.dll, etc.) are required

## Build Examples

### Example 1: Clean Build for Linux

```bash
./build-qt-with-depends.sh --clean --jobs 4
```

This will:
1. Clean all previous build artifacts
2. Build all dependencies from scratch
3. Build linkcoin-qt with 4 parallel jobs

### Example 2: Incremental Build (Skip Depends)

```bash
# First build (builds dependencies)
./build-qt-with-depends.sh --jobs 4

# Make code changes...

# Rebuild only LinkCoin (skip dependencies)
./build-qt-with-depends.sh --skip-depends --jobs 4
```

### Example 3: Windows Build without QR Codes

```bash
./build-qt-with-depends.sh \
    --target x86_64-w64-mingw32 \
    --no-qrcode \
    --jobs 4
```

### Example 4: Linux Build with UPnP

```bash
./build-qt-with-depends.sh \
    --enable-upnp \
    --jobs 4
```

## Build Time Estimates

| Build Type | First Build | Incremental Build |
|------------|-------------|-------------------|
| Linux (with Qt) | 45-60 min | 5-10 min |
| Windows (with Qt) | 50-70 min | 5-10 min |
| Linux (skip depends) | N/A | 5-10 min |
| Windows (skip depends) | N/A | 5-10 min |

*Times based on 4-core CPU with 8GB RAM*

## Output

### Successful Build Output

```
[SUCCESS] =========================================
[SUCCESS] Qt GUI Build completed successfully!
[SUCCESS] =========================================

[INFO] Target platform: x86_64-pc-linux-gnu
[INFO] Binary location: linkcoin-qt
[INFO] Binary size: 25M

[INFO] Features:
[INFO]   - QR Code support: enabled
[INFO]   - UPnP support: disabled
[INFO]   - IPv6 support: enabled

[INFO] To run the Qt GUI:
  ./linkcoin-qt
```

### Binary Information

**Linux (x86_64-pc-linux-gnu):**
```
File: linkcoin-qt
Size: ~25MB (stripped) or ~150MB (with debug symbols)
Type: ELF 64-bit LSB executable, x86-64
Dependencies: Only system libraries (libc, libpthread, libX11, etc.)
```

**Windows (x86_64-w64-mingw32):**
```
File: linkcoin-qt.exe
Size: ~30MB (stripped) or ~160MB (with debug symbols)
Type: PE32+ executable (GUI) x86-64, for MS Windows
Dependencies: Only Windows system DLLs (KERNEL32, USER32, GDI32, etc.)
```

## Troubleshooting

### Issue: "Qt libraries not found in depends"

**Solution:** Run without `--skip-depends` to build Qt:
```bash
./build-qt-with-depends.sh --jobs 4
```

### Issue: "Missing required tool: x86_64-w64-mingw32-g++"

**Solution:** Install MinGW cross-compiler:
```bash
sudo apt-get install g++-mingw-w64-x86-64 mingw-w64-tools
```

### Issue: Build fails with "out of memory"

**Solution:** Reduce parallel jobs:
```bash
./build-qt-with-depends.sh --jobs 2
```

Or increase swap space:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Issue: "qmake not found"

**Solution:** The script should use qmake from depends. If it fails, check:
```bash
ls -la depends/x86_64-pc-linux-gnu/bin/qmake
```

If missing, rebuild depends without `--skip-depends`.

## Advanced Usage

### Custom Boost Suffix

For platforms with different Boost naming conventions:

```bash
# Edit bitcoin-qt.pro and modify BOOST_LIB_SUFFIX
# The script automatically sets:
# - Linux: -mt
# - Windows: -mt-s
```

### Debug Build

To build with debug symbols (for development):

```bash
# Edit bitcoin-qt.pro and change:
# RELEASE=1 to RELEASE=0
./build-qt-with-depends.sh --jobs 4
```

### Strip Binary

To reduce binary size:

```bash
# Linux
strip linkcoin-qt

# Windows
x86_64-w64-mingw32-strip linkcoin-qt.exe
```

## Comparison with Daemon Build

| Feature | build-with-depends.sh | build-qt-with-depends.sh |
|---------|----------------------|--------------------------|
| Output | linkcoind (daemon) | linkcoin-qt (GUI) |
| Qt Dependencies | NO_QT=1 (skipped) | Qt built and linked |
| Build Time | 15-30 min | 45-60 min |
| Binary Size | ~10MB (stripped) | ~25MB (stripped) |
| Use Case | Servers, mining | Desktop wallets |

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Build Qt GUI

on: [push, pull_request]

jobs:
  build-linux:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config
      - name: Build Qt GUI
        run: |
          ./build-qt-with-depends.sh --jobs 4
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: linkcoin-qt-linux
          path: linkcoin-qt

  build-windows:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config g++-mingw-w64-x86-64
      - name: Build Qt GUI for Windows
        run: |
          ./build-qt-with-depends.sh --target x86_64-w64-mingw32 --jobs 4
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: linkcoin-qt-windows
          path: linkcoin-qt.exe
```

## See Also

- [build-with-depends.sh](build-with-depends.sh) - Build daemon (linkcoind)
- [depends/README.md](depends/README.md) - Depends system documentation
- [bitcoin-qt.pro](bitcoin-qt.pro) - Qt project file
- [BUILD_SUCCESS_SUMMARY.md](BUILD_SUCCESS_SUMMARY.md) - General build information

## License

Same as LinkCoin - see [COPYING](COPYING)
