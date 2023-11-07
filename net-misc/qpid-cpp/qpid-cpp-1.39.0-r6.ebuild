# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )
inherit cmake git-r3

DESCRIPTION="An AMQP message broker written in C++"
HOMEPAGE="https://qpid.apache.org/cpp/"
LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86"
IUSE="acl amqp doc ha legacystore linearstore msclfs mssql perl qpid-service qpid-test qpid-xml rdma ruby sasl ssl"
SLOT="0"

EGIT_REPO_URI="https://github.com/apache/qpid-cpp.git"
EGIT_COMMIT="8029971c328020221d5bbc548bb75bb6442c4f75"

RDEPEND="
dev-lang/python
qpid-service? ( acct-user/qpidd )
net-misc/qpid-proton
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
	)
!net-misc/qpid-qmf
!net-misc/qpid-tools
"

DEPEND="${RDEPEND}
dev-util/ninja
dev-libs/boost
virtual/rubygems
doc? ( app-doc/doxygen )
"

PATCHES=(
	"${FILESDIR}/${P}-no-cmake-python-tools-install.patch"
	"${FILESDIR}/${P}-fix-python2-in-cmake.patch"
	"${FILESDIR}/${P}-fix-invalid-hex-literal.patch"
	"${FILESDIR}/${P}-fix-installing-missing-compiled-bindings.patch"
)

src_configure() {
	if use linearstore || use legacystore; then
		# Berkeley DB include directory can be in unexpected places - try to find it here
		DB_INCLUDE=$( find /usr/include -type f -name 'db_cxx.h' -printf "%h\n" | tail -n1)
		if [ ! -z "$DB_INCLUDE" ]; then
			CMAKE_SWITCHES="-DDB_CXX_INCLUDE_DIR=$DB_INCLUDE"
		fi
	fi

	local mycmakeargs=(${CMAKE_SWITCHES}
		-DENABLE_WARNING_ERROR=off
		-DBUILD_AMQP=$(usex amqp)
		-DBUILD_BINDING_PERL=$(usex perl)
		-DBUILD_BINDING_RUBY=$(usex ruby)
		-DBUILD_DOCS=$(usex doc)
		-DBUILD_HA=$(usex ha)
		-DBUILD_LEGACYSTORE=$(usex legacystore)
		-DBUILD_LINEARSTORE=$(usex linearstore)
		-DBUILD_MSCLFS=$(usex msclfs)
		-DBUILD_MSSQL=$(usex mssql)
		-DBUILD_RDMA=$(usex rdma)
		-DBUILD_SASL=$(usex sasl)
		-DBUILD_SSL=$(usex ssl)
		-DBUILD_TESTING=$(usex qpid-test)
		-DBUILD_XML=$(usex qpid-xml)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use qpid-service; then
		newinitd "${FILESDIR}/qpidd-init.d-gentoo-v3" qpidd
		newconfd "${FILESDIR}/qpidd-conf.d-gentoo-v1" qpidd
		if use ha; then
			newinitd "${WORKDIR}/${P}_build/etc/qpidd-primary" qpidd-primary
		fi

		insinto "/etc"
		newins "${FILESDIR}/qpidd.conf.default-gentoo-v1" "qpidd.conf"
	fi
}
