From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:46 -0500
Subject: master - raid: move VG update after archiving happened
Message-ID: <201803061445.w26Ejkgg026625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2f1254c14b7b86789e542be14041252a652eec2
Commit:        b2f1254c14b7b86789e542be14041252a652eec2
Parent:        ce199db848e663ffa040015106725553eafb1c98
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 6 13:38:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:38:15 2018 +0100

raid: move VG update after archiving happened

Update of LV le_count needs to happen after archive().
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 52cf4bc..49b995e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Do not modify archived metadata when removing striped raid.
   Fix memleak on error path when obtaining lv_raid_data_offset.
   Fix compatibility size test of extended external origin.
   Add external_origin visiting in for_each_sub_lv().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 044214c..88b0d9d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6077,13 +6077,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		is_last_pool = 1;
 	}
 
-	/* Special case removing a striped raid LV with allocated reshape space */
-	if (seg && seg->reshape_len) {
-		if (!(seg->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
-			return_0;
-		lv->le_count = seg->len = seg->area_len = seg_lv(seg, 0)->le_count * seg->area_count;
-	}
-
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if (!lv_is_used_cache_pool(lv) &&
 	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
@@ -6097,6 +6090,13 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!archive(vg))
 		return 0;
 
+	/* Special case removing a striped raid LV with allocated reshape space */
+	if (seg && seg->reshape_len) {
+		if (!(seg->segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
+			return_0;
+		lv->le_count = seg->len = seg->area_len = seg_lv(seg, 0)->le_count * seg->area_count;
+	}
+
 	/* Clear thin pool stacked messages */
 	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
 	    !update_pool_lv(pool_lv, 1)) {


