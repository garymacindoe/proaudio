# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

AUTOTOOLS_AUTORECONF="1"
PYTHON_COMPAT=( python2_7 )
inherit autotools-utils git-2 python-single-r1

RESTRICT="mirror"
DESCRIPTION="Internet DJ Console has two media players, jingles player, crossfader, VoIP and streaming"
HOMEPAGE="http://idjc.sourceforge.net/"
EGIT_REPO_URI="git://${PN}.git.sourceforge.net/gitroot/${PN}/${PN}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="doc ffmpeg flac mad mpg123 nls opus speex twolame"

RDEPEND=">=media-sound/jack-audio-connection-kit-0.100.7
	dev-python/eyeD3[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
	media-libs/libsamplerate
	media-libs/libsndfile
	media-libs/libvorbis
	media-libs/mutagen[${PYTHON_USEDEP}]
	media-libs/libshout-idjc
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/flac )
	mad? ( media-sound/lame )
	mpg123? ( media-sound/mpg123 )
	nls? ( sys-devel/gettext )
	opus? ( media-libs/opus )
	speex? ( media-libs/speex )
	twolame? ( media-sound/twolame )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	pushd "${S}/docsrc"
	emake && emake doc
	popd

	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		$(use_enable ffmpeg libav)
		$(use_enable flac)
		$(use_enable mad lame)
		$(use_enable mpg123)
		$(use_enable nls)
		$(use_enable opus)
		$(use_enable speex)
		$(use_enable twolame)
	)
	autotools-utils_src_configure
}

src_install() {
	use doc && HTML_DOCS=( doc/ )

	autotools-utils_src_install
}
