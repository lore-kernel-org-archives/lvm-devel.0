From: Jim Meyering <jim@meyering.net>
Date: Mon, 17 Sep 2007 11:56:06 -0000
Subject: [PATCH] Clean up shared-lib support in test/.
Message-ID: <mailman.1.1646510520.4176946.lvm-devel@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

* test/Makefile.in (so_name): Use @DMDIR at .
(.bin-dir-stamp): Create symlink only if @DMDIR@ is nonempty.
(lvm-wrapper): Emit LD_LIBRARY_PATH setting only if @DMDIR@ is nonempty.
Based on a patch from Jun'ichi Nomura.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 test/Makefile.in |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 0d8da89..a7f2876 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -42,13 +42,13 @@ $(T): init.sh
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
@@ -59,7 +59,8 @@ so_name = $(dmdir)/lib/ioctl/libdevmapper.so.1.02
 lvm-wrapper: Makefile
 	rm -f $@-t $@
 	echo '#!/bin/sh' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(dmdir)/lib/ioctl"' >> $@-t
+	test -n "@DMDIR@" \
+	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib/ioctl"' >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")' >> $@-t
 	echo 'test "$$cmd" = lvm &&' >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm"         "$$@"' >> $@-t
-- 
1.5.3.1.19.gb5ef6-dirty


