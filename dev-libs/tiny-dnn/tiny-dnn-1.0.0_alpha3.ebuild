# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils toolchain-funcs vcs-snapshot

DESCRIPTION="Header only, dependency free deep learning library written in C++"
HOMEPAGE="https://github.com/tiny-dnn"
MY_PV="1.0.0a3"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_sse3 doc examples opencl openmp test threads"

RDEPEND="
	opencl? ( virtual/opencl )
	threads? ( dev-cpp/tbb:= )
	dev-libs/cereal"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

PATCHES=( "${FILESDIR}"/${PN}-1.0.0-doc-target.patch )

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	cmake-utils_src_prepare

	# Fix the location of third party headers
	grep -nrwl . -e "third_party" | xargs sed -i 's|third_party|tiny_dnn/third_party|g' || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCS=$(usex doc)
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTS=$(usex test)
		-DCOVERALLS=OFF

		-DUSE_DOUBLE=ON
		-DUSE_LIBDNN=OFF
		-DUSE_NNPACK=OFF
		-DUSE_SERIALIZER=ON

		# Threading
		-DUSE_OMP=$(usex openmp)
		-DUSE_OPENCL=$(usex opencl)
		-DUSE_TBB=$(usex threads)

		# SIMD
		-DUSE_SSE=$(usex cpu_flags_x86_sse3)
		-DUSE_AVX=$(usex cpu_flags_x86_avx)
		-DUSE_AVX2=$(usex cpu_flags_x86_avx2)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	insinto /usr/include/tiny_dnn
	doins -r third_party
}
