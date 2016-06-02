# Copyright 2016 Adrian Grigo <agrigo2001@yahoo.com.au>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils cmake-utils

DESCRIPTION="Per-Face Texture Mapping for Production Rendering"
HOMEPAGE="http://ptex.us/"
SRC_URI="http://github.com/wdas/ptex/archive/v${PV}.zip -> ${P}.zip"
LICENSE="PTEX"
SLOT="0"
DEPEND=">=dev-util/cmake-2.8
	app-arch/unzip
	sys-libs/zlib
	app-doc/doxygen"

KEYWORDS="~amd64 ~x86"

PATCHES=( "${FILESDIR}/${P}-install-version-header.patch" )
