From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Sep 2011 14:49:01 -0000
Subject: LVM2/daemons Makefile.in
Message-ID: <20110902144901.21671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-02 14:49:00

Modified files:
	daemons        : Makefile.in 

Log message:
	Hack for build rules of lvmetad
	
	FIXME

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/daemons/Makefile.in	2011/09/01 17:56:53	1.18
+++ LVM2/daemons/Makefile.in	2011/09/02 14:49:00	1.19
@@ -32,7 +32,8 @@
 
 ifeq ("@BUILD_LVMETAD@", "yes")
   SUBDIRS += lvmetad
-device-mapper: libdaemon.a
+# FIXME: build dependency order needs rule fixing, using hack
+all: libdaemon.a
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")


