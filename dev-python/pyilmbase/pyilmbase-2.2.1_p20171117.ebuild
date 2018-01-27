# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 cmake-utils vcs-snapshot

DESCRIPTION="ilmbase Python bindings"
HOMEPAGE="http://www.openexr.com"

MY_GIT_COMMIT="165dceaeee86e0f8ce1ed1db3e3030c609a49f17"
SRC_URI="https://github.com/openexr/openexr/archive/${MY_GIT_COMMIT}.tar.gz \
		-> OpenEXR-${PV}.tar.gz"

SLOT="0/23" # based on SONAME
KEYWORDS="~x86 ~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/boost-1.62.0-r1[python(+),${PYTHON_USEDEP}]
	>=dev-python/numpy-1.10.4
	~media-libs/ilmbase-${PV}:="

DEPEND="${RDEPEND}
	>=virtual/pkgconfig-0-r1"

RESTRICT="test"

S="${WORKDIR}/OpenEXR-${PV}/PyIlmBase"

PATCHES=( "${FILESDIR}/${PN}-2.2.1-cmake-fixes.patch" )

pkg_setup() {
	python-single-r1_pkg_setup
}
