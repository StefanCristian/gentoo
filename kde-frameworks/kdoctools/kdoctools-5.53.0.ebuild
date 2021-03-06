# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_QTHELP="false"
inherit kde5

DESCRIPTION="Tools to generate documentation in various formats from DocBook files"
LICENSE="MIT"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="nls"

RDEPEND="
	$(add_frameworks_dep karchive)
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	app-text/sgml-common
	dev-libs/libxml2:2
	dev-libs/libxslt
"
DEPEND="${RDEPEND}
	dev-lang/perl
	dev-perl/URI
	nls? ( $(add_frameworks_dep ki18n) )
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package nls KF5I18n)
	)

	kde5_src_configure
}
