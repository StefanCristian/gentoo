# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Note: please bump this together with mail-mta/sendmail and mail-filter/libmilter

inherit toolchain-funcs

DESCRIPTION="Sendmail restricted shell, for use with MTAs other than Sendmail"
HOMEPAGE="https://www.proofpoint.com/us/products/email-protection/open-source-email-solution"
if [[ -n $(ver_cut 4) ]] ; then
	# Snapshots have an extra version component (e.g. 8.17.1 vs 8.17.1.9)
	SRC_URI="https://ftp.sendmail.org/snapshots/sendmail.${PV}.tar.gz"
fi
SRC_URI+=" https://ftp.sendmail.org/sendmail.${PV}.tar.gz"
SRC_URI+=" https://ftp.sendmail.org/past-releases/sendmail.${PV}.tar.gz"
S="${WORKDIR}/sendmail-${PV}"

LICENSE="Sendmail"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="!mail-mta/sendmail"
DEPEND="${RDEPEND}
	sys-devel/m4"

src_prepare() {
	local confENVDEF="-DXDEBUG=0"

	eapply "${FILESDIR}"/${PN}-8.18.1-c23-sm_strtoll.patch

	if use elibc_musl; then
		eapply "${FILESDIR}"/${PN}-musl-disable-cdefs.patch
		confENVDEF+=" -DHASSTRERROR"
	fi

	cd "${S}/${PN}" || die

	default

	sed -e "s:/usr/libexec:/usr/sbin:g" \
		-e "s:/usr/adm/sm.bin:/var/lib/smrsh:g" \
		-i README -i smrsh.8 || die "sed failed"

	sed -e "s|@@confCCOPTS@@|${CFLAGS}|" \
		-e "s|@@confLDOPTS@@|${LDFLAGS}|" \
		-e "s|@@confENVDEF@@|${confENVDEF}|" \
		-e "s:@@confCC@@:$(tc-getCC):" "${FILESDIR}/site.config.m4" \
		> "${S}/devtools/Site/site.config.m4" || die "sed failed"
}

src_compile() {
	cd "${S}/${PN}" || die
	/bin/sh Build AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" || die
}

src_install() {
	dosbin "${S}/obj.$(uname -s).$(uname -r).$(arch)/${PN}/${PN}"

	cd "${S}/${PN}" || die
	doman "${PN}.8"
	dodoc README

	keepdir /var/lib/${PN}
}

pkg_postinst() {
	elog "smrsh is compiled to look for programs in /var/lib/smrsh."
}
