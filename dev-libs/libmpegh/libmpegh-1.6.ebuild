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
    # Debug: show build tree so you can see where the library is
    einfo "Listing build-tree files for diagnosis:"
    find "${WORKDIR}/${P}_build" -type f \
      | sed "s:^${WORKDIR}/${P}_build/::g" \
      || die "cannot list build tree"

    # Known library name patterns (shared / static)
    # Adjust these if upstream names differ
    local libnames_shared="libmpeghdec.so libmpegh_dec.so libmpegh_dec_shared.so"
    local libnames_static="libmpeghdec.a libmpegh_dec.a"

    local libpath=""
    local found=0

    # Try to find shared library first in common subdirs
    for nm in ${libnames_shared}; do
        # check top-level build
        if [[ -f "${WORKDIR}/${P}_build/${nm}" ]]; then
            libpath="${WORKDIR}/${P}_build}/${nm}"
            found=1
            break
        fi
        # check lib/ subdir
        if [[ -f "${WORKDIR}/${P}_build/lib/${nm}" ]]; then
            libpath="${WORKDIR}/${P}_build/lib/${nm}"
            found=1
            break
        fi
        # check decoder/ subdir
        if [[ -f "${WORKDIR}/${P}_build/decoder/${nm}" ]]; then
            libpath="${WORKDIR}/${P}_build/decoder/${nm}"
            found=1
            break
        fi
    done

    # If not found as shared, try static
    if [[ ${found} -eq 0 ]]; then
        for nm in ${libnames_static}; do
            if [[ -f "${WORKDIR}/${P}_build/${nm}" ]]; then
                libpath="${WORKDIR}/${P}_build/${nm}"
                found=1
                break
            fi
            if [[ -f "${WORKDIR}/${P}_build/lib/${nm}" ]]; then
                libpath="${WORKDIR}/${P}_build/lib/${nm}"
                found=1
                break
            fi
            if [[ -f "${WORKDIR}/${P}_build/decoder/${nm}" ]]; then
                libpath="${WORKDIR}/${P}_build/decoder/${nm}"
                found=1
                break
            fi
        done
    fi

    if [[ ${found} -eq 0 ]]; then
        die "No library file found in build tree – cannot install"
    fi

    # Install library (shared or static)
    case "${libpath##*.}" in
        so)
            dolib.so "${libpath}" || die "Failed to install shared library"
            ;;
        a)
            dolib.a "${libpath}" || die "Failed to install static library"
            ;;
        *)
            die "Library name has unexpected extension: ${libpath}"
            ;;
    esac

    # Install headers
    insinto /usr/include/libmpegh
    doins "${WORKDIR}/${P}/decoder/include/"*.h || die "Header install failed"

    # Documentation
    dodoc README.md LICENSE || die "Failed to install docs"
}
