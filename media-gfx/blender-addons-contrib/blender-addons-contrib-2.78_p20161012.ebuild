# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit vcs-snapshot

DESCRIPTION="Upstream and user created addons for Blender"
HOMEPAGE="http://www.blender.org"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"

MY_PV=${PV%_*}

GIT_BASE_URI="https://git.blender.org/gitweb/gitweb.cgi"
GIT_CONTRIB_URI="${GIT_BASE_URI}/blender-addons-contrib.git"
GIT_CONTRIB_HASH="a52733b58d95ce60ecde95a9eca242e7319c285a"
SRC_URI="${GIT_CONTRIB_URI}/snapshot/${GIT_CONTRIB_HASH}.tar.gz -> ${P}.tar.gz"

RDEPEND="~media-gfx/blender-${MY_PV}"
DEPEND="~media-gfx/blender-${MY_PV}"

src_compile() { :; }

src_install() {
	MYPATH="/usr/share/blender/${MY_PV}/scripts/addons_contrib"
	dodir ${MYPATH}
	insinto ${MYPATH}
	doins -r ${S}/*
}
