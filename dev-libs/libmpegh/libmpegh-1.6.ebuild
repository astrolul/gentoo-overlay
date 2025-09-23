# dev-libs/libmpeghe/libmpegh-1.6.ebuild
EAPI=8

inherit cmake

DESCRIPTION="MPEG-H 3D Audio Low Complexity Profile decoder (libmpegh)"
HOMEPAGE="https://github.com/ittiam-systems/libmpegh"
SRC_URI="https://github.com/ittiam-systems/libmpegh/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3-Clause-Clear"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# build-time deps
DEPEND="
    dev-build/cmake
    sys-devel/gcc
    dev-build/make
    dev-util/pkgconf
"

# minimal runtime deps (library is self-contained upstream)
RDEPEND="${DEPEND}"

src_prepare() {
    cmake_src_prepare
}

src_configure() {
    # Optionally enable LC_LEVEL_4 if desired; default is level 3
    cmake_src_configure -DLC_LEVEL_4=OFF
}

src_compile() {
    cmake_src_compile
}

src_install() {
    # Expected shared library name from upstream
    local lib_shared="${BUILD_DIR}/decoder/lib/libMpeghDec.so"
    local lib_static="${BUILD_DIR}/decoder/lib/libMpeghDecStatic.a"

    if [[ -f "${lib_shared}" ]]; then
        dolib.so "${lib_shared}" || die "Failed to install shared library"
    elif [[ -f "${lib_static}" ]]; then
        dolib.a "${lib_static}" || die "Failed to install static library"
    else
        die "No decoder library found in ${BUILD_DIR}/decoder/lib"
    fi

    # Install headers
    insinto /usr/include/libmpegh
    doins "${S}/decoder/include/"*.h || die "Header install failed"

    # Documentation
    dodoc README.md LICENSE || die "Failed to install docs"
}
