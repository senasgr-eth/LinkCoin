#!/bin/bash
# LinkCoin Qt GUI Build Script with Depends System
# This script builds LinkCoin Qt GUI using the depends build system
# for deterministic, reproducible builds

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
DEFAULT_HOST="x86_64-pc-linux-gnu"
DEFAULT_JOBS=$(nproc)
CLEAN_BUILD=0
SKIP_DEPENDS=0
USE_QRCODE=1
USE_UPNP=0
USE_IPV6=1

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build LinkCoin Qt GUI using the depends build system.

OPTIONS:
    -h, --help              Show this help message
    -t, --target TARGET     Target platform (default: x86_64-pc-linux-gnu)
                            Options:
                              x86_64-pc-linux-gnu    - Linux 64-bit
                              i686-pc-linux-gnu      - Linux 32-bit
                              x86_64-w64-mingw32     - Windows 64-bit
                              i686-w64-mingw32       - Windows 32-bit
                              x86_64-apple-darwin    - macOS 64-bit
    -j, --jobs N            Number of parallel jobs (default: $(nproc))
    -c, --clean             Clean build (remove previous build artifacts)
    -s, --skip-depends      Skip building dependencies (use existing)
    --no-qrcode             Disable QR code support
    --enable-upnp           Enable UPnP support (default: disabled)
    --no-ipv6               Disable IPv6 support
    
EXAMPLES:
    # Build Qt GUI for Linux 64-bit (default)
    $0
    
    # Build for Windows 64-bit
    $0 --target x86_64-w64-mingw32
    
    # Build with 4 parallel jobs
    $0 --jobs 4
    
    # Clean build for Windows
    $0 --target x86_64-w64-mingw32 --clean
    
    # Skip depends build (use existing dependencies)
    $0 --skip-depends
    
    # Build without QR code support
    $0 --no-qrcode

EOF
    exit 0
}

# Parse command line arguments
HOST="$DEFAULT_HOST"
JOBS="$DEFAULT_JOBS"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -t|--target)
            HOST="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        -s|--skip-depends)
            SKIP_DEPENDS=1
            shift
            ;;
        --no-qrcode)
            USE_QRCODE=0
            shift
            ;;
        --enable-upnp)
            USE_UPNP=1
            shift
            ;;
        --no-ipv6)
            USE_IPV6=0
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate target
case "$HOST" in
    x86_64-pc-linux-gnu|i686-pc-linux-gnu|x86_64-w64-mingw32|i686-w64-mingw32|x86_64-apple-darwin)
        print_info "Target platform: $HOST"
        ;;
    *)
        print_error "Invalid target platform: $HOST"
        usage
        ;;
esac

# Determine if cross-compiling
if [[ "$HOST" == "x86_64-pc-linux-gnu" ]]; then
    CROSS_COMPILE=0
    print_info "Building for native Linux x86_64"
else
    CROSS_COMPILE=1
    print_info "Cross-compiling for $HOST"
fi

# Check for required tools
print_info "Checking for required tools..."

REQUIRED_TOOLS="make g++ pkg-config autoconf automake"
if [[ "$HOST" == *"mingw"* ]]; then
    # Check for specific mingw compiler
    if [[ "$HOST" == "x86_64-w64-mingw32" ]]; then
        MINGW_COMPILER="x86_64-w64-mingw32-g++"
    else
        MINGW_COMPILER="i686-w64-mingw32-g++"
    fi

    if ! command -v $MINGW_COMPILER &> /dev/null; then
        print_error "Missing required tool: $MINGW_COMPILER"
        print_info "Install it with: sudo apt-get install g++-mingw-w64"
        exit 1
    fi
fi

MISSING_TOOLS=""
for tool in $REQUIRED_TOOLS; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS="$MISSING_TOOLS $tool"
    fi
done

if [[ -n "$MISSING_TOOLS" ]]; then
    print_error "Missing required tools:$MISSING_TOOLS"
    print_info "Install them with: sudo apt-get install$MISSING_TOOLS"
    exit 1
fi

print_success "All required tools found"

# Clean build if requested
if [[ $CLEAN_BUILD -eq 1 ]]; then
    print_info "Cleaning previous build artifacts..."
    
    # Clean depends
    if [[ -d "depends" ]]; then
        cd depends
        make clean HOST="$HOST" 2>/dev/null || true
        rm -rf work build "$HOST" 2>/dev/null || true
        cd ..
    fi
    
    # Clean Qt build artifacts
    make -f Makefile clean 2>/dev/null || true
    rm -f Makefile Makefile.Release Makefile.Debug 2>/dev/null || true
    rm -rf build/ 2>/dev/null || true
    rm -f linkcoin-qt linkcoin-qt.exe 2>/dev/null || true
    rm -f object_script.* 2>/dev/null || true
    
    print_success "Clean completed"
fi

