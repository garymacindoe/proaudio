# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Ebuild stolen from http://forums.gentoo.org/viewtopic-t-465973-highlight-.html
# Modified to use a fixed date.

inherit autotools cvs eutils flag-o-matic
RESTRICT="nomirror"

ECVS_SERVER="cvs.fvwm.org:/home/cvs/fvwm"
ECVS_USER="anonymous"
ECVS_PASS="guest"
ECVS_MODULE="fvwm"
ECVS_UP_OPTS="-D 20070204"
ECVS_CO_OPTS="-D 20070204"

PATCHSET="fvwm-patchset-20070101.tar.gz"

DESCRIPTION="An extremely powerful ICCCM-compliant multiple virtual desktop window manager - CVS version"
HOMEPAGE="http://www.fvwm.org/"
SRC_URI="!vanilla? (
	http://crystalaudio.tuxfamily.org/files/${PATCHSET}
	)"

LICENSE="GPL-2 FVWM"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="bidi debug default-charset-fix extras first-item-under-pointer flux-corner gtk iconv nls perl png readline rplay stroke tk thin-geometry-proxy truetype vanilla xinerama"

S="${WORKDIR}/${ECVS_MODULE}"

RDEPEND="readline? ( sys-libs/readline sys-libs/ncurses )
		gtk? ( =x11-libs/gtk+-1.2* )
		rplay? ( media-sound/rplay )
		bidi? ( dev-libs/fribidi )
		png? ( media-libs/libpng )
		stroke? ( dev-libs/libstroke )
		perl? ( tk? ( dev-lang/tk
						dev-perl/perl-tk
						>=dev-perl/X11-Protocol-0.56 ) )
		truetype? ( virtual/xft media-libs/fontconfig )
		dev-lang/perl
		sys-libs/zlib
		sys-apps/debianutils
		|| ( (
			x11-libs/libXpm
			x11-libs/libXft
			xinerama? ( x11-libs/libXinerama ) )
		virtual/x11 )"
# XXX:	gtk2 perl bindings require dev-perl/gtk2-perl, worth a dependency?
# XXX:	gtk perl bindings require dev-perl/gtk-perl, worth a dependency?
# XXX:	netpbm is used by FvwmScript-ScreenDump, worth a dependency?
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		!x11-wm/metisse
		|| ( (
			x11-libs/libXrandr
			x11-proto/xextproto
			x11-proto/xproto
			xinerama? ( x11-proto/xineramaproto ) )
		virtual/x11 )"

src_unpack() {

	export EPATCH_OPTS="-F3 -l"

	cvs_src_unpack

	# this patch enables fast translucent menus in fvwm. this is a
	# minor tweak of a patch posted to fvwm-user mailing list by Olivier
	# Chapuis in <20030827135125.GA6370@snoopy.folie>.
	cd ${S}; epatch ${FILESDIR}/fvwm-translucent-menus.diff.gz

	# fixing #51287, the fvwm-menu-xlock script is not compatible
	# with the xlockmore implementation in portage.
	cd ${S}; epatch ${FILESDIR}/fvwm-menu-xlock-xlockmore-compat.diff

	# with use vanilla, fvwm will be built without extras patches
	if ! use vanilla; then
		cd ${WORKDIR}; unpack ${A}

		# Those patches have not effects until they're not used in the
		# configuration
		EPATCH_SUFFIX="patch"
		EPATCH_FORCE="yes"
		EPATCH_SOURCE="${WORKDIR}/patchset"
		cd "${S}"; epatch
		
		# Those patches have immediate and irreversible effets
		EXTRAS="${WORKDIR}/patchset/extras"
		if use first-item-under-pointer; then
			cd "${S}"; epatch ${EXTRAS}/FirstItemUnderPointer.patch
		fi
		if use thin-geometry-proxy; then
			cd "${S}"; epatch ${EXTRAS}/ThinGeometryProxy.patch
		fi
		if use flux-corner; then
			cd "${S}"; epatch ${EXTRAS}/FluxCorner.patch
		fi
		if use default-charset-fix; then
			cd "${S}"; epatch ${EXTRAS}/DefaultCharset.patch
		fi
	fi

	cd "${S}"; eautoreconf
}

