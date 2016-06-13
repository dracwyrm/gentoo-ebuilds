# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="Per-Face Texture Mapping for Production Rendering"
HOMEPAGE="http://ptex.us/"
SRC_URI="http://github.com/wdas/ptex/archive/v${PV}.zip -> ${P}.zip"
LICENSE="Ptex"
SLOT="0"
RDEPEND="app-arch/unzip
	sys-libs/zlib"
DEPEND="${RDEPEND}
	app-doc/doxygen"

KEYWORDS="~amd64 ~x86"
