# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit libtool toolchain-funcs

DESCRIPTION="Unsymmetric multifrontal sparse LU factorization library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="http://202.36.178.9/sage/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~mips ~ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~x64-macos"
IUSE="+cholmod doc"

BDEPEND="virtual/pkgconfig
	doc? ( virtual/latex-base )"
DEPEND="
	sci-libs/amd
	>=sci-libs/suitesparseconfig-5.4.0
	virtual/blas
	cholmod? ( sci-libs/cholmod )"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	econf \
		--with-blas="$($(tc-getPKG_CONFIG) --libs blas)" \
		$(use_with doc) \
		$(use_with cholmod)
}

src_compile() {
	use doc && export VARTEXFONTS="${T}/fonts"
	default
}

src_install() {
	default

	# no static archives
	find "${D}" -name '*.la' -delete || die
}