src_compile() {
	local myconf="--libexecdir=/usr/lib --with-imagepath=/usr/include/X11/bitmaps:/usr/include/X11/pixmaps:/usr/share/icons/fvwm --enable-package-subdirs"

	# use readline in FvwmConsole.
	if use readline; then
		myconf="${myconf} --without-termcap-library"
	fi

	# FvwmGtk can be built as a gnome application, or a Gtk+ application.
	if ! use gtk; then
		myconf="${myconf} --disable-gtk --without-gnome"
	else
		einfo "ATTN: You can safely ignore any imlib related configure errors."
		myconf="${myconf} --with-imlib-prefix=${T}"
		myconf="${myconf} --without-gnome"
	fi

	# set the local maintainer for fvwm-bug.
	# taviso is not maintainer of this ebuild
	# export FVWM_BUGADDR="taviso@gentoo.org"

	# reccommended by upstream
	append-flags -fno-strict-aliasing

	econf ${myconf} `use_enable truetype xft` \
					`use_with stroke stroke-library` \
					`use_enable nls` \
					`use_enable iconv` \
					`use_enable png png-library` \
					`use_enable bidi` \
					`use_enable xinerama` \
					`use_enable debug debug-msgs` \
					`use_enable debug command-log` \
					`use_enable perl perllib` \
					`use_with readline readline-library` \
					`use_with rplay rplay-library` || die
	emake || die
}

src_install() {
	emake DESTDIR=${D} install || die

	if use perl; then

		local toolkits="gtk tcltk"

		if ! use tk; then
			# Remove the Tk bindings (requires perl-tk)
			rm -f ${D}/usr/share/fvwm/perllib/FVWM/Module/Tk.pm
			toolkits=${toolkits/tcltk/}
		fi
		if ! use gtk; then
			# Remove gtk bindings (requires gtk-perl/gtk2-perl)
			rm -f ${D}/usr/share/fvwm/perllib/FVWM/Module/Gtk.pm \
				${D}/usr/share/fvwm/perllib/FVWM/Module/Gtk2.pm
			toolkits=${toolkits/gtk/}
		fi
		toolkits=${toolkits// /}
		if ! test "${toolkits}"; then
			# No perl toolkit bindings wanted, remove the unneeded files
			# and empty directories.
			rm -f ${D}/usr/share/fvwm/perllib/FVWM/Module/Toolkit.pm
			find ${D}/usr/share/fvwm/perllib -depth -type d -exec rmdir {} \; 2>/dev/null
		fi
	else
		# Remove useless script if perllib isnt required.
		rm -rf ${D}/usr/bin/fvwm-perllib ${D}/usr/share/man/man1/fvwm-perllib.1
	fi

	# neat utility for testing fvwm behaviour on applications setting various
	# hints, creates a simple black window with configurable hints set.
	if use debug; then
		dobin ${S}/tests/hints/hints_test
		newdoc ${S}/tests/hints/README README.hints
	fi

	# fvwm-convert-2.6 is just a stub, contains no code - remove it for now.
	# fvwm-convert-2.2 has a man page, but the script is no longer distributed.
	rm -f ${D}/usr/bin/fvwm-convert-2.6 ${D}/usr/share/man/man1/fvwm-convert-2.6.1
	rm -f ${D}/usr/share/man/man1/fvwm-convert-2.2.1

	# ive included `exec` to save a few bytes of memory.
	echo "#!/bin/bash" > fvwm2
	echo "exec /usr/bin/fvwm2" >> fvwm2

	exeinto /etc/X11/Sessions
	doexe fvwm2

	# desktop entry for gdm, kdm, ...
	dodir /usr/share/xsessions
	insinto /usr/share/xsessions
	doins ${FILESDIR}/${PN}.desktop

	dodoc AUTHORS ChangeLog COPYING README NEWS docs/ANNOUNCE docs/BUGS \
	docs/COMMANDS docs/DEVELOPERS docs/FAQ docs/error_codes docs/TODO \
	docs/fvwm.lsm

	dodoc ${FILESDIR}/README.transluceny
}

pkg_postinst() {
	einfo
	einfo "For information about the changes in this release, please"
	einfo "refer to the NEWS file."
	einfo
}
