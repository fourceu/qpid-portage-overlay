# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8
PYTHON_COMPAT=( python2_7 )
inherit cmake-utils python-single-r1

DESCRIPTION="A lightweight message router that provides interconnect between AMQP endpoints"
HOMEPAGE="http://qpid.apache.org/dispatch/"
SRC_URI="mirror://apache/qpid/dispatch/${PV}/qpid-dispatch-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
IUSE="doc qpid-test"
SLOT="0"

RDEPEND="
dev-libs/openssl:*
sys-libs/zlib
>=net-misc/qpid-proton-0.9[python]
"

DEPEND="${RDEPEND}
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare (){
	for patch in $(ls "${FILESDIR}/${PV}/*.patch" 2>/dev/null); do
		echo "Applying patch '$patch'..."
		epatch $patch
	done

	python_fix_shebang .
#	python_convert_shebangs -r 2 python
}

src_configure() {
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build doc DOCS)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build qpid-test TESTING)"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Install the python package
	cd "${WORKDIR}/${P}_build/python/"
	"${PYTHON}" setup.py install --root="${D}" || die "Failed to install python package"
}
