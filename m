From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 13:41:11 -0000
Subject: LVM2/daemons Makefile.in
Message-ID: <20120223134111.25976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 13:41:11

Modified files:
	daemons        : Makefile.in 

Log message:
	We need daemons/common now even if the lvmetad server side is not built.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/daemons/Makefile.in	2011/09/24 20:57:49	1.22
+++ LVM2/daemons/Makefile.in	2012/02/23 13:41:11	1.23
@@ -15,8 +15,10 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+SUBDIRS += common
+
 ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += common lvmetad
+  SUBDIRS += lvmetad
 endif
 
 .PHONY: dmeventd clvmd common cmirrord lvmetad


