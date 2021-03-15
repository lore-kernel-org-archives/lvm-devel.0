From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:12 +0000 (GMT)
Subject: main - lvremove: use common routine for prompting
Message-ID: <20210315101412.A08C93858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a2d7c57a1120045e1a93a63bc568dc1e3dbb734
Commit:        0a2d7c57a1120045e1a93a63bc568dc1e3dbb734
Parent:        a18409b6d1d6a90e432b0b0079ce702d0055fa5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 13:17:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:08:47 2021 +0100

lvremove: use common routine for prompting

Move code for prompting about removed LV to a single function
and use it also to prompt for removal of origin and all its thick
snapshots and also when removing merging origin.

Function does handle postponed write_and_commit so there is
no 'in-flight' operation while waiting on [y|n] answer.
---
 lib/metadata/lv_manip.c | 136 +++++++++++++++++++++++++++---------------------
 1 file changed, 76 insertions(+), 60 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ec8704ce7..1d341eea2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6527,6 +6527,65 @@ void lv_set_hidden(struct logical_volume *lv)
 	log_debug_metadata("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
 }
 
+static int _lv_remove_check_in_use(struct logical_volume *lv, force_t force)
+{
+	struct volume_group *vg = lv->vg;
+	const char *volume_type = "";
+	char buffer[50 * NAME_LEN * 2] = "";
+	int active;
+	int issue_discards =
+		(vg->cmd->current_settings.issue_discards &&
+		 !lv_is_thin_volume(lv) &&
+		 !lv_is_vdo(lv) &&
+		 !lv_is_virtual_origin(lv)) ? 1 : 0;
+
+	switch (lv_check_not_in_use(lv, 1)) {
+	case 2: /* Not active, prompt when discarding real LVs */
+		if (!issue_discards ||
+		    lv_is_historical(lv))
+			return 1;
+		active = 0;
+		break;
+	case 1: /* Active, not in use, prompt when visible */
+		if (!lv_is_visible(lv) ||
+		    lv_is_pending_delete(lv))
+			return 1;
+		active = 1;
+		break;
+	default: /* Active, in use, can't remove */
+		return_0;
+	}
+
+	if (force == PROMPT) {
+		if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
+			return_0;
+
+		if (lv_is_origin(lv)) {
+			volume_type = " origin";
+			(void) dm_snprintf(buffer, sizeof(buffer), " with %u snapshots(s)",
+					   lv->origin_count);
+		} else if (lv_is_merging_origin(lv)) {
+			volume_type = " merging origin";
+			(void) dm_snprintf(buffer, sizeof(buffer), " with snapshot %s",
+					   display_lvname(find_snapshot(lv)->lv));
+		}
+
+		if (yes_no_prompt("Do you really want to remove%s%s%s%s "
+				  "logical volume %s%s? [y/n]: ",
+				  issue_discards ? " and DISCARD" : "",
+				  active ? " active" : "",
+				  vg_is_clustered(vg) ? " clustered" : "",
+				  volume_type, display_lvname(lv),
+				  buffer) == 'n') {
+			lv->to_remove = 0;
+			log_error("Logical volume %s not removed.", display_lvname(lv));
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     force_t force, int suppress_remove_message)
 {
@@ -6535,7 +6594,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *lock_lv = lv;
 	struct lv_segment *cache_seg = NULL;
-	int ask_discard;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
 	char msg[NAME_LEN + 300], *msg_dup;
@@ -6602,31 +6660,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv(cmd, lock_lv, "ex", LDLV_PERSISTENT))
 		return_0;
 
-	/* FIXME Ensure not referred to by another existing LVs */
-	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
-
 	if (!lv_is_cache_vol(lv)) {
-		switch (lv_check_not_in_use(lv, 1)) {
-		case 0: return_0;
-		case 1: /* Active, not in use */
-			if ((force == PROMPT) &&
-			    !lv_is_pending_delete(lv) &&
-			    lv_is_visible(lv)) {
-				if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
-					return_0;
-				if (yes_no_prompt("Do you really want to remove%s active "
-						  "%slogical volume %s? [y/n]: ",
-						  ask_discard ? " and DISCARD" : "",
-						  vg_is_clustered(vg) ? "clustered " : "",
-						  display_lvname(lv)) == 'n') {
-					log_error("Logical volume %s not removed.", display_lvname(lv));
-					return 0;
-				}
-				ask_discard = 0;
-			}
-			break;
-		default: /* Not active */ ;
-		}
+		if (!_lv_remove_check_in_use(lv, force))
+			return_0;
 	}
 
 	if (lv_is_writecache(lv)) {
@@ -6651,17 +6687,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard) {
-		/* try to store on disks already confirmed removals */
-		if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
-			return_0;
-		if (yes_no_prompt("Do you really want to remove and DISCARD "
-				  "logical volume %s? [y/n]: ",
-				  display_lvname(lv)) == 'n') {
-			log_error("Logical volume %s not removed.", display_lvname(lv));
-			return 0;
-		}
-	}
 
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if (!lv_is_used_cache_pool(lv) &&
@@ -6872,20 +6897,12 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 
 	if (lv_is_origin(lv)) {
 		/* Remove snapshot LVs first */
-		if ((force == PROMPT) &&
-		    /* Active snapshot already needs to confirm each active LV */
-		    (yes_no_prompt("Do you really want to remove%s "
-				   "%sorigin logical volume %s with %u snapshot(s)? [y/n]: ",
-				   lv_is_active(lv) ? " active" : "",
-				   vg_is_clustered(lv->vg) ? "clustered " : "",
-				   display_lvname(lv),
-				   lv->origin_count) == 'n'))
-			goto no_remove;
+		if (!_lv_remove_check_in_use(lv, force))
+			return_0;
 
-		if (!deactivate_lv(cmd, lv)) {
-			stack;
+		if (!deactivate_lv(cmd, lv))
 			goto no_remove;
-		}
+
 		log_verbose("Removing origin logical volume %s with %u snapshots(s).",
 			    display_lvname(lv), lv->origin_count);
 
@@ -6894,20 +6911,19 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 										  origin_list)->cow,
 							 force, level + 1))
 				return_0;
-	}
+	} else if (lv_is_merging_origin(lv)) {
+		/* Removing thin merging origin requires to remove its merging snapshot first */
+		if (!_lv_remove_check_in_use(lv, force))
+			return_0;
+
+		if (!deactivate_lv(cmd, lv))
+			goto no_remove;
+
+		log_verbose("Removing merging origin logical volume %s.", display_lvname(lv));
 
-	if (lv_is_merging_origin(lv)) {
-		if (!deactivate_lv(cmd, lv)) {
-			log_error("Unable to fully deactivate merging origin %s.",
-				  display_lvname(lv));
-			return 0;
-		}
 		if (!lv_remove_with_dependencies(cmd, find_snapshot(lv)->lv,
-						 force, level + 1)) {
-			log_error("Unable to remove merging origin %s.",
-				  display_lvname(lv));
-			return 0;
-		}
+						 force, level + 1))
+			return_0;
 	}
 
 	if (!level && lv_is_merging_thin_snapshot(lv)) {


