From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Apr 2009 10:16:15 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20090416101615.14328.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-16 10:16:14

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Add MMC device type to filters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1086&r2=1.1087
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2009/04/10 09:59:18	1.1086
+++ LVM2/WHATS_NEW	2009/04/16 10:16:14	1.1087
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add MMC (mmcblk) device type to filters.
   Introduce memory pools per volume group (to reduce memory for large VGs).
   Add memory pool leaks detection.
   Use copy of PV structure when manipulating with global PV lists.
--- LVM2/lib/filters/filter.c	2008/04/03 10:29:00	1.46
+++ LVM2/lib/filters/filter.c	2009/04/16 10:16:14	1.47
@@ -78,6 +78,7 @@
 	{"vdisk", 8},		/* SUN's LDOM virtual block device */
 	{"ps3disk", 16},	/* PlayStation 3 internal disk */
 	{"virtblk", 8},		/* VirtIO disk */
+	{"mmc", 16},		/* MMC block device */
 	{NULL, 0}
 };
 


