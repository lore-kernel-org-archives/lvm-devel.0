From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:47 -0500
Subject: master - activate_lvs: use exclusive activation
Message-ID: <201711151309.vAFD9l8L002007@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=838592a17119814adc5564569ef431fb0000c639
Commit:        838592a17119814adc5564569ef431fb0000c639
Parent:        8212e1047e2f42f4e13e2aadec5cf73b8d3a082e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 14 11:46:43 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:03:22 2017 +0100

activate_lvs: use exclusive activation

There is no need to differentiation between clustered VG and normal VG.
As the activation depends on locking type.

Use unconditionally locally exclusive activation for pvmove.
---
 lib/locking/locking.c |   11 +---
 lib/locking/locking.h |    2 +-
 tools/pvmove.c        |  119 ++++++++----------------------------------------
 3 files changed, 24 insertions(+), 108 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 067cd69..0426744 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -460,19 +460,14 @@ int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv)
 }
 
 /* Lock a list of LVs */
-int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive)
+int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 {
 	struct dm_list *lvh;
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs) {
-		if (!exclusive && !lv_is_active_exclusive(lvl->lv)) {
-			if (!activate_lv(cmd, lvl->lv)) {
-				log_error("Failed to activate %s", lvl->lv->name);
-				return 0;
-			}
-		} else if (!activate_lv_excl(cmd, lvl->lv)) {
-			log_error("Failed to activate %s", lvl->lv->name);
+		if (!activate_lv_excl_local(cmd, lvl->lv)) {
+			log_error("Failed to activate %s", display_lvname(lvl->lv));
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				if (!deactivate_lv(cmd, lvl->lv))
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index d39a725..4b5490e 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -266,6 +266,6 @@ int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
 		struct volume_group *vg_to_revert);
 int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs);
-int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
+int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 
 #endif
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0f54a50..ff36b55 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -64,16 +64,6 @@ static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 	return found;
 }
 
-static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
-				     struct volume_group *vg)
-{
-	if (vg_is_clustered(vg))
-		if (!_pvmove_target_present(cmd, 1))
-			return 1;
-
-	return 0;
-}
-
 /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
 static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 				   const char *arg)
@@ -346,8 +336,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						const char *lv_name,
 						struct dm_list *allocatable_pvs,
 						alloc_policy_t alloc,
-						struct dm_list **lvs_changed,
-						unsigned *exclusive)
+						struct dm_list **lvs_changed)
 {
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_segment *seg;
@@ -555,25 +544,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (vg_is_clustered(vg) && lv_active_count && *exclusive) {
-		log_error("Cannot move in clustered VG %s, "
-			  "clustered mirror (cmirror) not detected "
-			  "and LVs are activated non-exclusively.",
-			  vg->name);
-		return NULL;
-	}
-
-	if (vg_is_clustered(vg) && lv_exclusive_count) {
-		if (lv_active_count) {
-			log_error("Cannot move in clustered VG %s "
-				  "if some LVs are activated "
-				  "exclusively while others don't.",
-				  vg->name);
-			return NULL;
-		}
-		*exclusive = 1;
-	}
-
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
 			    allocatable_pvs, alloc,
 			    (arg_is_set(cmd, atomic_ARG)) ?
@@ -590,83 +560,37 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	return lv_mirr;
 }
 
-static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
-			unsigned exclusive)
-{
-	int r = 0;
-
-	if (exclusive || lv_is_active_exclusive(lv_mirr))
-		r = activate_lv_excl(cmd, lv_mirr);
-	else
-		r = activate_lv(cmd, lv_mirr);
-
-	if (!r)
-		stack;
-
-	return r;
-}
-
 /*
  * Called to set up initial pvmove LV only.
  * (Not called after first or any other section completes.)
  */
-static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
-			    struct logical_volume *lv_mirr,
-			    struct dm_list *lvs_changed, unsigned exclusive)
+static int _update_metadata(struct logical_volume *lv_mirr,
+			    struct dm_list *lvs_changed)
 {
-	int r = 0;
-
-	log_verbose("Setting up pvmove in on-disk volume group metadata.");
-	if (!vg_write(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		return 0;
-	}
-
-	if (!suspend_lvs(cmd, lvs_changed, vg)) {
-		log_error("ABORTING: Temporary pvmove mirror activation failed.");
-		/* FIXME Add a recovery path for first time too. */
-		return 0;
-	}
+	struct lv_list *lvl;
+	struct logical_volume *lv = lv_mirr;
 
-	/* Commit on-disk metadata */
-	if (!vg_commit(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		if (!resume_lvs(cmd, lvs_changed))
-			log_error("Unable to resume logical volumes.");
-		return 0;
+	dm_list_iterate_items(lvl, lvs_changed) {
+		lv = lvl->lv;
+		break;
 	}
 
-	/* Activate the temporary mirror LV */
-	/* Only the first mirror segment gets activated as a mirror */
-	/* FIXME: Add option to use a log */
-	if (!exclusive && _pvmove_is_exclusive(cmd, vg))
-		exclusive = 1;
+	if (!lv_update_and_reload(lv))
+                return_0;
 
-	if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-		if (test_mode()) {
-			r = 1;
-			goto out;
-		}
+	/* Ensure mirror LV is active */
+	if (!activate_lv_excl_local(lv_mirr->vg->cmd, lv_mirr)) {
+		if (test_mode())
+			return 1;
 
 		/*
 		 * FIXME Run --abort internally here.
 		 */
 		log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
-		goto out;
-	}
-
-	r = 1;
-
-out:
-	if (!resume_lvs(cmd, lvs_changed)) {
-		log_error("Unable to resume logical volumes.");
-		r = 0;
+		return 0;
 	}
 
-	if (r)
-		backup(vg);
-
-	return r;
+	return 1;
 }
 
 static int _copy_id_components(struct cmd_context *cmd,
@@ -698,7 +622,6 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	struct logical_volume *lv = NULL;
 	const char *pv_name = pv_dev_name(pv);
 	unsigned flags = PVMOVE_FIRST_TIME;
-	unsigned exclusive;
 	int r = ECMD_FAILED;
 
 	pp->found_pv = 1;
@@ -745,8 +668,6 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 		}
 	}
 
-	exclusive = _pvmove_is_exclusive(cmd, vg);
-
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print_unless_silent("Detected pvmove in progress for %s.", pv_name);
 		if (pp->pv_count || lv_name)
@@ -758,7 +679,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 		}
 
 		/* Ensure mirror LV is active */
-		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
+		if (!activate_lv_excl_local(cmd, lv_mirr)) {
 			log_error("ABORTING: Temporary mirror activation failed.");
 			goto out;
 		}
@@ -783,12 +704,12 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 
 		if (!(lv_mirr = _set_up_pvmove_lv(cmd, vg, source_pvl, lv_name,
 						  allocatable_pvs, pp->alloc,
-						  &lvs_changed, &exclusive)))
+						  &lvs_changed)))
 			goto_out;
 	}
 
 	/* Lock lvs_changed and activate (with old metadata) */
-	if (!activate_lvs(cmd, lvs_changed, exclusive))
+	if (!activate_lvs(cmd, lvs_changed))
 		goto_out;
 
 	/* FIXME Presence of a mirror once set PVMOVE - now remove associated logic */
@@ -799,7 +720,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 		goto out;
 
 	if (flags & PVMOVE_FIRST_TIME)
-		if (!_update_metadata(cmd, vg, lv_mirr, lvs_changed, exclusive))
+		if (!_update_metadata(lv_mirr, lvs_changed))
 			goto_out;
 
 	/* LVs are all in status LOCKED */


