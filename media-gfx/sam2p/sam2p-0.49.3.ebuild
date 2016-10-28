# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools eutils toolchain-funcs

DESCRIPTION="Utility to convert raster images to EPS, PDF and many others"
HOMEPAGE="https://github.com/pts/sam2p"
SRC_URI="https://github.com/pts/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="examples gif"

DEPEND="dev-lang/perl"

RESTRICT="test"

PATCHES=( "${FILESDIR}"/${P}-build-fixes.patch )

src_prepare() {
	default
	# eautoreconf is still needed or you get bad warnings
	eautoreconf
	tc-export CXX
}

src_configure() {
	econf --enable-lzw $(use_enable gif)
}

src_install() {
	dobin sam2p
	dodoc README

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
