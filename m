From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:18:49 -0000
Subject: LVM2 configure.in
Message-ID: <20120228181849.19643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:18:48

Modified files:
	.              : configure.in 

Log message:
	Define LVMETAD_SUPPORT in source code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/configure.in	2012/02/24 13:03:50	1.188
+++ LVM2/configure.in	2012/02/28 18:18:48	1.189
@@ -847,6 +847,10 @@
 
 BUILD_LVMETAD=$LVMETAD
 
+if test x$BUILD_LVMETAD = xyes; then
+	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
+fi
+
 ################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
@@ -1496,7 +1500,6 @@
 daemons/Makefile
 daemons/clvmd/Makefile
 daemons/cmirrord/Makefile
-daemons/common/Makefile
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile
@@ -1520,6 +1523,9 @@
 lib/raid/Makefile
 lib/snapshot/Makefile
 lib/thin/Makefile
+libdaemon/Makefile
+libdaemon/client/Makefile
+libdaemon/server/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile


