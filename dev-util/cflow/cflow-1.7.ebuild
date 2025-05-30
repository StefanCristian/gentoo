# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit elisp-common flag-o-matic

DESCRIPTION="C function call hierarchy analyzer"
HOMEPAGE="https://www.gnu.org/software/cflow/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug emacs nls"

RDEPEND="emacs? ( >=app-editors/emacs-23.1:* )
	nls? ( virtual/libintl virtual/libiconv )"
DEPEND="nls? ( virtual/libintl virtual/libiconv )"
BDEPEND="emacs? ( >=app-editors/emacs-23.1:* )
	app-alternatives/lex
	nls? ( sys-devel/gettext )"

SITEFILE="50${PN}-gentoo.el"

src_configure() {
	# bug #944004
	append-flags -std=gnu17

	econf \
		$(use_enable nls) \
		$(use_enable debug) \
		EMACS=no
}

src_compile() {
	default

	if use emacs; then
		elisp-compile elisp/cflow-mode.el
	fi
}

src_install() {
	default
	doinfo doc/cflow.info

	if use emacs; then
		elisp-install ${PN} elisp/cflow-mode.{el,elc}
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
