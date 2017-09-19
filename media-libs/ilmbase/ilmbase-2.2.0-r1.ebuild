# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-multilib

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/12" # based on SONAME
KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"

DEPEND="virtual/pkgconfig"

MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/IlmBaseConfig.h )

PATCHES=(
	"${FILESDIR}/${P}-post-release-fixes-v20170109.patch"
	"${FILESDIR}/${P}-use-gnuinstall-dirs-and-fix-pkgconfig-file.patch"
)
