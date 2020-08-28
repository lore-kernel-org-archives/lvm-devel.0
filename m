From: David Teigland <teigland@sourceware.org>
Date: Fri, 28 Aug 2020 18:29:07 +0000 (GMT)
Subject: master - Revert "lvdisplay: dispaly correct status when underlying devs missing"
Message-ID: <20200828182907.524C8385041B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a88a9c4ce8fc930328e8d7d56fae8e964f8df02
Commit:        9a88a9c4ce8fc930328e8d7d56fae8e964f8df02
Parent:        1d0dc74f9147e3c1f3681efa4166cbe2edcb6571
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 28 13:26:50 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 28 13:28:15 2020 -0500

Revert "lvdisplay: dispaly correct status when underlying devs missing"

This reverts commit 1d0dc74f9147e3c1f3681efa4166cbe2edcb6571.

We should avoid adding anything new to lvdisplay and report
new information via lvs reporting fields.
---
 lib/display/display.c  | 13 +++---------
 lib/metadata/segtype.h |  1 -
 lib/raid/raid.c        | 54 --------------------------------------------------
 3 files changed, 3 insertions(+), 65 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 3bb570f03..36c9879b3 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -399,7 +399,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 		   void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
-	int inkernel, snap_active = 0, partial = 0, raid_is_avail = 1;
+	int inkernel, snap_active = 0;
 	char uuid[64] __attribute__((aligned(8)));
 	const char *access_str;
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
@@ -553,18 +553,11 @@ int lvdisplay_full(struct cmd_context *cmd,
 		log_print("LV VDO Pool name       %s", seg_lv(seg, 0)->name);
 	}
 
-	if (lv_is_partial(lv)) {
-		partial = 1;
-		if (lv_is_raid(lv))
-			raid_is_avail = raid_is_available(lv) ? 1 : 0;
-	}
-
 	if (inkernel && info.suspended)
 		log_print("LV Status              suspended");
 	else if (activation())
-		log_print("LV Status              %savailable %s",
-			  (inkernel && raid_is_avail) ? "" : "NOT ",
-			  partial ? "(partial)" : "");
+		log_print("LV Status              %savailable",
+			  inkernel ? "" : "NOT ");
 
 /********* FIXME lv_number
     log_print("LV #                   %u", lv->lv_number + 1);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 1a840707d..08ddc3565 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -326,7 +326,6 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
-bool raid_is_available(const struct logical_volume *lv);
 #endif
 
 #define THIN_FEATURE_DISCARDS			(1U << 0)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 4ed77e9a8..e88a15408 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -25,60 +25,6 @@
 #include "lib/metadata/metadata.h"
 #include "lib/metadata/lv_alloc.h"
 
-/*
- * below case think as available, return true:
- * - raid 1:@least 1 disk live
- * - raid 10: loose 1 disk
- * - raid 4/5: loose 1 disk
- * - raid 6: loose 2 disk
- *
- * raid 0: if there is any disk loose, return false
- * */
-bool raid_is_available(const struct logical_volume *lv)
-{
-	int s, missing_pv = 0, exist_pv = 0;
-	bool ret = true;
-	struct lv_segment *seg = NULL;
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; ++s) {
-			if (seg_type(seg, s) == AREA_LV) {
-				if (seg_lv(seg, s)->status & PARTIAL_LV)
-					missing_pv++;
-				else
-					exist_pv++;
-			}
-		}
-	}
-	if (seg_is_any_raid0(first_seg(lv))){
-		ret = missing_pv ? false : true;
-		goto out;
-	}
-	if (seg_is_raid1(first_seg(lv))){
-		ret = exist_pv ? true : false;
-		goto out;
-	}
-	if (seg_is_any_raid10(first_seg(lv))) {
-		ret = (missing_pv > 1) ? false : true;
-		goto out;
-	}
-	if (seg_is_raid4(first_seg(lv))) {
-		ret = (missing_pv > 1) ? false : true;
-		goto out;
-	}
-	if (seg_is_any_raid5(first_seg(lv))) {
-		ret = (missing_pv > 1) ? false : true;
-		goto out;
-	}
-	if (seg_is_any_raid6(first_seg(lv))) {
-		ret = (missing_pv > 2) ? false : true;
-		goto out;
-	}
-
-out:
-	return ret;
-}
-
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes);


