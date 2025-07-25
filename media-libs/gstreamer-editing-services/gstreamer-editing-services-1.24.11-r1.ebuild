# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )

inherit meson python-r1

DESCRIPTION="SDK for making video editors and more"
HOMEPAGE="http://wiki.pitivi.org/wiki/GES"
SRC_URI="https://gstreamer.freedesktop.org/src/${PN}/${P/gstreamer/gst}.tar.xz"
S="${WORKDIR}"/${P/gstreamer/gst}

LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="amd64 ~arm64 x86"

IUSE="+introspection test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
# Some tests are failing
RESTRICT="test"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.40.0:2
	dev-libs/libxml2:2=
	>=media-libs/gstreamer-${PV}:1.0[introspection?]
	>=media-libs/gst-plugins-base-${PV}:1.0[introspection?]
	>=media-libs/gst-plugins-bad-${PV}:1.0[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	python_setup

	local emesonargs=(
		-Ddoc=disabled # hotdoc not packaged
		$(meson_feature introspection)
		$(meson_feature test tests)
		-Dbash-completion=disabled
		-Dxptv=disabled
		-Dpython=enabled
		-Dvalidate=disabled
		-Dexamples=disabled
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_moduleinto gi.overrides
	python_foreach_impl python_domodule bindings/python/gi/overrides/GES.py
}
