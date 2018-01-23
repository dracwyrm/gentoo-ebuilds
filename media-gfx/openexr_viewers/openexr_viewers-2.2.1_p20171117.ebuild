# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils flag-o-matic vcs-snapshot

DESCRIPTION="OpenEXR Viewers"
HOMEPAGE="http://openexr.com/"

MY_GIT_COMMIT="165dceaeee86e0f8ce1ed1db3e3030c609a49f17"
SRC_URI="https://github.com/openexr/openexr/archive/${MY_GIT_COMMIT}.tar.gz \
		-> OpenEXR-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0/23"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="cg"

RDEPEND="~media-libs/ilmbase-${PV}:=
	~media-libs/openexr-${PV}:=
	>=media-libs/ctl-1.5.2:=
	virtual/opengl
	x11-libs/fltk:1[opengl]
	cg? ( media-gfx/nvidia-cg-toolkit
	      || ( media-libs/freeglut media-libs/mesa[glut] ) )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/OpenEXR-${PV}/OpenEXR_Viewers"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.1-cmake-fixes.patch"
)

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package cg GLUT)
		$(cmake-utils_use_find_package cg Cg)
		-DOPENEXR_PACKAGE_PREFIX="${EPREFIX}/usr"
		-DILMBASE_PACKAGE_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
	)

	use cg && append-flags "$(no-as-needed)" # binary-only libCg is not properly linked

	cmake-utils_src_configure
}
