# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils gnome2-utils xdg
DESCRIPTION="The downright luxurious Git client,for Windows, Mac & Linux"
HOMEPAGE="https://www.gitkraken.com"
SRC_URI="https://release.gitkraken.com/linux/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"
LICENSE="gitkraken-EULA"
RDEPEND="
	dev-libs/expat
	dev-libs/nss
	gnome-base/gconf
	gnome-base/libgnome-keyring
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/libpng
	net-print/cups
	net-libs/gnutls
	sys-libs/zlib
	x11-libs/gtk+
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libXtst"

DEPEND="${RDEPEND}"

QA_PREBUILT="opt/gitkraken-bin/resources/app.asar.unpacked/node_modules/nodegit/build/Release/nodegit.node
	opt/gitkraken-bin/gitkraken"
QA_PRESTRIPPED="/opt/gitkraken-bin/libffmpeg.so
	/opt/gitkraken-bin/libnode.so"

S=${WORKDIR}/gitkraken

src_install() {
	local destdir="/opt/${PN}"
	insinto $destdir
	doins -r locales resources
	doins	content_shell.pak \
		icudtl.dat \
		natives_blob.bin \
		snapshot_blob.bin \
		libffmpeg.so \
		libnode.so
	exeinto $destdir
	doexe gitkraken
	doicon -s 512 "$FILESDIR"/ico/gitkraken.png
	dosym $destdir/gitkraken /usr/bin/gitkraken
	make_desktop_entry gitkraken Gitkraken "gitkraken" Network
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
