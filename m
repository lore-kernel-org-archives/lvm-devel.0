From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Oct 2006 16:10:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20061030161056.3594.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-30 16:10:56

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix high-level free space check for partial allocations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.486&r2=1.487
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2006/10/27 15:37:02	1.486
+++ LVM2/WHATS_NEW	2006/10/30 16:10:55	1.487
@@ -1,5 +1,6 @@
 Version 2.02.14 - 
 ===================================
+  Fix high-level free space check for partial allocations.
 
 Version 2.02.13 - 27th October 2006
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2006/10/23 15:54:51	1.111
+++ LVM2/lib/metadata/lv_manip.c	2006/10/30 16:10:55	1.112
@@ -894,10 +894,10 @@
 
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
-	if (needed > free_pes) {
+	if (needed - *allocated > free_pes) {
 		log_error("Insufficient free space: %" PRIu32 " extents needed,"
-			  " but only %" PRIu32 " available", needed,
-			  free_pes);
+			  " but only %" PRIu32 " available",
+			  needed - *allocated, free_pes);
 		return 0;
 	}
 


