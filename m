From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2011 01:31:24 -0000
Subject: LVM2 lib/metadata/lv_manip.c ./WHATS_NEW
Message-ID: <20111104013124.13022.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-04 01:31:24

Modified files:
	lib/metadata   : lv_manip.c 
	.              : WHATS_NEW 

Log message:
	Add missing lvrename mirrored log recursion in for_each_sub_lv.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.319&r2=1.320
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2176&r2=1.2177

--- LVM2/lib/metadata/lv_manip.c	2011/11/03 15:46:51	1.319
+++ LVM2/lib/metadata/lv_manip.c	2011/11/04 01:31:23	1.320
@@ -2749,13 +2749,20 @@
 	struct lv_segment *seg;
 	uint32_t s;
 
-	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv)))
+	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {
 		if (!fn(cmd, org, data))
 			return_0;
+		if (!for_each_sub_lv(cmd, org, fn, data))
+			return_0;
+	}
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->log_lv && !fn(cmd, seg->log_lv, data))
-			return_0;
+		if (seg->log_lv) {
+			if (!fn(cmd, seg->log_lv, data))
+				return_0;
+			if (!for_each_sub_lv(cmd, seg->log_lv, fn, data))
+				return_0;
+		}
 		if (seg->pool_metadata_lv && !fn(cmd, seg->pool_metadata_lv, data))
 			return_0;
 		for (s = 0; s < seg->area_count; s++) {
--- LVM2/WHATS_NEW	2011/10/28 20:23:24	1.2176
+++ LVM2/WHATS_NEW	2011/11/04 01:31:23	1.2177
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add missing lvrename mirrored log recursion in for_each_sub_lv.
   Improve lv_extend stack reporting.
   Increase virtual segment size instead of creating multiple segment list.
   Add last_seg(lv) internal function.


