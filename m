From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 22:55:07 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110819225507.5515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 22:55:07

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove incorrect error message added in 2.02.87.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.275&r2=1.276

--- LVM2/lib/metadata/lv_manip.c	2011/08/19 16:41:26	1.275
+++ LVM2/lib/metadata/lv_manip.c	2011/08/19 22:55:07	1.276
@@ -1706,10 +1706,8 @@
 			if ((alloc_parms->alloc == ALLOC_ANYWHERE &&
 			    ix + ix_offset >= devices_needed + alloc_state->log_area_count_still_needed) ||
 			    (preferred_count == ix_offset &&
-			     (ix_offset == devices_needed + alloc_state->log_area_count_still_needed))) {
-				log_error("Breaking: preferred_count = %d, ix_offset = %d, devices_needed = %d", preferred_count, ix_offset, devices_needed);
+			     (ix_offset == devices_needed + alloc_state->log_area_count_still_needed)))
 				break;
-			}
 		}
 	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < devices_needed + alloc_state->log_area_count_still_needed) ||
 		/* With cling_to_alloced, if there were gaps in the preferred areas, have a second iteration */


