From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 15:55:08 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20090911155508.10597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 15:55:07

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	Add libudev configuration check.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1255&r2=1.1256
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2009/09/04 12:54:23	1.1255
+++ LVM2/WHATS_NEW	2009/09/11 15:55:07	1.1256
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Add libudev configuration check.
   Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
   Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
   Enforce an alphabetical lock ordering for vgname locks.
--- LVM2/configure.in	2009/09/02 19:32:37	1.111
+++ LVM2/configure.in	2009/09/11 15:55:07	1.112
@@ -651,6 +651,20 @@
 AC_MSG_RESULT($UDEV_RULES)
 
 ################################################################################
+dnl -- Check for libudev's udev_queue_get_udev_is_active function when udev synchronisation is enabled
+
+if test x$UDEV_SYNC = xyes; then
+	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active, HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=yes,
+		HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=no)
+
+		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
+			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
+			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
+			LIBS="-ludev $LIBS"
+		fi
+fi
+
+################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
   DM_COMPAT=$enableval, DM_COMPAT=no)


