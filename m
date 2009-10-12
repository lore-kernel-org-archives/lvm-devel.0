From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 12 Oct 2009 16:59:21 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20091012165921.21424.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-10-12 16:59:20

Modified files:
	.              : WHATS_NEW configure configure.in 
	lib            : Makefile.in 

Log message:
	Disable realtime support by default.
	
	This code is used only in a under development feature and it's not used
	anywhere in the tree.
	
	Allow to build it conditionally.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1293&r2=1.1294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2009/10/12 08:33:30	1.1293
+++ LVM2/WHATS_NEW	2009/10/12 16:59:20	1.1294
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Disable realtime support code by default.
   Make clvmd return 0 on success rather than 1.
   Add --pvmetadatacopies for pvcreate, vgcreate, vgextend, vgconvert.
   Add implict pvcreate support to vgcreate and vgextend.
--- LVM2/configure	2009/10/05 12:11:30	1.110
+++ LVM2/configure	2009/10/12 16:59:20	1.111
@@ -1508,7 +1508,7 @@
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
   --disable-readline      Disable readline support
-  --disable-realtime      Disable realtime clock support
+  --enable-realtime       Enable realtime clock support
   --enable-cmirrord       Enable the cluster mirror log daemon
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
@@ -2226,7 +2226,6 @@
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
-		REALTIME=yes
 		CLUSTER=internal
 		FSADM=yes
 		;;
@@ -2241,7 +2240,6 @@
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
-		REALTIME=no
 		CLUSTER=none
 		FSADM=no
 		;;
--- LVM2/configure.in	2009/10/05 12:11:30	1.118
+++ LVM2/configure.in	2009/10/12 16:59:20	1.119
@@ -40,7 +40,6 @@
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
-		REALTIME=yes
 		CLUSTER=internal
 		FSADM=yes
 		;;
@@ -55,7 +54,6 @@
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
-		REALTIME=no
 		CLUSTER=none
 		FSADM=no
 		;;
@@ -318,7 +316,7 @@
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
-AC_ARG_ENABLE(realtime, [  --disable-realtime      Disable realtime clock support],
+AC_ARG_ENABLE(realtime, [  --enable-realtime       Enable realtime clock support],
 REALTIME=$enableval)
 AC_MSG_RESULT($REALTIME)
 
--- LVM2/lib/Makefile.in	2009/10/05 13:46:02	1.94
+++ LVM2/lib/Makefile.in	2009/10/12 16:59:20	1.95
@@ -82,7 +82,6 @@
 	misc/lvm-globals.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
-	misc/timestamp.c \
 	misc/util.c \
 	mm/memlock.c \
 	report/report.c \
@@ -90,6 +89,11 @@
 	uuid/uuid.c \
 	zero/zero.c
 
+ifeq ("@HAVE_REALTIME@", "yes")
+  SOURCES +=\
+	misc/timestamp.c
+endif
+
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
 	format1/disk-rep.c \


