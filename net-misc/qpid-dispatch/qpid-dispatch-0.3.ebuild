# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_DEPEND="2"
inherit eutils cmake-utils python

DESCRIPTION="A lightweight message router, written in C and built on Qpid Proton, that provides flexible and scalable interconnect between AMQP endpoints or between endpoints and brokers."
HOMEPAGE="http://qpid.apache.org/dispatch/"
SRC_URI="ftp://ftp.mirrorservice.org/sites/ftp.apache.org/qpid/dispatch/${PV}/qpid-dispatch-${PV}.tar.gz" 
LICENSE="Apache 2.0"
KEYWORDS="~x86 ~amd64"
IUSE="doc qpid-test"
SLOT="0"

RDEPEND="${DEPEND} 
sys-libs/glibc
sys-apps/util-linux
dev-libs/openssl
sys-libs/zlib
>=net-misc/qpid-proton-0.8[python]
"
DEPEND="${RDEPEND}
"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare (){
	for patch in $(ls ${FILESDIR}/${PV}/*.patch 2>/dev/null); do
		echo "Applying patch '$patch'..."
		epatch $patch
	done

	python_convert_shebangs -r 2 python
}

src_configure() {
	mycmakeargs="-DPYTHON_INCLUDE_DIR=$(python_get_includedir) -DPYTHON_LIBRARY=$(python_get_library)"

        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build doc DOCS)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build qpid-test TESTING)"

        cmake-utils_src_configure
}

src_compile() {
        cmake-utils_src_compile
}

src_install() {
        cmake-utils_src_install 

	# Install the python package
	cd ${WORKDIR}/${P}_build/python/
	"$(PYTHON)" setup.py install --root=${D} || die "Failed to install python package"
}
