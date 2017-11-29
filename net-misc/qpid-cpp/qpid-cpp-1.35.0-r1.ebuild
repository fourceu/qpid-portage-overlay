# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils cmake-utils distutils-r1 user

DESCRIPTION="An AMQP message broker written in C++"
HOMEPAGE="https://qpid.apache.org/cpp/"
SRC_URI="https://archive.apache.org/dist/qpid/cpp/${PV}/qpid-cpp-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
IUSE="acl amqp doc ha legacystore linearstore msclfs mssql perl rdma ruby sasl ssl qpid-test qpid-xml qpid-service"
SLOT="0"

RDEPEND="
${PYTHON_DEPS}
<net-misc/qpid-proton-0.15.0
linearstore? (
	dev-libs/libaio
	sys-libs/db:*[cxx]
	)
legacystore? (
	dev-libs/libaio
	sys-libs/db:*[cxx]
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
!net-misc/qpid-qmf
!net-misc/qpid-tools
"

DEPEND="${RDEPEND}
dev-libs/boost
virtual/rubygems
doc? ( app-doc/doxygen )
"

pkg_setup() {
	if use qpid-service; then
		enewgroup qpidd
		enewuser qpidd -1 -1 -1 "qpidd"
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${P}-no-cmake-python-tools-install.patch"
}

src_configure() {
	if use linearstore || use legacystore; then
		# Berkeley DB include directory can be in unexpected places - try to find it here
		DB_INCLUDE=$( find /usr/include -type f -name 'db_cxx.h' -printf %h)
		if [ ! -z "$DB_INCLUDE" ]; then
			CMAKE_SWITCHES="-DDB_CXX_INCLUDE_DIR=$DB_INCLUDE"
		fi
	fi

	local mycmakeargs=(${CMAKE_SWITCHES}
		-DPYTHON_EXECUTABLE=$(which python2) # Override system default, which is probably python 3
		$(cmake-utils_use_build acl ACL)
		$(cmake-utils_use_build amqp AMQP)
		$(cmake-utils_use_build doc DOCS)
		$(cmake-utils_use_build ha HA)
		$(cmake-utils_use_build legacystore LEGACYSTORE)
		$(cmake-utils_use_build linearstore LINEARSTORE)
		$(cmake-utils_use_build msclfs MSCLFS)
		$(cmake-utils_use_build mssql MSSQL)
		$(cmake-utils_use_build perl BINDING_PERL)
		$(cmake-utils_use_build rdma RDMA)
		$(cmake-utils_use_build ruby BINDING_RUBY)
		$(cmake-utils_use_build sasl SASL)
		$(cmake-utils_use_build ssl SSL)
		$(cmake-utils_use_build qpid-test TESTING)
		$(cmake-utils_use_build qpid-xml XML)
	)

	cmake-utils_src_configure
}

python_compile() {
	cd management/python

	distutils-r1_python_compile
}

python_install() {
	cd management/python

	distutils-r1_python_install
}

src_install() {
	cmake-utils_src_install

	distutils-r1_src_install

	if use qpid-service; then
		newinitd "${FILESDIR}/qpidd-init.d-gentoo-v2" qpidd
		newconfd "${FILESDIR}/qpidd-conf.d-gentoo-v1" qpidd
		if use ha; then
			newinitd "${WORKDIR}/${P}_build/etc/qpidd-primary" qpidd-primary
		fi

		insinto "/etc"
		newins "${FILESDIR}/qpidd.conf.default-gentoo-v1" "qpidd.conf"
	fi
}