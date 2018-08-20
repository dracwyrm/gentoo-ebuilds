# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal

DESCRIPTION="A Vulkan-based translation layer for Direct3D 10/11"
HOMEPAGE="https://github.com/doitsujin/dxvk"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/doitsujin/dxvk.git"
	EGIT_BRANCH="master"
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/doitsujin/dxvk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
fi

LICENSE="ZLIB"
SLOT="${PV}"
IUSE="test utils"

RESTRICT="test"

RDEPEND="
	|| (
		>=app-emulation/wine-vanilla-3.14:*[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-staging-3.14:*[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-d3d9-3.14:*[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-any-3.14:*[${MULTILIB_USEDEP},vulkan]
	)
	utils? ( app-emulation/winetricks )"
DEPEND="${RDEPEND}
	dev-util/glslang"

PATCHES=(
	"${FILESDIR}/${P}-fix-32bit-build.patch"
	"${FILESDIR}/${P}-winelib-fix.patch"
)

dxvk_check_requirements() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! tc-is-gcc || [[ $(gcc-major-version) -lt 7 || $(gcc-major-version) -eq 7 && $(gcc-minor-version) -lt 3 ]]; then
			die "At least gcc 7.3 is required"
		fi
	fi
}

pkg_pretend() {
	dxvk_check_requirements
}

pkg_setup() {
	dxvk_check_requirements
	default
}

multilib_src_configure() {
	local emesonargs=(
		--buildtype="release"
		--prefix="${EPREFIX}/usr/$(get_libdir)"
		--libdir="dxvk-${PV}"
		--bindir="dxvk-${PV}/bin"
		--datadir="dxvk-${PV}"
		$(meson_use test enable_tests)
		--unity=on
	)
	if [[ ${ABI} == amd64 ]]; then
		emesonargs+=(
			--cross-file "$S/build-wine64.txt"
		)
	else
		emesonargs+=(
			--cross-file "$S/build-wine32.txt"
		)
	fi
	meson_src_configure

	# Edit setup_dxvk.sh.in to work for specific variant
	sed -e "/\/\.\.\/lib/s/.*//" -i "${BUILD_DIR}/utils/setup_dxvk.sh" || die
	sed -e "/dlls_dir=/s/.*/dlls_dir=${EPREFIX}\/usr\/$(get_libdir)\/dxvk-${PV}/" -i "${BUILD_DIR}/utils/setup_dxvk.sh" || die
}

multilib_src_install() {
	if use utils; then
		# install winetricks verb
		insinto "/usr/$(get_libdir)/dxvk-${PV}/bin"
		doins "${S}/utils/setup_dxvk.verb"

		exeinto "/usr/$(get_libdir)/dxvk-${PV}/bin"
		doexe "${FILESDIR}/setup.sh"
	fi

	# install DXVK setup healper script
	dosym "${EPREFIX}/usr/$(get_libdir)/dxvk-${PV}/bin/setup_dxvk.sh" "${EPREFIX}/usr/bin/dxvk-setup-${ABI}-${PV}"

	# create combined setup helper
	[ ! -f "${S}/dxvk-setup-${PV}" ] && echo '#!/bin/sh' > "${S}/dxvk-setup-${PV}"
	echo "dxvk-setup-${ABI}-${PV}" '$@' >> "${S}/dxvk-setup-${PV}"

	exeinto /usr/bin
	doexe "${S}/dxvk-setup-${PV}"

	meson_src_install
}
