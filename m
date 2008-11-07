From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Nov 2008 01:30:04 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20081107013004.9516.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-07 01:30:04

Modified files:
	test           : Makefile.in 

Log message:
	Set LD_LIBRARY_PATH in init.sh, as it is required to run dmsetup now as well,
	which otherwise picks up the system version of libdevmapper, which is a pretty
	bad idea.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/Makefile.in	2008/11/04 14:37:10	1.13
+++ LVM2/test/Makefile.in	2008/11/07 01:30:03	1.14
@@ -34,6 +34,7 @@
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/dmeventd"' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
@@ -63,7 +64,6 @@
 lvm-wrapper: Makefile
 	rm -f $@-t $@
 	echo '#!/bin/sh'                                          >  $@-t
-	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/dmeventd"' >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
 	echo 'test "$$cmd" = lvm &&'                              >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t


