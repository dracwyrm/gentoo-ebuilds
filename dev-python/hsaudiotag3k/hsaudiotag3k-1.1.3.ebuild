# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python3_{3,4,5,6} )

inherit distutils-r1

MY_PN="hsaudiotag3k"
DESCRIPTION="Read metdata (tags) of mp3, mp4, wma, ogg, flac and aiff files."
HOMEPAGE="https://github.com/hsoft/hsaudiotag"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="amd64 x86 arm"
LICENSE="BSD"
SLOT="0"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

S="${WORKDIR}"/${MY_PN}-${PV}
