# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils flag-o-matic

DESCRIPTION="OpenEXR Viewers"
HOMEPAGE="http://openexr.com/"
# changing sources. Using a revision on the binary in order
# to keep the old one for previous ebuilds.
SRC_URI="https://github.com/openexr/openexr/archive/v${PV}.tar.gz -> openexr-${PV}-r1.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="cg namespace-versioning"

RDEPEND="~media-libs/ilmbase-${PV}:=[namespace-versioning=]
	~media-libs/openexr-${PV}:=[namespace-versioning=]
	>=media-libs/ctl-1.5.2:=
	virtual/opengl
	x11-libs/fltk:1[opengl]
	cg? ( media-gfx/nvidia-cg-toolkit
	      || ( media-libs/freeglut media-libs/mesa[glut] ) )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/openexr-${PV}/OpenEXR_Viewers"

src_prepare() {
	default

	sed -e 's|doc/OpenEXR-${OPENEXR_VERSION}|share/doc/'${PF}'|' \
	    -i CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package cg GLUT)
		$(cmake-utils_use_find_package cg Cg)
		-DNAMESPACE_VERSIONING=$(usex namespace-versioning)
		-DOPENEXR_PACKAGE_PREFIX="/usr"
	)

	use cg && append-flags "$(no-as-needed)" # binary-only libCg is not properly linked

	cmake-utils_src_configure
}
