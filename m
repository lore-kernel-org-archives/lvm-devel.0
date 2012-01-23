From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2012 17:48:19 -0000
Subject: LVM2 configure.in configure
Message-ID: <20120123174819.18466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-23 17:48:19

Modified files:
	.              : configure.in configure 

Log message:
	Fix metad help.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/configure.in	2011/12/21 13:08:12	1.178
+++ LVM2/configure.in	2012/01/23 17:48:18	1.179
@@ -792,8 +792,8 @@
 dnl -- Build lvmetad
 AC_MSG_CHECKING(whether to build LVMetaD)
 AC_ARG_ENABLE(lvmetad,
-	      AC_HELP_STRING([--disable-lvmetad],
-			     [disable the LVM Metadata Daemon]),
+	      AC_HELP_STRING([--enable-lvmetad],
+			     [enable the LVM Metadata Daemon]),
 	      LVMETAD=$enableval)
 AC_MSG_RESULT($LVMETAD)
 
--- LVM2/configure	2011/12/21 13:08:11	1.163
+++ LVM2/configure	2012/01/23 17:48:18	1.164
@@ -1510,7 +1510,7 @@
   --enable-testing        enable testing targets in the makefile
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
-  --disable-lvmetad       disable the LVM Metadata Daemon
+  --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
   --enable-compat         enable support for old device-mapper versions


