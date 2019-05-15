# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_5,3_6} )

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/STEllAR-GROUP/hpx.git"
else
	SRC_URI="https://stellar.cct.lsu.edu/files/${PN}_${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
	S="${WORKDIR}/${PN}_${PV}"
fi
inherit cmake-utils fortran-2 python-any-r1

DESCRIPTION="C++ runtime system for parallel and distributed applications"
HOMEPAGE="https://stellar.cct.lsu.edu/tag/hpx/"

SLOT="0"
LICENSE="Boost-1.0"
IUSE="doc examples jemalloc papi +perftools tbb test"

REQUIRED_USE="?? ( jemalloc perftools tbb )"

BDEPEND="
	virtual/pkgconfig
	doc? ( >=dev-libs/boost-1.56.0-r1[tools] )
"
RDEPEND="
	>=dev-libs/boost-1.49:=
	>=sys-apps/hwloc-1.8
	>=sys-libs/libunwind-1
	sys-libs/zlib
	papi? ( dev-libs/papi )
	perftools? ( >=dev-util/google-perftools-1.7.1 )
	tbb? ( dev-cpp/tbb )
"
DEPEND="${RDEPEND}
	test? ( ${PYTHON_DEPS} )
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DHPX_BUILD_EXAMPLES=OFF
		-DHPX_MALLOC=system
		-DLIB=$(get_libdir)
		-Dcmake_dir=cmake
		-DHPX_BUILD_DOCUMENTATION=$(usex doc)
		-DHPX_JEMALLOC=$(usex jemalloc)
		-DBUILD_TESTING=$(usex test)
		-DHPX_GOOGLE_PERFTOOLS=$(usex perftools)
		-DHPX_PAPI=$(usex papi)
	)

	use jemalloc && mycmakeargs+=( -DHPX_MALLOC=jemalloc )
	use perftools && mycmakeargs+=( -DHPX_MALLOC=tcmalloc )
	use tbb && mycmakeargs+=( -DHPX_MALLOC=tbbmalloc )

	cmake-utils_src_configure
}

src_test() {
	# avoid over-suscribing
	cmake-utils_src_make -j1 tests
}

src_install() {
	cmake-utils_src_install
	mv "${D}/usr/bin/spin" "${D}/usr/bin/hpx_spin" || die
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
