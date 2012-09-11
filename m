From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 11 Sep 2012 18:11:35 +0000 (UTC)
Subject: master - cleanup: Restructure code that handles mirror resyncing
Message-ID: <20120911181135.AEC352364@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2d9b1a7e92aab78c80be0e0cbd45fde00d42aa4
Commit:        a2d9b1a7e92aab78c80be0e0cbd45fde00d42aa4
Parent:        05131f5853e86419d9c726faa961b8d012298d9c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 11 13:01:05 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 11 13:01:05 2012 -0500

cleanup:  Restructure code that handles mirror resyncing

When an LV is to be resynced, the metadata areas are cleared and the
LV is reactivated.  This is true for mirroring and will also be true
for RAID LVs.  We restructure the code in lvchange_resync() so that we
keep all the common steps necessary (validation of ability to resync,
deactivation, activation of meta/log devices, clearing of those devices,
etc) and place the code that will be divergent in separate functions:
	detach_metadata_devices()
	attach_metadata_devices()

The common steps will be processed on lists of metadata devices.  Before
RAID capability is added, this will simply be the mirror log device (if
found).

This patch lays the ground-work for adding resync of RAID LVs.
---
 tools/lvchange.c |  115 ++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 86 insertions(+), 29 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index cbdb353..6972aac 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -256,13 +256,57 @@ static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	return lv_refresh(cmd, lv);
 }
 
+static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct lv_list *lvl;
+
+	if (seg_is_raid(seg)) {
+		return 0;
+	}
+
+	if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl))))
+		return_0;
+
+	lvl->lv = detach_mirror_log(seg);
+	dm_list_add(list, &lvl->list);
+
+	return 1;
+}
+
+static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct lv_list *lvl;
+
+	if (seg_is_raid(seg)) {
+		return 0;
+	}
+
+	dm_list_iterate_items(lvl, list)
+		break;  /* get first item */
+
+	if (!attach_mirror_log(seg, lvl->lv)) {
+		dm_pool_free(cmd->mem, lvl);
+		return_0;
+	}
+
+	dm_pool_free(cmd->mem, lvl);
+
+	return 1;
+}
+
 static int lvchange_resync(struct cmd_context *cmd,
 			      struct logical_volume *lv)
 {
 	int active = 0;
 	int monitored;
 	struct lvinfo info;
-	struct logical_volume *log_lv;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list device_list;
+	struct lv_list *lvl;
+
+	dm_list_init(&device_list);
 
 	if (!(lv->status & MIRRORED)) {
 		log_error("Unable to resync %s because it is not mirrored.",
@@ -321,21 +365,19 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	init_dmeventd_monitor(monitored);
 
-	log_lv = first_seg(lv)->log_lv;
-
 	log_very_verbose("Starting resync of %s%s%s mirror \"%s\"",
 			 (active) ? "active " : "",
 			 vg_is_clustered(lv->vg) ? "clustered " : "",
-			 (log_lv) ? "disk-logged" : "core-logged",
+			 (seg->log_lv) ? "disk-logged" : "core-logged",
 			 lv->name);
 
 	/*
-	 * If this mirror has a core log (i.e. !log_lv),
+	 * If this mirror has a core log (i.e. !seg->log_lv),
 	 * then simply deactivating/activating will cause
 	 * it to reset the sync status.  We only need to
 	 * worry about persistent logs.
 	 */
-	if (!log_lv) {
+	if (!seg->log_lv) {
 		if (!(lv->status & LV_NOTSYNCED)) {
 			lv->status &= ~LV_NOTSYNCED;
 			log_very_verbose("Updating logical volume \"%s\""
@@ -360,12 +402,17 @@ static int lvchange_resync(struct cmd_context *cmd,
 	 */
 	lv->status &= ~LV_NOTSYNCED;
 
-	/* Separate mirror log so we can clear it */
-	detach_mirror_log(first_seg(lv));
+	/* Separate mirror log or metadata devices so we can clear them */
+	if (!detach_metadata_devices(seg, &device_list)) {
+		log_error("Failed to clear %s %s for %s",
+			  seg->segtype->name, seg_is_raid(seg) ?
+			  "metadata area" : "mirror log", lv->name);
+		return 0;
+	}
 
 	if (!vg_write(lv->vg)) {
 		log_error("Failed to write intermediate VG metadata.");
-		if (!attach_mirror_log(first_seg(lv), log_lv))
+		if (!attach_metadata_devices(seg, &device_list))
 			stack;
 		if (active && !activate_lv(cmd, lv))
 			stack;
@@ -374,7 +421,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	if (!vg_commit(lv->vg)) {
 		log_error("Failed to commit intermediate VG metadata.");
-		if (!attach_mirror_log(first_seg(lv), log_lv))
+		if (!attach_metadata_devices(seg, &device_list))
 			stack;
 		if (active && !activate_lv(cmd, lv))
 			stack;
@@ -383,31 +430,41 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	backup(lv->vg);
 
-	if (!activate_lv(cmd, log_lv)) {
-		log_error("Unable to activate %s for mirror log resync",
-			  log_lv->name);
-		return 0;
-	}
+	dm_list_iterate_items(lvl, &device_list) {
+		if (!activate_lv(cmd, lvl->lv)) {
+			log_error("Unable to activate %s for mirror log resync",
+				  lvl->lv->name);
+			return 0;
+		}
 
-	log_very_verbose("Clearing log device %s", log_lv->name);
-	if (!set_lv(cmd, log_lv, log_lv->size, 0)) {
-		log_error("Unable to reset sync status for %s", lv->name);
-		if (!deactivate_lv(cmd, log_lv))
-			log_error("Failed to deactivate log LV after "
-				  "wiping failed");
-		return 0;
+		log_very_verbose("Clearing %s device %s",
+				 (seg_is_raid(seg)) ? "metadata" : "log",
+				 lvl->lv->name);
+		if (!set_lv(cmd, lvl->lv, lvl->lv->size, 0)) {
+			log_error("Unable to reset sync status for %s",
+				  lv->name);
+			if (!deactivate_lv(cmd, lvl->lv))
+				log_error("Failed to deactivate log LV after "
+					  "wiping failed");
+			return 0;
+		}
+
+		if (!deactivate_lv(cmd, lvl->lv)) {
+			log_error("Unable to deactivate %s LV %s "
+				  "after wiping for resync",
+				  (seg_is_raid(seg)) ? "metadata" : "log",
+				  lvl->lv->name);
+			return 0;
+		}
 	}
 
-	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Unable to deactivate log LV %s after wiping "
-			  "for resync", log_lv->name);
+	/* Put metadata sub-LVs back in place */
+	if (!attach_metadata_devices(seg, &device_list)) {
+		log_error("Failed to reattach %s device after clearing",
+			  (seg_is_raid(seg)) ? "metadata" : "log");
 		return 0;
 	}
 
-	/* Put mirror log back in place */
-	if (!attach_mirror_log(first_seg(lv), log_lv))
-		stack;
-
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 		log_error("Failed to update metadata on disk.");


