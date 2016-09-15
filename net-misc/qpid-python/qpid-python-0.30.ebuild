# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils python-r1 distutils-r1

DESCRIPTION="Python client implementation for Apache Qpid"
HOMEPAGE="http://qpid.apache.org/components/messaging-api"
SRC_URI="https://dist.apache.org/repos/dist/release/qpid/${PV}/qpid-python-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
SLOT="0"

DEPEND="
"

RDEPEND="${DEPEND}
"
