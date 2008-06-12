From: meyering@sourceware.org <meyering@sourceware.org>
Date: 12 Jun 2008 09:48:46 -0000
Subject: LVM2 Makefile.in
Message-ID: <20080612094846.27393.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-12 09:48:45

Modified files:
	.              : Makefile.in 

Log message:
	Makefile.in: correct distclean rule
	
	* Makefile.in (SUBDIRS): Remove long-unused test/* names.
	(SUBDIRS) [distclean]: Append "test".
	Discovered with Zden??k Kabel????.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/Makefile.in	2007/09/21 10:16:43	1.20
+++ LVM2/Makefile.in	2008/06/12 09:48:45	1.21
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -36,8 +36,8 @@
 	     lib/locking \
 	     lib/mirror \
 	     lib/snapshot \
-	     po \
-	     test/mm test/device test/format1 test/regex test/filters
+	     test \
+	     po
   DISTCLEAN_TARGETS += lib/misc/configure.h
 endif
 


