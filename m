From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 12:21:43 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW test/Makefile.i ...
Message-ID: <20111123122143.31878.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 12:21:42

Modified files:
	.              : Makefile.in WHATS_NEW 
	test           : Makefile.in 
	test/api       : Makefile.in 
	test/unit      : Makefile.in 

Log message:
	Cleanup test makefiles
	
	Simplify /api makefile and use SUBDIRS target for test dir.
	Properly cleanup Makefiles with distclean in /test.
	Use symbolic links for shell scripts for non-srcdir compilation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2196&r2=1.2197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/Makefile.in	2011/11/20 21:43:20	1.66
+++ LVM2/Makefile.in	2011/11/23 12:21:41	1.67
@@ -36,7 +36,7 @@
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man scripts \
     lib tools daemons libdm \
-    udev po liblvm test/api test \
+    udev po liblvm test \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
 endif
 DISTCLEAN_DIRS += lcov_reports*
--- LVM2/WHATS_NEW	2011/11/23 01:34:38	1.2196
+++ LVM2/WHATS_NEW	2011/11/23 12:21:41	1.2197
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use gcc warning options only with .c to .o compilation.
   Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
   Replace the unit testing framework with CUnit (--enable-testing).
   Fix dmeventd snapshot monitoring when multiple extensions were involved.
--- LVM2/test/Makefile.in	2011/11/21 00:15:42	1.63
+++ LVM2/test/Makefile.in	2011/11/23 12:21:41	1.64
@@ -12,10 +12,9 @@
 
 #TEST_OPTS=--verbose --debug
 SHELL_PATH ?= $(SHELL)
-TAR ?= $(TAR)
 RM ?= rm -f
 
-subdir := $(shell pwd|sed 's,.*/,,')
+subdir = $(shell pwd|sed 's,.*/,,')
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
@@ -24,6 +23,9 @@
 abs_builddir = @abs_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
+
+SUBDIRS = api unit
+
 include $(top_builddir)/make.tmpl
 
 T ?= .
@@ -43,24 +45,16 @@
 all: check
 
 check: .tests-stamp
-	@echo "Running API (liblvm2app) tests"
-	make -C api tests
-ifeq ("$(TESTING)", "yes")
-	@echo Running unit tests
-	make unit
-endif
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) ./lib/harness $(RUN_BASE)
 	@echo Testing with locking_type 3
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
 
 check_cluster: .tests-stamp
-	make -C api tests
 	@echo Testing with locking_type 3
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
 
 check_local: .tests-stamp
-	make -C api tests
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./lib/harness $(RUN_BASE)
 
@@ -75,7 +69,7 @@
 	chmod +x $@
 
 lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
-	rm -f $@-t
+	$(RM) $@-t
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_srcdir)' >> $@-t
@@ -90,39 +84,34 @@
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 
-.tests-stamp: $(ALL) $(LIB)
-	mkdir -p shell
+.tests-stamp: $(ALL) $(LIB) $(SUBDIRS)
 	@if test "$(srcdir)" != . ; then \
-	    echo "Copying tests to builddir."; \
-	    for f in $(ALL); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
+		echo "Linking tests to builddir."; \
+		$(MKDIR_P) shell; \
+		for f in $(subst $(srcdir)/,,$(ALL)); do \
+			ln -sf $(abs_top_srcdir)/test/$$f $$f; \
+		done; \
 	fi
 	touch $@
 
-Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
-	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
-
-.lib-dir-stamp: $(top_srcdir)/scripts/fsadm.sh
-	mkdir -p lib
+.lib-dir-stamp:
+	$(MKDIR_P) lib
 	for i in $(CMDS); do ln -fs lvm-wrapper lib/$$i; done
 	ln -fs "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
 	ln -fs "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
 	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
 	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
 	ln -fs "$(abs_top_srcdir)/scripts/vgimportclone.sh" lib/vgimportclone
-	cp -f "$(top_srcdir)/scripts/fsadm.sh" lib/fsadm
-	@chmod +x lib/fsadm
+	ln -fs "$(abs_top_srcdir)/scripts/fsadm.sh" lib/fsadm
 	touch $@
 
 clean:
-	make -C api clean
-	test "$(srcdir)" != . && rm -f $(RUN_BASE) lvm2app.sh
-
-.PHONY: unit
-
-unit:
-	make -C unit $(@)
+	test "$(srcdir)" != . && $(RM) $(RUN_BASE) lvm2app.sh
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone
 
+Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
+	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
+
 .NOTPARALLEL:
--- LVM2/test/api/Makefile.in	2011/06/04 21:46:34	1.22
+++ LVM2/test/api/Makefile.in	2011/11/23 12:21:41	1.23
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,53 +15,26 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-ifeq ("@DEBUG@", "yes")
-	DEFS += -DDEBUG
-endif
-
-TARGETS = 
+TARGETS =
 ifeq ("@APPLIB@", "yes")
 TARGETS += test
-test_SOURCES = test.c
-wrapper_SOURCES = test.c
-INCLUDES += -I../../include
+SOURCES = test.c
 
 TARGETS += vgtest.t percent.t pe_start.t
 endif
 
-LVMLIBS = @LVM2APP_LIB@ -ldevmapper
-DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
-
-DEFS += -D_REENTRANT
-
 include $(top_builddir)/make.tmpl
 
-LDFLAGS = -L$(top_builddir)/libdm -L$(top_builddir)/liblvm
-
-ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event
-	LDFLAGS += -L$(top_builddir)/daemons/dmeventd
-endif
-
-test_OBJECTS = $(test_SOURCES:.c=.o)
-wrapper_OBJECTS = $(wrapper_SOURCES:.c=.o)
-OBJECTS = $(test_OBJECTS)
-
-all: tests
-
-tests: $(TARGETS)
-
-test: $(test_OBJECTS) $(DEPLIBS)
-	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
+DEFS += -D_REENTRANT
+DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
+LDFLAGS += -L$(top_builddir)/liblvm
+LVMLIBS = @LVM2APP_LIB@ -ldevmapper $(LIBS)
 
 %.t: %.o $(DEPLIBS)
-	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+	$(CC) -o $@ $(<) $(LDFLAGS) $(LVMLIBS)
 
-wrapper: $(wrapper_OBJECTS) $(DEPLIBS)
-	$(CC) -o wrapper $(wrapper_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) -lreadline
+test: $(OBJECTS) $(DEPLIBS)
+	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LVMLIBS) $(READLINE_LIBS)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status test/api/Makefile
-
-clean:
-	rm -f *.t
--- LVM2/test/unit/Makefile.in	2011/11/21 13:11:03	1.2
+++ LVM2/test/unit/Makefile.in	2011/11/23 12:21:42	1.3
@@ -13,13 +13,18 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
+VPATH = $(srcdir)
 SOURCES = bitset_t.c matcher_t.c run.c
 TARGETS = run
 
 include $(top_builddir)/make.tmpl
 LDFLAGS += -ldevmapper -lcunit
 
-unit: run
-	LD_LIBRARY_PATH=$(top_builddir)/libdm ./run
+ifeq ("$(TESTING)", "yes")
+all: unit
+endif
+
+unit: $(TARGETS)
+	@echo Running unit tests
+	LD_LIBRARY_PATH=$(top_builddir)/libdm ./$(TARGETS)


