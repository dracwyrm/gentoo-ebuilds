# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $id$

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit eutils multilib python-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"

SRC_URI="http://www.openvdb.org/download/${PN}_${PV//./_}_library.zip"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc pdfdoc python +openvdb-compression X"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	pdfdoc? ( doc )"

RDEPEND="${PYTHON_DEPS}"

DEPEND="${RDEPEND}
	sys-libs/zlib
	>=dev-libs/boost-1.42.0[${PYTHON_USEDEP}]
	media-libs/openexr
	>=dev-cpp/tbb-3.0
	>=dev-util/cppunit-1.10
	doc? (
		>=app-doc/doxygen-1.8.7
		python? ( >=dev-python/pdoc-0.2.4[${PYTHON_USEDEP}] )
		pdfdoc? (
			>=dev-texlive/texlive-latex-2015
			>=app-text/ghostscript-gpl-8.70
		)
	)
	X? ( media-libs/glfw )
	dev-libs/jemalloc
	python? ( dev-python/numpy[${PYTHON_USEDEP}] )
	openvdb-compression? ( >=dev-libs/c-blosc-1.5.0 )
	dev-libs/log4cplus"

S="${WORKDIR}"/openvdb

PATCHES=(
	"${FILESDIR}"/${P}-python3-compat.patch
	"${FILESDIR}"/use_svg.patch
	"${FILESDIR}"/${P}-makefile-fixes.patch
)

src_prepare() {
	default

	sed	-e	"s|--html -o|--html --html-dir|" \
		-e	"s|vdb_render vdb_test|vdb_render vdb_view vdb_test|" \
		-i Makefile || die "sed failed"
}

python_module_compile() {
	mypythonargs=(
		PYTHON_VERSION=${EPYTHON/python/}
		PYTHON_INCL_DIR="$(python_get_includedir)"
		PYCONFIG_INCL_DIR="$(python_get_includedir)"
		PYTHON_LIB_DIR="$(python_get_library_path)"
		PYTHON_LIB="$(python_get_LIBS)"
		PYTHON_INSTALL_INCL_DIR="${myinstallbase}$(python_get_includedir)"
		PYTHON_INSTALL_LIB_DIR="${myinstallbase}$(python_get_sitedir)"
		NUMPY_INCL_DIR="$(python_get_sitedir)"/numpy/core/include/numpy
		BOOST_PYTHON_LIB_DIR="${myprefix}"/"$(get_libdir)"
		BOOST_PYTHON_LIB=-lboost_python-${EPYTHON/python/}
	)

	einfo "Compiling module for ${EPYTHON}."
	emake python ${myemakeargs[@]} ${mypythonargs[@]} EPYDOC=
}

src_compile() {
	local myprefix="${EPREFIX}"/usr
	local myinstallbase="${WORKDIR}"/install
	local myinstalldir="${myinstallbase}${myprefix}"

	# So individule targets can be called without duplication
	# Common depends:
	local myemakeargs=(
		rpath=no shared=yes
		LIBOPENVDB_RPATH=
		DESTDIR="${myinstalldir}"
		HFS="${myprefix}"
		HT="${myprefix}"
		HDSO="${myprefix}"/"$(get_libdir)"
		CPPUNIT_INCL_DIR="${myprefix}"/include/cppunit
		CPPUNIT_LIB_DIR="${myprefix}"/"$(get_libdir)"
		LOG4CPLUS_INCL_DIR="${myprefix}"/include/log4cplus
		LOG4CPLUS_LIB_DIR="${myprefix}"/"$(get_libdir)"
	)

	# Optional depends:
	if use X; then
		myemakeargs+=(
			GLFW_INCL_DIR="${myprefix}"/"$(get_libdir)"
			GLFW_LIB_DIR="${myprefix}"/"$(get_libdir)"
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
			BLOSC_LIB_DIR="${myprefix}"/"$(get_libdir)"
		)
	else
		myemakeargs+=(
			BLOSC_INCL_DIR=
			BLOSC_LIB_DIR=
		)
	fi

	use doc || myemakeargs+=( DOXYGEN= )
	
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

	# The install won't like like it if this is not down
	mkdir -p "${myinstalldir}" || die "mkdir failed"

	# Create python modules for each version selected
	use python && python_foreach_impl python_module_compile
	
	if use python && use doc; then
		mypythonargs+=( EPYDOC=pdoc )
	else
		mypythonargs+=( EPYDOC= )
	fi

	# Installing to a temp dir, because variables won't be remembered.
	einfo "Compiling the main components."
	emake install ${myemakeargs[@]} ${mypythonargs[@]}
	use pdfdoc && emake pdfdoc ${myemakeargs[@]} ${mypythonargs[@]}
}

src_install() {
	einfo "Copying files to the image directory."
	doins -r "${WORKDIR}"/install/*
	einfo "Installing files to the system."
}
