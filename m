From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 18:43:00 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110913184300.12758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 18:42:59

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix for bug 737200 - Can't create mirrored-log mirror on a VG with small extents
	
	Kernel requires a mirror to be at least 1 region large.  So,
	if our mirror log is itself a mirror, it must be at least
	1 region large.  This restriction may not be necessary for
	non-mirrored logs, but we apply the rule anyway.
	
	(The other option is to make the region size of the log
	mirror smaller than the mirror it is acting as a log for,
	but that really complicates things.  It's much easier to
	keep the region_size the same for both.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2104&r2=1.2105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.283&r2=1.284

--- LVM2/WHATS_NEW	2011/09/13 16:33:21	1.2104
+++ LVM2/WHATS_NEW	2011/09/13 18:42:57	1.2105
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix mirrored log creation when PE size is small - force log_size >= region_size
   Fix improper RAID 64-bit status flag reset when and'ing against 32-bit flag.
   Fix log size calculation when only a log is being added to a mirror.
   Work around resume_lv causing error LV scanning during splitmirror operation.
--- LVM2/lib/metadata/lv_manip.c	2011/09/08 16:41:18	1.283
+++ LVM2/lib/metadata/lv_manip.c	2011/09/13 18:42:58	1.284
@@ -687,8 +687,21 @@
 	/* Log device holds both header and bitset. */
 	log_size = dm_round_up((MIRROR_LOG_OFFSET << SECTOR_SHIFT) + bitset_size, 1 << SECTOR_SHIFT);
 	log_size >>= SECTOR_SHIFT;
+	log_size = dm_div_up(log_size, pe_size);
 
-	return dm_div_up(log_size, pe_size);
+	/*
+	 * Kernel requires a mirror to be at least 1 region large.  So,
+	 * if our mirror log is itself a mirror, it must be at least
+	 * 1 region large.  This restriction may not be necessary for
+	 * non-mirrored logs, but we apply the rule anyway.
+	 *
+	 * (The other option is to make the region size of the log
+	 * mirror smaller than the mirror it is acting as a log for,
+	 * but that really complicates things.  It's much easier to
+	 * keep the region_size the same for both.)
+	 */
+	return (log_size > (region_size / pe_size)) ? log_size :
+		(region_size / pe_size);
 }
 
 /*


