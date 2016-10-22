# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils toolchain-funcs versionator

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv/"

MY_PV="$(replace_all_version_separators '_')"

SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
IUSE="cuda doc examples opencl openmp ptex tbb test tutorials"

# OpenCL does not work with Open Source drivers.
RDEPEND="media-libs/glew:=
	media-libs/glfw:=
	opencl? ( x11-drivers/ati-drivers:* )
	cuda? ( dev-util/nvidia-cuda-toolkit:* )
	ptex? ( media-libs/ptex )"

DEPEND="${RDEPEND}
	tbb? ( dev-cpp/tbb )
	doc? ( dev-python/docutils app-doc/doxygen )"

KEYWORDS="~amd64 ~x86"

S=${WORKDIR}/OpenSubdiv-${MY_PV}

PATCHES=( "${FILESDIR}"/${P}-skip-osd-regression.patch )

pkg_pretend() {
	use openmp && tc-check-openmp
}

src_configure() {
	local mycmakeargs=(
		-DNO_MAYA=1
		-DNO_CLEW=1
		-DNO_DOC=$(usex doc 0 1)
		-DNO_TBB=$(usex tbb 0 1)
		-DNO_PTEX=$(usex ptex 0 1)
		-DNO_OMP=$(usex openmp 0 1)
		-DNO_OPENCL=$(usex opencl 0 1)
		-DNO_CUDA=$(usex cuda 0 1)
		-DNO_REGRESSION=$(usex test 0 1)
		-DNO_EXAMPLES=$(usex examples 0 1)
		-DNO_TUTORIALS=$(usex tutorials 0 1)
		-DGLEW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
		-DGLFW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
	)

	cmake-utils_src_configure
}