# Build dependencies
if [[ $SKIP_DEPENDS -eq 0 ]]; then
    print_info "Building dependencies for $HOST (including Qt)..."
    print_info "This may take 30-60 minutes on first build..."
    print_warning "Qt compilation is very time-consuming, please be patient!"
    
    cd depends
    
    # Build depends WITHOUT NO_QT flag (to include Qt)
    print_info "Building with Qt GUI support"
    
    # Build depends
    if make HOST="$HOST" -j"$JOBS"; then
        print_success "Dependencies built successfully"
    else
        print_error "Failed to build dependencies"
        exit 1
    fi
    
    cd ..
else
    print_warning "Skipping depends build (using existing dependencies)"
    
    # Check if dependencies exist
    if [[ ! -d "depends/$HOST" ]]; then
        print_error "Dependencies not found for $HOST"
        print_info "Run without --skip-depends to build them first"
        exit 1
    fi
    
    # Check if Qt was built
    if [[ ! -d "depends/$HOST/lib" ]] || ! ls depends/$HOST/lib/libQt5* &> /dev/null; then
        print_error "Qt libraries not found in depends/$HOST"
        print_info "Qt dependencies are required for GUI build"
        print_info "Run without --skip-depends to build Qt"
        exit 1
    fi
fi

# Build LinkCoin Qt GUI
print_info "Building LinkCoin Qt GUI..."

# Determine binary name based on target
if [[ "$HOST" == *"mingw"* ]]; then
    BINARY_NAME="linkcoin-qt.exe"
else
    BINARY_NAME="linkcoin-qt"
fi

# Set depends path
DEPENDS_PATH="$(pwd)/depends/$HOST"

# Determine qmake to use
if [[ -f "$DEPENDS_PATH/bin/qmake" ]]; then
    QMAKE="$DEPENDS_PATH/bin/qmake"
    print_info "Using depends qmake: $QMAKE"
elif command -v qmake &> /dev/null; then
    QMAKE="qmake"
    print_warning "Using system qmake (not from depends)"
else
    print_error "qmake not found"
    exit 1
fi

# Prepare qmake arguments
QMAKE_ARGS=""

# Set library paths from depends
QMAKE_ARGS+=" BOOST_INCLUDE_PATH=$DEPENDS_PATH/include"
QMAKE_ARGS+=" BOOST_LIB_PATH=$DEPENDS_PATH/lib"
QMAKE_ARGS+=" BDB_INCLUDE_PATH=$DEPENDS_PATH/include"
QMAKE_ARGS+=" BDB_LIB_PATH=$DEPENDS_PATH/lib"
QMAKE_ARGS+=" OPENSSL_INCLUDE_PATH=$DEPENDS_PATH/include"
QMAKE_ARGS+=" OPENSSL_LIB_PATH=$DEPENDS_PATH/lib"
QMAKE_ARGS+=" QRENCODE_INCLUDE_PATH=$DEPENDS_PATH/include"
QMAKE_ARGS+=" QRENCODE_LIB_PATH=$DEPENDS_PATH/lib"

# Set Boost library suffix based on platform
if [[ "$HOST" == *"mingw"* ]]; then
    # Windows uses -mt-s suffix for static multi-threaded
    QMAKE_ARGS+=" BOOST_LIB_SUFFIX=-mt-s"
    QMAKE_ARGS+=" BOOST_THREAD_LIB_SUFFIX=_win32-mt-s"
else
    # Linux uses -mt suffix
    QMAKE_ARGS+=" BOOST_LIB_SUFFIX=-mt"
    QMAKE_ARGS+=" BOOST_THREAD_LIB_SUFFIX=-mt"
fi

# Set BDB library suffix
QMAKE_ARGS+=" BDB_LIB_SUFFIX="

# Set feature flags
if [[ $USE_QRCODE -eq 1 ]]; then
    QMAKE_ARGS+=" USE_QRCODE=1"
    print_info "QR code support: enabled"
else
    QMAKE_ARGS+=" USE_QRCODE=0"
    print_info "QR code support: disabled"
fi

if [[ $USE_UPNP -eq 1 ]]; then
    QMAKE_ARGS+=" USE_UPNP=1"
    QMAKE_ARGS+=" MINIUPNPC_INCLUDE_PATH=$DEPENDS_PATH/include"
    QMAKE_ARGS+=" MINIUPNPC_LIB_PATH=$DEPENDS_PATH/lib"
    print_info "UPnP support: enabled"
else
    QMAKE_ARGS+=" USE_UPNP=-"
    print_info "UPnP support: disabled"
fi

if [[ $USE_IPV6 -eq 1 ]]; then
    QMAKE_ARGS+=" USE_IPV6=1"
    print_info "IPv6 support: enabled"
else
    QMAKE_ARGS+=" USE_IPV6=-"
    print_info "IPv6 support: disabled"
fi

# Set release mode
QMAKE_ARGS+=" RELEASE=1"

