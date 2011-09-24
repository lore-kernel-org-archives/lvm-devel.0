From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:05:03 -0000
Subject: LVM2 ./WHATS_NEW scripts/Makefile.in
Message-ID: <20110924210503.1680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:05:03

Modified files:
	.              : WHATS_NEW 
	scripts        : Makefile.in 

Log message:
	Fix install_ocf
	
	When builddir is different from srcdir install_ocf: has not been able to find
	files for installation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2135&r2=1.2136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2011/09/24 20:50:35	1.2135
+++ LVM2/WHATS_NEW	2011/09/24 21:05:03	1.2136
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix install_ocf make target when srcdir != builddir. (2.02.80)
   Support env vars LVM_CLVMD_BINARY and LVM_BINARY in clvmd.
   Fix restart of clvmd (preserve exlusive locks). (2.02.64)
   Add 'Volume Type' lv_attr characters for RAID and RAID_IMAGE.
--- LVM2/scripts/Makefile.in	2011/07/28 12:57:26	1.21
+++ LVM2/scripts/Makefile.in	2011/09/24 21:05:03	1.22
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2006-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2006-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -28,6 +28,7 @@
 endif
 
 vpath %.sh $(srcdir)
+vpath %.ocf $(srcdir)
 
 %_install: %.sh
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(basename $(<F))


