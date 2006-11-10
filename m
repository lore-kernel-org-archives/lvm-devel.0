From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2006 19:35:04 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20061110193504.11580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-10 19:35:03

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix adjusted_mirror_region_size() for 64-bit size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.492&r2=1.493
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2006/11/10 18:24:11	1.492
+++ LVM2/WHATS_NEW	2006/11/10 19:35:02	1.493
@@ -1,6 +1,7 @@
 Version 2.02.14 - 
 ===================================
-  Add some missing bounds checks on 32 bit extent counters.
+  Fix adjusted_mirror_region_size() to handle 64-bit size.
+  Add some missing bounds checks on 32-bit extent counters.
   Add Petabyte and Exabyte support.
   Fix lvcreate error message when 0 extents requested.
   lvremove man page: volumes must be cluster inactive before being removed.
--- LVM2/lib/metadata/mirror.c	2006/10/18 18:01:52	1.34
+++ LVM2/lib/metadata/mirror.c	2006/11/10 19:35:03	1.35
@@ -36,20 +36,20 @@
 }
 
 /*
- * Ensure region size is compatible with volume size.
+ * Reduce the region size if necessary to ensure
+ * the volume size is a multiple of the region size.
  */
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size)
 {
-	uint32_t region_max;
+	uint64_t region_max;
 
 	region_max = (1 << (ffs((int)extents) - 1)) * extent_size;
 
-	if (region_max < region_size) {
-		region_size = region_max;
+	if (region_max < UINT32_MAX && region_size > region_max) {
+		region_size = (uint32_t) region_max;
 		log_print("Using reduced mirror region size of %" PRIu32
-			  " sectors", region_max);
-		return region_max;
+			  " sectors", region_size);
 	}
 
 	return region_size;


