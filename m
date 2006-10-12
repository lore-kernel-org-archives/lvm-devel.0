From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Oct 2006 18:17:11 -0000
Subject: LVM2 configure configure.in
Message-ID: <20061012181711.30352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-12 18:17:10

Modified files:
	.              : configure configure.in 

Log message:
	fix realtime msg alignment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/configure	2006/09/30 20:02:02	1.53
+++ LVM2/configure	2006/10/12 18:17:09	1.54
@@ -853,7 +853,7 @@
                           statically.  Default is dynamic linking
   --enable-readline       Enable readline support
   --disable-selinux       Disable selinux support
-  --disable-realtime       Disable realtime clock support
+  --disable-realtime      Disable realtime clock support
   --enable-debug          Enable debugging
   --disable-devmapper     Disable device-mapper interaction
   --disable-o_direct      Disable O_DIRECT
--- LVM2/configure.in	2006/09/30 20:02:02	1.52
+++ LVM2/configure.in	2006/10/12 18:17:09	1.53
@@ -287,7 +287,7 @@
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
-AC_ARG_ENABLE(realtime, [  --disable-realtime       Disable realtime clock support],
+AC_ARG_ENABLE(realtime, [  --disable-realtime      Disable realtime clock support],
 REALTIME=$enableval)
 AC_MSG_RESULT($REALTIME)
 


