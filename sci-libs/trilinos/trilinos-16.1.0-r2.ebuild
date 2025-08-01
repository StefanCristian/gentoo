# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR=emake
inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="Scientific library collection for large scale problems"
HOMEPAGE="http://trilinos.sandia.gov/"
MY_PV="${PV//\./-}"
PATCHSET="r0"
SRC_URI="https://github.com/${PN}/Trilinos/archive/${PN}-release-${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Trilinos-${PN}-release-${MY_PV}"

LICENSE="BSD LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

IUSE="
	adolc all-packages arprec clp cuda eigen glpk gtest hdf5 hwloc hypre
	matio metis mkl mumps netcdf openmp petsc qd scalapack scotch sparse
	superlu taucs tbb test threads tvmet yaml zlib X
"

# TODO: fix export cmake function for tests
RESTRICT="test"

RDEPEND="
	!dev-cpp/kokkos
	dev-libs/boost:=
	sys-libs/binutils-libs:=
	virtual/blas
	virtual/lapack
	virtual/mpi
	adolc? ( sci-libs/adolc )
	arprec? ( sci-libs/arprec )
	clp? ( sci-libs/coinor-clp )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-3.2 )
	eigen? ( dev-cpp/eigen:3 )
	glpk? ( sci-mathematics/glpk )
	gtest? ( dev-cpp/gtest )
	hdf5? ( sci-libs/hdf5:=[mpi] )
	hypre? ( sci-libs/hypre:= )
	hwloc? ( sys-apps/hwloc:= )
	matio? ( sci-libs/matio )
	mkl? ( sci-libs/mkl )
	metis? ( sci-libs/metis )
	mumps? ( sci-libs/mumps )
	netcdf? ( sci-libs/netcdf:= )
	petsc? ( sci-mathematics/petsc )
	qd? ( sci-libs/qd )
	scalapack? ( sci-libs/scalapack )
	scotch? ( sci-libs/scotch:= )
	sparse? ( sci-libs/cxsparse sci-libs/umfpack )
	superlu? ( <sci-libs/superlu-5.0.0:= )
	taucs? ( sci-libs/taucs )
	tbb? ( dev-cpp/tbb:= )
	tvmet? ( dev-libs/tvmet )
	yaml? ( dev-cpp/yaml-cpp:= )
	zlib? ( sys-libs/zlib )
	X? ( x11-libs/libX11 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

PATCHES=(
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

trilinos_conf() {
	local dirs libs d
	for d in $($(tc-getPKG_CONFIG) --libs-only-L $1); do
		dirs="${dirs};${d:2}"
	done
	[[ -n ${dirs} ]] && mycmakeargs+=( "-D${2}_LIBRARY_DIRS=${dirs:1}" )
	for d in $($(tc-getPKG_CONFIG) --libs-only-l $1); do
		libs="${libs};${d:2}"
	done
	[[ -n ${libs} ]] && mycmakeargs+=( "-D${2}_LIBRARY_NAMES=${libs:1}" )
	dirs=""
	for d in $($(tc-getPKG_CONFIG) --cflags-only-I $1); do
		dirs="${dirs};${d:2}"
	done
	[[ -n ${dirs} ]] && mycmakeargs+=( "-D${2}_INCLUDE_DIRS=${dirs:1}" )
}

src_configure() {
	# Trilinos is a massive C++ project. Fixing all of the lto warnings and
	# making safe for lto compilation/linking will be a massive
	# undertaking. Thus, simply filter lto flags. bug #862987
	filter-lto

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_SKIP_RPATH=ON
		-DCMAKE_SKIP_INSTALL_RPATH=ON
		-DTrilinos_INSTALL_INCLUDE_DIR="${EPREFIX}/usr/include/trilinos"
		-DTrilinos_INSTALL_LIB_DIR="${EPREFIX}/usr/$(get_libdir)/trilinos"
		-DTrilinos_ENABLE_ALL_PACKAGES="$(usex all-packages)"
		-DTrilinos_ENABLE_PyTrilinos=OFF
		-DTrilinos_ENABLE_Amesos=ON
		-DTrilinos_ENABLE_AztecOO=ON
		-DTrilinos_ENABLE_EpetraExt=ON
		-DTrilinos_ENABLE_Epetra=ON
		-DTrilinos_ENABLE_Ifpack=ON
		-DTrilinos_ENABLE_ML=ON
		-DTrilinos_ENABLE_MueLu=ON
		-DTrilinos_ENABLE_OpenMP="$(usex openmp)"
		-DTrilinos_ENABLE_ROL=ON
		-DTrilinos_ENABLE_Sacado=ON
		-DTrilinos_ENABLE_Teuchos=ON
		-DTrilinos_ENABLE_Tpetra=ON
		-DTrilinos_ENABLE_Zoltan=ON
		-DTrilinos_ENABLE_TESTS="$(usex test)"
		-DTPL_ENABLE_BinUtils=ON
		-DTPL_ENABLE_BLAS=ON
		-DTPL_ENABLE_LAPACK=ON
		-DTPL_ENABLE_MPI=ON
		-DTPL_ENABLE_ADOLC="$(usex adolc)"
		-DTPL_ENABLE_AMD="$(usex sparse)"
		-DTPL_ENABLE_ARPREC="$(usex arprec)"
		-DTPL_ENABLE_BLACS="$(usex scalapack)"
		-DTPL_ENABLE_BoostLib=ON
		-DTPL_ENABLE_Boost=ON
		-DTPL_ENABLE_Clp="$(usex clp)"
		-DTPL_ENABLE_CSparse="$(usex sparse)"
		-DTPL_ENABLE_CUDA="$(usex cuda)"
		-DTPL_ENABLE_CUSPARSE="$(usex cuda)"
		-DTPL_ENABLE_Eigen="$(usex eigen)"
		-DTPL_ENABLE_GLPK="$(usex glpk)"
		-DTPL_ENABLE_gtest="$(usex gtest)"
		-DTPL_ENABLE_HDF5="$(usex hdf5)"
		-DTPL_ENABLE_HWLOC="$(usex hwloc)"
		-DTPL_ENABLE_HYPRE="$(usex hypre)"
		-DTPL_ENABLE_Matio="$(usex matio)"
		-DTPL_ENABLE_METIS="$(usex metis)"
		-DTPL_ENABLE_MKL="$(usex mkl)"
		-DTPL_ENABLE_MUMPS="$(usex mumps)"
		-DTPL_ENABLE_Netcdf="$(usex netcdf)"
		-DTPL_ENABLE_PARDISO_MKL="$(usex mkl)"
		-DTPL_ENABLE_PETSC="$(usex petsc)"
		-DTPL_ENABLE_Pthread="$(usex threads)"
		-DTPL_ENABLE_QD="$(usex qd)"
		-DTPL_ENABLE_SCALAPACK="$(usex scalapack)"
		-DTPL_ENABLE_Scotch="$(usex scotch)"
		-DTPL_ENABLE_SuperLU="$(usex superlu)"
		-DTPL_ENABLE_TAUCS="$(usex taucs)"
		-DTPL_ENABLE_TBB="$(usex tbb)"
		-DTPL_ENABLE_TVMET="$(usex tvmet)"
		-DTPL_ENABLE_UMFPACK="$(usex sparse)"
		-DTPL_ENABLE_X11="$(usex X)"
		-DTPL_ENABLE_yamlcpp="$(usex yaml)"
		-DTPL_ENABLE_Zlib="$(usex zlib)"
	)

	#
	# Make sure some critical configuration options are always set
	# correctly independently of what Trilinos dependency resolver thinks
	# it should be doing.
	#
	local mycmakeargs+=(
		-DAmesos2_ENABLE_LAPACK=ON
		-DAmesos2_ENABLE_MUMPS=OFF
		-DTpetra_INST_SERIAL=ON
	)

	use eigen && \
		mycmakeargs+=(
		-DEigen_INCLUDE_DIRS="${EPREFIX}/usr/include/eigen3"
	)
	use hypre && \
		mycmakeargs+=(
		-DHYPRE_INCLUDE_DIRS="${EPREFIX}/usr/include/hypre"
	)
	use scotch && \
		mycmakeargs+=(
		-DScotch_INCLUDE_DIRS="${EPREFIX}/usr/include/scotch"
	)

	# cxsparse is a rewrite of csparse + extras
	use sparse && \
		mycmakeargs+=(
		-DCSparse_LIBRARY_NAMES="cxsparse"
	)

	# mandatory blas and lapack
	trilinos_conf blas BLAS
	trilinos_conf lapack LAPACK
	use superlu && trilinos_conf superlu SuperLU
	use metis && trilinos_conf metis METIS

	# blacs library is included in scalapack these days
	if use scalapack; then
		trilinos_conf scalapack SCALAPACK
		mycmakeargs+=(
			-DBLACS_LIBRARY_NAMES="scalapack"
			-DBLACS_INCLUDE_DIRS="${EPREFIX}/usr/include/blacs"
		)
	fi

	#
	# Make sure we use the compiler wrappers in order to build trilinos.
	#
	[ ! -z "${CC}"] && export OMPI_CC="${CC}" MPICH_CC="${CC}" && tc-export OMPI_CC MPICH_CC
	[ ! -z "${CXX}"] && export OMPI_CXX="${CXX}" MPICH_CXX="${CXX}" && tc-export OMPI_CXX MPICH_CXX
	export CC=mpicc CXX=mpicxx && tc-export CC CXX

	# Trilinos needs a custom build type:
	local CMAKE_BUILD_TYPE=Release

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Move the cmake directory to the right location:
	mkdir -p "${ED}/usr/$(get_libdir)"/cmake
	mv "${ED}/usr/$(get_libdir)"/trilinos/cmake/* "${ED}/usr/$(get_libdir)"/cmake || die "mv failed"
	# Fix up include paths:
	sed -i -e 's#external_packages#trilinos/external_packages#g' \
		"${ED}/usr/$(get_libdir)"/cmake/**/*.cmake || die "sed failed"
	rmdir "${ED}/usr/$(get_libdir)/trilinos/cmake" || die "rmdir failed"

	# Register $(get_libdir)/trilinos in LDPATH so that the dynamic linker
	# has a chance to pick up the libraries, also add Trilinos' binaries ot
	# the PATH environment variable.
	cat >> "${T}"/99trilinos <<- EOF
	LDPATH="${EPREFIX}/usr/$(get_libdir)/trilinos"
	PATH="${EPREFIX}/usr/$(get_libdir)/trilinos/bin"
	EOF
	doenvd "${T}"/99trilinos
}
