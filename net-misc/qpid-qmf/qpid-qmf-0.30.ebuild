# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_DEPEND="2"
inherit eutils python distutils

DESCRIPTION="A general-purpose management bus built on Qpid messaging."
HOMEPAGE="http://qpid.apache.org/components/qmf"
SRC_URI="https://dist.apache.org/repos/dist/release/qpid/${PV}/qpid-qmf-${PV}.tar.gz"
LICENSE="Apache 2.0"

DEPEND="
"

RDEPEND="${DEPEND}
=net-misc/qpid-python-${PV}
"

INSTALL_DIR="tools/install-qpid.dir"
SOURCE_DIR="qpid-qmf-${PV}"

SLOT="0"
KEYWORDS="ia64 x86 amd64-linux x86-linux"

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup
}

src_prepare (){
    python_convert_shebangs -r 2 .
}


src_compile() {
    distutils_src_compile
}

src_install() {
    distutils_src_install

}
