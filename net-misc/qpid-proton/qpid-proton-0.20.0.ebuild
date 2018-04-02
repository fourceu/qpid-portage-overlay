# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils cmake-utils python-single-r1

DESCRIPTION="A high-performance, lightweight, AMQP messaging library."
HOMEPAGE="https://qpid.apache.org/proton/"
SRC_URI="mirror://apache/qpid/proton/${PV}/qpid-proton-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
IUSE="libressl cxx java ruby perl php python qpid-test ruby"
SLOT="0"

RDEPEND="
sys-apps/util-linux
!libressl? ( dev-libs/openssl:* )
libressl? ( dev-libs/libressl:* )
sys-libs/zlib
php? (
	dev-lang/php:*
	)
"

DEPEND="${RDEPEND}
java? (
	dev-lang/swig
	)
perl? (
	dev-lang/swig
	)
php? (
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

src_prepare (){
	if use python; then
		python_fix_shebang proton-c/bindings/python
	fi

	cmake-utils_src_prepare
}

src_configure() {
	if use java; then
		ewarn "WARNING: Building with \"java\" use flag, but this ebuild does not declare an explicit JDK dependency."
		ewarn "You will need to install one manually."
	fi

	if use ruby; then
		CMAKE_SWITCHES="-DDEFAULT_RUBY_TESTING=on"
	fi

	local mycmakeargs=( $CMAKE_SWITCHES
		-DCMAKE_CXX_FLAGS="-Wno-error=unused-result -std=c++11"
		-DBUILD_CPP=off
		$(cmake-utils_use_build cxx WITH_CXX)
		$(cmake-utils_use_build java JAVA)
		$(cmake-utils_use_build ruby RUBY)
		$(cmake-utils_use_build perl PERL)
		$(cmake-utils_use_build php PHP)
		$(cmake-utils_use_build python PYTHON)
	)

	cmake-utils_src_configure
}
