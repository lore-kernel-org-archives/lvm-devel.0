From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Apr 2011 11:56:42 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure.in libdm/libdm ...
Message-ID: <20110422115642.17063.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-22 11:56:41

Modified files:
	.              : WHATS_NEW_DM configure.in 
	libdm          : libdm-common.c 
	tools          : dmsetup.c lvmcmdline.c 

Log message:
	Require libudev >= 143 when compiling with udev support.
	
	Old versions of libudev < 143 were experimental and unstable. Require recent
	and stable versions only (version 143 is old enough anyway).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.461&r2=1.462
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/WHATS_NEW_DM	2011/03/30 12:57:03	1.461
+++ LVM2/WHATS_NEW_DM	2011/04/22 11:56:41	1.462
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Require libudev >= 143 when compiling with udev support.
   Use word alignment for dm_pool_strdup() and dm_pool_strndup().
   Use dm_snprintf() to fix signess warning in dm_set_dev_dir().
   Use unsigned loop counter to fix signess warning in _other_node_ops().
--- LVM2/configure.in	2011/02/04 22:17:54	1.160
+++ LVM2/configure.in	2011/04/22 11:56:41	1.161
@@ -803,9 +803,7 @@
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active,
-		     [UDEV_PC="libudev"; UDEV_LIBS="-ludev"],
-		     [AC_MSG_ERROR([bailing out... libudev library is required])])
+	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
 
--- LVM2/libdm/libdm-common.c	2011/03/30 12:14:36	1.116
+++ LVM2/libdm/libdm-common.c	2011/04/22 11:56:41	1.117
@@ -29,7 +29,6 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 
--- LVM2/tools/dmsetup.c	2011/04/08 14:40:21	1.159
+++ LVM2/tools/dmsetup.c	2011/04/22 11:56:41	1.160
@@ -45,7 +45,6 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 
--- LVM2/tools/lvmcmdline.c	2011/04/08 14:40:21	1.138
+++ LVM2/tools/lvmcmdline.c	2011/04/22 11:56:41	1.139
@@ -43,7 +43,6 @@
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 


