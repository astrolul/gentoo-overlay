# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# simple-deinterlacer-9999.ebuild

EAPI=8

inherit git-r3

PROPERTIES="live"

DESCRIPTION="A simple bash script to deinterlace any video file using ffmpeg"
HOMEPAGE="https://github.com/astrolul/simple-deinterlacer"
EGIT_REPO_URI="https://github.com/astrolul/simple-deinterlacer.git"

SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
    >=app-shells/bash-4
    media-video/ffmpeg
"

DEPEND="${RDEPEND}"

src_unpack() {
    # Clone the Git repo into ${WORKDIR}/${P} (automatically S)
    git-r3_src_unpack
}

src_install() {
    # Install with desired name, stripping .sh suffix
    newbin simple-deinterlacer.sh simple-deinterlacer
}

pkg_postinst() {
    elog "To run the script, just use 'simple-deinterlacer <video-file>'"
}
