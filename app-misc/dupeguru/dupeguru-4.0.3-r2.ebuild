# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )
PYTHON_REQ_USE="sqlite"

inherit eutils python-single-r1

DESCRIPTION="Find duplicate files on your system"
HOMEPAGE="https://dupeguru.voltaicideas.net/"
MY_P="${PN}-src-${PV}"
MY_COMMIT="aebc24f80fe176cdb541efcdae62fa05685f00a5"
SRC_URI="https://github.com/arsenetar/${PN}/archive/${PV}-InstallFix.tar.gz -> ${P}.tar.gz
	https://github.com/arsenetar/hscommon/archive/${MY_COMMIT}.tar.gz -> hscommon-20171018.tar.gz"
S="${WORKDIR}/${P}-InstallFix"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	dev-python/PyQt5[${PYTHON_USEDEP},gui,widgets]
	>=dev-qt/qtgui-5.5[jpeg,png,gif]
	>=dev-python/hsaudiotag3k-1.1.3[${PYTHON_USEDEP}]
	>=dev-python/send2trash-1.3.0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/polib[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]"

src_prepare() {
	default

	rm -r hscommon || die "remove directory hscommon failed"
	ln -sf ../hscommon-${MY_COMMIT} hscommon || die "link failed"
}
src_compile() {
	emake PYTHON=${EPYTHON} all build/help
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
}
