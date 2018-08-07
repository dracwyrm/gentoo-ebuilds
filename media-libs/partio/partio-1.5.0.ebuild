# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit cmake-utils python-single-r1

DESCRIPTION="A library for particle IO and manipulation"
HOMEPAGE="http://www.disneyanimation.com/technology/partio.html"

SRC_URI="https://github.com/wdas/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	media-libs/freeglut
	sys-libs/zlib:=
	virtual/opengl
"

DEPEND="${RDEPEND}
	dev-lang/swig:*
	doc? ( app-doc/doxygen[latex] )
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package doc Doxygen)
	)

	cmake-utils_src_configure
}
