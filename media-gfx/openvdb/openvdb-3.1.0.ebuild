# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $id$

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit eutils multilib python-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"

SRC_URI="https://github.com/dreamworksanimation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+openvdb-compression doc pdfdoc python X"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	pdfdoc? ( doc )"

RDEPEND="${PYTHON_DEPS}"

DEPEND="${RDEPEND}
	sys-libs/zlib
	dev-libs/boost[${PYTHON_USEDEP}]
	media-libs/openexr
	dev-cpp/tbb
	dev-util/cppunit
	doc? (
		app-doc/doxygen
		python? ( dev-python/pdoc[${PYTHON_USEDEP}] )
	)
	pdfdoc? (
		app-doc/doxygen[dot,latex]
		app-text/ghostscript-gpl
	)
	X? ( media-libs/glfw )
	dev-libs/jemalloc
	python? ( dev-python/numpy[${PYTHON_USEDEP}] )
	openvdb-compression? ( >=dev-libs/c-blosc-1.5.0 )
	dev-libs/log4cplus"

S="${WORKDIR}/${P}/${PN}"

PATCHES=(
	"${FILESDIR}"/${P}-python3-compat.patch
	"${FILESDIR}"/${P}-makefile-fixes.patch
)

src_prepare() {
	default

	sed	-e "s|--html -o|--html --html-dir|" \
		-e "s|vdb_render vdb_test|vdb_render vdb_view vdb_test|" \
		-i Makefile || die "sed failed"

	sed	-e "s|= png|= svg|" -i doxygen-config || die "sed doxygen failed"
}

python_module_compile() {
	mypythonargs=(
		PYTHON_VERSION=${EPYTHON/python/}
		PYTHON_INCL_DIR="$(python_get_includedir)"
		PYCONFIG_INCL_DIR="$(python_get_includedir)"
		PYTHON_LIB_DIR="$(python_get_library_path)"
		PYTHON_LIB="$(python_get_LIBS)"
		PYTHON_INSTALL_INCL_DIR="${D}$(python_get_includedir)"
		PYTHON_INSTALL_LIB_DIR="${D}$(python_get_sitedir)"
		NUMPY_INCL_DIR="$(python_get_sitedir)"/numpy/core/include/numpy
		BOOST_PYTHON_LIB_DIR="${myprefixlibdir}"
		BOOST_PYTHON_LIB=-lboost_python-${EPYTHON/python/}
	)

	einfo "Compiling module for ${EPYTHON}."
	emake python ${myemakeargs[@]} ${mypythonargs[@]} EPYDOC=

	# This is so the correct version of pdoc is used
	mypyscriptdir=$(python_get_scriptdir)
}

src_compile() {
	# The build system is designed to compile and install all
	# in one go, so doing each phase separately would be be
	# impossible and the functions would all overlap anyways.
	# Do nothing
	return
}

src_install() {
	local myprefix="${EPREFIX}"/usr
	local myprefixlibdir="${myprefix}"/"$(get_libdir)"
	local mypyscriptdir

	# So individule targets can be called without duplication
	# Common depends:
	local myemakeargs=(
		rpath=no shared=yes
		LIBOPENVDB_RPATH=
		DESTDIR="${D}"
		HFS="${myprefix}"
		HT="${myprefix}"
		HDSO="${myprefixlibdir}"
		CPPUNIT_INCL_DIR="${myprefix}"/include/cppunit
		CPPUNIT_LIB_DIR="${myprefixlibdir}"
		LOG4CPLUS_INCL_DIR="${myprefix}"/include/log4cplus
		LOG4CPLUS_LIB_DIR="${myprefixlibdir}"
	)

	# Create python list here for use during install phase:
	# - If python is used, then the last used module will trigger
	#   document install phase. It's the same doc, so build once.
	# - If no python used, then this will remail blanked out to
	#   disable pydoc.
	# - pydoc will be called if doc and python use flags are set.
	local mypythonargs=(
		PYTHON_VERSION=
		PYTHON_INCL_DIR=
		PYCONFIG_INCL_DIR=
		PYTHON_LIB_DIR=
		PYTHON_LIB=
		PYTHON_INSTALL_INCL_DIR=
		PYTHON_INSTALL_LIB_DIR=
		NUMPY_INCL_DIR=
		BOOST_PYTHON_LIB_DIR=
		BOOST_PYTHON_LIB=
	)

	# Optional depends:
	if use X; then
		myemakeargs+=(
			GLFW_INCL_DIR="${myprefixlibdir}"
			GLFW_LIB_DIR="${myprefixlibdir}"
		)
	else
		myemakeargs+=(
			GLFW_INCL_DIR=
			GLFW_LIB_DIR=
			GLFW_LIB=
			GLFW_MAJOR_VERSION=
		)
	fi

	if use openvdb-compression; then
		myemakeargs+=(
			BLOSC_INCL_DIR="${myprefix}"/include
			BLOSC_LIB_DIR="${myprefixlibdir}"
		)
	else
		myemakeargs+=(
			BLOSC_INCL_DIR=
			BLOSC_LIB_DIR=
		)
	fi

	use doc || myemakeargs+=( DOXYGEN= )

	# Create python modules for each version selected
	use python && python_foreach_impl python_module_compile

	if use python && use doc; then
		mypythonargs+=( EPYDOC="${mypyscriptdir}"/pdoc )
	else
		mypythonargs+=( EPYDOC= )
	fi

	# Installing to a temp dir, because variables won't be remembered.
	einfo "Compiling the main components."
	emake install ${myemakeargs[@]} ${mypythonargs[@]}
	use pdfdoc && emake pdfdoc ${myemakeargs[@]} ${mypythonargs[@]}
}
