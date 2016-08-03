# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit cmake-utils vcs-snapshot python-r1

DESCRIPTION="A library for particle IO and manipulation"
HOMEPAGE="http://www.disneyanimation.com/technology/partio.html"

MY_EGIT_REV="7f3e0d19e1931a591f53d4485bfffc665724a967"
https://github.com/wdas/partio/archive/${MY_EGIT_REV}.tar.gz
SRC_URI="https://github.com/wdas/partio/archive/${MY_EGIT_REV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="media-libs/freeglut
	virtual/opengl
	sys-libs/zlib
	media-libs/seexpr
"

DEPEND="${RDEPEND}
	app-doc/doxygen[latex]
	dev-lang/swig
"
