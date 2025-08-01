# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit edo vim-plugin python-single-r1

MY_PN="${PN}-vim"
DESCRIPTION="vim plugin: binding to the autocompletion library jedi"
HOMEPAGE="https://github.com/davidhalter/jedi-vim"
SRC_URI="https://github.com/davidhalter/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_PN}-${PV}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '>=dev-python/jedi-0.19[${PYTHON_USEDEP}]')
	|| (
		app-editors/vim[python,${PYTHON_SINGLE_USEDEP}]
		app-editors/gvim[python,${PYTHON_SINGLE_USEDEP}]
	)
"
BDEPEND="
	test? (
		${RDEPEND}
		app-vim/vspec
	)
"

DOCS=( AUTHORS.txt CONTRIBUTING.md README.rst )

PATCHES=(
	# https://github.com/davidhalter/jedi-vim/pull/1131
	# Seemingly fallout from jedi/parso update
	"${FILESDIR}"/${P}-remove-unreasonable-test.patch
)

src_prepare() {
	vim-plugin_src_prepare

	rm doc/logotype-a.svg || die
	rmdir pythonx/{jedi,parso} || die
}

# Makefile tries hard to call tests so let's silence this phase.
src_compile() { :; }

src_test() {
	local bindir="${S}"/venv/bin
	local sitedir="${S}"/venv/lib/${EPYTHON}/site-packages

	mkdir -p "${bindir}" || die
	mkdir -p "${sitedir}" || die
	ln -s "${PYTHON}" "${bindir}/${EPYTHON}" || die
	ln -s "${EPYTHON}" "${bindir}/python3" || die
	ln -s "${EPYTHON}" "${bindir}/python" || die
	cat > "${bindir}"/pyvenv.cfg <<-EOF || die
		include-system-site-packages = false
	EOF

	ln -s "$(python_get_sitedir)"/parso "${sitedir}"/parso || die
	cp -r "$(python_get_sitedir)"/parso-*.dist-info "${sitedir}" || die

	ln -s "$(python_get_sitedir)"/jedi "${sitedir}"/jedi || die
	cp -r "$(python_get_sitedir)"/jedi-*.dist-info "${sitedir}" || die

	export PATH="${bindir}:${PATH}"
	unset PYTHONPATH

	edo prove-vspec -d "${S}" test/vspec
}

src_install() {
	vim-plugin_src_install pythonx
	python_optimize "${ED}"/usr/share/vim/vimfiles/pythonx
}
