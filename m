From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Oct 2009 12:11:31 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20091005121131.5800.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-05 12:11:31

Modified files:
	.              : WHATS_NEW configure configure.in 
	libdm          : libdevmapper.pc.in 

Log message:
	Only include selinux libs in libdevmapper.pc when selinux build enabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1288&r2=1.1289
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.pc.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/10/02 19:10:31	1.1288
+++ LVM2/WHATS_NEW	2009/10/05 12:11:30	1.1289
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Only include selinux libs in libdevmapper.pc when selinux build enabled.
   Allow for a build directory separate from the source.
   Update distclean target for rename clogd to cmirrord. (2.02.52)
   Only do lock conversions in clvmd if we are explicitly asked for one.
--- LVM2/configure	2009/10/02 19:10:31	1.109
+++ LVM2/configure	2009/10/05 12:11:30	1.110
@@ -651,6 +651,7 @@
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
+SELINUX_LIBS
 POOL
 PKGCONFIG
 OWNER
@@ -12910,7 +12911,7 @@
 #define HAVE_SEPOL 1
 _ACEOF
 
-		LIBS="-lsepol $LIBS"
+		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
 	fi
 
 	{ $as_echo "$as_me:$LINENO: checking for is_selinux_enabled in -lselinux" >&5
@@ -12991,11 +12992,12 @@
 #define HAVE_SELINUX 1
 _ACEOF
 
-		LIBS="-lselinux $LIBS"
+		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
 	else
 		{ $as_echo "$as_me:$LINENO: WARNING: Disabling selinux" >&5
 $as_echo "$as_me: WARNING: Disabling selinux" >&2;}
 	fi
+	LIBS="$SELINUX_LIBS $LIBS"
 
 	# With --enable-static_link and selinux enabled, linking
 	# fails on at least Debian unstable due to unsatisfied references
@@ -15524,6 +15526,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2009/10/02 19:10:32	1.117
+++ LVM2/configure.in	2009/10/05 12:11:30	1.118
@@ -841,17 +841,18 @@
 	if test x$HAVE_SEPOL = xyes; then
 		AC_DEFINE([HAVE_SEPOL], 1,
 		  [Define to 1 if sepol_check_context is available.])
-		LIBS="-lsepol $LIBS"
+		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
 	fi
 
 	AC_CHECK_LIB(selinux, is_selinux_enabled, HAVE_SELINUX=yes, HAVE_SELINUX=no)
 
 	if test x$HAVE_SELINUX = xyes; then
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
-		LIBS="-lselinux $LIBS"
+		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
 	else
 		AC_MSG_WARN(Disabling selinux)
 	fi
+	LIBS="$SELINUX_LIBS $LIBS"
 
 	# With --enable-static_link and selinux enabled, linking
 	# fails on at least Debian unstable due to unsatisfied references
@@ -1126,6 +1127,7 @@
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
+AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
--- LVM2/libdm/libdevmapper.pc.in	2008/11/01 20:48:09	1.2
+++ LVM2/libdm/libdevmapper.pc.in	2009/10/05 12:11:30	1.3
@@ -8,4 +8,4 @@
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Libs.private: -lselinux -lsepol
+Libs.private: @SELINUX_LIBS@


