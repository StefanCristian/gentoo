# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="Trivial metaprogramming tool"
HOMEPAGE="https://github.com/ocaml-ppx/cinaps"
SRC_URI="https://github.com/ocaml-ppx/cinaps/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="amd64 arm arm64 ~ppc ppc64 ~riscv x86"
IUSE="+ocamlopt test"
RESTRICT="!test? ( test )"

DEPEND="dev-ml/re:="
RDEPEND="${DEPEND}"
BDEPEND="test? ( dev-ml/ppx_jane )"

PATCHES=( "${FILESDIR}"/${P}-test.patch )
