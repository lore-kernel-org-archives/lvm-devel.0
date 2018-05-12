From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:46 -0400
Subject: master - build: fix build rules for srcdir
Message-ID: <201805121626.w4CGQk4A008376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2c766d37e20231db48e55edb5e23973df590569
Commit:        e2c766d37e20231db48e55edb5e23973df590569
Parent:        ac768a9d2baca83bd9043d4d36f8e436894d29f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 18:14:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

build: fix build rules for srcdir

It's very hard to use some 'non-recurive' Makefiles with
rest of system running 'recursively'.

So ATM drop inclusion of subdir makefile and add support
for 2 new top-level targets:

unit-test  (builds test/unit dir)
run-unit-test (build & run test/unit/unit-test run)
---
 Makefile.in           |   13 ++++-----
 test/Makefile.in      |   10 +++++--
 test/unit/Makefile.in |   67 ++++++++++++++++++++++++++++--------------------
 3 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 3274f17..b0bceb0 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -61,6 +61,9 @@ po: tools daemons
 man: tools
 all_man: tools
 scripts: liblvm libdm
+test: lib
+unit-test: lib
+run-unit-test: unit-test
 
 lib.device-mapper: include.device-mapper
 libdm.device-mapper: include.device-mapper
@@ -96,7 +99,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test run-unit-test: all
 	$(MAKE) -C test $(@)
 
 conf.generate man.generate: tools
@@ -145,7 +148,7 @@ install_system_dirs:
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_RUN_DIR)
 	$(INSTALL_ROOT_DATA) /dev/null $(DESTDIR)$(DEFAULT_CACHE_DIR)/.cache
 
-install_initscripts: 
+install_initscripts:
 	$(MAKE) -C scripts install_initscripts
 
 install_systemd_generators:
@@ -210,10 +213,6 @@ endif
 
 endif
 
-include test/unit/Makefile
-
-include device-mapper/Makefile
-
 ifneq ($(shell which ctags),)
 .PHONY: tags
 tags:
diff --git a/test/Makefile.in b/test/Makefile.in
index de8e3a1..67f2753 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -27,7 +27,7 @@ datarootdir = @datarootdir@
 
 LVM_TEST_RESULTS ?= results
 
-SUBDIRS = api
+SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
@@ -37,9 +37,9 @@ include $(top_builddir)/make.tmpl
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | $(SORT))
+ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) | $(SORT))
 comma = ,
-RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
+RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMETAD@", "yes")
@@ -83,6 +83,7 @@ help:
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
 	@echo "  check_lvmlockd_test    Run tests with lvmlockd --test."
+	@echo "  run-unit-test          Run only unit tests (root not needed)."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
@@ -190,6 +191,9 @@ check_lvmlockd_test: .tests-stamp
 		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 
+run-unit-test unit-test:
+	$(MAKE) -C unit $(@)
+
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 9d18608..017afaa 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -10,38 +10,49 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-UNIT_SOURCE=\
-	base/data-struct/radix-tree.c \
-	device-mapper/vdo/status.c \
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES=\
+	radix-tree.c \
+	status.c \
 	\
-	test/unit/bcache_t.c \
-	test/unit/bcache_utils_t.c \
-	test/unit/bitset_t.c \
-	test/unit/config_t.c \
-	test/unit/dmlist_t.c \
-	test/unit/dmstatus_t.c \
-	test/unit/io_engine_t.c \
-	test/unit/radix_tree_t.c \
-	test/unit/matcher_t.c \
-	test/unit/framework.c \
-	test/unit/percent_t.c \
-	test/unit/run.c \
-	test/unit/string_t.c \
-	test/unit/vdo_t.c
-
-UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
-UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
-CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
+	bcache_t.c \
+	bcache_utils_t.c \
+	bitset_t.c \
+	config_t.c \
+	dmlist_t.c \
+	dmstatus_t.c \
+	framework.c \
+	io_engine_t.c \
+	matcher_t.c \
+	percent_t.c \
+	radix_tree_t.c \
+	run.c \
+	string_t.c \
+	vdo_t.c
+
+TARGETS += unit-test
+
+# Using vpath for other src dirs
+# FIXME: hopefully later we will just link libs without need to extract sources
+# via usage of vpath
+vpath %.c \
+	$(top_srcdir)/base/data-struct \
+	$(top_srcdir)/device-mapper/vdo
+
+include $(top_builddir)/make.tmpl
+
 UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
+INCLUDES += -I$(top_srcdir)
 
-test/unit/unit-test: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
+unit-test: $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX) $(top_builddir)/lib/liblvm-internal.a
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
+	      -o $@ $(OBJECTS) $(UNIT_LDLIBS)
 
-.PHONEY: run-unit-test
-run-unit-test: test/unit/unit-test
+.PHONY: run-unit-test
+run-unit-test: unit-test
 	@echo Running unit tests
-	LD_LIBRARY_PATH=libdm test/unit/unit-test run
-
--include $(UNIT_DEPENDS)
+	LD_LIBRARY_PATH=$(top_builddir)/libdm ./unit-test run


