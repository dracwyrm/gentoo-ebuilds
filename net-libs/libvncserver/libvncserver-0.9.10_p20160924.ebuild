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

RDEPEND="
	gcrypt? ( >=dev-libs/libgcrypt-1.5.3:0=[${MULTILIB_USEDEP}] )
	gnutls? ( >=net-libs/gnutls-2.12.23-r6[${MULTILIB_USEDEP}] )
	!gnutls? (
		ssl? (
			!libressl? ( >=dev-libs/openssl-1.0.1h-r2:0=[${MULTILIB_USEDEP}] )
			libressl? ( dev-libs/libressl[${MULTILIB_USEDEP}] )
		)
	)
	jpeg? ( >=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}] )
	png? ( >=media-libs/libpng-1.6.10:0=[${MULTILIB_USEDEP}] )
	sdl? (
		!sdl2? ( media-libs/libsdl[X] )
		sdl2? ( media-libs/libsdl2[X] )
	)
	systemd? ( sys-apps/systemd )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

REQUIRED_USE="?? ( gnutls ssl )
	      gnutls? ( gcrypt )
	      sdl2? ( sdl )"

src_prepare() {
	default

	sed -e "s|SYSTEMD_FOUND|WITH_SYSTEMD|" \
	    -e "s|(LIBGCRYPT_LIBRARIES)|(WITH_GCRYPT)|" \
	    -i CMakeLists.txt || die

	if ! use test; then
		sed -e '/foreach(test ${LIBVNCSERVER_TESTS})/,+3d' \
		    -e '/foreach(test ${LIBVNCCLIENT_TESTS})/,+3d' \
		    -i CMakeLists.txt || die
	fi
}

multilib_src_configure() {
	local mycmakeargs=(
		-DLIBVNCSERVER_ALLOW24BPP=$(usex 24bpp)
		-DWITH_SYSTEMD=$(usex systemd)
		-DWITH_GCRYPT=$(usex gcrypt)
		-DWITH_LIBVNCSERVER_IPv6=$(usex ipv6)
		$(cmake-utils_use_find_package zlib ZLIB)
		$(cmake-utils_use_find_package jpeg JPEG)
		$(cmake-utils_use_find_package png PNG)
		$(cmake-utils_use_find_package sdl SDL)
		$(cmake-utils_use_find_package gnutls GnuTLS)
		$(cmake-utils_use_find_package threads Threads)
		$(cmake-utils_use_find_package ssl OpenSSL)
		)

	cmake-utils_src_configure
}
