From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 14 Aug 2023 15:03:13 +0000
Subject: [Git][lvmteam/lvm2][main] 9 commits: lvconvert: preserve UUID for swapped metadata
Message-ID: <64da42312bc10_28a84441c3@gitlab-sidekiq-low-urgency-cpu-bound-v2-7c94898c65-ms5gq.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
ac36153e by Zdenek Kabelac at 2023-08-14T17:02:09+02:00
lvconvert: preserve UUID for swapped metadata

When swapping metadata LV for a pool volume, preserve UUID for metadata
LV during the swap - this allows to better utilise locks with lvmlockd.

- - - - -
80377eeb by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: preserve UUID on pool repair

Once lvm2 repairs pool&#39;s metadata LV and preserves the original metadata LV
with unmodified metadata, for such LV in VG use newly created UUID for new
_pmspare and actually preserve UUID for this hidden _pmspare (if it
exists).

- - - - -
0b7239eb by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: fix ret values fro integrity remove

Fix return value from _lvconvert_integrity_remove()
as it is expected to match _add() and be 0/1.

Also add some missing log_error() messages.

- - - - -
2f3d8659 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
commands: add lv_is_writable

- - - - -
23019946 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
lvconvert: vdo needs writable LV

- - - - -
741a166f by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: use common error exit path

- - - - -
ee6519f8 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: use just single label

- - - - -
b764665f by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
debug: add missing log_error

Report error with failure.

- - - - -
060491c4 by Zdenek Kabelac at 2023-08-14T17:02:11+02:00
WHATS_NEW: update

- - - - -


7 changed files:

- WHATS_NEW
- lib/locking/lvmlockd.c
- lib/metadata/metadata-exported.h
- tools/command-lines.in
- tools/lv_props.h
- tools/lvconvert.c
- tools/toollib.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,9 @@
 version 2.03.23 - 
 ==================================
+  Require writable LV for convertion to vdo pool.
+  Fix return value from lvconvert integrity remove.
+  Preserve UUID for pool metadata spare.
+  Preserve UUID for swapped pool metadata.
 
 version 2.03.22 - 02nd August 2023
 ==================================


=====================================
lib/locking/lvmlockd.c
=====================================
@@ -1030,10 +1030,14 @@ static int _busy_vg(struct cmd_context *cmd, struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!_use_lvmlockd)
+	if (!_use_lvmlockd) {
+		log_error("Lvmlockd is not in use.");
 		return 0;
-	if (!_lvmlockd_connected)
+	}
+	if (!_lvmlockd_connected) {
+		log_error("Lvmlockd is not connected.");
 		return 0;
+	}
 
 	/*
 	 * Check that other hosts do not have the VG lockspace started.
@@ -1085,10 +1089,14 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!_use_lvmlockd)
+	if (!_use_lvmlockd) {
+		log_error("Cannot free VG sanlock, lvmlockd is not in use.");
 		return 0;
-	if (!_lvmlockd_connected)
+	}
+	if (!_lvmlockd_connected) {
+		log_error("Cannot free VG sanlock, lvmlockd is not connected.");
 		return 0;
+	}
 
 	/*
 	 * vgremove originally held the global lock, but lost it because the


=====================================
lib/metadata/metadata-exported.h
=====================================
@@ -220,6 +220,7 @@
 #define lv_is_locked(lv)	(((lv)->status & LOCKED) ? 1 : 0)
 #define lv_is_partial(lv)	(((lv)->status & PARTIAL_LV) ? 1 : 0)
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
+#define lv_is_writable(lv)	(((lv)->status & LVM_WRITE) ? 1 : 0)
 #define lv_is_merging(lv)	(((lv)->status & MERGING) ? 1 : 0)
 #define lv_is_merging_origin(lv) (lv_is_merging(lv) && (lv)->snapshot)
 #define lv_is_snapshot(lv)	(((lv)->status & SNAPSHOT) ? 1 : 0)


=====================================
tools/command-lines.in
=====================================
@@ -657,7 +657,7 @@ lvconvert --type vdo-pool LV_linear_striped_raid_cache
 OO: --name LV_new, --virtualsize SizeMB, OO_LVCONVERT_VDO, OO_LVCONVERT
 ID: lvconvert_to_vdopool
 DESC: Convert LV to type vdopool.
-RULE: all and lv_is_visible
+RULE: all and lv_is_visible lv_is_writable
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 
 lvconvert --vdopool LV_linear_striped_raid_cache


=====================================
tools/lv_props.h
=====================================
@@ -25,6 +25,7 @@ lvp(is_error_when_full_LVP, "lv_is_error_when_full", NULL)
 lvp(is_pvmove_LVP, "lv_is_pvmove", NULL)
 lvp(is_removed_LVP, "lv_is_removed", NULL)
 lvp(is_vg_writable_LVP, "lv_is_vg_writable", NULL)
+lvp(is_writable_LVP, "lv_is_writable", NULL)
 
 /* kinds of sub LV */
 lvp(is_thinpool_data_LVP, "lv_is_thinpool_data", NULL)


