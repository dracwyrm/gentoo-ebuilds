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
	doc? (
		>=app-doc/doxygen-1.4.7
		>=dev-python/pdoc-0.2.4[${PYTHON_USEDEP}]
		>=dev-texlive/texlive-latex-2015
		>=app-text/ghostscript-gpl-8.70 
	)
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
	epatch "${FILESDIR}"/${P}-python3-compat.patch
	epatch "${FILESDIR}"/use_svg.patch
	epatch "${FILESDIR}"/${P}-change-python-module-install-locations-to-variables.patch

	sed \
		-e	"s|--html -o|--html --html-dir|" \
		-e	"s|vdb_render vdb_test|vdb_render vdb_view vdb_test|" \
		-i Makefile || die "sed failed"
}

src_compile() {
	local myprefix="${EPREFIX}/usr"
	local myinstallbase="${WORKDIR}/install"
	local myinstalldir="${myinstallbase}${myprefix}"
	local myemakeargs=""
	
	# So individule targets can be called without duplication
	myemakeargs="
		rpath=no shared=yes
		LIBOPENVDB_RPATH= \
		DESTDIR=\"${myinstalldir}\"
		HFS=\"${myprefix}\"
		HT=\"${myprefix}\"
		HDSO=\"${myprefix}/$(get_libdir)\"
		CPPUNIT_INCL_DIR=\"${myprefix}/include/cppunit\"
		CPPUNIT_LIB_DIR=\"${myprefix}/$(get_libdir)\"
		LOG4CPLUS_INCL_DIR=\"${myprefix}/include/log4cplus\"
		LOG4CPLUS_LIB_DIR=\"${myprefix}/$(get_libdir)\"
		PYTHON_VERSION=\"${EPYTHON/python/}\"
		PYTHON_INCL_DIR=\"$(python_get_includedir)\"
		PYCONFIG_INCL_DIR=\"$(python_get_includedir)\"
		PYTHON_LIB_DIR=\"$(python_get_library_path)\"
		PYTHON_LIB=\"$(python_get_LIBS)\"
		PYTHON_INSTALL_INCL_DIR=\"${myinstallbase}$(python_get_includedir)\"
		PYTHON_INSTALL_LIB_DIR=\"${myinstallbase}$(python_get_sitedir)\"
		NUMPY_INCL_DIR=\"$(python_get_sitedir)/numpy/core/include/numpy\"
		BOOST_PYTHON_LIB_DIR=\"${myprefix}/$(get_libdir)\"
		BOOST_PYTHON_LIB=\"-lboost_python-${EPYTHON/python/}\" "

	if use X; then
		myemakeargs+="GLFW_INCL_DIR=\"${myprefix}/$(get_libdir)\" "
		myemakeargs+="GLFW_LIB_DIR=\"${myprefix}/$(get_libdir)\" "
	else
		myemakeargs+="GLFW_INCL_DIR= "
		myemakeargs+="GLFW_LIB_DIR= "
		myemakeargs+="GLFW_LIB= "
		myemakeargs+="GLFW_MAJOR_VERSION= "
	fi

	if use openvdb-compression; then
		myemakeargs+="BLOSC_INCL_DIR=\"${myprefix}/include\" "
		myemakeargs+="BLOSC_LIB_DIR=\"${myprefix}/$(get_libdir)\" "
	else
		myemakeargs+="BLOSC_INCL_DIR= "
		myemakeargs+="BLOSC_LIB_DIR= "
	fi
	
	if use doc; then
		myemakeargs+="EPYDOC=pdoc "
	else
		myemakeargs+="EPYDOC= "
		myemakeargs+="DOXYGEN= "
	fi

	# Installing to a temp dir, because all targets install.
	mkdir -p ${myinstalldir} || die "mkdir failed"
	emake install ${myemakeargs}
}

src_install() {
	doins -r ${WORKDIR}/install/*
}
