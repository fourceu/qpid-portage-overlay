# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils cmake-utils python-single-r1

DESCRIPTION="A high-performance, lightweight, AMQP messaging library."
HOMEPAGE="http://qpid.apache.org/proton/"
SRC_URI="mirror://apache/qpid/proton/${PV}/qpid-proton-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
IUSE="cxx java ruby perl php python qpid-test ruby"
SLOT="0"

RDEPEND="
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

pkg_setup() {
	python-single-r1_pkg_setup

	# Don't use the SYSINSTALL_BINDINGS[<lang>] switches here as the build will then attempt to write to the system root rather than the build image.
	# We will fix this later in the src_install stage.
}

src_unpack() {
	# This is a hack for the invalid unpack location of the source archive. Should be removed from future ebuilds.
	unpack ${A}
	mv "${WORKDIR}/qpid-proton-0.9.1-rc1" "${WORKDIR}/${P}"
}

src_prepare (){
	if use python; then
		python_fix_shebang proton-c/bindings/python
	fi
}

src_configure() {
	if use java; then
		ewarn "WARNING: Building with \"java\" use flag, but this ebuild does not declare an explicit JDK dependency."
		ewarn "You will need to install one manually."
	fi

	CMAKE_SWITCHES="-DCMAKE_CXX_FLAGS=-Wno-error=long-long"
	if use ruby; then
		CMAKE_SWITCHES="$CMAKE_SWITCHES -DDEFAULT_RUBY_TESTING=on"
	fi

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
		touch proton/cproton.i
		"$(PYTHON)" setup.py install || die "Failed to install python bindings"
	fi
}
