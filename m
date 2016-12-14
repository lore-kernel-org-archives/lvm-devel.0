From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Dec 2016 10:42:40 +0000 (UTC)
Subject: master - raid: split preserves local exlusive activation
Message-ID: <20161214104240.2226860C8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fecd043cca4b5f4d5a244d715c60ce35ff1b62d7
Commit:        fecd043cca4b5f4d5a244d715c60ce35ff1b62d7
Parent:        77e09c3fb4d019ab3a0472059481ef990c64b415
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 14 10:19:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 14 11:40:01 2016 +0100

raid: split preserves local exlusive activation

---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   19 ++-----------------
 2 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 60e8fa5..4ac3377 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Always active splitted RAID LV exclusively locally.
   Do not use LV RAID status bit for segment status.
   Check segtype directly instead of checking RAID in segment status. 
   Reusing exiting code for raid image removal.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ed48239..b48b959 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -163,22 +163,6 @@ uint32_t lv_raid_image_count(const struct logical_volume *lv)
 	return seg->area_count;
 }
 
-static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
-					   struct logical_volume *sub_lv)
-{
-	struct cmd_context *cmd = top_lv->vg->cmd;
-
-	/* If top RAID was EX, use EX */
-	if (lv_is_active_exclusive_locally(top_lv)) {
-		if (!activate_lv_excl_local(cmd, sub_lv))
-			return_0;
-	} else {
-		if (!activate_lv(cmd, sub_lv))
-			return_0;
-	}
-	return 1;
-}
-
 /* HM Helper: prohibit allocation on @pv if @lv already has segments allocated on it */
 static int _avoid_pv_of_lv(struct logical_volume *lv, struct physical_volume *pv)
 {
@@ -1553,7 +1537,8 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 				display_lvname(lv));
 
 	/* Activate the split (and tracking) LV */
-	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
+	/* Preserving exclusive local activation also for tracked LV */
+	if (!activate_lv_excl_local(lv->vg->cmd, seg_lv(seg, s)))
 		return_0;
 
 	log_print_unless_silent("Use 'lvconvert --merge %s' to merge back into %s.",


