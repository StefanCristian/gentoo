# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature xdg

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discord.com/"
SRC_URI="https://dl.discordapp.net/apps/linux/${PV}/${P}.tar.gz"

S="${WORKDIR}/${PN^}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip test"

RDEPEND="
	sys-libs/glibc
"

QA_PREBUILT="*"

src_install() {
	dobin "${PN}"

	insinto "/usr/share/${PN}"
	insopts -m0755
	doins updater_bootstrap

	doicon -s 256 "${PN}.png"
	domenu "${PN}.desktop"
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "GUI progress dialog during first-run bootstrap" gnome-extra/zenity
	einfo "Discord 1.0.x is a bootstrapper: the real client is downloaded to"
	einfo "~/.config/discord/ on first launch and is not managed by Portage."
}
