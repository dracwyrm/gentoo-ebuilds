# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils cmake-utils multilib

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv/"

SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${PV//./_}.tar.gz \
	-> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
IUSE="ptex cuda tbb examples tutorials test doc openmp opencl"
DEPEND=">=media-libs/glew-1.9.0
	>=media-libs/glfw-3.0.0
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.0 )
	tbb? ( >=dev-cpp/tbb-4.0 )
	ptex? ( >=media-libs/ptex-2.0 )
	doc? ( dev-python/docutils app-doc/doxygen )
	opencl? ( virtual/opencl )
	openmp? ( >=sys-devel/gcc-4.2[openmp] )"

KEYWORDS="~amd64 ~x86"

S=${WORKDIR}/OpenSubdiv-${PV//./_}

src_prepare() {
  epatch "${FILESDIR}"/${P}-fix-gpu-architecture.patch
  epatch "${FILESDIR}"/${P}-skip-osd-regression.patch
  epatch "${FILESDIR}"/${P}-Improved-Ptex-configuration-and-DX-compatibility.patch
  cmake-utils_src_prepare
}

src_configure() {
  mycmakeargs=(
    -DNO_MAYA=1
    -DNO_CLEW=1
    -DNO_PTEX=$(usex ptex OFF ON)
    -DNO_DOC=$(usex doc OFF ON)
    -DNO_OMP=$(usex openmp OFF ON)
    -DNO_TBB=$(usex tbb OFF ON)
    -DNO_CUDA=$(usex cuda CUDA OFF ON)
    -DNO_OPENCL=$(usex opencl OFF ON)
    -DNO_EXAMPLES=$(usex examples OFF ON)
    -DNO_TUTORIALS=$(usex tutorials OFF ON)
    -DNO_REGRESSION=$(usex test OFF ON)
    -DGLEW_LOCATION="/usr/$(get_libdir)"
    -DGLFW_LOCATION="/usr/$(get_libdir)"
  )

  cmake-utils_src_configure
}


