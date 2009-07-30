From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jul 2009 12:31:46 -0000
Subject: LVM2 configure.in configure
Message-ID: <20090730123146.23400.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-30 12:31:46

Modified files:
	.              : configure.in configure 

Log message:
	corosync not cman...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/configure.in	2009/07/30 12:25:42	1.102
+++ LVM2/configure.in	2009/07/30 12:31:45	1.103
@@ -340,7 +340,7 @@
 fi
 
 dnl -- Look for corosync libraries if required.
-if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
+if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
 		[AC_MSG_RESULT([no pkg for quorum library, using -lquorum]);
 		QUORUM_LIBS="-lquorum"])
--- LVM2/configure	2009/07/30 12:25:42	1.97
+++ LVM2/configure	2009/07/30 12:31:45	1.98
@@ -9190,7 +9190,7 @@
 	CLUSTER=internal
 fi
 
-if [ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
+if [ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
 
 
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then


