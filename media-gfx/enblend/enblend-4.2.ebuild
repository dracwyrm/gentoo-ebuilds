# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

MY_P="${PN}-enfuse-${PV/_rc/rc}"

DESCRIPTION="Image Blending with Multiresolution Splines"
HOMEPAGE="http://enblend.sourceforge.net/"
SRC_URI="mirror://sourceforge/enblend/${MY_P}.tar.gz"

LICENSE="GPL-2 VIGRA"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="debug doc image-cache openmp tcmalloc"

REQUIRED_USE="openmp? ( !image-cache )
	      tcmalloc ( !debug )"

RDEPEND="
	>=dev-libs/boost-1.55.0:=
	media-libs/glew
	>=media-libs/lcms-2.5:2
	>=media-libs/libpng-1.2.43:0=
	>=media-libs/openexr-1.0:=
	media-libs/plotutils[X]
	media-libs/tiff:=
	>=media-libs/vigra-1.9.0[openexr]
	sci-libs/gsl:=
	virtual/jpeg:0=
	debug? ( dev-libs/dmalloc )
	tcmalloc? ( dev-util/google-perftools )"
DEPEND="${RDEPEND}
	media-gfx/imagemagick
	sys-apps/help2man
	virtual/pkgconfig
	doc? (
		dev-lang/perl
		dev-perl/Readonly
		media-gfx/transfig
		sci-visualization/gnuplot[gd]
		virtual/latex-base
		app-text/dvipsk
		dev-tex/hevea
		media-gfx/graphviz
		media-gfx/imagemagick
		gnome-base/librsvg
	)"

S="${WORKDIR}/${MY_P}"

PATCHES=( "${FILESDIR}/${PN}-4.1.3-vigra_check.patch" )

src_configure() {
	use doc || sed -e "s|can_build_doc=yes|can_build_doc=no|" -i configure || die "sed failed"
	local myeconfargs=(
		--CXXFLAGS="-O3"
		--prefix="${EPREFIX}"
		$(use_enable debug)
		$(use_with debug dmalloc)
		$(use_with tcmalloc)
		$(use_enable image-cache)
		$(use_enable openmp)
	)
	econf $(myeconfargs[@])
}

src_compile() {
	# latex writes to this directory
	addwrite "/var/cache/fonts"

	# forcing -j1 as every parallel compilation process needs about 1 GB RAM.
	emake -j1
}

src_install() {
	local DOCS=( AUTHORS ChangeLog NEWS README )
	default
}
