# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-multilib vcs-snapshot

DESCRIPTION="library for creating vnc servers"
HOMEPAGE="http://libvncserver.sourceforge.net/"
SRC_URI="https://github.com/LibVNC/${PN}/archive/3df54ce7ce2e126a7e5f88c4ae1f515509abc19b.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
IUSE="+24bpp gcrypt gnutls ipv6 +jpeg libressl +png sdl sdl2 ssl systemd test threads +zlib"

DEPEND="
	gcrypt? ( >=dev-libs/libgcrypt-1.5.3:0[${MULTILIB_USEDEP}] )
	gnutls? ( >=net-libs/gnutls-2.12.23-r6[${MULTILIB_USEDEP}] )
	!gnutls? (
		ssl? (
			!libressl? ( >=dev-libs/openssl-1.0.1h-r2:0[${MULTILIB_USEDEP}] )
			libressl? ( dev-libs/libressl[${MULTILIB_USEDEP}] )
		)
	)
	jpeg? ( >=virtual/jpeg-0-r2:0[${MULTILIB_USEDEP}] )
	png? ( >=media-libs/libpng-1.6.10:0[${MULTILIB_USEDEP}] )
	sdl? (
		!sdl2? ( media-libs/libsdl[X] )
		sdl2? ( media-libs/libsdl2[X] )
	)
	systemd? ( sys-apps/systemd )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )"
RDEPEND="${DEPEND}"

REQUIRED_USE="?? ( gnutls ssl )
	      gnutls? ( gcrypt )
	      sdl2? ( sdl )"

PATCHES=( "${FILESDIR}"/${PN}-0.9.10-cmake-fixes.patch )

DOCS=( AUTHORS ChangeLog NEWS README TODO )

multilib_src_configure() {
	local mycmakeargs=(
		-DWITH_24BPP=$(usex 24bpp)
		-DWITH_GNUTLS=$(usex gnutls)
		-DWITH_SSL=$(usex ssl)
		-DWITH_IPV6=$(usex ipv6)
		-DWITH_JPEG=$(usex jpeg)
		-DWITH_PNG=$(usex png)
		-DWITH_SYSTEMD=$(usex systemd)
		-DWITH_THREADS=$(usex threads)
		-DWITH_ZLIB=$(usex zlib)
		-DWITH_TESTS=$(usex test)
		)

	cmake-utils_src_configure
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
