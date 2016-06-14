# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"

SRC_URI="https://github.com/imageworks/OpenShadingLanguage/archive/Release-${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/dracwyrm/gentoo-patches/raw/master/${PN}/${PV}/${P}-patchset-1.tar.xz"

LICENSE="Osl"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="<dev-libs/boost-1.61.0
	<sys-devel/llvm-3.6.0
	media-libs/openexr
	media-libs/openimageio
	dev-libs/pugixml
	sys-libs/zlib
"

# Restricting tests
RESTRICT="test"

S=${WORKDIR}/OpenShadingLanguage-Release-${PV}

PATCHES=( "${WORKDIR}"/${P}-patchset-1.patch )

src_configure() {
	local mycmakeargs=(
		-DUSE_EXTERNAL_PUGIXML=ON
		-DOSL_BUILD_CPP11=ON
		-DENABLERTTI=OFF
		-DSTOP_ON_WARNING=OFF
		-DSELF_CONTAINED_INSTALL_TREE=OFF
		-DOSL_BUILD_TESTS=$(usex test ON OFF)
		-DINSTALL_DOCS=$(usex doc ON OFF)
	)

	cmake-utils_src_configure
}
