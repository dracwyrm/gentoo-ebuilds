# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $id$

EAPI="6"

inherit eutils

DESCRIPTION="RenderMan for Blender addon"
HOMEPAGE="https://renderman.pixar.com/view/renderman4blender"
SRC_URI="https://github.com/bsavery/PRMan-for-Blender/archive/21_2.tar.gz -> ${P}.tar.gz"

# The code was initially forked from mattebb/3delightblender which does not specify a license.
# According to github this generally means the default copyright lwas apply
# An issue requesting clarification has been opened at https://github.com/mattebb/3delightblender/issues/9
LICENSE="Non-Free"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="=media-gfx/blender-${PV}*
	=media-gfx/RenderMan-Installer-ncr-21.2"

DEPEND="${RDEPEND}"

PATCHES=(${FILESDIR}/PRMan-for-Blender-2.78-fix-integrator-widget-flag.patch
	${FILESDIR}/PRMan-for-Blender-2.78-remove-trailing-full-stop-from-descriptions.patch)


S="${WORKDIR}/PRMan-for-Blender-21_2"

src_install() {
	dodir "/usr/share/blender/${PV}/scripts/addons/PRMan-for-Blender-21_2"
	cp -R "${S}" "${D}/usr/share/blender/${PV}/scripts/addons/" || die "Install failed!"
}
