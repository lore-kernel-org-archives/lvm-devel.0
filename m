From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jul 2009 12:25:43 -0000
Subject: LVM2 configure configure.in WHATS_NEW
Message-ID: <20090730122543.21207.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-30 12:25:42

Modified files:
	.              : configure configure.in WHATS_NEW 

Log message:
	Fix configure script to handle multiple clvmd selections.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1210&r2=1.1211

--- LVM2/configure	2009/07/22 21:09:13	1.96
+++ LVM2/configure	2009/07/30 12:25:42	1.97
@@ -9190,7 +9190,7 @@
 	CLUSTER=internal
 fi
 
-if [ "x$CLVMD" = xcorosync -o "x$CLVMD" = xall ]; then
+if [ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
 
 
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
--- LVM2/configure.in	2009/07/22 21:09:14	1.101
+++ LVM2/configure.in	2009/07/30 12:25:42	1.102
@@ -340,7 +340,7 @@
 fi
 
 dnl -- Look for corosync libraries if required.
-if [[ "x$CLVMD" = xcorosync -o "x$CLVMD" = xall ]]; then
+if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
 		[AC_MSG_RESULT([no pkg for quorum library, using -lquorum]);
 		QUORUM_LIBS="-lquorum"])
--- LVM2/WHATS_NEW	2009/07/29 19:24:11	1.1210
+++ LVM2/WHATS_NEW	2009/07/30 12:25:42	1.1211
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Fix configure script to handle multiple clvmd selections.
   Fix lvm2app.pc installation filename.
   Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
   Rename lvm.h to lvm2app.h for now.


