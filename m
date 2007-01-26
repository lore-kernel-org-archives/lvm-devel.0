From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2007 17:15:17 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c
Message-ID: <20070126171517.11826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-26 17:15:16

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 

Log message:
	Fix md signature check to handle both endiannesses.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.562&r2=1.563
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2007/01/25 23:40:33	1.562
+++ LVM2/WHATS_NEW	2007/01/26 17:15:16	1.563
@@ -1,5 +1,6 @@
 Version 2.02.21 -
 ===================================
+  Fix md signature check to handle both endiannesses.
 
 Version 2.02.20 - 25th January 2007
 ===================================
--- LVM2/lib/device/dev-md.c	2004/11/27 22:07:41	1.3
+++ LVM2/lib/device/dev-md.c	2007/01/26 17:15:16	1.4
@@ -53,8 +53,10 @@
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
 
 	/* Check if it is an md component device. */
+	/* Version 1 is little endian; version 0.90.0 is machine endian */
 	if (dev_read(dev, sb_offset, sizeof(uint32_t), &md_magic) &&
-	    (md_magic == xlate32(MD_SB_MAGIC))) {
+	    ((md_magic == xlate32(MD_SB_MAGIC)) ||
+	     (md_magic == MD_SB_MAGIC))) {
 		if (sb)
 			*sb = sb_offset;
 		ret = 1;


