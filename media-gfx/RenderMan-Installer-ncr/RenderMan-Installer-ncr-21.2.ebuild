# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
inherit rpm

DESCRIPTION="Pixar's core rendering technology for animation and VFX"
HOMEPAGE="https://renderman.pixar.com/view/renderman"
SRC_URI="RenderMan-InstallerNCR-21.2.0_1676607-linuxRHEL6_gcc44icc150.x86_64.rpm"

LICENSE="Pixar-NCR"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror fetch"

OUTPUTDIR="/opt/pixar/${P}"

S="${WORKDIR}${OUTPUTDIR}"

check_tarballs_available() {
        local uri=$1; shift
        local dl= unavailable=
        for dl in "${@}"; do
                [[ ! -f "${DISTDIR}/${dl}" ]] && unavailable+=" ${dl}"
        done

        if [[ -n "${unavailable}" ]] ; then
                if [[ -z ${_check_tarballs_available_once} ]] ; then
                        einfo
                        einfo "Pixar requires you to download the needed files manually after"
                        einfo "signing up and logging into their forum"
                        einfo
                        _check_tarballs_available_once=1
                fi
                einfo "Download the following files:"
                for dl in ${unavailable}; do
                        einfo "  ${dl}"
                done
                einfo "following the instructions at '${uri}'"
                einfo "and move them to '${DISTDIR}'"
                einfo
        fi
}

pkg_nofetch() {
        check_tarballs_available "https://renderman.pixar.com/view/get-renderman" "${SRC_URI}"
}

src_install() {
	dodir "${OUTPUTDIR}/"
	cp -R "${S}/bin" "${D}${OUTPUTDIR}/" || die "Install binary files failed!"
	cp -R "${S}/lib" "${D}${OUTPUTDIR}/" || die "Install library files failed!"

	#TODO: Solve the QA non-stripped binaries/libraries notice. prepall does not seem to be working.
	prepall
}

pkg_postinst() {
	elog "To install the renderman components you must now manually run"
	elog "# ${OUTPUTDIR}/bin/RenderManInstaller"
	elog
	elog "Log in with your renderman forum username and password and select at least RenderMan ProServer 21.2"
	elog
	elog "For blender integration you also need to install the PRMan-for-blender addon"
}
