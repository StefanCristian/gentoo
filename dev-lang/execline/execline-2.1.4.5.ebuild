# Copyright 2013-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="a non-interactive scripting language similar to SH"
HOMEPAGE="http://www.skarnet.org/software/execline/"
SRC_URI="http://www.skarnet.org/software/${PN}/${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static static-libs"

DEPEND=">=sys-devel/make-4.0
	static? ( >=dev-libs/skalibs-2.3.8.3[static-libs] )
	!static? ( >=dev-libs/skalibs-2.3.8.3 )
"
RDEPEND="!static? ( >=dev-libs/skalibs-2.3.8.3 )"

src_prepare() {
	# Remove QA warning about LDFLAGS addition
	sed -i "s~tryldflag LDFLAGS_AUTO -Wl,--hash-style=both~:~" "${S}/configure" || die
}

src_configure()
{
	econf \
		$(use_enable static-libs static) \
		$(use_enable static allstatic) \
		$(use_enable !static shared) \
		--bindir=/bin \
		--sbindir=/sbin \
		--dynlibdir=/$(get_libdir) \
		--libdir=/usr/$(get_libdir)/${PN} \
		--datadir=/etc \
		--sysdepdir=/usr/$(get_libdir)/${PN} \
		--with-dynlib=/$(get_libdir) \
		--with-lib=/usr/$(get_libdir)/skalibs \
		--with-sysdeps=/usr/$(get_libdir)/skalibs
}

src_compile()
{
	emake DESTDIR="${D}"
}

src_install()
{
	default
	dohtml -r doc/*
}
