From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 11 Sep 2012 18:11:37 +0000 (UTC)
Subject: master - RAID: Properly handle resync of RAID LVs
Message-ID: <20120911181137.F1EAA2364@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ededc698f32a4cbabaf70bfd3835abab866cbb9
Commit:        4ededc698f32a4cbabaf70bfd3835abab866cbb9
Parent:        a2d9b1a7e92aab78c80be0e0cbd45fde00d42aa4
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 11 13:09:35 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 11 13:09:35 2012 -0500

RAID:  Properly handle resync of RAID LVs

Issuing a 'lvchange --resync <VG>/<RAID_LV>' had no effect.  This is
because the code to handle RAID LVs was not present.  This patch adds
the code that will clear the metadata areas of RAID LVs - causing them
to resync upon activation.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |   51 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c0b84ab..0c3b591 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Properly handle 'resync' of RAID LVs.
   Disallow addition of RAID images until the array is in-sync.
   Fix RAID LV creation with '--test' so valid commands do not fail.
   Add lvm_lv_rename() to lvm2api.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6972aac..0904e7b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -258,29 +258,50 @@ static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 
 static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
+	uint32_t s;
+	uint32_t num_meta_lvs;
 	struct cmd_context *cmd = seg->lv->vg->cmd;
 	struct lv_list *lvl;
 
-	if (seg_is_raid(seg)) {
-		return 0;
-	}
+	num_meta_lvs = seg_is_raid(seg) ? seg->area_count : !!seg->log_lv;
+
+	if (!num_meta_lvs)
+		return_0;
 
-	if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl))))
+	if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl) * num_meta_lvs)))
 		return_0;
 
-	lvl->lv = detach_mirror_log(seg);
-	dm_list_add(list, &lvl->list);
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (!seg_metalv(seg, s))
+				return_0; /* Trap this future possibility */
+
+			lvl[s].lv = seg_metalv(seg, s);
+			lv_set_visible(lvl[s].lv);
+
+			dm_list_add(list, &lvl[s].list);
+		}
+		return 1;
+	}
+
+	lvl[0].lv = detach_mirror_log(seg);
+	dm_list_add(list, &lvl[0].list);
 
 	return 1;
 }
 
 static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
+	uint32_t s = 0;
 	struct cmd_context *cmd = seg->lv->vg->cmd;
-	struct lv_list *lvl;
+	struct lv_list *lvl, *tmp;
 
 	if (seg_is_raid(seg)) {
-		return 0;
+		dm_list_iterate_items_safe(lvl, tmp, list) {
+			lv_set_hidden(lvl->lv);
+			dm_pool_free(cmd->mem, lvl);
+		}
+		return 1;
 	}
 
 	dm_list_iterate_items(lvl, list)
@@ -308,8 +329,8 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	dm_list_init(&device_list);
 
-	if (!(lv->status & MIRRORED)) {
-		log_error("Unable to resync %s because it is not mirrored.",
+	if (!(lv->status & MIRRORED) && !seg_is_raid(seg)) {
+		log_error("Unable to resync %s.  It is not RAID or mirrored.",
 			  lv->name);
 		return 1;
 	}
@@ -364,12 +385,14 @@ static int lvchange_resync(struct cmd_context *cmd,
 	}
 
 	init_dmeventd_monitor(monitored);
+	init_mirror_in_sync(0);
 
-	log_very_verbose("Starting resync of %s%s%s mirror \"%s\"",
+	log_very_verbose("Starting resync of %s%s%s%s \"%s\"",
 			 (active) ? "active " : "",
 			 vg_is_clustered(lv->vg) ? "clustered " : "",
-			 (seg->log_lv) ? "disk-logged" : "core-logged",
-			 lv->name);
+			 (seg->log_lv) ? "disk-logged " :
+			 seg_is_raid(seg) ? "" : "core-logged ",
+			 seg->segtype->ops->name(seg), lv->name);
 
 	/*
 	 * If this mirror has a core log (i.e. !seg->log_lv),
@@ -377,7 +400,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 	 * it to reset the sync status.  We only need to
 	 * worry about persistent logs.
 	 */
-	if (!seg->log_lv) {
+	if (!seg_is_raid(seg) && !seg->log_lv) {
 		if (!(lv->status & LV_NOTSYNCED)) {
 			lv->status &= ~LV_NOTSYNCED;
 			log_very_verbose("Updating logical volume \"%s\""


