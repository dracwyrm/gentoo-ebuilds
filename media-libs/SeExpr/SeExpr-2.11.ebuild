# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit cmake-utils python-single-r1

DESCRIPTION="An embeddable expression evaluation engine"
HOMEPAGE="http://www.disneyanimation.com/technology/seexpr.html"

SRC_URI="https://github.com/wdas/SeExpr/archive/v2.11.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="docs"

RDEPEND="sys-devel/llvm
	dev-libs/boost[python]
	dev-cpp/gtest
	media-libs/libpng:=
	virtual/opengl
	dev-qt/qtcore:4=
	dev-qt/qtgui:4=
	dev-qt/qtopengl:4=
"

DEPEND="${RDEPEND}
	docs? ( app-doc/doxygen )
	sys-devel/bison
	sys-devel/flex
"

S="${WORKDIR}/SeExpr-${PV}"

src_configure() {
	local mycmakeargs=(
		-DBOOST_PYTHON_LIBNAME=boost_python-${PYTHON_USEDEP}
		$(cmake-utils_use_find_package docs Doxygen)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	die
}
