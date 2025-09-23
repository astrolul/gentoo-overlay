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
    dev-build/ninja
"

# minimal runtime deps (library is self-contained upstream)
RDEPEND="${DEPEND}"

src_prepare() {
    cmake_src_prepare
}

src_configure() {
    # Force release, static-by-default (upstream produces a static .a)
    cmake_src_configure -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DLC_LEVEL_4=OFF
}

src_compile() {
    cmake_src_compile
}

src_install() {
    local BUILD_DIR="${WORKDIR}/${P}_build"
    einfo "Scanning build tree for library files under ${BUILD_DIR}..."

    # try to find known library outputs (static first, then shared)
    local libfile
    libfile="$(find "${BUILD_DIR}" -type f -name 'libia_mpeghd_lib.a' -print -quit 2>/dev/null || true)"

    if [ -z "${libfile}" ]; then
        # fallback patterns for shared/static names upstream might use
        libfile="$(find "${BUILD_DIR}" -type f \( -name 'libMpeghDec*.so*' -o -name 'libMpeghDec*.a' -o -name 'libia_mpeghd_lib*' \) -print -quit 2>/dev/null || true)"
    fi

    if [ -z "${libfile}" ]; then
        die "No decoder library found in build tree (${BUILD_DIR}) — cannot install."
    fi

    einfo "Installing library: ${libfile}"
    case "${libfile##*.}" in
        a)
            dolib.a "${libfile}" || die "Failed to install static library ${libfile}"
            ;;
        so|so.*)
            dolib.so "${libfile}" || die "Failed to install shared library ${libfile}"
            ;;
        *)
            die "Unexpected library file type: ${libfile}"
            ;;
    esac

    # Install decoder executable (testbench)
    if [[ -x "${BUILD_DIR}/ia_mpeghd_testbench" ]]; then
        dobin "${BUILD_DIR}/ia_mpeghd_testbench" || die "Failed to install decoder binary"
    else
        ewarn "No testbench executable found — check build logs"
    fi

    # Find headers robustly (don't rely on a single glob)
    einfo "Searching source tree (${S}) for public headers..."
    # Prefer decoder headers first (upstream docs list 'impeghd_*.h').
    local headers
    headers="$(find "${S}/decoder" -maxdepth 3 -type f -name 'impeghd_*.h' -print 2>/dev/null || true)"

    if [ -z "${headers}" ]; then
        # fallback: any headers under decoder/
        headers="$(find "${S}/decoder" -maxdepth 4 -type f -name '*.h' -print 2>/dev/null || true)"
    fi

    if [ -z "${headers}" ]; then
        # final fallback: any .h under the source tree
        headers="$(find "${S}" -maxdepth 5 -type f -name '*.h' -print 2>/dev/null || true)"
    fi

    if [ -z "${headers}" ]; then
        die "No header files found in source tree (${S}). Aborting install."
    fi

    einfo "Installing headers into /usr/include/libmpegh"
    insinto /usr/include/libmpegh
    # install each header individually (doins with explicit files, not a raw glob)
    local hf
    for hf in ${headers}; do
        # only install the headers we really want (avoid copying test internals) — pick public names if possible
        # but if there are no 'impeghd_' headers we fall back to installing all found .h
        doins "${hf}" || die "doins failed for ${hf}"
    done

    # docs
    dodoc README.md LICENSE || die "Failed to install docs"
}
