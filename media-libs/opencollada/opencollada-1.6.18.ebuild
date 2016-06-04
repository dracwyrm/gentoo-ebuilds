# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils multilib cmake-utils

DESCRIPTION="Stream based read/write library for COLLADA files"
HOMEPAGE="http://www.opencollada.org/"
LICENSE="MIT"
IUSE="expat"

# seems like the Khronos Group hasnt invented the SOVERSION yet
MY_SOVERSION="1.6"

SLOT="0"

SRC_URI="https://github.com/KhronosGroup/OpenCOLLADA/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64 ~ppc64 x86"

RDEPEND="dev-libs/libpcre
	dev-libs/zziplib
	media-libs/lib3ds
	sys-libs/zlib
	>=sys-devel/gcc-4.7
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )"
DEPEND="${RDEPEND}
	sys-apps/findutils
	sys-apps/sed"

S=${WORKDIR}/OpenCOLLADA-${PV}
BUILD_DIR="${S}"/build

src_prepare() {

	# Remove some bundled dependencies
	edos2unix CMakeLists.txt || die

	epatch "${FILESDIR}"/${PN}-0_p864-expat.patch

	epatch "${FILESDIR}"/${PN}-1.2.2-soversion.patch
	epatch "${FILESDIR}"/${PN}-1.2.2-no-undefined.patch
	epatch "${FILESDIR}"/${PN}-1.2.2-libdir.patch
	
	# For EAPI v6
	eapply_user

	rm -R Externals/{expat,lib3ds,LibXML,pcre,zlib,zziplib} || die
	ewarn "$(echo "Remaining bundled dependencies:";
		find Externals -mindepth 1 -maxdepth 1 -type d | sed 's|^|- |')"

	# Remove unused build systems
	rm Makefile scripts/{unixbuild.sh,vcproj2cmake.rb} || die
	find "${S}" -name SConscript -delete || die
}

src_configure() {
	local mycmakeargs=(-DUSE_SHARED=ON -DUSE_STATIC=OFF)

	# Master CMakeLists.txt says "EXPAT support not implemented"
	# Something like "set(LIBEXPAT_LIBRARIES expat)" is missing to make it build
	use expat \
		&& mycmakeargs+=(-DUSE_EXPAT=ON -DUSE_LIBXML=OFF) \
		|| mycmakeargs+=(-DUSE_EXPAT=OFF -DUSE_LIBXML=ON)

        # Seems like the Khronos Group hasnt invented the SOVERSION yet.
	mycmakeargs+=(-Dsoversion=${MY_SOVERSION})
	
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dodir /etc/env.d || die
	echo "LDPATH=/usr/$(get_libdir)/opencollada" \
			> "${D}"/etc/env.d/99opencollada || die

	dobin build/bin/OpenCOLLADAValidator || die
}
