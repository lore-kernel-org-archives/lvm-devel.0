From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 10:52:46 -0000
Subject: LVM2 ./WHATS_NEW liblvm/Makefile.in
Message-ID: <20120208105246.20811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 10:52:46

Modified files:
	.              : WHATS_NEW 
	liblvm         : Makefile.in 

Log message:
	Add missing deps for lvm2api
	
	Hmm, wasted some time because of this missing deps....

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2260&r2=1.2261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2012/02/08 10:49:36	1.2260
+++ LVM2/WHATS_NEW	2012/02/08 10:52:45	1.2261
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Add missing deps for lvm2api for rebuild when lvm-internal is changed.
   Fix resource leaks for failing allocation of formats (lvm1/2,pool).
   Release allocated resources in error path for composite_filter_create().
   Do not use lstat() results when failed in _rm_link().
--- LVM2/liblvm/Makefile.in	2010/08/03 13:00:46	1.26
+++ LVM2/liblvm/Makefile.in	2012/02/08 10:52:46	1.27
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -37,6 +37,8 @@
 EXPORTED_HEADER = $(srcdir)/lvm2app.h
 EXPORTED_FN_PREFIX = lvm
 
+LDDEPS += $(top_builddir)/lib/liblvm-internal.a
+
 include $(top_builddir)/make.tmpl
 
 LIBS += $(LVMINTERNAL_LIBS) -ldevmapper


