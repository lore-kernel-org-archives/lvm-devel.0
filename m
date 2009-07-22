From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jul 2009 20:12:15 -0000
Subject: LVM2 ./WHATS_NEW liblvm/Makefile.in
Message-ID: <20090722201215.23145.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-22 20:12:14

Modified files:
	.              : WHATS_NEW 
	liblvm         : Makefile.in 

Log message:
	Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1196&r2=1.1197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2009/07/22 20:01:28	1.1196
+++ LVM2/WHATS_NEW	2009/07/22 20:12:14	1.1197
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.
   Add an API version number, LVM_LIBAPI, to the VERSION string for liblvm.
   Pass a pointer to struct cmd_context to init_multiple_segtypes
   Return EINVALID_CMD_LINE not success when invalid VG name format is used.
--- LVM2/liblvm/Makefile.in	2009/07/14 03:02:14	1.7
+++ LVM2/liblvm/Makefile.in	2009/07/22 20:12:14	1.8
@@ -21,8 +21,8 @@
 	lvm_vg.c
 
 LIB_NAME = liblvm2app
-LIB_VERSION = $(LIB_VERSION_LVM)
-VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
+LIB_VERSION = $(LIB_VERSION_APP)
+VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_APP)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(LIB_NAME).a


