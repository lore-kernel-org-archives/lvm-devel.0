From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jan 2007 21:55:12 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.c tools/too ...
Message-ID: <20070115215512.16380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-15 21:55:11

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.c 
	tools          : toollib.c 

Log message:
	Fix partition table processing after sparc changes (introduced in 2.02.16).
	Fix cmdline PE range processing segfault (introduced in 2.02.13).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.541&r2=1.542
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2007/01/15 18:22:01	1.541
+++ LVM2/WHATS_NEW	2007/01/15 21:55:11	1.542
@@ -1,5 +1,7 @@
 Version 2.02.19 - 
 ===================================
+  Fix partition table processing after sparc changes (2.02.16).
+  Fix cmdline PE range processing segfault (2.02.13).
   Some libdevmapper-event interface changes.
   Report dmeventd mirror monitoring status.
   Fix dmeventd mirror status line processing.
--- LVM2/lib/device/device.c	2006/11/30 23:11:40	1.22
+++ LVM2/lib/device/device.c	2007/01/15 21:55:11	1.23
@@ -72,7 +72,7 @@
 	/* Check for msdos partition table */
 	part_magic = buf + PART_MAGIC_OFFSET/sizeof(buf[0]);
 	if ((*part_magic == xlate16(PART_MAGIC))) {
-		part = (struct partition *) (buf + PART_OFFSET);
+		part = (struct partition *) (buf + PART_OFFSET/sizeof(buf[0]));
 		for (p = 0; p < 4; p++, part++) {
 			/* Table is invalid if boot indicator not 0 or 0x80 */
 			if ((part->boot_ind & 0x7f)) {
--- LVM2/tools/toollib.c	2006/11/03 21:23:06	1.95
+++ LVM2/tools/toollib.c	2007/01/15 21:55:11	1.96
@@ -993,7 +993,7 @@
 	}
 
 	/* Determine selected physical extents */
-	if (!_parse_pes(mem, colon, pe_ranges, dev_name(pvl->pv->dev),
+	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, dev_name(pvl->pv->dev),
 			pvl->pv->pe_count)) {
 		stack;
 		return 0;


