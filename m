From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Sep 2011 09:48:22 -0000
Subject: LVM2 ./WHATS_NEW_DM man/Makefile.in
Message-ID: <20110923094822.20009.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-23 09:48:21

Modified files:
	.              : WHATS_NEW_DM 
	man            : Makefile.in 

Log message:
	Build all man pages
	
	When running plain 'make' in man dir - do also those for device-mapper target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.504&r2=1.505
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW_DM	2011/09/22 17:36:50	1.504
+++ LVM2/WHATS_NEW_DM	2011/09/23 09:48:21	1.505
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dependency for dm man pages to man subdirectory make target all:.
   Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.
   Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
   Add dm_device_has_holders fn to to check use of the device by another device.
--- LVM2/man/Makefile.in	2010/07/01 10:57:03	1.40
+++ LVM2/man/Makefile.in	2011/09/23 09:48:21	1.41
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -60,7 +60,7 @@
   install: install_cluster
 endif
 
-all: man
+all: man device-mapper
 
 .PHONY: man install_man5 install_man8
 


