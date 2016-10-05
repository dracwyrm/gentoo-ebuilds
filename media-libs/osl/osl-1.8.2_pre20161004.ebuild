# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils vcs-snapshot

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"

MY_GIT_COMMIT="4299503900a1867d762a399856738b7a905a3c96"
SRC_URI="https://github.com/imageworks/OpenShadingLanguage/archive/${MY_GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

X86_CPU_FEATURES=( sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2 f16c:f16c )
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
IUSE="doc test ${CPU_FEATURES[@]%:*}"

RDEPEND="
	media-libs/openexr
	media-libs/openimageio
	dev-libs/pugixml
	sys-libs/zlib
"
# TODO: Logic to enable higher versions of Boost when
#	Boost ebuild supports C++ 11 ABI.
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.62:=
	sys-devel/llvm[clang]
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

# Restricting tests as Make file handles them differently
RESTRICT="test"

S=${WORKDIR}/OpenShadingLanguage-Release-${PV}

PATCHES=(
	"${FILESDIR}"/${PN}-fix-pdf-install-dir.patch
)

src_configure() {
	local cpufeature

	# Build with SIMD support (choices: 0, sse2, sse3,"
	#	ssse3, sse4.1, sse4.2, f16c)"
	local mysimd=""
	for cpufeature in "${CPU_FEATURES[@]}"; \
		do use ${cpufeature%:*} && mysimd+="${cpufeature#*:},"; \
		done

	# If no CPU SIMDs were used, completely disable them
	[[ -z $mysimd ]] && mysimd="0"
 
	# LLVM needs CPP11. Do not disable.
	local mycmakeargs=(
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_PARTIO=OFF
		-DUSE_CPP11=OFF
		-DUSE_CPP14=ON
		-DENABLERTTI=OFF
		-DSTOP_ON_WARNING=OFF
		-DSELF_CONTAINED_INSTALL_TREE=OFF
		-DOSL_BUILD_TESTS=$(usex test)
		-DINSTALL_DOCS=$(usex doc)
		-DUSE_SIMD=${mysimd%,}
		-DVERBOSE=ON
	)

	cmake-utils_src_configure
}
