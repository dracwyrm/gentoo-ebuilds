# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{2_7,3_5,3_6} )

inherit autotools multilib-minimal python-single-r1 toolchain-funcs

DESCRIPTION="ilmbase Python bindings"
HOMEPAGE="http://www.openexr.com"
SRC_URI="https://github.com/openexr/openexr/releases/download/v${PV}/${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64"
IUSE="+numpy"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEP}
	>=dev-libs/boost-1.62.0-r1[${MULTILIB_USEDEP},python(+),${PYTHON_USEDEP}]
	~media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]
	numpy? ( >=dev-python/numpy-1.10.4 )"
DEPEND="${RDEPEND}
	${PYTHON_DEP}
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]"



AT_M4DIR=m4

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	multilib_copy_sources
}

multilib_src_configure() {
	local myeconfargs=(
		--with-boost-include-dir="${EPREFIX}/usr/include/boost"
		--with-boost-lib-dir="${EPREFIX}/usr/$(get_libdir)"
		--with-boost-python-libname="boost_python-${EPYTHON:6}"
		$(use_with numpy)
	)

	econf "${myeconfargs[@]}"
}
