# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils versionator toolchain-funcs

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv/"

MY_PV="$(replace_all_version_separators '_')"

SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/dracwyrm/gentoo-patches/raw/master/${PN}/${PV}/${P}-patchset-1.tar.xz"

LICENSE="ZLIB"
SLOT="0"
IUSE="cuda doc examples opencl openmp ptex tbb test tutorials"

# OpenCL does not work with Open Source drivers.
RDEPEND="media-libs/glew:*
	media-libs/glfw
	opencl? ( x11-drivers/ati-drivers:* )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	ptex? ( media-libs/ptex )"

DEPEND="${RDEPEND}
	tbb? ( dev-cpp/tbb )
	doc? ( dev-python/docutils app-doc/doxygen )"

KEYWORDS="~amd64 ~x86"

S=${WORKDIR}/OpenSubdiv-${MY_PV}

PATCHES=(
	"${WORKDIR}"/${P}-fix-gpu-architecture.patch
	"${WORKDIR}"/${P}-skip-osd-regression.patch
	"${WORKDIR}"/${P}-Improved-Ptex-configuration-and-DX-compatibility.patch
)

pkg_setup() {
	if use openmp && ! tc-has-openmp; then
		ewarn "OpenMP is not available in your current selected compiler"

		if tc-is-clang; then
			ewarn "OpenMP support in sys-devel/clang is provided by sys-libs/libomp,"
			ewarn "which you will need to build ${CATEGORY}/${PN} with USE=\"openmp\""
		fi

		die "need openmp capable compiler"
	fi
}

src_configure() {
	mycmakeargs=(
		-DNO_MAYA=1
		-DNO_CLEW=1
		-DNO_DOC=$(usex !doc)
		-DNO_TBB=$(usex !tbb)
		-DNO_PTEX=$(usex !ptex)
		-DNO_OMP=$(usex !openmp)
		-DNO_OPENCL=$(usex !opencl)
		-DNO_CUDA=$(usex !cuda)
		-DNO_REGRESSION=$(usex !test)
		-DNO_EXAMPLES=$(usex !examples)
		-DNO_TUTORIALS=$(usex !tutorials)
		-DGLEW_LOCATION="/usr/$(get_libdir)"
		-DGLFW_LOCATION="/usr/$(get_libdir)"
	)

	cmake-utils_src_configure
}
