# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils vcs-snapshot

DESCRIPTION="An extremely low latency KVMFR implementation for guests with VGA PCI Passthrough."
HOMEPAGE="https://looking-glass.hostfission.com/"

MY_GIT_COMMIT="f75e2fe8dbeff26a08c18f18061abda17b2b31a6"
SRC_URI="https://github.com/gnif/${PN}/archive/${MY_GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="app-emulation/spice-protocol
	dev-libs/gmp
	dev-libs/libconfig
	dev-libs/nettle
	dev-util/pkgconfig
	media-fonts/freefont
	media-libs/glu
	media-libs/libsdl2
	media-libs/mesa
	media-libs/sdl2-ttf
	x11-libs/libX11"

DEPEND="${RDEPEND}
	media-libs/fontconfig"

S="${S}/client"

src_install() {
	dobin ${WORKDIR}/${P}_build/looking-glass-client
}

pkg_postinst() {
	elog "Please read the all the instructions at"
	elog "https://looking-glass.hostfission.com/quickstart"
}
