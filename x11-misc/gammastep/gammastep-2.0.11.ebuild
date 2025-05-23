# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..13} )

inherit autotools systemd xdg-utils python-r1

DESCRIPTION="A screen color temperature adjusting software"
HOMEPAGE="https://gitlab.com/chinstrap/gammastep"
SRC_URI="https://gitlab.com/chinstrap/gammastep/-/archive/v${PV}/gammastep-v${PV}.tar.bz2"

S="${WORKDIR}"/${PN}-v${PV}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ppc64 ~x86"
IUSE="appindicator geoclue gtk nls wayland"

COMMON_DEPEND=">=x11-libs/libX11-1.4
	x11-libs/libXxf86vm
	x11-libs/libxcb
	x11-libs/libdrm
	appindicator? ( dev-libs/libayatana-appindicator )
	geoclue? ( app-misc/geoclue:2.0 dev-libs/glib:2 )
	gtk? ( ${PYTHON_DEPS} )"
RDEPEND="${COMMON_DEPEND}
	gtk? ( dev-python/pygobject[${PYTHON_USEDEP}]
		x11-libs/gtk+:3[introspection]
		dev-python/pyxdg[${PYTHON_USEDEP}] )"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	nls? ( sys-devel/gettext )
"
REQUIRED_USE="gtk? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use gtk && python_setup

	econf \
		$(use_enable nls) \
		--enable-drm \
		$(use_enable wayland) \
		--enable-randr \
		--enable-vidmode \
		$(use_enable geoclue geoclue2) \
		$(use_enable gtk gui) \
		--enable-apparmor \
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
}

_impl_specific_src_install() {
	emake DESTDIR="${D}" \
		PYTHON="${PYTHON}" \
		pythondir="$(python_get_sitedir)" \
		-C src/gammastep_indicator install
}

src_install() {
	emake DESTDIR="${D}" UPDATE_ICON_CACHE=/bin/true install

	if use gtk; then
		python_foreach_impl _impl_specific_src_install
		python_replicate_script "${D}"/usr/bin/gammastep-indicator

		python_foreach_impl python_optimize
	fi

	insinto /etc/gammastep/
	newins gammastep.conf.sample config.ini.example
}

pkg_postinst() {
	use gtk && xdg_icon_cache_update
}

pkg_postrm() {
	use gtk && xdg_icon_cache_update
}