=====================================
tools/lvconvert.c
=====================================
@@ -2332,6 +2332,17 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	return 1;
 }
 
+static void _swap_lv_uuid(struct logical_volume *lv1, struct logical_volume *lv2)
+{
+	union lvid lvid;
+
+	if (lv1 && lv2) {
+		lvid = lv1->lvid;
+		lv1->lvid = lv2->lvid;
+		lv2->lvid = lvid;
+	}
+}
+
 static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 				       struct logical_volume *pool_lv,
 				       struct dm_list *pvh, int poolmetadataspare)
@@ -2500,6 +2511,9 @@ deactivate_pmslv:
 	if (!lv_rename_update(cmd, mlv, pms_path, 0))
 		return_0;
 
+	/* Preserve UUID for _pmspare if possible */
+	_swap_lv_uuid(mlv, mlv->vg->pool_metadata_spare_lv);
+
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
@@ -2657,6 +2671,9 @@ deactivate_pmslv:
 	if (!lv_rename_update(cmd, mlv, pms_path, 0))
 		return_0;
 
+	/* Preserve UUID for _pmspare if possible */
+	_swap_lv_uuid(mlv, mlv->vg->pool_metadata_spare_lv);
+
 	if (!vg_write(cache_lv->vg) || !vg_commit(cache_lv->vg))
 		return_0;
 
@@ -2955,20 +2972,8 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	if (!detach_pool_metadata_lv(seg, &prev_metadata_lv))
 		return_0;
 
-	swap_name = metadata_lv->name;
-
-	if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
-		return_0;
-
-	/* Give the previous metadata LV the name of the LV replacing it. */
-
-	if (!lv_rename_update(cmd, prev_metadata_lv, swap_name, 0))
-		return_0;
-
-	/* Rename deactivated metadata LV to have _tmeta suffix */
-
-	if (!lv_rename_update(cmd, metadata_lv, meta_name, 0))
-		return_0;
+	if (!swap_lv_identifiers(cmd, metadata_lv, prev_metadata_lv))
+                return_0;
 
 	if (!attach_pool_metadata_lv(seg, metadata_lv))
 		return_0;
@@ -6297,7 +6302,7 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	if (!_writecache_zero(cmd, lv_fast)) {
 		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	/*
@@ -6307,10 +6312,10 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 */
 	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", lv_fast->name) < 0) {
 		log_error("Can't prepare new metadata name for %s.", display_lvname(lv_fast));
-		return ECMD_FAILED;
+		goto bad;
 	}
 	if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
-		return_ECMD_FAILED;
+		goto_bad;
 
 	lv_fast->status |= LV_CACHE_VOL;
 
