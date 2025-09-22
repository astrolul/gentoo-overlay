# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# simple-deinterlacer-9999.ebuild

EAPI=8

inherit git-r3

DESCRIPTION="A simple bash script to deinterlace any video file using ffmpeg"
HOMEPAGE="https://github.com/astrolul/simple-deinterlacer"
SRC_URI="git://github.com/astrolul/simple-deinterlacer.git"

SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
    >=app-shells/bash-4
    media-video/ffmpeg
"

DEPEND="${RDEPEND}"

S=${P}

src_unpack() {
    # git-r3 should handle the clone; make sure script is executable
    default
    dodir "${WORKDIR}"
}

src_install() {
    # Install the bash script so it is runnable by user
    # The upstream script is simple-deinterlacer.sh, we'll install it as simple-deinterlacer
    dodir /usr/bin
    # make sure script has executable permissions
    dobin simple-deinterlacer.sh

    # Optionally rename so user doesn't need .sh suffix
    # We can install with a wrapper or symlink
    # Method 1: directly copy as simple-deinterlacer
    # Using dosym or cp; but better to install with dobin, then rename.

    # Let's install renamed script:
    dodir /usr/bin
    # Remove extension
    doexe simple-deinterlacer.sh /usr/bin/simple-deinterlacer
}

pkg_postinst() {
    elog "To run the script, just use 'simple-deinterlacer <video-file>'"
}
