From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Jan 2012 21:40:36 -0000
Subject: LVM2/test/unit Makefile.in
Message-ID: <20120126214036.13233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-26 21:40:36

Modified files:
	test/unit      : Makefile.in 

Log message:
	Build test run target only for $(TESTING)
	
	Add libraries properly in LDLIBS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/unit/Makefile.in	2011/12/11 15:19:41	1.5
+++ LVM2/test/unit/Makefile.in	2012/01/26 21:40:36	1.6
@@ -1,4 +1,4 @@
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,11 +16,11 @@
 
 VPATH = $(srcdir)
 SOURCES = bitset_t.c matcher_t.c config_t.c run.c
-TARGETS = run
 
 include $(top_builddir)/make.tmpl
 ifeq ("$(TESTING)", "yes")
-LDFLAGS += -ldevmapper @CUNIT_LIBS@
+TARGETS = run
+LDLIBS += -ldevmapper @CUNIT_LIBS@
 CFLAGS += @CUNIT_CFLAGS@
 
 all: unit


