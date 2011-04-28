From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Apr 2011 16:54:35 -0000
Subject: LVM2 configure configure.in
Message-ID: <20110428165435.15680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-28 16:54:33

Modified files:
	.              : configure configure.in 

Log message:
	Add missing pkg_config_init check with --enable-udev_sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/configure	2011/04/22 12:13:05	1.147
+++ LVM2/configure	2011/04/28 16:54:32	1.148
@@ -8767,6 +8767,9 @@
 $as_echo "$UDEV_SYNC" >&6; }
 
 if test x$UDEV_SYNC = xyes; then
+		if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
--- LVM2/configure.in	2011/04/22 11:56:41	1.161
+++ LVM2/configure.in	2011/04/28 16:54:33	1.162
@@ -803,6 +803,10 @@
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
+	dnl -- init pkgconfig if required
+	if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi

