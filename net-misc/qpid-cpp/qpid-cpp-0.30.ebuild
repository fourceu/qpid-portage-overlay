# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_DEPEND="2"
inherit eutils cmake-utils python user

DESCRIPTION="A message broker written in C++ that stores, routes, and forwards messages using AMQP."
HOMEPAGE="http://qpid.apache.org/cpp/"
LICENSE="Apache 2.0"
IUSE="acl amqp doc ha legacystore linearstore msclfs mssql perl rdma ruby sasl ssl qpid-test qpid-xml service"

SRC_URI="https://dist.apache.org/repos/dist/release/qpid/${PV}/qpid-cpp-${PV}.tar.gz"

RDEPEND="
>=net-misc/qpid-proton-0.7
linearstore? (
    dev-libs/libaio
    sys-libs/db[cxx]
    )
legacystore? (
    dev-libs/libaio
    sys-libs/db[cxx]
    )
ssl? (
    dev-libs/nss
    dev-libs/nspr
    dev-libs/cyrus-sasl
    )
sasl? ( dev-libs/cyrus-sasl )
qpid-xml? (
    dev-libs/xerces-c
    dev-libs/xqilla 
    )
"

DEPEND="${RDEPEND}
dev-libs/boost
>=dev-lang/ruby-1.9.3
doc? ( app-doc/doxygen )
"

CMAKE_SWITCHES=""
if use linearstore || use legacystore; then
	# Berkeley DB include directory can be in unexpected places - try to find it here
	DB_INCLUDE=$(find /usr/include -type d -name 'db*' -print -quit)
	if [ ! -z "$DB_INCLUDE" ]; then
		CMAKE_SWITCHES="$CMAKE_SWITCHES -DDB_CXX_INCLUDE_DIR=$DB_INCLUDE"
	fi
fi

SLOT="0"
KEYWORDS="ia64 x86 amd64-linux x86-linux"
 
pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	CMAKE_SWITCHES="$CMAKE_SWITCHES -DPYTHON_INCLUDE_DIR=$(python_get_includedir) -DPYTHON_LIBRARY=$(python_get_library)"

	if use service; then
		enewgroup qpidd
		enewuser qpidd -1 -1 -1 "qpidd"
	fi
}

src_prepare (){
        for patch in $(ls ${FILESDIR}/${PV}/*.patch 2>/dev/null); do
                echo "Applying patch '$patch'..."
                epatch $patch
        done
}

src_configure() {
        mycmakeargs="${CMAKE_SWITCHES}"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build acl ACL)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build amqp AMQP)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build doc DOCS)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build ha HA)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build legacystore LEGACYSTORE)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build linearstore LINEARSTORE)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build msclfs MSCLFS)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build mssql MSSQL)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build perl BINDING_PERL)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build rdma RDMA)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build ruby BINDING_RUBY)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build sasl SASL)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build ssl SSL)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build qpid-test TESTING)"
        mycmakeargs="${mycmakeargs} $(cmake-utils_use_build qpid-xml XML)"

        cmake-utils_src_configure
}

src_install() {
        cmake-utils_src_install

if use service; then
	sed 's/QPID_CONFIG=.*/QPID_CONFIG=\/etc\/qpidd\.conf/' -i ${WORKDIR}/${P}_build/etc/qpidd 
	sed 's/source.*functions/source \/etc\/init.d\/functions.sh/' -i ${WORKDIR}/${P}_build/etc/qpidd 

        newinitd "${WORKDIR}/${P}_build/etc/qpidd" qpidd
        if use ha; then
                newinitd "${WORKDIR}/${P}_build/etc/qpidd-primary" qpidd-primary
        fi

        insinto "${ROOT}/etc"
        doins "${WORKDIR}/${P}/etc/qpidd.conf"

        dodir -g qpidd -o qpidd -m 754 /var/lib/qpidd
        keepdir /var/lib/qpidd
fi
}
