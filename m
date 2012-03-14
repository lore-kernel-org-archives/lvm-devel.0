From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 17:14:34 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20120314171434.10306.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 17:14:34

Modified files:
	test           : Makefile.in 

Log message:
	Use proper "" for absolute paths

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/test/Makefile.in	2012/02/15 14:24:31	1.67
+++ LVM2/test/Makefile.in	2012/03/14 17:14:33	1.68
@@ -1,4 +1,4 @@
-# Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,10 +19,10 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-abs_srcdir = @abs_srcdir@
-abs_builddir = @abs_builddir@
-abs_top_builddir = @abs_top_builddir@
-abs_top_srcdir = @abs_top_srcdir@
+abs_srcdir = "@abs_srcdir@"
+abs_builddir = "@abs_builddir@"
+abs_top_builddir = "@abs_top_builddir@"
+abs_top_srcdir = "@abs_top_srcdir@"
 
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
@@ -98,12 +98,12 @@
 .lib-dir-stamp:
 	$(MKDIR_P) lib
 	for i in $(CMDS); do ln -fs lvm-wrapper lib/$$i; done
-	ln -fs "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
-	ln -fs "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
-	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
-	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
-	ln -fs "$(abs_top_srcdir)/scripts/vgimportclone.sh" lib/vgimportclone
-	ln -fs "$(abs_top_srcdir)/scripts/fsadm.sh" lib/fsadm
+	ln -fs $(abs_top_builddir)/tools/dmsetup lib/dmsetup
+	ln -fs $(abs_top_builddir)/daemons/clvmd/clvmd lib/clvmd
+	ln -fs $(abs_top_builddir)/daemons/dmeventd/dmeventd lib/dmeventd
+	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
+	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
+	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
 	touch $@
 
 clean:


