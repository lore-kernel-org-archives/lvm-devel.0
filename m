From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Jun 2017 06:03:46 -0400
Subject: master - tests: fix compilation of unit tests
Message-ID: <201706081003.v58A3k2o007804@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f91ea96b4f221894008d196c1f87b93527c51311
Commit:        f91ea96b4f221894008d196c1f87b93527c51311
Parent:        ee5ecde35eca656e85ee5c83b15ad4029d0acf4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 6 15:38:45 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 8 11:59:02 2017 +0200

tests: fix compilation of unit tests

Rule for TARGET compiling got missing and needs to be explicitely
expressed, otherwise default unsuitable rule is applied.
---
 test/unit/Makefile.in |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 70b7e79..7aa180f 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -24,15 +24,15 @@ UNITS = \
 	string_t.c\
 	run.c
 
-include $(top_builddir)/make.tmpl
-
-ifeq ($(MAKECMDGOALS),distclean)
+ifeq ("@TESTING@", "yes")
 SOURCES = $(UNITS)
+TARGETS = run
 endif
 
-ifeq ("$(TESTING)", "yes")
+include $(top_builddir)/make.tmpl
+
+ifeq ($(MAKECMDGOALS),distclean)
 SOURCES = $(UNITS)
-TARGETS = run
 endif
 
 ifeq ("$(TESTING)", "yes")
@@ -42,6 +42,8 @@ CFLAGS += @CUNIT_CFLAGS@
 check: unit
 
 $(TARGETS): $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	      -o $@ $(OBJECTS) $(LDLIBS)
 
 unit: $(TARGETS)
 	@echo Running unit tests


