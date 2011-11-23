From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 12:18:42 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20111123121842.31131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 12:18:42

Modified files:
	.              : make.tmpl.in 

Log message:
	Use 3 digits for chmod
	
	Use same sized chmod params (0 are filled from left on its own)
	and we use just 3 digits elsewhere.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/make.tmpl.in	2011/11/21 13:11:03	1.125
+++ LVM2/make.tmpl.in	2011/11/23 12:18:42	1.126
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -106,9 +106,9 @@
 INSTALL_DATA = $(INSTALL) -p $(M_INSTALL_DATA)
 INSTALL_WDATA = $(INSTALL) -p -m 644
 
-INSTALL_DIR = $(INSTALL) -m 0755 -d
-INSTALL_ROOT_DIR = $(INSTALL) -m 0700 -d
-INSTALL_ROOT_DATA = $(INSTALL) -m 0600
+INSTALL_DIR = $(INSTALL) -m 755 -d
+INSTALL_ROOT_DIR = $(INSTALL) -m 700 -d
+INSTALL_ROOT_DATA = $(INSTALL) -m 600
 INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib


