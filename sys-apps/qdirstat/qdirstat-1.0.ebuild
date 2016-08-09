EAPI=6

inherit qmake-utils

DESCRIPTION="QDirStat - Qt-based directory statistics"
HOMEPAGE="https://github.com/shundhammer/qdirstat"
SRC_URI="https://github.com/shundhammer/qdirstat/archive/${PV}.zip"

LICENSE="GPL V2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="dev-qt/qtgui:5"
RDEPEND="${DEPEND}"

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${ED}" install
}
