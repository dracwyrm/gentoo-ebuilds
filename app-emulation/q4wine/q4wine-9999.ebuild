# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils xdg-utils

DESCRIPTION="Qt GUI configuration tool for Wine"
HOMEPAGE="https://github.com/brezerk/q4wine"

if [[ ${PV} == "9999" ]] ; then
        EGIT_REPO_URI="https://github.com/brezerk/q4wine.git"
        EGIT_BRANCH="master"
        inherit git-r3
        SRC_URI=""
else
        SRC_URI="https://github.com/brezerk/q4wine/archive/v${PV}.tar.gz -> ${P}.tar.gz"
        KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+dbus debug +ico +iso +wineappdb"

CDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsingleapplication[qt5(+),X]
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	dbus? ( dev-qt/qtdbus:5 )
	ico? ( >=media-gfx/icoutils-0.26.0 )
"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5
"
RDEPEND="${CDEPEND}
	app-admin/sudo
	>=sys-apps/which-2.19
	iso? ( sys-fs/fuseiso )
"

DOCS=( AUTHORS ChangeLog README )

src_configure() {
	local mycmakeargs=(
		-DDEBUG=$(usex debug ON OFF)
		-DWITH_ICOUTILS=$(usex ico ON OFF)
		-DWITH_SYSTEM_SINGLEAPP=ON
		-DWITH_WINEAPPDB=$(usex wineappdb ON OFF)
		-DUSE_BZIP2=OFF
		-DUSE_GZIP=OFF
		-DWITH_DBUS=$(usex dbus ON OFF)
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
