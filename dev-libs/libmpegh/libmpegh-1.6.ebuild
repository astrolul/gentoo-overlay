# dev-libs/libmpeghe/libmpegh-1.6.ebuild
EAPI=8

DESCRIPTION="MPEG-H 3D Audio Low Complexity Profile decoder (libmpegh)"
HOMEPAGE="https://github.com/ittiam-systems/libmpegh"
SRC_URI="https://github.com/ittiam-systems/libmpegh/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3-Clause-Clear"
SLOT="0"
KEYWORDS=""
IUSE=""

# build-time deps
DEPEND="
    dev-util/cmake
    sys-devel/gcc
    sys-devel/make
    app-misc/pkgconfig
"

# minimal runtime deps (library is self-contained upstream)
RDEPEND="${DEPEND}"

inherit git-r3

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

