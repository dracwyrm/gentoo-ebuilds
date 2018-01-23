# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib vcs-snapshot

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="http://openexr.com/"

MY_GIT_COMMIT="165dceaeee86e0f8ce1ed1db3e3030c609a49f17"
SRC_URI="https://github.com/openexr/openexr/archive/${MY_GIT_COMMIT}.tar.gz \
		-> OpenEXR-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0/23" # based on SONAME
KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="examples"

# Only need hard blocker for 2.2.0 series. Can remove on version bump.
RDEPEND="sys-libs/zlib[${MULTILIB_USEDEP}]
	~media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]
	!!=media-libs/ilmbase-2.2.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=sys-devel/autoconf-archive-2016.09.16"

S="${WORKDIR}/OpenEXR-${PV}/OpenEXR"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.0-fix-cpuid-on-abi_x86_32.patch"
	"${FILESDIR}/${PN}-2.2.1-cmake-fixes.patch"
)

mycmakeargs=(
	-DILMBASE_PACKAGE_PREFIX="${EPREFIX}/usr"
	-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
)

src_prepare() {
	cmake-utils_src_prepare

	# Fix path for testsuite
	sed -i -e "s:/var/tmp/:${T}:" IlmImfTest/tmpDir.h || die
}

multilib_src_install_all() {
	einstalldocs

	docompress -x /usr/share/doc/${PF}/examples
	if ! use examples; then
		rm -rf "${ED%/}"/usr/share/doc/${PF}/examples || die
	fi
}
