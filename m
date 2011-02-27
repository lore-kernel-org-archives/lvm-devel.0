From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Feb 2011 01:16:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110227011656.24324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-27 01:16:54

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix check for log-only allocation in new alloc normal loop.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1927&r2=1.1928
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.249&r2=1.250

--- LVM2/WHATS_NEW	2011/02/27 00:38:31	1.1927
+++ LVM2/WHATS_NEW	2011/02/27 01:16:52	1.1928
@@ -1,7 +1,7 @@
 Version 2.02.85 - 
 ===================================
-  Extend normal policy to allow mirror logs on same devs as images if necessary.
-  Improve cling policy to recognise devs already allocated in the transaction.
+  Extend normal policy to allow mirror logs on same PVs as images if necessary.
+  Improve cling policy to recognise PVs already used during the transaction.
   Improve normal allocation algorithm to include clinging to existing areas.
   Add allocation/maximise_cling & mirror_logs_require_separate_pvs to lvm.conf.
   Fix metadata balance code to work with recent changes in metadata handling.
--- LVM2/lib/metadata/lv_manip.c	2011/02/27 00:38:32	1.249
+++ LVM2/lib/metadata/lv_manip.c	2011/02/27 01:16:53	1.250
@@ -1555,9 +1555,9 @@
 		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
 		/* Extra iteration needed to fill log areas on PVs already used? */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == ix_offset && !ah->mirror_logs_separate &&
+		  (ix + preferred_count >= ah->area_count) && 
 		  (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
-
 	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED))
 		return 1;
 


