From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Nov 2009 15:16:22 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20091102151622.11596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-02 15:16:21

Modified files:
	test           : Makefile.in 

Log message:
	Rudimentary support for running testsuite in a builddir != srcdir situation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/test/Makefile.in	2009/09/15 19:59:05	1.19
+++ LVM2/test/Makefile.in	2009/11/02 15:16:21	1.20
@@ -26,15 +26,15 @@
 abs_top_srcdir = @abs_top_srcdir@
 
 all: init.sh
-	./bin/harness $(T)
+	./bin/harness t-*.sh
 
-bin/not: .bin-dir-stamp not.c
-	$(CC) -o bin/not not.c
+bin/not: $(srcdir)/not.c .bin-dir-stamp
+	$(CC) -o bin/not $<
 
-bin/harness: .bin-dir-stamp harness.c
-	$(CC) -o bin/harness harness.c
+bin/harness: $(srcdir)/harness.c .bin-dir-stamp
+	$(CC) -o bin/harness $<
 
-init.sh: Makefile.in .bin-dir-stamp bin/not bin/harness
+init.sh: $(srcdir)/Makefile.in $(srcdir)/test-utils.sh .bin-dir-stamp bin/not bin/harness $(T)
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
@@ -46,11 +46,14 @@
 	echo 'export PATH' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
+	-cp $(srcdir)/test-utils.sh .
+	-cp $(srcdir)/test-lib.sh .
+	-cp $(T) .
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
-T = $(wildcard t-*.sh)
+T = $(wildcard $(srcdir)/t-*.sh)
 
 ifeq ("@APPLIB@", "yes")
 T += lvm2app.sh
@@ -62,13 +65,13 @@
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-$(T): init.sh
-	./bin/harness $@
+#$(T): init.sh
+#	./bin/harness $@
 
 .bin-dir-stamp: lvm-wrapper
 	rm -rf bin
 	mkdir bin
-	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
+	for i in lvm $$(cat ../tools/.commands); do \
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
 	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup


