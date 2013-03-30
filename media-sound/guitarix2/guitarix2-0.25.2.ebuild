# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

DESCRIPTION="A simple Linux Guitar Amplifier for jack with one input and two outputs"
SRC_URI="mirror://sourceforge/guitarix/guitarix/${P}.tar.bz2"
HOMEPAGE="http://guitarix.sourceforge.net/"

RESTRICT="mirror"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

IUSE="+capture +convolver faust +meterbridge"

RDEPEND="
	>=dev-libs/boost-1.38
	media-libs/ladspa-sdk
	>=media-libs/libsndfile-1.0.17
	>=media-sound/jack-audio-connection-kit-0.109.1
	media-sound/lame
	media-sound/vorbis-tools
	>=x11-libs/gtk+-2.12.0
	capture? ( media-sound/jack_capture )
	convolver? ( media-libs/zita-convolver )
	faust? ( dev-lang/faust )
	meterbridge? ( media-sound/meterbridge )
	!media-sound/guitarix"

S="${WORKDIR}/guitarix-${PV}"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	./waf configure --prefix=/usr --ladspadir=/usr/share/ladspa \
	|| die
}

src_compile() {
	./waf build || die
}

src_install() {
	# needed at first time install
	addpredict /usr/share/applications

	DESTDIR=${D} ./waf install
}
