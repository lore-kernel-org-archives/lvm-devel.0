From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 06:45:54 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100413064554.19866.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 06:45:53

Modified files:
	test           : Makefile.in 

Log message:
	Make it easy to run just a subset of tests by saying `make check T="regex"`.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/test/Makefile.in	2010/04/12 19:02:59	1.36
+++ LVM2/test/Makefile.in	2010/04/13 06:45:53	1.37
@@ -25,6 +25,9 @@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
+T ?= .
+RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*")
+
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
@@ -45,9 +48,9 @@
 
 all: init.sh
 	@echo Testing with locking_type 1
-	./bin/harness t-*.sh
+	./bin/harness $(RUN)
 	@echo Testing with locking_type 3
-	LVM_TEST_LOCKING=3 ./bin/harness t-*.sh
+	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
 
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
@@ -74,7 +77,7 @@
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	if test "$(srcdir)" != . ; then  cp $(SCRIPTS) . ; fi
+	@if test "$(srcdir)" != . ; then echo "Copying tests to builddir."; cp $(SCRIPTS) . ; fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


