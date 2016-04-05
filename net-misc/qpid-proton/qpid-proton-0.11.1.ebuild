# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_DEPEND="2"
inherit eutils cmake-utils python

DESCRIPTION="A high-performance, lightweight, AMQP messaging library."
HOMEPAGE="http://qpid.apache.org/proton/"
SRC_URI="mirror://apache/qpid/proton/${PV}/qpid-proton-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
IUSE="cxx java ruby perl php python qpid-test ruby"
SLOT="0"

RDEPEND="
sys-libs/glibc
sys-apps/util-linux
dev-libs/openssl:*
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

if use java; then
	ewarn "WARNING: Building with \"java\" use flag, but this ebuild does not declare an explicit JDK dependency."
	ewarn "You will need to install one manually."
fi

CMAKE_SWITCHES="$CMAKE_SWITCHES -DCMAKE_CXX_FLAGS=-Wno-error=long-long -DCMAKE_SKIP_RPATH=On"
if use ruby; then
	CMAKE_SWITCHES="$CMAKE_SWITCHES -DDEFAULT_RUBY_TESTING=on"
fi

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	# Don't use the SYSINSTALL_BINDINGS[<lang>] switches here as the build will then attempt to write to the system root rather than the build image.
	# We will fix this later in the src_install stage.
	CMAKE_SWITCHES="$CMAKE_SWITCHES -DPYTHON_INCLUDE_DIR=$(python_get_includedir) -DPYTHON_LIBRARY=$(python_get_library)"
}

src_prepare (){
	if use python; then
		python_convert_shebangs -r 2 proton-c/bindings/python
	fi
}

src_configure() {
	mycmakeargs="${CMAKE_SWITCHES}"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build cxx WITH_CXX)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build java JAVA)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build ruby RUBY)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build perl PERL)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build php PHP)"
	mycmakeargs="${mycmakeargs} $(cmake-utils_use_build python PYTHON)"

	cmake-utils_src_configure
}

pkg_postinst() {
	if use python; then
		# Install the python bindings
		cd "${WORKDIR}/${P}/proton-c/bindings/python/"
		"$(PYTHON)" setup.py install || die "Failed to install python bindings"
	fi
}
