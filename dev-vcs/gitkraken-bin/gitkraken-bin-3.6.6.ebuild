# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils xdg

ELECTRON_SLOT="1.8"
DESCRIPTION="The intuitive, fast, and beautiful cross-platform Git client"
HOMEPAGE="https://www.gitkraken.com"
SRC_URI="https://release.gitkraken.com/linux/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="gitkraken-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	dev-util/electron-bin:${ELECTRON_SLOT}
	gnome-base/libgnome-keyring
	net-misc/curl
	net-libs/gnutls
"

S="${WORKDIR}/gitkraken"

src_install() {
	newbin "${FILESDIR}"/gitkraken-launcher.sh-r1 gitkraken
	sed "s:%%ELECTRON%%:electron-${ELECTRON_SLOT}:" \
		-i "${ED%/}"/usr/bin/gitkraken || die

	# note: intentionally not using "doins" so that we preserve +x bits
	dodir /usr/libexec/gitkraken
	cp -R resources/app.asar{,.unpacked} "${ED%/}"/usr/libexec/gitkraken || die
	scanelf -Xe "${ED%/}"/usr/libexec/gitkraken/app.asar.unpacked/node_modules/nodegit/build/Release/nodegit.node || die

	dosym libcurl.so.4 "/usr/$(get_libdir)/libcurl-gnutls.so.4"

	doicon -s 512 "${FILESDIR}"/icon/gitkraken.png
	make_desktop_entry gitkraken GitKraken gitkraken Development
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
