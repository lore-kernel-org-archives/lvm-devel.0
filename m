From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2009 14:59:26 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20091130145926.13267.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-30 14:59:26

Modified files:
	test           : Makefile.in 

Log message:
	More fixes for the testsuite in the $(builddir) != $(srcdir) situation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/test/Makefile.in	2009/11/19 12:01:39	1.21
+++ LVM2/test/Makefile.in	2009/11/30 14:59:26	1.22
@@ -25,6 +25,18 @@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
+# Shell quote;
+SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
+
+T = $(wildcard $(srcdir)/t-*.sh)
+
+ifeq ("@APPLIB@", "yes")
+T += $(srcdir)/lvm2app.sh
+all: api/vgtest
+api/vgtest:
+	$(MAKE) -C api vgtest
+endif
+
 all: init.sh
 	./bin/harness t-*.sh
 
@@ -46,21 +58,9 @@
 	echo 'export PATH' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	-cp $(srcdir)/test-utils.sh .
-	-cp $(srcdir)/test-lib.sh .
-	-cp $(T) .
-
-# Shell quote;
-SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
-
-T = $(wildcard $(srcdir)/t-*.sh)
-
-ifeq ("@APPLIB@", "yes")
-T += lvm2app.sh
-all: api/vgtest
-api/vgtest:
-	$(MAKE) -C api vgtest
-endif
+	test "$(srcdir)" != "." && cp $(srcdir)/test-utils.sh \
+	                              $(srcdir)/test-lib.sh \
+	                              $(T) .
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


