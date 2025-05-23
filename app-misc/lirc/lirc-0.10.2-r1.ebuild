# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

inherit autotools linux-info python-single-r1 xdg-utils

DESCRIPTION="decode and send infra-red signals of many commonly used remote controls"
HOMEPAGE="https://www.lirc.org/"

LIRC_DRIVER_DEVICE="/dev/lirc0"

MY_P=${PN}-${PV/_/-}
S="${WORKDIR}/${MY_P}"

if [[ ${PV} == *_pre* ]] ; then
	SRC_URI="https://www.lirc.org/software/snapshots/${MY_P}.tar.bz2"
elif [[ ${PV} == *_p* ]] ; then
	inherit autotools
	SRC_URI="https://downloads.sourceforge.net/lirc/${PN}-$(ver_cut 1-3).tar.bz2"
	SRC_URI+=" mirror://debian/pool/main/l/${PN}/${PN}_$(ver_cut 1-3)-$(ver_cut 5-).debian.tar.xz"
	S="${WORKDIR}"/${PN}-$(ver_cut 1-3)
else
	SRC_URI="https://downloads.sourceforge.net/lirc/${MY_P}.tar.bz2"
fi

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~loong ppc ppc64 ~riscv x86"
IUSE="audio +devinput doc ftdi gtk inputlirc selinux static-libs systemd +uinput usb X"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	gtk? ( X )
"

COMMON_DEPEND="
	${PYTHON_DEPS}
	audio? (
		>media-libs/portaudio-18
		media-libs/alsa-lib
	)
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
	ftdi? ( dev-embedded/libftdi:0 )
	systemd? ( sys-apps/systemd )
	usb? ( virtual/libusb:0 )
	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
	)
"

DEPEND="
	${COMMON_DEPEND}
	dev-libs/libxslt
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
	')
	doc? ( app-text/doxygen )
	sys-apps/kmod
	sys-kernel/linux-headers
"

RDEPEND="
	${COMMON_DEPEND}
	gtk? (
		x11-libs/vte[introspection]
		$(python_gen_cond_dep '
			dev-python/pygobject[${PYTHON_USEDEP}]
		')
	)
	inputlirc? ( app-misc/inputlircd )
	selinux? ( sec-policy/selinux-lircd )
"

PATCHES=(
	"${FILESDIR}/${PN}-0.10.1-runtimedirectory.patch"
	"${FILESDIR}/${PN}-0.10.2-fix-python-pkg.patch"
)

MAKEOPTS+=" -j1"

pkg_setup() {
	use uinput && CONFIG_CHECK="~INPUT_UINPUT"
	python-single-r1_pkg_setup
	linux-info_pkg_setup
}

src_prepare() {
	default

	if [[ -d "${WORKDIR}"/debian/patches ]] ; then
		eapply $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die)
	fi

	# https://bugs.gentoo.org/922209
	sed -i -e "/^libpython / s|\$(libdir)/python\$(PYTHON_VERSION)|$(python_get_stdlib)|" Makefile.am || die
	sed -i -e "/^libpython / s|\$(libdir)/python\$(PYTHON_VERSION)|$(python_get_stdlib)|" tools/Makefile.am || die

	eautoreconf
}

src_configure() {
	xdg_environment_reset
	econf \
		--localstatedir="${EPREFIX}/var" \
		$(use_enable static-libs static) \
		$(use_enable devinput) \
		$(use_enable uinput) \
		$(use_with X x)
}

src_install() {
	default

	if use !gtk ; then
		# lirc-setup requires gtk
		rm "${ED}"/usr/bin/lirc-setup || die
	fi

	newinitd "${FILESDIR}"/lircd-0.8.6-r2 lircd
	newinitd "${FILESDIR}"/lircmd-0.9.4a-r2 lircmd
	newconfd "${FILESDIR}"/lircd.conf.4 lircd
	newconfd "${FILESDIR}"/lircmd-0.10.0.conf lircmd

	insinto /etc/modprobe.d/
	newins "${FILESDIR}"/modprobed.lirc lirc.conf

	newinitd "${FILESDIR}"/irexec-initd-0.9.4a-r2 irexec
	newconfd "${FILESDIR}"/irexec-confd irexec

	keepdir /etc/lirc
	if [[ -e "${ED}"/etc/lirc/lircd.conf ]]; then
		newdoc "${ED}"/etc/lirc/lircd.conf lircd.conf.example
	fi

	find "${ED}" -name '*.la' -delete || die

	# https://bugs.gentoo.org/830522
	python_optimize

	# Avoid QA notice
	rm -d "${ED}"/var/run/lirc || die
	rm -d "${ED}"/var/run || die
}

pkg_preinst() {
	local dir="${EROOT}/etc/modprobe.d"
	if [[ -a "${dir}"/lirc && ! -a "${dir}"/lirc.conf ]]; then
		elog "Renaming ${dir}/lirc to lirc.conf"
		mv -f "${dir}/lirc" "${dir}/lirc.conf" || die
	fi

	# copy the first file that can be found
	if [[ -f "${EROOT}"/etc/lirc/lircd.conf ]]; then
		cp "${EROOT}"/etc/lirc/lircd.conf "${T}"/lircd.conf || die
	elif [[ -f "${EROOT}"/etc/lircd.conf ]]; then
		cp "${EROOT}"/etc/lircd.conf "${T}"/lircd.conf || die
		MOVE_OLD_LIRCD_CONF=1
	elif [[ -f "${ED}"/etc/lirc/lircd.conf ]]; then
		cp "${ED}"/etc/lirc/lircd.conf "${T}"/lircd.conf || die
	fi

	# stop portage from touching the config file
	if [[ -e "${ED}"/etc/lirc/lircd.conf ]]; then
		rm -f "${ED}"/etc/lirc/lircd.conf || die
	fi
}

pkg_postinst() {
	# copy config file to new location
	# without portage knowing about it
	# so it will not delete it on unmerge or ever touch it again
	if [[ -e "${T}"/lircd.conf ]]; then
		cp "${T}"/lircd.conf "${EROOT}"/etc/lirc/lircd.conf || die
		if [[ "$MOVE_OLD_LIRCD_CONF" = "1" ]]; then
			elog "Moved /etc/lircd.conf to /etc/lirc/lircd.conf"
			rm -f "${EROOT}"/etc/lircd.conf || die
		fi
	fi

	einfo "The new default location for lircd.conf is inside of"
	einfo "${EROOT}/etc/lirc/ directory"
}
