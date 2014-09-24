From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:08 +0000 (UTC)
Subject: master - activate: update lv_check_not_in_use: API
Message-ID: <20140924085708.C9AFB60D58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8aee7dba2b76409d1630edc4f76021b50b08792
Commit:        a8aee7dba2b76409d1630edc4f76021b50b08792
Parent:        c96665e6a88780e31a84f9fb287c2e30c7552b0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 24 10:05:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

activate: update lv_check_not_in_use: API

Use of lv_info() internally in lv_check_not_in_use(),
so it always could use with_open_count properly.

Skip sysfs() testing in open_count == 0 case.

Accept just 'lv' pointer like other functions.

The function has 'built-in' lv_is_active_locally check,
which however is not what we need to check in many place.
For now at least remotely active snapshot merge is
detected and for this case merge on next activation is scheduled.
---
 lib/activate/activate.c |   25 +++++++++++--------------
 lib/activate/activate.h |    3 +--
 lib/metadata/lv_manip.c |    6 ++----
 tools/lvchange.c        |    4 ++--
 tools/lvconvert.c       |   23 +++++++++++++----------
 tools/vgchange.c        |    4 +---
 6 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 82ce6d8..3f9d1a2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -248,8 +248,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 {
 	return 0;
 }
-int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
-			struct lvinfo *info)
+int lv_check_not_in_use(const struct logical_volume *lv)
 {
         return 0;
 }
@@ -695,23 +694,23 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 #define OPEN_COUNT_CHECK_RETRIES 25
 #define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
 
