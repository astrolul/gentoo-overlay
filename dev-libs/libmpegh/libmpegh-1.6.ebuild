# dev-libs/libmpeghe/libmpegh-1.6.ebuild
EAPI=8

inherit git-r3

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

# prefer to use a private build dir for out-of-source CMake builds
src_configure() {
    cmake -S "${WORKDIR}/${P}" -B "${WORKDIR}/cmake_build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=/usr || die "cmake configure failed"
}

src_compile() {
    emake -C "${WORKDIR}/cmake_build" || die "compile failed"
}

src_install() {
    emake -C "${WORKDIR}/cmake_build" DESTDIR="${D}" install || die "install failed"

    # install license & readme
    dodoc "${WORKDIR}/${P}/README.md" "${WORKDIR}/${P}/LICENSE" || true
}

