From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2011 15:28:35 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20110112152835.3597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-12 15:28:34

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	add fio

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1876&r2=1.1877
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2011/01/11 17:05:08	1.1876
+++ LVM2/WHATS_NEW	2011/01/12 15:28:33	1.1877
@@ -1,5 +1,6 @@
 Version 2.02.81 -
 ===================================
+  Accept fusion fio in device type filter.
   Add disk to mirrored log type conversion.
 
 Version 2.02.80 - 10th January 2011
--- LVM2/lib/filters/filter.c	2010/12/20 13:12:56	1.58
+++ LVM2/lib/filters/filter.c	2011/01/12 15:28:34	1.59
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -128,6 +128,7 @@
 	{"virtblk", 8},		/* VirtIO disk */
 	{"mmc", 16},		/* MMC block device */
 	{"blkext", 1},		/* Extended device partitions */
+	{"fio", 16},		/* Fusion */
 	{NULL, 0}
 };
 


