# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools linux-info vcs-snapshot

DESCRIPTION="Program for querying and changing monitor settings"
HOMEPAGE="http://www.ddctool.com/"

MY_GIT_COMMIT="9712e9b54693872cd390476a7606fc8d13b66034"
SRC_URI="https://github.com/rockowitz/ddctool/raw/${MY_GIT_COMMIT}/${P}.tar.gz"

# Binary drivers need special instructions compared to the open source counterparts.
# If a user switches drivers, they will need to set different use flags for
# Xorg or Wayland or Mesa, so this will trigger the rebuild against
# the different drivers.
IUSE="video_cards_fglrx video_cards_nvidia"

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

pkg_postinst() {
	einfo "You many need to change device permissions to allow users to"
	einfo "access the monitor. More information can be found here:"
	einfo "http://www.ddctool.com/i2c_permissions/"
	einfo "On Gentoo, you will need to create the i2c group."

	if use video_cards_nvidia; then
		einfo "=================================================================="
		einfo "Please read the following webpage on proper usage with the nVidia "
		einfo "Binary drivers, or it may not work: http://www.ddctool.com/nvidia/"
		einfo "=================================================================="
	fi
}
