# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools linux-info vcs-snapshot udev user

DESCRIPTION="Program for querying and changing monitor settings"
HOMEPAGE="http://www.ddctool.com/"

MY_GIT_COMMIT="9712e9b54693872cd390476a7606fc8d13b66034"
SRC_URI="https://github.com/rockowitz/ddctool/raw/${MY_GIT_COMMIT}/${P}.tar.gz"

# Binary drivers need special instructions compared to the open source counterparts.
# If a user switches drivers, they will need to set different use flags for
# Xorg or Wayland or Mesa, so this will trigger the rebuild against
# the different drivers.
IUSE="udev-i2c udev-usb video_cards_fglrx video_cards_nvidia"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="x11-libs/libXrandr"
DEPEND="video_cards_fglrx? ( x11-libs/amd-adl-sdk )
	virtual/pkgconfig
	${RDEPEND}"

pkg_pretend() {
	# This program needs /dev/ic2-* devices to communicate with the monitor.
	# It will support control over USB if the monitor supports it.
	CONFIG_CHECK="~I2C_CHARDEV"
	ERROR_I2C_CHARDEV="You must enable I2C_CHARDEV in your kernel to continue"
}

src_configure() {
	econf $(usex video_cards_fglrx "--with-adl-headers=/usr/include/ADL" "")
}

src_install() {
	default
	use udev-i2c && udev_dorules data/etc/udev/rules.d/45-ddctool-i2c.rules
	use udev-usb && udev_dorules data/etc/udev/rules.d/45-ddctool-usb.rules
}

pkg_postinst() {
	if use udev-i2c; then
		enewgroup i2c
		udev_reload
		einfo "To access the /dev/i2c devices as non-root users, add the user"
		einfo "to the i2c group. usermod -aG i2c user"
		einfo "For more information read: http://www.ddctool.com/i2c_permissions/"
	fi
	
	if use udev-usb; then
		udev_reload
		einfo "To access the USB monitor as non-root users, add the user"
		einfo "to the video group. usermod -aG video user"
		einfo "For more information read: http://www.ddctool.com/usb/"
	fi

	if use video_cards_nvidia; then
		einfo "=================================================================="
		einfo "Please read the following webpage on proper usage with the nVidia "
		einfo "Binary drivers, or it may not work: http://www.ddctool.com/nvidia/"
		einfo "=================================================================="
	fi
}
