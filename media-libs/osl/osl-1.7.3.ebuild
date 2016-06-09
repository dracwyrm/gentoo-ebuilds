# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGIT_REPO_URI="https://github.com/imageworks/OpenShadingLanguage.git"
EGIT_BRANCH="RB-1.7"

inherit cmake-utils git-r3

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"

LICENSE="Osl"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="test"

RDEPEND="dev-libs/boost
	media-libs/openexr
	media-libs/openimageio
	dev-libs/pugixml
	sys-libs/zlib
	"

# Restricting tests
RESTRICT="test"

src_configure() {
	local mycmakeargs=(
		-DUSE_EXTERNAL_PUGIXML=ON
		-DOSL_BUILD_CPP11=ON
		-DENABLERTTI=OFF
	)

	cmake-utils_src_configure
}
