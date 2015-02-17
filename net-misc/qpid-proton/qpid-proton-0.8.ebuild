# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_DEPEND="2"
inherit eutils cmake-utils python

DESCRIPTION="A high-performance, lightweight, AMQP messaging library."
HOMEPAGE="http://qpid.apache.org/proton/"
LICENSE="Apache 2.0"
SRC_URI="ftp://ftp.mirrorservice.org/sites/ftp.apache.org/qpid/proton/${PV}/qpid-proton-${PV}.tar.gz" 
IUSE="cxx java ruby perl php python qpid-test ruby"

RDEPEND="
sys-libs/glibc
sys-apps/util-linux
dev-libs/openssl
sys-libs/zlib
php? (
	dev-lang/php
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

if [ -f /etc/os-release ]; then REGEX=".*\sID=(\w*).*"; OS_RELEASE=$(cat /etc/os-release); [[ $OS_RELEASE =~ $REGEX ]]; DISTRO=${BASH_REMATCH[1]}; else DISTRO="unknown"; fi
MACHINE=$(uname -m)
SPEC="${DISTRO}-${MACHINE}.cmake-spec"

SLOT="0"
KEYWORDS="ia64 x86 amd64-linux x86-linux"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup

	# Don't use the SYSINSTALL_BINDINGS[<lang>] switches here as the build will then attempt to write to the system root rather than the build image.
	# We will fix this later in the src_install stage.
	CMAKE_SWITCHES="$CMAKE_SWITCHES -DPYTHON_INCLUDE_DIR=$(python_get_includedir) -DPYTHON_LIBRARY=$(python_get_library)"
}

src_prepare (){
	for patch in $(ls ${FILESDIR}/${PV}/*.patch 2>/dev/null); do
		echo "Applying patch '$patch'..."
		epatch $patch
	done

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

src_compile() {
	cmake-utils_src_compile
}

src_install() {
        cmake-utils_src_install 

	if use python; then	
		# Install the python bindings
		cd ${WORKDIR}/${P}_build/proton-c/bindings/python/
		"$(PYTHON)" setup.py install --root=${D} || die "Failed to install python bindings"
	fi
}