# Set cross-compilation spec for Windows
if [[ "$HOST" == "x86_64-w64-mingw32" ]]; then
    QMAKE_SPEC="win32-g++"
    export PATH="$DEPENDS_PATH/bin:$PATH"
    export PKG_CONFIG_PATH="$DEPENDS_PATH/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Set cross-compile tools
    QMAKE_ARGS+=" QMAKE_CC=x86_64-w64-mingw32-gcc"
    QMAKE_ARGS+=" QMAKE_CXX=x86_64-w64-mingw32-g++"
    QMAKE_ARGS+=" QMAKE_AR=x86_64-w64-mingw32-ar"
    QMAKE_ARGS+=" QMAKE_RANLIB=x86_64-w64-mingw32-ranlib"
    QMAKE_ARGS+=" QMAKE_STRIP=x86_64-w64-mingw32-strip"

    print_info "Using Windows cross-compilation spec: $QMAKE_SPEC"
elif [[ "$HOST" == "i686-w64-mingw32" ]]; then
    QMAKE_SPEC="win32-g++"
    export PATH="$DEPENDS_PATH/bin:$PATH"
    export PKG_CONFIG_PATH="$DEPENDS_PATH/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Set cross-compile tools
    QMAKE_ARGS+=" QMAKE_CC=i686-w64-mingw32-gcc"
    QMAKE_ARGS+=" QMAKE_CXX=i686-w64-mingw32-g++"
    QMAKE_ARGS+=" QMAKE_AR=i686-w64-mingw32-ar"
    QMAKE_ARGS+=" QMAKE_RANLIB=i686-w64-mingw32-ranlib"
    QMAKE_ARGS+=" QMAKE_STRIP=i686-w64-mingw32-strip"

    print_info "Using Windows cross-compilation spec: $QMAKE_SPEC"
else
    # Linux native build
    export PATH="$DEPENDS_PATH/bin:$PATH"
    export PKG_CONFIG_PATH="$DEPENDS_PATH/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="$DEPENDS_PATH/lib:$LD_LIBRARY_PATH"
fi

# Generate Makefile with qmake
print_info "Generating Makefile with qmake..."
print_info "Command: $QMAKE bitcoin-qt.pro $QMAKE_ARGS"

if [[ -n "$QMAKE_SPEC" ]]; then
    if $QMAKE bitcoin-qt.pro -spec $QMAKE_SPEC $QMAKE_ARGS; then
        print_success "Makefile generated successfully"
    else
        print_error "Failed to generate Makefile"
        exit 1
    fi
else
    if $QMAKE bitcoin-qt.pro $QMAKE_ARGS; then
        print_success "Makefile generated successfully"
    else
        print_error "Failed to generate Makefile"
        exit 1
    fi
fi

# Build with make
print_info "Building $BINARY_NAME..."
print_info "This may take 10-20 minutes..."

if make -j"$JOBS"; then
    print_success "Build completed successfully!"
else
    print_error "Build failed"
    exit 1
fi

# Check if binary exists
if [[ -f "$BINARY_NAME" ]]; then
    BINARY_SIZE=$(du -h "$BINARY_NAME" | cut -f1)
    print_success "Binary: $BINARY_NAME ($BINARY_SIZE)"

    # Show file info
    print_info "Binary information:"
    file "$BINARY_NAME"

    # Show dependencies (for Linux)
    if [[ "$HOST" == "x86_64-pc-linux-gnu" ]]; then
        print_info "Dynamic dependencies:"
        ldd "$BINARY_NAME" | head -20

        # Check for static linking of our dependencies
        if ! ldd "$BINARY_NAME" | grep -qE "boost|ssl|crypto|db_cxx"; then
            print_success "All application dependencies are statically linked!"
        else
            print_warning "Some dependencies are dynamically linked"
        fi
    elif [[ "$HOST" == *"mingw"* ]]; then
        print_info "Windows DLL dependencies:"
        if command -v x86_64-w64-mingw32-objdump &> /dev/null; then
            x86_64-w64-mingw32-objdump -p "$BINARY_NAME" | grep "DLL Name" | head -20
        fi
    fi
else
    print_error "Binary not found: $BINARY_NAME"
    exit 1
fi

# Summary
echo ""
print_success "========================================="
print_success "Qt GUI Build completed successfully!"
print_success "========================================="
echo ""
print_info "Target platform: $HOST"
print_info "Binary location: $BINARY_NAME"
print_info "Binary size: $BINARY_SIZE"
echo ""
print_info "Features:"
print_info "  - QR Code support: $([ $USE_QRCODE -eq 1 ] && echo 'enabled' || echo 'disabled')"
print_info "  - UPnP support: $([ $USE_UPNP -eq 1 ] && echo 'enabled' || echo 'disabled')"
print_info "  - IPv6 support: $([ $USE_IPV6 -eq 1 ] && echo 'enabled' || echo 'disabled')"
echo ""

if [[ "$HOST" == "x86_64-pc-linux-gnu" ]]; then
    print_info "To run the Qt GUI:"
    echo "  ./$BINARY_NAME"
elif [[ "$HOST" == *"mingw"* ]]; then
    print_info "To run on Windows:"
    echo "  Copy $BINARY_NAME to a Windows machine"
    echo "  Double-click or run: $BINARY_NAME"
fi

echo ""
print_info "For more information, see README.md"

