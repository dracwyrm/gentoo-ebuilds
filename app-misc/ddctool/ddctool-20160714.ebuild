# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools vcs-snapshot

DESCRIPTION="Program for querying and changing monitor settings"
HOMEPAGE="http://www.ddctool.com/"

MY_GIT_COMMIT="9712e9b54693872cd390476a7606fc8d13b66034"
SRC_URI="https://github.com/rockowitz/ddctool/archive/${MY_GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

IUSE="video_cards_fglrx video_cards_nvidia"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="video_cards_fglrx? ( x11-libs/amd-adl-sdk )"

pkg_pretend() {
	CONFIG_CHECK="~I2C_CHARDEV"
	ERROR_I2C_CHARDEV="You must enable I2C_CHARDEV in your kernel to continue"
}

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local econfargs=()

	if use video_cards_fglrx; then
		econfargs+=( --with-adl-headers="/usr/include/ADL" )
	fi

	econf "${econfargs[@]}"
}

pkg_postinst() {
	if use video_cards_nvidia; then
		einfo "=================================================================="
		einfo "Please read the following webpage on proper usage with the nVidia "
		einfo "Binary drivers, or it may not work: http://www.ddctool.com/nvidia/"
		einfo "=================================================================="
	fi
}
