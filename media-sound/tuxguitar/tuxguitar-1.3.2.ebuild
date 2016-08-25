# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $id$

EAPI="6"
JAVA_PKG_IUSE="source"

inherit eutils java-pkg-2 java-ant-2 toolchain-funcs flag-o-matic fdo-mime gnome2-utils

MY_P="${P}-src"
DESCRIPTION="TuxGuitar is a multitrack guitar tablature editor and player written in Java-SWT"
HOMEPAGE="http://tuxguitar.herac.com.ar/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"

IUSE="alsa fluidsynth jack lilypond oss pdf timidity tray"

KEYWORDS="~amd64 ~x86"

CDEPEND="dev-java/swt:3.7[cairo]
	alsa? ( media-libs/alsa-lib )
	pdf? ( dev-java/itext:5 )
	fluidsynth? ( media-sound/fluidsynth )
	lilypond? ( media-sound/lilypond )"

RDEPEND=">=virtual/jre-1.5
	timidity? (
		alsa? ( media-sound/timidity++[alsa] )
		oss? ( media-sound/timidity++[oss] )
		media-sound/timidity++
	)
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"

S="${WORKDIR}/${MY_P}"

LIBRARY_LIST=()
PLUGIN_LIST=()

src_prepare() {
	java-pkg-2_src_prepare

	eapply "${FILESDIR}"/${PN}-fixed-ant-files.patch
	eapply_user

	sed -e "s|../TuxGuitar/lib/swt.jar|$(java-pkg_getjar swt-3.7 swt.jar)|" \
		-i TuxGuitar*/build.properties || die "Sed failed to live up to it's name"

	if use pdf; then
		sed -e "s|../TuxGuitar/lib/itext.jar|$(java-pkg_getjar itext-5 itext.jar)|" \
		-i TuxGuitar-pdf/build.properties || die "Sed failed to live up to it's name"
	fi

	LIBRARY_LIST=( TuxGuitar-lib TuxGuitar-awt-graphics TuxGuitar-editor-utils
		TuxGuitar-gm-utils TuxGuitar
	)

	PLUGIN_LIST=( $(usev alsa) ascii browser-ftp community compat
		converter $(usev fluidsynth) gm-settings gpx gtp gtp-ui image
		$(usev jack) $(usex jack jack-ui "") jsa $(usev lilypond) midi
		musicxml $(usev oss) $(usev pdf) ptb svg tef $(usev tray) tuner
	)
}

src_compile() {
	BUILD_ORDER=( ${LIBRARY_LIST[@]} ${PLUGIN_LIST[@]/#/TuxGuitar-} )

	for directory in ${BUILD_ORDER[@]}; do
		cd "${S}"/${directory} || die "cd ${directory} failed"
		eant
		if [[ -d jni ]]; then
			append-flags -fPIC $(java-pkg_get-jni-cflags)
			cd jni || die "cd jni failed"
			CC=$(tc-getCC) emake
		fi
	done
}

src_install() {
	local TUXGUITAR_INST_PATH="/usr/share/${PN}"

	for library in ${LIBRARY_LIST[@]}; do
		cd "${S}"/${library} || die "cd failed"
		java-pkg_dojar ${library,,}.jar
		use source && java-pkg_dosrc src/org
	done

	java-pkg_dolauncher ${PN} \
		--main org.herac.tuxguitar.app.TGMainSingleton \
		--java_args "-Xmx512m  -Dtuxguitar.share.path=${TUXGUITAR_INST_PATH}/share"

	# Images and Files
	insinto ${TUXGUITAR_INST_PATH}
	doins -r share

	java-pkg_sointo ${TUXGUITAR_INST_PATH}/lib
	insinto ${TUXGUITAR_INST_PATH}/share/plugins
	for plugin in ${PLUGIN_LIST[@]/#/TuxGuitar-}; do
		cd "${S}"/${plugin} || die
		doins ${plugin,,}.jar

		#TuxGuitar has its own classloader. No need to register the plugins.
		if [[ -d jni ]]; then
			java-pkg_doso jni/lib${plugin,,}-jni.so
		fi
	done

	insinto ${TUXGUITAR_INST_PATH}/share
	doins -r "${S}"/TuxGuitar-resources/resources/soundfont
	doman "${S}/misc/${PN}.1"
	insinto /usr/share/mime/packages
	doins "${S}/misc/${PN}.xml"
	doicon "${S}/misc/${PN}.xpm"
	domenu "${S}/misc/${PN}.desktop"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
	if use fluidsynth; then
		ewarn "Fluidsynth plugin blocks behavior of JSA plugin."
		ewarn "Enable only one of them in \"Tools > Plugins\""
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
