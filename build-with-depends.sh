#!/bin/bash
# LinkCoin Build Script with Depends System
# This script builds LinkCoin daemon using the depends build system
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
BUILD_QT=0
CLEAN_BUILD=0
SKIP_DEPENDS=0

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

Build LinkCoin daemon using the depends build system.

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
    -q, --qt                Build Qt GUI (default: daemon only)
    -c, --clean             Clean build (remove previous build artifacts)
    -s, --skip-depends      Skip building dependencies (use existing)
    
EXAMPLES:
    # Build for Linux 64-bit (default)
    $0
    
    # Build for Windows 64-bit
    $0 --target x86_64-w64-mingw32
    
    # Build with 4 parallel jobs
    $0 --jobs 4
    
    # Clean build for Windows
    $0 --target x86_64-w64-mingw32 --clean
    
    # Skip depends build (use existing dependencies)
    $0 --skip-depends

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
        -q|--qt)
            BUILD_QT=1
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        -s|--skip-depends)
            SKIP_DEPENDS=1
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
    
    # Clean src
    if [[ -d "src" ]]; then
        cd src
        make -f makefile.unix clean 2>/dev/null || true
        rm -rf obj/*.o obj/*.P obj-test/*.o obj-test/*.P 2>/dev/null || true
        rm -f linkcoind linkcoin-cli test_linkcoin 2>/dev/null || true
        cd ..
    fi
    
    print_success "Clean completed"
fi

# Build dependencies
if [[ $SKIP_DEPENDS -eq 0 ]]; then
    print_info "Building dependencies for $HOST..."
    print_info "This may take 15-30 minutes on first build..."
    
    cd depends
    
    # Set NO_QT flag
    if [[ $BUILD_QT -eq 0 ]]; then
        NO_QT_FLAG="NO_QT=1"
        print_info "Building without Qt (daemon only)"
    else
        NO_QT_FLAG=""
        print_info "Building with Qt GUI support"
    fi
    
    # Build depends
    if make HOST="$HOST" $NO_QT_FLAG -j"$JOBS"; then
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
fi

# Build LinkCoin
print_info "Building LinkCoin daemon..."

cd src

# Determine makefile and build command based on target
if [[ "$HOST" == *"mingw"* ]]; then
    # Windows cross-compilation
    print_info "Using cross-compilation for Windows"
    
    MAKEFILE="makefile.mingw"
    
    # Check if makefile.mingw exists, if not use makefile.unix with modifications
    if [[ ! -f "$MAKEFILE" ]]; then
        print_warning "makefile.mingw not found, using makefile.unix with cross-compile settings"
        MAKEFILE="makefile.unix"
    fi
    
    # Set cross-compile environment
    if [[ "$HOST" == "x86_64-w64-mingw32" ]]; then
        export CC=x86_64-w64-mingw32-gcc
        export CXX=x86_64-w64-mingw32-g++
        export AR=x86_64-w64-mingw32-ar
        export RANLIB=x86_64-w64-mingw32-ranlib
    else
        export CC=i686-w64-mingw32-gcc
        export CXX=i686-w64-mingw32-g++
        export AR=i686-w64-mingw32-ar
        export RANLIB=i686-w64-mingw32-ranlib
    fi
    
    BINARY_NAME="linkcoind.exe"
else
    # Linux native or cross-compilation
    MAKEFILE="makefile.unix"
    BINARY_NAME="linkcoind"
fi

# Build command
DEPENDS_PATH="../depends/$HOST"

if make -f "$MAKEFILE" \
    STATIC=1 \
    BOOST_INCLUDE_PATH="$DEPENDS_PATH/include" \
    BOOST_LIB_PATH="$DEPENDS_PATH/lib" \
    BDB_INCLUDE_PATH="$DEPENDS_PATH/include" \
    BDB_LIB_PATH="$DEPENDS_PATH/lib" \
    OPENSSL_INCLUDE_PATH="$DEPENDS_PATH/include" \
    OPENSSL_LIB_PATH="$DEPENDS_PATH/lib" \
    -j"$JOBS"; then
    
    print_success "LinkCoin built successfully!"
    
    # Check if binary exists
    if [[ -f "$BINARY_NAME" ]]; then
        BINARY_SIZE=$(du -h "$BINARY_NAME" | cut -f1)
        print_success "Binary: src/$BINARY_NAME ($BINARY_SIZE)"
        
        # Show file info
        print_info "Binary information:"
        file "$BINARY_NAME"
        
        # Show dependencies (for Linux)
        if [[ "$HOST" == "x86_64-pc-linux-gnu" ]]; then
            print_info "Dynamic dependencies:"
            ldd "$BINARY_NAME" | grep -v "=>" | head -10
            
            # Check for static linking of our dependencies
            if ! ldd "$BINARY_NAME" | grep -qE "boost|ssl|crypto|db_cxx"; then
                print_success "All application dependencies are statically linked!"
            else
                print_warning "Some dependencies are dynamically linked"
            fi
        fi
    else
        print_error "Binary not found: $BINARY_NAME"
        exit 1
    fi
else
    print_error "Failed to build LinkCoin"
    exit 1
fi

cd ..

# Summary
echo ""
print_success "========================================="
print_success "Build completed successfully!"
print_success "========================================="
echo ""
print_info "Target platform: $HOST"
print_info "Binary location: src/$BINARY_NAME"
print_info "Binary size: $BINARY_SIZE"
echo ""

if [[ "$HOST" == "x86_64-pc-linux-gnu" ]]; then
    print_info "To run the daemon:"
    echo "  ./src/linkcoind"
elif [[ "$HOST" == *"mingw"* ]]; then
    print_info "To run on Windows:"
    echo "  Copy src/linkcoind.exe to a Windows machine"
    echo "  Run: linkcoind.exe"
fi

echo ""
print_info "For more information, see README.md"

