# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Check 'next' branch for backports.

inherit autotools multilib-minimal

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Protocol Buffers implementation in C"
HOMEPAGE="https://github.com/protobuf-c/protobuf-c"
SRC_URI="
	https://github.com/${PN}/${PN}/releases/download/v${MY_PV}/${MY_P}.tar.gz
	https://github.com/protobuf-c/protobuf-c/commit/25174818178d4761f971dab1c47083b892297dc2.patch
		-> ${PN}-1.5.1-protobuf-30.patch
"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD-2"
# Subslot == SONAME version
SLOT="0/1.0.0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="static-libs"

BDEPEND="
	>=dev-libs/protobuf-3:0
	virtual/pkgconfig
"
DEPEND="
	>=dev-libs/protobuf-3:0=[${MULTILIB_USEDEP}]"
# NOTE
# protobuf links to abseil-cpp libraries via it's .pc files.
# To cause rebuild when the abseil-cpp version changes we add it to RDEPEND only.
RDEPEND="${DEPEND}
	dev-cpp/abseil-cpp:=[${MULTILIB_USEDEP}]
"

src_prepare() {
	if has_version ">=dev-libs/protobuf-30"; then
		eapply "${DISTDIR}/${PN}-1.5.1-protobuf-30.patch"
	fi

	default
	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		--enable-year2038
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -type f -delete || die
	einstalldocs
}
