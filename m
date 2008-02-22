From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2008 13:22:46 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c
Message-ID: <20080222132246.11092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-22 13:22:45

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c 

Log message:
	Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.796&r2=1.797
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2008/02/22 13:22:19	1.796
+++ LVM2/WHATS_NEW	2008/02/22 13:22:44	1.797
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)
   Add missing no-longer-used segs_using_this_lv test to check_lv_segments.
   Remove redundant non-NULL tests before calling free in clvmd.c.
   Avoid a compiler warning: make is_orphan's parameter const.
--- LVM2/lib/metadata/merge.c	2008/01/30 14:00:00	1.34
+++ LVM2/lib/metadata/merge.c	2008/02/22 13:22:44	1.35
@@ -224,6 +224,20 @@
 				  seg->le + seg->len - 1, seg_found);
 			r = 0;
 		}
+
+		seg_found = 0;
+		list_iterate_items(seg2, &seg->lv->segments)
+			if (sl->seg == seg2) {
+				seg_found++;
+				break;
+			}
+		if (!seg_found) {
+			log_error("LV segment %s:%" PRIu32 "-%" PRIu32
+				  "is incorrectly listed as being used by LV %s",
+				  seg->lv->name, seg->le, seg->le + seg->len - 1,
+				  lv->name);
+			r = 0;
+		}
 	}
 
 	if (le != lv->le_count) {


