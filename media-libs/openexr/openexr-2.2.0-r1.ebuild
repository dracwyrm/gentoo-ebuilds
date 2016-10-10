# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils multilib-minimal

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/22" # based on SONAME
KEYWORDS="~amd64 -arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="examples static-libs"

RDEPEND=">=sys-libs/zlib-1.2.8-r1:=[${MULTILIB_USEDEP}]
	>=media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	!!<media-libs/${P}"

MY_S="${WORKDIR}/${P}"
DOCS=( ${MY_S}/AUTHORS ${MY_S}/ChangeLog ${MY_S}/NEWS ${MY_S}/README )

PATCHES=( "${FILESDIR}"/${P}-fix-cpuid-on-abi_x86_32.patch
	  "${FILESDIR}"/${P}-use-ull-for-64-bit-literals.patch )

src_prepare() {
	# Fix path for testsuite
	sed -i -e "s:/var/tmp/:${T}:" IlmImfTest/tmpDir.h || die
	default
}

multilib_src_configure() {
	local docdir="${EPREFIX}"/usr/share/doc/${PF}
	local myconf=(
		$(use_enable static-libs static)
		$(use_enable examples imfexamples)
		--docdir=${docdir}
		--pdfdir=${docdir}/pdf
	)
	# Enable building out-of-source using sources in ${S}
	ECONF_SOURCE=${S} \
	econf "${myconf[@]}"
}

multilib_src_install() {
	emake install DESTDIR="${D}" \
		docdir="${EPREFIX}"/usr/share/doc/${PF}/pdf \
		examplesdir="${EPREFIX}"/usr/share/doc/${PF}/examples
	docompress -x /usr/share/doc/${PF}/examples
	use examples || rm -rf "${ED}"/usr/share/doc/${PF}/examples
	einstalldocs
}