@@ -6410,24 +6415,26 @@ int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char
 
 static int _lvconvert_integrity_remove(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	int ret = 0;
-
-	if (!lv_is_integrity(lv) && !lv_is_raid(lv)) {
+	if (!lv_is_integrity(lv)) {
 		log_error("LV does not have integrity.");
-		return ECMD_FAILED;
+		return 0;
+	}
+
+	if (!lv_is_raid(lv)) {
+		log_error("Cannot remove integrity from non raid type LV %s.",
+			  display_lvname(lv));
+		return 0;
 	}
 
 	/* ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
-		return_ECMD_FAILED;
+		return_0;
 
-	if (lv_is_raid(lv))
-		ret = lv_remove_integrity_from_raid(lv);
-	if (!ret)
-		return_ECMD_FAILED;
+	if (!lv_remove_integrity_from_raid(lv))
+		return_0;
 
 	log_print_unless_silent("Logical volume %s has removed integrity.", display_lvname(lv));
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _lvconvert_integrity_add(struct cmd_context *cmd, struct logical_volume *lv,
@@ -6435,7 +6442,6 @@ static int _lvconvert_integrity_add(struct cmd_context *cmd, struct logical_volu
 {
 	struct volume_group *vg = lv->vg;
 	struct dm_list *use_pvh;
-	int ret = 0;
 
 	/* ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
@@ -6453,9 +6459,13 @@ static int _lvconvert_integrity_add(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
-	if (lv_is_raid(lv))
-		ret = lv_add_integrity_to_raid(lv, set, use_pvh, NULL);
-	if (!ret)
+	if (!lv_is_raid(lv)) {
+		log_error("Cannot add integrity to non raid type LV %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!lv_add_integrity_to_raid(lv, set, use_pvh, NULL))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s has added integrity.", display_lvname(lv));
@@ -6466,10 +6476,8 @@ static int _lvconvert_integrity_single(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct processing_handle *handle)
 {
-	struct integrity_settings settings;
-	int ret = 0;
-
-	memset(&settings, 0, sizeof(settings));
+	struct integrity_settings settings = { 0 };
+	int ret;
 
 	if (!integrity_mode_set(arg_str_value(cmd, raidintegritymode_ARG, NULL), &settings))
 		return_ECMD_FAILED;
@@ -6483,7 +6491,8 @@ static int _lvconvert_integrity_single(struct cmd_context *cmd,
 		ret = _lvconvert_integrity_remove(cmd, lv);
 
 	if (!ret)
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 


=====================================
tools/toollib.c
=====================================
@@ -2714,6 +2714,8 @@ static int _lv_is_prop(struct cmd_context *cmd, struct logical_volume *lv, int l
 		return lv_is_pvmove(lv);
 	case is_removed_LVP:
 		return lv_is_removed(lv);
+	case is_writable_LVP:
+		return lv_is_writable(lv);
 	case is_vg_writable_LVP:
 		return (lv->vg->status & LVM_WRITE) ? 1 : 0;
 	case is_thinpool_data_LVP:
@@ -5704,13 +5706,13 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		}
 
 		if (!dm_list_empty(&pp->arg_fail) && must_use_all)
-			goto_out;
+			goto_bad;
 
 		if (sigint_caught())
-			goto_out;
+			goto_bad;
 
 		if (prompt->abort_command)
-			goto_out;
+			goto_bad;
 	}
 
 	/*
@@ -5723,7 +5725,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	if (!lockf_global_nonblock(cmd, "ex")) {
 		log_error("Failed to reacquire global lock after prompt.");
-		goto_out;
+		goto bad;
 	}
 
 do_command:
@@ -5983,10 +5985,9 @@ do_command:
 			  cmd->command->name, pd->name);
 
 	if (!dm_list_empty(&pp->arg_fail))
-		goto_out;
+		goto_bad;
 
 	return 1;
 bad:
-out:
 	return 0;
 }



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/2928891bd00bce8d880f8c3a6aec430a57c49377...060491c4ee9863b594873483019f13f695d8b7b8

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/2928891bd00bce8d880f8c3a6aec430a57c49377...060491c4ee9863b594873483019f13f695d8b7b8
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230814/577ca1e8/attachment-0001.htm>
