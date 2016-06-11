# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv/"

MY_PV=${PV//./_}

SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
IUSE="ptex cuda tbb examples tutorials test doc openmp opencl"

RDEPEND="media-libs/glew
	media-libs/glfw
	opencl? ( virtual/opencl )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	ptex? ( media-libs/ptex )"

DEPEND="${RDEPEND}
	tbb? ( dev-cpp/tbb )
	doc? ( dev-python/docutils app-doc/doxygen )
	openmp? ( sys-devel/gcc[openmp] )"

KEYWORDS="~amd64 ~x86"

S=${WORKDIR}/OpenSubdiv-${MY_PV}

PATCHES=(
	"${FILESDIR}"/${P}-fix-gpu-architecture.patch
	"${FILESDIR}"/${P}-skip-osd-regression.patch
	"${FILESDIR}"/${P}-Improved-Ptex-configuration-and-DX-compatibility.patch
)

src_configure() {
	mycmakeargs=(
		-DNO_MAYA=1
		-DNO_CLEW=1
		-DNO_DOC=$(usex doc OFF ON)
		-DNO_TBB=$(usex tbb OFF ON)
		-DNO_PTEX=$(usex ptex OFF ON)
		-DNO_OMP=$(usex openmp OFF ON)
		-DNO_OPENCL=$(usex opencl OFF ON)
		-DNO_CUDA=$(usex cuda CUDA OFF ON)
		-DNO_REGRESSION=$(usex test OFF ON)
		-DNO_EXAMPLES=$(usex examples OFF ON)
		-DNO_TUTORIALS=$(usex tutorials OFF ON)
		-DGLEW_LOCATION="/usr/$(get_libdir)"
		-DGLFW_LOCATION="/usr/$(get_libdir)"
	)

	cmake-utils_src_configure
}
