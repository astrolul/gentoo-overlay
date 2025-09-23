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

src_compile() {
    cmake_src_compile
}

src_install() {
    # Install static library
    dolib.a "${BUILD_DIR}/libia_mpeghd_lib.a" || die "Failed to install static library"

    # Install headers
    insinto /usr/include/libmpegh
    doins "${S}/decoder/include/"*.h || die "Header install failed"

    # Documentation
    dodoc README.md LICENSE || die "Failed to install docs"
}
