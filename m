From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:34 +0000 (UTC)
Subject: master - makefiles: cleanup update
Message-ID: <20130604135834.64F7160FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b2be901ed55ff309da8e94879cacb560f21dc2b
Commit:        9b2be901ed55ff309da8e94879cacb560f21dc2b
Parent:        eb2c68590b766e25ada9d425ad0b6602cd724fcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 3 12:05:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:18 2013 +0200

makefiles: cleanup update

Cleanup also test dir.
Distclean unit tests.
---
 Makefile.in           |    3 +++
 test/unit/Makefile.in |   12 +++++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 4d39577..ceb8964 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -38,6 +38,9 @@ endif
 
 SUBDIRS += scripts
 
+ifeq ($(MAKECMDGOALS),clean)
+  SUBDIRS += test
+endif
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man test scripts \
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 740eb14..62a0077 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,8 +15,14 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
-ifeq ("@TESTING@", "yes")
-SOURCES = bitset_t.c matcher_t.c config_t.c string_t.c run.c
+UNITS = bitset_t.c matcher_t.c config_t.c string_t.c run.c
+
+ifeq ($(MAKECMDGOALS),distclean)
+SOURCES = $(UNITS)
+endif
+
+ifeq ("$(TESTING)", "yes")
+SOURCES = $(UNITS)
 TARGETS = run
 endif
 


