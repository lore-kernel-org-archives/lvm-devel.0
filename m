From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:01:24 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20070918140124.4954.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:01:24

Modified files:
	test           : Makefile.in 

Log message:
	Clean up shared-lib support in test/.
	
	* test/Makefile.in (so_name): Use @DMDIR at .
	(.bin-dir-stamp): Create symlink only if @DMDIR@ is nonempty.
	(lvm-wrapper): Emit LD_LIBRARY_PATH setting only if @DMDIR@ is nonempty.
	Based on a patch from Jun'ichi Nomura.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/Makefile.in	2007/09/18 14:00:42	1.1
+++ LVM2/test/Makefile.in	2007/09/18 14:01:24	1.2
@@ -42,13 +42,13 @@
 	@echo "*** $@ ***"; '$(SHELL_PATH_SQ)' \
 	  $(TESTS_ENVIRONMENT) $@ $(GIT_TEST_OPTS)
 
-dmdir = $(abs_top_srcdir)/../device-mapper
-so_name = $(dmdir)/lib/ioctl/libdevmapper.so.1.02
+so_name = @DMDIR@/lib/ioctl/libdevmapper.so.1.02
 
-# Having to create this link is a huge kludge,
+# Having to create this symlink is an ugly kludge,
 # and a major argument for including device-mapper in lvm.
 .bin-dir-stamp: lvm-wrapper
-	ln -fs libdevmapper.so $(so_name)
+	test -n "@DMDIR@" \
+	  && ln -fs libdevmapper.so $(so_name)
 	rm -rf bin
 	mkdir bin
 	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
@@ -59,7 +59,8 @@
 lvm-wrapper: Makefile
 	rm -f $@-t $@
 	echo '#!/bin/sh' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(dmdir)/lib/ioctl"' >> $@-t
+	test -n "@DMDIR@" \
+	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib/ioctl"' >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")' >> $@-t
 	echo 'test "$$cmd" = lvm &&' >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm"         "$$@"' >> $@-t


