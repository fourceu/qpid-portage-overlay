# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8,9} )
inherit python-any-r1

DESCRIPTION="Python client implementation for Apache Qpid"
HOMEPAGE="https://qpid.apache.org/components/messaging-api"
SRC_URI="https://dist.apache.org/repos/dist/release/qpid/python/${PV}/qpid-python-${PV}.tar.gz"
LICENSE="Apache-2.0"
KEYWORDS="~x86 ~amd64"
SLOT="0"

DEPEND="
"

RDEPEND="${DEPEND}
dev-lang/python:2.7
"
