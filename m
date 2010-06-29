From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:08 +0200
Subject: [PATCH 08/12] Replicator: lv_manip - create replicator
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <3bc31d8b591d1c7896625761ddbf9437ff7943b6.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |  126 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 125 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5e4a674..b817eb5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -418,6 +418,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 			/* FIXME Check this is safe */
 			if (seg->log_lv && !lv_remove(seg->log_lv))
 				return_0;
+			if (seg->rlog_lv && !lv_remove(seg->rlog_lv))
+				return_0;
 			dm_list_del(&seg->list);
 			reduction = seg->len;
 		} else
@@ -2205,6 +2207,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
+	struct logical_volume *replicator = NULL;
 	int was_merging = 0;
 
 	vg = lv->vg;
@@ -2230,6 +2233,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_rimage(lv) || lv_is_rlog(lv) || lv_is_slog(lv)) {
+		log_error("Can't remove logical volume %s used by a "
+			  "replicator.", lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
@@ -2267,6 +2276,14 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 	}
 
+	if (lv_is_replicator_dev(lv)) {
+                replicator = first_seg(lv)->replicator;
+		if (!lv_remove_replicator_dev(lv)) {
+			log_error("Unable to remove replicator-dev %s", lv->name);
+			return 0;
+		}
+	}
+
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",
 			  lv->name);
@@ -2295,6 +2312,17 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (replicator) {
+		if (!suspend_lv(cmd, replicator)) {
+			log_error("Failed to refresh replicator %s.", replicator->name);
+			return 0;
+		}
+		if (!resume_lv(cmd, replicator)) {
+			log_error("Failed to resume replicator %s.", replicator->name);
+			return 0;
+		}
+	}
+
 	backup(vg);
 
 	if (lv_is_visible(lv))
@@ -2310,6 +2338,8 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 				const force_t force, unsigned level)
 {
 	struct dm_list *snh, *snht;
+	struct replicator_site *rsite;
+	struct replicator_device *rdev;
 
 	if (lv_is_cow(lv)) {
 		/* A merging snapshot cannot be removed directly */
@@ -2320,6 +2350,18 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		}
 	}
 
+	if (lv_is_replicator(lv)) {
+		/* Remove replicators' head LVs first */
+		dm_list_iterate_items(rsite, &lv->rsites) {
+			if (rsite->site_index != 0)
+				continue;
+			dm_list_iterate_items(rdev, &rsite->rdevices)
+				if (!lv_remove_with_dependencies(cmd, rdev->lv,
+								 force, level + 1))
+					return_0;
+		}
+	}
+
 	if (lv_is_origin(lv)) {
 		/* remove snapshot LVs first */
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
@@ -2998,6 +3040,7 @@ int lv_create_single(struct volume_group *vg,
 	struct logical_volume *lv, *org = NULL;
 	int origin_active = 0;
 	struct lvinfo info;
+	struct logical_volume *replicator;
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -3118,6 +3161,13 @@ int lv_create_single(struct volume_group *vg,
 		}
 	}
 
+	if (lp->replicator) {
+		if (!vg_prepare_replicator(vg, lp))
+			return_0;
+		if (lp->rsite.name && !lp->replicator_dev)
+			return 1; /* Do not create any LV this time */
+	}
+
 	if (!lp->extents) {
 		log_error("Unable to create new logical volume with no extents");
 		return 0;
@@ -3169,6 +3219,19 @@ int lv_create_single(struct volume_group *vg,
 		}
 	}
 
+	if (lp->replicator_dev) {
+		init_replicator_in_sync(lp->nosync);
+
+		if (lp->nosync) {
+			log_error("FIXME: Unsupported.");
+			return 0;
+
+			log_warn("WARNING: New replicator won't be synchronised. "
+				  "Don't read what you didn't write!");
+			status |= REPLICATOR_NOTSYNCED;
+		}
+	}
+
 	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
 				   status, lp->alloc, vg)))
 		return_0;
@@ -3225,6 +3288,12 @@ int lv_create_single(struct volume_group *vg,
 				  "exception store.");
 			goto revert_new_lv;
 		}
+	} else if (lp->replicator_dev || lp->replicator) {
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Aborting. Failed to activate replicator "
+				  "device.");
+			goto revert_new_lv;
+		}
 	} else if (!activate_lv(cmd, lv)) {
 		if (lp->zero) {
 			log_error("Aborting. Failed to activate new LV to wipe "
@@ -3240,10 +3309,65 @@ int lv_create_single(struct volume_group *vg,
 	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe %s.",
 			  lp->snapshot ? "snapshot exception store" :
-					 "start of new LV");
+			  lp->replicator ? "replicator backing store" :
+					   "start of new LV");
 		goto deactivate_and_revert_new_lv;
 	}
 
+	if (!lp->replicator_dev && lp->replicator) {
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Couldn't deactivate replicator log."
+				  " Manual intervention required.");
+			return 0;
+		}
+		if (!vg_add_replicator(lv, lp->rlog_type, lp->region_size)) {
+			log_error("Could not create replicator.");
+			goto revert_new_lv;
+		}
+		/* store vg on disk(s) */
+		if (!vg_write(vg) || !vg_commit(vg))
+			return_0;
+	}
+
+	if (lp->replicator_dev) {
+		if (!lp->replicator) {
+			log_error("Replicator is not specified.");
+			return 0;
+		}
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Could not deactivate new LV.");
+			return 0;
+		}
+
+		if (!(replicator = find_lv(vg, lp->replicator))) {
+			log_error("Could not find replicator.");
+			goto revert_new_lv;
+		}
+
+		if (!lv_add_replicator_dev(replicator, lv)) {
+			log_error("Could not insert replicator device to replicator.");
+			goto revert_new_lv;
+		}
+
+		/* store vg on disk(s) */
+		if (!vg_write(vg))
+			return_0;
+
+		if (!suspend_lv(cmd, replicator)) {
+			log_error("Failed to suspend replicator %s", replicator->name);
+			vg_revert(vg);
+			return 0;
+		}
+
+		if (!vg_commit(vg))
+			return_0;
+
+		if (!resume_lv(cmd, replicator)) {
+			log_error("Problem reactivating replicator %s", replicator->name);
+			return 0;
+		}
+	}
+
 	if (lp->snapshot) {
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
-- 
1.7.1


