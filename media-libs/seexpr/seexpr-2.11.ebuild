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

RDEPEND="sys-devel/llvm
	dev-libs/boost[python]
	dev-cpp/gtest
	media-libs/libpng:=
	virtual/opengl
	dev-qt/qtcore:=
	dev-qt/qtgui:=
	dev-qt/qtopengl:=
"

DEPEND="${RDEPEND}
	app-doc/doxygen
	sys-devel/bison
	sys-devel/flex
"

S="${WORKDIR}/SeExpr-${PV}"

src_configure() {
	local mycmakeargs=(
		-DBOOST_PYTHON_LIBNAME=boost_python-${PYTHON_USEDEP}
	)

	cmake-utils_src_configure
}
