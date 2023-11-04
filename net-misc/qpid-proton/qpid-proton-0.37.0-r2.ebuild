# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8,9,10} )
inherit cmake python-single-r1

DESCRIPTION="A high-performance, lightweight, AMQP messaging library."
HOMEPAGE="https://qpid.apache.org/proton/"
SRC_URI="mirror://apache/qpid/proton/${PV}/qpid-proton-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86"
IUSE="cxx go python qpid-test ruby"
SLOT="0"

RDEPEND="
sys-apps/util-linux
dev-libs/openssl:*
sys-libs/zlib
"

DEPEND="${RDEPEND}
dev-util/ninja
go? (
	dev-lang/swig
	)
python? (
	dev-lang/swig
	)
ruby? (
	dev-lang/swig
	)
"

pkg_setup() {
	if use python; then
		python-single-r1_pkg_setup
	fi

	# Don't use the SYSINSTALL_BINDINGS[<lang>] switches here as the build will then attempt to write to the system root rather than the build image.
}

src_prepare () {
	eapply_user

	if use python; then
		python_fix_shebang python
	fi

	cmake_src_prepare
}

src_configure() {
	if use ruby; then
		CMAKE_SWITCHES="-DDEFAULT_RUBY_TESTING=on"
	fi

	local mycmakeargs=( $CMAKE_SWITCHES
		-DCMAKE_CXX_FLAGS="-Wno-error=unused-result"
		-DBUILD_CPP="$(usex cxx)"
		-DBUILD_GO="$(usex go)"
		-DBUILD_TESTING="$(usex qpid-test)"
	)

	cmake_src_configure
}
