# Copyright 2016 Adrian Grigo <agrigo2001@yahoo.com.au>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils cmake-utils git-r3 multilib

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv/"

EGIT_REPO_URI="https://github.com/PixarAnimationStudios/OpenSubdiv.git"
EGIT_BRANCH="dev"
# Fixes for ptex are not merged into 3.0.5 yet but present in the dev branch

LICENSE="ZLIB"
SLOT="0"
IUSE="ptex cuda tbb examples tutorials test doc openmp opencl"
DEPEND=">=dev-util/cmake-2.8.6
	>=media-libs/glew-1.9.0
	>=media-libs/glfw-3.0.0
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.0 )
	tbb? ( >=dev-util/tbb-4.0 )
	ptex? ( >=media-libs/ptex-2.0 )
	doc? ( dev-python/docutils app-doc/doxygen )
	opencl? ( virtual/opencl )
	openmp? ( >=sys-devel/gcc-4.2[openmp] )"

KEYWORDS=""

src_prepare() {
  epatch "${FILESDIR}"/${PN}-3.0.5-fix-gpu-architecture.patch
  cmake-utils_src_prepare
}

src_configure() {
  mycmakeargs=(
    -DNO_MAYA=1 \
    `cmake-utils_use_no ptex PTEX` \
    `cmake-utils_use_no doc DOC` \
    `cmake-utils_use_no openmp OMP` \
    `cmake-utils_use_no tbb TBB` \
    `cmake-utils_use_no cuda CUDA` \
    `cmake-utils_use_no opencl OPENCL` \
    -DNO_CLEW=1 \
    `cmake-utils_use_no examples EXAMPLES` \
    `cmake-utils_use_no tutorials TUTORIALS` \
    `cmake-utils_use_no test REGRESSION` \
    -DGLEW_LOCATION="/usr/$(get_libdir)" \
    -DGLFW_LOCATION="/usr/$(get_libdir)"
  )

  cmake-utils_src_configure
}


