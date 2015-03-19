# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils python-r1 distutils-r1

DESCRIPTION="Used to view management information/statistics and call any management actions on the broker"
HOMEPAGE="http://qpid.apache.org/"
SRC_URI="https://dist.apache.org/repos/dist/release/qpid/${PV}/qpid-tools-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
SLOT="0"

DEPEND="
"

RDEPEND="${DEPEND}
=net-misc/qpid-qmf-${PV}
"
