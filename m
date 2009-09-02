From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 2 Sep 2009 11:49:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/Makefile.in
Message-ID: <20090902114904.1468.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-09-02 11:49:03

Modified files:
	.              : WHATS_NEW 
	daemons        : Makefile.in 

Log message:
	Fix cmirrod build directory while we wait to do a proper rename of the
	directory and move files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1250&r2=1.1251
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2009/09/01 19:13:38	1.1250
+++ LVM2/WHATS_NEW	2009/09/02 11:49:03	1.1251
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix clogd build direcory.
   Drop unrequired clogd Makefile.
   Fix clvmd autodetection check and cleanup related configure messages.
   Fix Makefile distclean target.
--- LVM2/daemons/Makefile.in	2009/08/28 20:51:40	1.9
+++ LVM2/daemons/Makefile.in	2009/09/02 11:49:03	1.10
@@ -22,7 +22,7 @@
 endif
 
 ifeq ("@BUILD_CMIRRORD@", "yes")
-  SUBDIRS += cmirrord
+  SUBDIRS += clogd
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")


