# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $id$

EAPI="5"
PYTHON_COMPAT=( python3_5 )

inherit eutils python-single-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"

SRC_URI="http://www.openvdb.org/download/${PN}_${PV//./_}_library.zip"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc +openvdb-compression X"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"

DEPEND="${RDEPEND}
	sys-libs/zlib
	>=dev-libs/boost-1.56.0[${PYTHON_USEDEP}]
	media-libs/openexr
	>=dev-cpp/tbb-3.0
	>=dev-util/cppunit-1.10
	doc? ( >=app-doc/doxygen-1.4.7
	       >=dev-python/pdoc-0.2.4[${PYTHON_USEDEP}]
	       >=app-text/ghostscript-gpl-8.70 )
	X? ( media-libs/glfw )
	dev-libs/jemalloc
	dev-python/numpy[${PYTHON_USEDEP}]
	openvdb-compression? ( >=dev-libs/c-blosc-1.5.2 )
	dev-libs/log4cplus"

S="${WORKDIR}"/openvdb

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	#hack to get 3.5m, incase this changes in the future.
	local my_python_path=$(python_get_includedir)
	local my_python_ver=${my_python_path##*/python}
	
	epatch "${FILESDIR}"/${P}-python3-compat.patch
	epatch "${FILESDIR}"/use_svg.patch

	sed \
	-e	"s|--html -o|--html --html-dir|" \
	-e	"s|vdb_render vdb_test|vdb_render vdb_view vdb_test|" \
	-i Makefile || die "sed failed"
}

src_compile() {
	local myprefix="${EPREFIX}/usr"
	local myemakargs=""
	
	if use doc; then
		myemakargs+="EPYDOC=\"pdoc\" "
        else
		myemakargs+="EPYDOC=\"\" "
		myemakargs+="DOXYGEN=\"\" "
	fi

	if use X; then
		myemakargs+="GLFW_INCL_DIR=\"${myprefix}/$(get_libdir)\" "
		myemakargs+="GLFW_LIB_DIR=\"${myprefix}/$(get_libdir)\" "
	else
		myemakargs+="GLFW_INCL_DIR=\"\" "
		myemakargs+="GLFW_LIB_DIR=\"\" "
		myemakargs+="GLFW_LIB=\"\" "
		myemakargs+="GLFW_MAJOR_VERSION=\"\" "
	fi

	if use openvdb-compression; then
		myemakargs+="BLOSC_INCL_DIR=\"${myprefix}/include\" "
		myemakargs+="BLOSC_LIB_DIR=\"${myprefix}/$(get_libdir)\" "
	fi

	emake rpath=no shared=yes \
	DESTDIR="${D}/${myprefix}" \
	HFS="${myprefix}" \
	HT="${myprefix}" \
	HDSO="${myprefix}/$(get_libdir)" \
	${myemakargs} \
	LIBOPENVDB_RPATH="" \
	CPPUNIT_INCL_DIR="${myprefix}/include/cppunit" \
	CPPUNIT_LIB_DIR="${myprefix}/$(get_libdir)" \
	LOG4CPLUS_INCL_DIR="${myprefix}/include/log4cplus" \
	LOG4CPLUS_LIB_DIR="${myprefix}/$(get_libdir)" \
	PYTHON_VERSION="${EPYTHON/python/}" \
	PYTHON_INCL_DIR="$(python_get_includedir)" \
	PYCONFIG_INCL_DIR="$(python_get_includedir)" \
	PYTHON_LIB_DIR="$(python_get_library_path)" \
	PYTHON_LIB="$(python_get_LIBS)" \
	NUMPY_INCL_DIR="$(python_get_sitedir)/numpy/core/include/numpy" \
	BOOST_PYTHON_LIB_DIR="${myprefix}/$(get_libdir)" \
	BOOST_PYTHON_LIB="-lboost_python-${EPYTHON/python/}"
}
