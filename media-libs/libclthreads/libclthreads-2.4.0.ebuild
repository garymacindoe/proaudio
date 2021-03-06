# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libclthreads/libclthreads-2.4.0.ebuild,v 1.1 2008/04/19 12:52:24 aballier Exp $

inherit eutils multilib toolchain-funcs

MY_P="${P/lib/}"

S="${WORKDIR}/${MY_P}"

DESCRIPTION="An audio library by Fons Adriaensen <fons.adriaensen@skynet.be>"
HOMEPAGE="http://kokkinizita.linuxaudio.org/linuxaudio/"
SRC_URI="http://kokkinizita.linuxaudio.org/linuxaudio/downloads/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-Makefile.patch"
}

src_compile() {
	tc-export CC CXX
	emake || die "emake failed"
}

src_install() {
	emake CLTHREADS_LIBDIR="/usr/$(get_libdir)" DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS
}
