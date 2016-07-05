# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"

SRC_URI="https://github.com/imageworks/OpenShadingLanguage/archive/Release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

X86_CPU_FEATURES=( sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2 )
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
IUSE="doc test ${CPU_FEATURES[@]%:*}"

REQUIRED_USE="
	cpu_flags_x86_sse4_2? ( cpu_flags_x86_sse4_1 )
	cpu_flags_x86_sse4_1?  ( cpu_flags_x86_ssse3 )
	cpu_flags_x86_ssse3? ( cpu_flags_x86_sse3 )
	cpu_flags_x86_sse3? ( cpu_flags_x86_sse2 )
"

RDEPEND="
	media-libs/openexr
	media-libs/openimageio
	dev-libs/pugixml
	sys-libs/zlib
"
# TODO: Logic to enable higher versions of Boost when
#	Boost ebuild supports C++ 11 ABI.
DEPEND="${RDEPEND}
	<dev-libs/boost-1.61
	<sys-devel/llvm-3.6.0
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

# Restricting tests as Make file handles them differently
RESTRICT="test"

S=${WORKDIR}/OpenShadingLanguage-Release-${PV}

PATCHES=(
	"${FILESDIR}"/${P}-remove-mcjit.patch
	"${FILESDIR}"/${PN}-fix-pdf-install-dir.patch
)

src_configure() {
	local mysimd=""
	# Build with SIMD support (choices: 0, sse2, sse3,"
	#	ssse3, sse4.1, sse4.2, f16c)"
	# TODO: Figure out what f16c is
	# So the comma separation works correctly
	use cpu_flags_x86_sse2 && mysimd="sse2"
	# Loop through the other options
	for cpufeature in "${CPU_FEATURES[@]:1}"; \
		do use ${cpufeature%:*} && mysimd+=",${cpufeature#*:}"; \
		done
 
	# LLVM needs CPP11. Do not disable.
	local mycmakeargs=(
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_PARTIO=OFF
		-DOSL_BUILD_CPP11=ON
		-DENABLERTTI=OFF
		-DSTOP_ON_WARNING=OFF
		-DSELF_CONTAINED_INSTALL_TREE=OFF
		-DOSL_BUILD_TESTS=$(usex test ON OFF)
		-DINSTALL_DOCS=$(usex doc ON OFF)
		-DUSE_SIMD=${mysimd}
	)

	cmake-utils_src_configure
}