-int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
-			struct lvinfo *info)
+int lv_check_not_in_use(const struct logical_volume *lv)
 {
+	struct lvinfo info;
 	unsigned int open_count_check_retries;
 
-	if (!info->exists || !info->open_count)
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) || !info.exists || !info.open_count)
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
 	if (dm_sysfs_dir()) {
-		if (dm_device_has_holders(info->major, info->minor)) {
+		if (dm_device_has_holders(info.major, info.minor)) {
 			log_error("Logical volume %s/%s is used by another device.",
 				  lv->vg->name, lv->name);
 			return 0;
 		}
 
-		if (dm_device_has_mounted_fs(info->major, info->minor)) {
+		if (dm_device_has_mounted_fs(info.major, info.minor)) {
 			log_error("Logical volume %s/%s contains a filesystem in use.",
 				  lv->vg->name, lv->name);
 			return 0;
@@ -719,7 +718,7 @@ int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv
 	}
 
 	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
-	while (info->open_count > 0 && open_count_check_retries--) {
+	while (info.open_count > 0 && open_count_check_retries--) {
 		if (!open_count_check_retries) {
 			log_error("Logical volume %s/%s in use.",
 				  lv->vg->name, lv->name);
@@ -729,7 +728,7 @@ int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv
 		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
 		log_debug_activation("Retrying open_count check for %s/%s.",
 				     lv->vg->name, lv->name);
-		if (!lv_info(cmd, lv, 0, info, 1, 0)) {
+		if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
 			stack; /* device dissappeared? */
 			break;
 		}
@@ -2104,12 +2103,10 @@ int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
 static int _lv_has_open_snapshots(const struct logical_volume *lv)
 {
 	struct lv_segment *snap_seg;
-	struct lvinfo info;
 	int r = 0;
 
 	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list)
-		if (!lv_info(lv->vg->cmd, snap_seg->cow, 0, &info, 1, 0) ||
-		    !lv_check_not_in_use(lv->vg->cmd, snap_seg->cow, &info))
+		if (!lv_check_not_in_use(snap_seg->cow))
 			r++;
 
 	if (r)
@@ -2140,7 +2137,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	log_debug_activation("Deactivating %s/%s.", lv->vg->name, lv->name);
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0))
+	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists) {
@@ -2150,7 +2147,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||
 	    lv_is_merging_thin_snapshot(lv)) {
-		if (!lv_check_not_in_use(cmd, lv, &info))
+		if (!lv_check_not_in_use(lv))
 			goto_out;
 
 		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 17648fc..4f32bca 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -95,8 +95,7 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
-int lv_check_not_in_use(struct cmd_context *cmd, const struct logical_volume *lv,
-			struct lvinfo *info);
+int lv_check_not_in_use(const struct logical_volume *lv);
 
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 81cc997..70e8013 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5363,7 +5363,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     force_t force, int suppress_remove_message)
 {
 	struct volume_group *vg;
-	struct lvinfo info;
 	struct logical_volume *format1_origin = NULL;
 	int format1_reload_required = 0;
 	int visible;
@@ -5422,9 +5421,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (!lv_is_cache_pool(lv) &&
-	    lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (!lv_check_not_in_use(cmd, lv, &info))
+	if (!lv_is_cache_pool(lv) && lv_is_active_locally(lv)) {
+		if (!lv_check_not_in_use(lv))
 			return_0;
 
 		if ((force == PROMPT) &&
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e520157..7497bde 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -304,8 +304,8 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (!lv_check_not_in_use(cmd, lv, &info)) {
+	if (lv_is_active_locally(lv)) {
+		if (!lv_check_not_in_use(lv)) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
 			return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9f9ec5d..1b71866 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1929,7 +1929,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow,
 				    struct lvconvert_params *lp)
 {
-	struct lvinfo info;
 	struct volume_group *vg = cow->vg;
 
 	if (!lv_is_cow(cow)) {
@@ -1970,8 +1969,8 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return ECMD_FAILED;
 	}
 
-	if (lv_info(cmd, cow, 0, &info, 1, 0)) {
-		if (!lv_check_not_in_use(cmd, cow, &info))
+	if (lv_is_active_locally(cow)) {
+		if (!lv_check_not_in_use(cow))
 			return_ECMD_FAILED;
 
 		if ((lp->force == PROMPT) &&
@@ -2165,13 +2164,17 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	 * constructor and DM should prevent appropriate devices from
 	 * being open.
 	 */
-	if (lv_info(cmd, origin, 0, &info, 1, 0) &&
-	    !lv_check_not_in_use(cmd, origin, &info)) {
-		log_print_unless_silent("Can't merge over open origin volume.");
-		merge_on_activate = 1;
-	} else if (lv_info(cmd, lv, 0, &info, 1, 0) &&
-		   !lv_check_not_in_use(cmd, lv, &info)) {
-		log_print_unless_silent("Can't merge when snapshot is open.");
+	if (lv_is_active_locally(origin)) {
+		if (!lv_check_not_in_use(origin)) {
+			log_print_unless_silent("Can't merge over open origin volume.");
+			merge_on_activate = 1;
+		} else if (!lv_check_not_in_use(lv)) {
+			log_print_unless_silent("Can't merge when snapshot is open.");
+			merge_on_activate = 1;
+		}
+	} else if (vg_is_clustered(origin->vg) && lv_is_active(origin)) {
+		/* When it's active somewhere else */
+		log_print_unless_silent("Can't check whether remotely active snapshot is open.");
 		merge_on_activate = 1;
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 350d8a3..1a597a6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -197,7 +197,6 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int lv_open, active, monitored = 0, r = 1;
 	const struct lv_list *lvl;
-	struct lvinfo info;
 	int do_activate = is_change_activating(activate);
 
 	/*
@@ -210,8 +209,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	if (!do_activate && (lv_open = lvs_in_vg_opened(vg))) {
 		dm_list_iterate_items(lvl, &vg->lvs)
 			if (lv_is_visible(lvl->lv) &&
-			    lv_info(cmd, lvl->lv, 0, &info, 1, 0) &&
-			    !lv_check_not_in_use(cmd, lvl->lv, &info)) {
+			    !lv_check_not_in_use(lvl->lv)) {
 				log_error("Can't deactivate volume group \"%s\" with %d open "
 					  "logical volume(s)", vg->name, lv_open);
 				return 0;


