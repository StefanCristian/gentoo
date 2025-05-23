# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

MY_P1=${P^^}
MY_P=${MY_P1//./_}

DESCRIPTION="A tool for controlling amateur radios"
HOMEPAGE="http://groundstation.sourceforge.net/grig/"
SRC_URI="https://github.com/fillods/grig/releases/download//${MY_P}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	>=media-libs/hamlib-4:="
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/grig-0.8.1-hamlib46.patch )

src_configure() {
	econf --enable-hardware
}

src_install() {
	default
	make_desktop_entry ${PN} "GRig" "/usr/share/pixmaps/grig/grig-logo.png" "HamRadio"
	rm -rf "${ED}/usr/share/grig" || die "cleanup docs failed"
}
