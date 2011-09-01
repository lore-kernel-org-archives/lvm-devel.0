From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Sep 2011 17:56:54 -0000
Subject: LVM2/daemons Makefile.in
Message-ID: <20110901175654.15784.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-01 17:56:53

Modified files:
	daemons        : Makefile.in 

Log message:
	Only build libdaemon.a when we need it at the moment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/daemons/Makefile.in	2011/08/31 11:31:58	1.17
+++ LVM2/daemons/Makefile.in	2011/09/01 17:56:53	1.18
@@ -15,8 +15,10 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+ifeq ("@BUILD_LVMETAD@", "yes")
 LIB_STATIC=libdaemon.a
 SOURCES = common/daemon-shared.c common/daemon-server.c common/daemon-client.c
+endif
 
 .PHONY: dmeventd clvmd cmirrord lvmetad
 
@@ -30,6 +32,7 @@
 
 ifeq ("@BUILD_LVMETAD@", "yes")
   SUBDIRS += lvmetad
+device-mapper: libdaemon.a
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
@@ -48,5 +51,3 @@
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
 endif
-
-device-mapper: libdaemon.a


