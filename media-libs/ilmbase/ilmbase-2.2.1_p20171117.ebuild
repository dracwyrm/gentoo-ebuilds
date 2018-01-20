# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-multilib vcs-snapshot

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"

MY_GIT_COMMIT="165dceaeee86e0f8ce1ed1db3e3030c609a49f17"
SRC_URI="https://github.com/openexr/openexr/archive/${MY_GIT_COMMIT}.tar.gz \
		-> OpenEXR-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0/23" # based on SONAME
KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"

DEPEND="virtual/pkgconfig"

S="${WORKDIR}/OpenEXR-${PV}/IlmBase"

MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/IlmBaseConfig.h )

PATCHES=(
	"${FILESDIR}/${PN}-2.2.0-use-gnuinstall-dirs-and-fix-pkgconfig-file.patch"
	"${FILESDIR}/${PN}-2.2.1-soname.patch"
)
