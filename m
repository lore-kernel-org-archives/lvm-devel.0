From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:23 -0400
Subject: master - [build] include test/unit/Makefile rather than recursive build
Message-ID: <201804231347.w3NDlNR5031245@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ae3b244fcbc207b51a81514e51008fe64d13368
Commit:        8ae3b244fcbc207b51a81514e51008fe64d13368
Parent:        b03e55a5130ffdf6be9188b227c59e6793dc0dfc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 15:39:17 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[build] include test/unit/Makefile rather than recursive build

FIXME: unit tests are not currently run as part of make check.
---
 Makefile.in           |   23 +------------------
 test/Makefile.in      |    2 +-
 test/unit/Makefile.in |   58 ++++++++++++++++---------------------------------
 3 files changed, 21 insertions(+), 62 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 31d428d..146ed55 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -212,28 +212,7 @@ endif
 endif
 
 ifeq ("$(TESTING)", "yes")
-# testing and report generation
-RUBY=ruby1.9 -Ireport-generators/lib -Ireport-generators/test
-
-.PHONY: unit-test ruby-test test-programs
-
-# FIXME: put dependencies on libdm and liblvm
-# FIXME: Should be handled by Makefiles in subdirs, not here at top level.
-test-programs:
-	cd unit-tests/regex && $(MAKE)
-	cd unit-tests/datastruct && $(MAKE)
-	cd unit-tests/mm && $(MAKE)
-
-unit-test: test-programs
-	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
-	$(RUBY) report-generators/title_page.rb
-
-memcheck: test-programs
-	$(RUBY) report-generators/memcheck.rb $(shell find . -name TESTS)
-	$(RUBY) report-generators/title_page.rb
-
-ruby-test:
-	$(RUBY) report-generators/test/ts.rb
+include test/unit/Makefile
 endif
 
 ifneq ($(shell which ctags),)
diff --git a/test/Makefile.in b/test/Makefile.in
index 230ce5b..097b2fa 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -27,7 +27,7 @@ datarootdir = @datarootdir@
 
 LVM_TEST_RESULTS ?= results
 
-SUBDIRS = api unit
+SUBDIRS = api
 SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 5cf92ba..2e2c819 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -10,44 +10,24 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-VPATH = $(srcdir)
-UNITS = \
-	bcache_t.c \
-	bitset_t.c\
-	config_t.c\
-	dmlist_t.c\
-	dmstatus_t.c\
-	matcher_t.c\
-	percent_t.c\
-	string_t.c\
-	run.c
-
-ifeq ("@TESTING@", "yes")
-SOURCES = $(UNITS)
-TARGETS = run
-endif
-
-include $(top_builddir)/make.tmpl
-
-ifeq ($(MAKECMDGOALS),distclean)
-SOURCES = $(UNITS)
-endif
-
-ifeq ("$(TESTING)", "yes")
-LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio @CUNIT_LIBS@
-CFLAGS += @CUNIT_CFLAGS@
-
-check: unit
-
-$(TARGETS): $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
+UNIT_SOURCE=\
+	test/unit/bcache_t.c \
+	test/unit/bitset_t.c\
+	test/unit/config_t.c\
+	test/unit/dmlist_t.c\
+	test/unit/dmstatus_t.c\
+	test/unit/matcher_t.c\
+	test/unit/percent_t.c\
+	test/unit/string_t.c\
+	test/unit/run.c
+UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
+
+UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio -lcunit
+
+test/unit/run: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ $(OBJECTS) $(LDLIBS)
+	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
 
-unit: $(TARGETS) $(top_builddir)/lib/liblvm-internal.a
+unit-test: test/unit/run
 	@echo Running unit tests
-	LD_LIBRARY_PATH=$(top_builddir)/libdm ./$(TARGETS)
-endif
+	LD_LIBRARY_PATH=libdm test/unit/run


