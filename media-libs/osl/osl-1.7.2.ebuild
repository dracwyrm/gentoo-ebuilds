# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"

SRC_URI="https://github.com/imageworks/OpenShadingLanguage/archive/Release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="c++11 doc test"

RDEPEND="
	media-libs/openexr
	media-libs/openimageio
	dev-libs/pugixml
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-libs/boost
	<sys-devel/llvm-3.6.0
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

# Restricting tests as Make file handles them differently
RESTRICT="test"

S=${WORKDIR}/OpenShadingLanguage-Release-${PV}

PATCHES=(
	"${FILESDIR}"/${P}-remove-mcjit.patch
	"${FILESDIR}"/${PN}-boost-compile-fix
	"${FILESDIR}"/${PN}-fix-pdf-install-dir
)

src_configure() {
	local mycmakeargs=(
		-DUSE_EXTERNAL_PUGIXML=ON
		-DOSL_BUILD_CPP11=$(usex c++11 ON OFF)
		-DENABLERTTI=OFF
		-DSTOP_ON_WARNING=OFF
		-DSELF_CONTAINED_INSTALL_TREE=OFF
		-DOSL_BUILD_TESTS=$(usex test ON OFF)
		-DINSTALL_DOCS=$(usex doc ON OFF)
	)

	cmake-utils_src_configure
}
