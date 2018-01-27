# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit eutils autotools python-single-r1 multilib-minimal

DESCRIPTION="ilmbase Python bindings"
HOMEPAGE="http://www.openexr.com"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"
LICENSE="BSD"

SLOT="0/23" # based on SONAME
KEYWORDS="~x86 ~amd64"
IUSE="+numpy"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]
	>=dev-libs/boost-1.62.0-r1[${MULTILIB_USEDEP},python(+),${PYTHON_USEDEP}]
	numpy? ( >=dev-python/numpy-1.10.4 )"

DEPEND="
	${RDEPEND}
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]"

RESTRICT="test"

AT_M4DIR=m4
PATCHES=( 
	"${FILESDIR}/${PN}-2.2.0-configure-boost_python.patch" # Custom patch
	"${FILESDIR}/${P}-fix-pkgconfig-file.patch" # Based on upstream PR 242
	"${FILESDIR}/test.patch"
)

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
	multilib_copy_sources
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf "$(use_with numpy numpy)"
}

# fails to install successfully if MAKEOPTS is set to use more than one core.
#multilib_src_install() {
#	emake DESTDIR="${D}" -j1 install
#}
