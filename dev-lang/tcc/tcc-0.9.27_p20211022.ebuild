# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_COMMIT="16456168430c9e185dd94b8215aa77d02bbb8a2c"
DESCRIPTION="A very small C compiler for ix86/amd64"
HOMEPAGE="https://bellard.org/tcc/"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://repo.or.cz/r/tinycc.git"
	inherit git-r3
elif [[ ${PV} == *_p* ]] ; then
	SRC_URI="https://repo.or.cz/tinycc.git/snapshot/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}"/tinycc-1645616
else
	SRC_URI="https://download.savannah.gnu.org/releases/tinycc/${P}.tar.bz2"
fi

LICENSE="LGPL-2.1"
SLOT="0"
if [[ ${PV} != *9999* ]] ; then
	KEYWORDS="~amd64 ~x86 ~amd64-linux"
fi

BDEPEND="dev-lang/perl" # doc generation
IUSE="test"
RESTRICT="!test? ( test )"

src_prepare() {
	default

	# Don't strip
	sed -i \
		-e 's|$(INSTALL) -s|$(INSTALL)|' \
		-e 's|STRIP_yes = -s|STRIP_yes =|' \
		Makefile || die

	# Fix examples
	sed -i -e '1{
		i#! /usr/bin/tcc -run
		/^#!/d
	}' examples/ex*.c || die
	sed -i -e '1s/$/ -lX11/' examples/ex4.c || die

	# Fix texi2html invocation
	sed -i -e 's/-number//' Makefile || die
	sed -i -e 's/--sections//' Makefile || die
}

src_configure() {
	use test && unset CFLAGS LDFLAGS # Tests run with CC=tcc etc, they will fail hard otherwise
					# better fixes welcome, it feels wrong to hack the env like this

	# not autotools, so call configure directly
	./configure --cc="$(tc-getCC)" \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_compile() {
	emake AR="$(tc-getAR)"
}

src_test() {
	# this is using tcc bits that don't know as-needed etc.
	TCCFLAGS="" emake test
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc Changelog README TODO VERSION
	#dohtml tcc-doc.html
	exeinto /usr/share/doc/${PF}/examples
	doexe examples/ex*.c
}
