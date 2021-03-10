From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:31 +0000 (GMT)
Subject: main - cleanup: no backtraces needed after log_error
Message-ID: <20210310003631.DF5AE3858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f7a7af7f201fea454bc4200bc76c4c75ef95463
Commit:        5f7a7af7f201fea454bc4200bc76c4c75ef95463
Parent:        c05077f4d4534fd0f63a9642b596262843f81e30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 11:42:29 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:11:52 2021 +0100

cleanup: no backtraces needed after log_error

Reduce double backtracing.
---
 lib/integrity/integrity.c      |  2 +-
 lib/metadata/integrity_manip.c | 26 +++++++++++++-------------
 lib/metadata/lv_manip.c        |  6 +++---
 lib/metadata/metadata.c        |  9 +++------
 lib/metadata/pv_list.c         |  8 +++++---
 lib/metadata/raid_manip.c      |  8 ++++----
 tools/lvchange.c               |  2 +-
 tools/lvconvert.c              | 16 ++++++++--------
 tools/lvmdevices.c             |  6 +++---
 tools/pvck.c                   |  2 +-
 tools/pvscan.c                 |  2 +-
 tools/toollib.c                |  4 ++--
 12 files changed, 45 insertions(+), 46 deletions(-)

diff --git a/lib/integrity/integrity.c b/lib/integrity/integrity.c
index 7423e04ae..e4f99b400 100644
--- a/lib/integrity/integrity.c
+++ b/lib/integrity/integrity.c
@@ -294,7 +294,7 @@ static int _integrity_add_target_line(struct dev_manager *dm,
 
 	if (!seg->integrity_data_sectors) {
 		log_error("_integrity_add_target_line zero size");
-		return_0;
+		return 0;
 	}
 
 	if (!dm_tree_node_add_integrity_target(node, seg->integrity_data_sectors,
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index abf90d850..4fbccfb3c 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -332,20 +332,20 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 
 	if (lbs_4k && lbs_512) {
 		log_error("Integrity requires consistent logical block size for LV devices.");
-		goto_bad;
+		goto bad;
 	}
 
 	if (settings->block_size &&
 	    (settings->block_size != 512 && settings->block_size != 1024 &&
 	     settings->block_size != 2048 && settings->block_size != 4096)) {
 		log_error("Invalid integrity block size, possible values are 512, 1024, 2048, 4096");
-		goto_bad;
+		goto bad;
 	}
 
 	if (lbs_4k && settings->block_size && (settings->block_size < 4096)) {
 		log_error("Integrity block size %u not allowed with device logical block size 4096.",
 			  settings->block_size);
-		goto_bad;
+		goto bad;
 	}
 
 	if (!strcmp(cmd->name, "lvcreate")) {
@@ -369,11 +369,11 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		if (dm_snprintf(pathname, sizeof(pathname), "%s%s/%s", cmd->dev_dir,
 				lv->vg->name, lv->name) < 0) {
 			log_error("Path name too long to get LV block size %s", display_lvname(lv));
-			goto_bad;
+			goto bad;
 		}
 		if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
 			log_error("Device for LV not found to check block size %s", display_lvname(lv));
-			goto_bad;
+			goto bad;
 		}
 
 		/*
@@ -435,7 +435,7 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 			if (settings->block_size > fs_block_size) {
 				log_error("Integrity block size %u cannot be larger than file system block size %u.",
 					  settings->block_size, fs_block_size);
-				goto_bad;
+				goto bad;
 			}
 			log_print("Using integrity block size %u for file system block size %u.",
 				  settings->block_size, fs_block_size);
@@ -550,7 +550,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 
 		if (!seg_is_striped(first_seg(lv_image))) {
 			log_error("raid image must be linear to add integrity");
-			goto_bad;
+			goto bad;
 		}
 
 		/*
@@ -570,7 +570,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 
 		if (!get_pv_list_for_lv(cmd->mem, lv_image, &allocatable_pvs)) {
 			log_error("Failed to build list of PVs for %s.", display_lvname(lv_image));
-			goto_bad;
+			goto bad;
 		}
 
 		dm_list_iterate_items(pvl, &allocatable_pvs) {
@@ -620,19 +620,19 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 
 		if (!activate_lv(cmd, meta_lv)) {
 			log_error("Failed to activate LV %s to zero", display_lvname(meta_lv));
-			goto_bad;
+			goto bad;
 		}
 
 		if (!wipe_lv(meta_lv, wipe)) {
 			log_error("Failed to zero LV for integrity metadata %s", display_lvname(meta_lv));
 			if (deactivate_lv(cmd, meta_lv))
 				log_error("Failed to deactivate LV %s after zero", display_lvname(meta_lv));
-			goto_bad;
+			goto bad;
 		}
 
 		if (!deactivate_lv(cmd, meta_lv)) {
 			log_error("Failed to deactivate LV %s after zero", display_lvname(meta_lv));
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -726,7 +726,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 		/* vg_write(), suspend_lv(), vg_commit(), resume_lv() */
 		if (!lv_update_and_reload(lv)) {
 			log_error("LV update and reload failed");
-			goto_bad;
+			goto bad;
 		}
 		revert_meta_lvs = 0;
 
@@ -747,7 +747,7 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 
 		if (!activate_lv(cmd, lv)) {
 			log_error("Failed to activate integrity LV to initialize.");
-			goto_bad;
+			goto bad;
 		}
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2ecd45eb1..74a34c9cd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1367,7 +1367,7 @@ int add_lv_segment_areas(struct lv_segment *seg, uint32_t new_area_count)
 	if (!(newareas = dm_pool_zalloc(seg->lv->vg->vgmem, areas_sz))) {
 		log_error("Failed to allocate widened LV segment for %s.",
 			  display_lvname(seg->lv));
-		return_0;
+		return 0;
 	}
 
 	if (seg->area_count)
@@ -4359,12 +4359,12 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 
 			if (!(lv_imeta = seg_image->integrity_meta_dev)) {
 				log_error("1");
-				return_0;
+				return 0;
 			}
 
 			if (!(lv_iorig = seg_lv(seg_image, 0))) {
 				log_error("2");
-				return_0;
+				return 0;
 			}
 
 			/* new size in sectors */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 22cb78337..f82ada8be 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2682,15 +2682,13 @@ int vg_validate(struct volume_group *vg)
 	}
 
 	if (!(vhash.historical_lvname = dm_hash_create(dm_list_size(&vg->historical_lvs)))) {
-		log_error("Failed to allocate historical LV name hash");
 		r = 0;
-		goto out;
+		goto_out;
 	}
 
         if (!(vhash.historical_lvid = dm_hash_create(dm_list_size(&vg->historical_lvs)))) {
-                log_error("Failed to allocate historical LV uuid hash");
                 r = 0;
-                goto out;
+                goto_out;
         }
 
 	dm_list_iterate_items(glvl, &vg->historical_lvs) {
@@ -3043,8 +3041,7 @@ int vg_write(struct volume_group *vg)
 		}
 
 		if (!mda->ops->vg_write) {
-			log_error("Format does not support writing volume"
-				  "group metadata areas");
+			log_error("Format does not support writing volume group metadata areas.");
 			revert = 1;
 			break;
 		}
diff --git a/lib/metadata/pv_list.c b/lib/metadata/pv_list.c
index 143b573b6..813e8e525 100644
--- a/lib/metadata/pv_list.c
+++ b/lib/metadata/pv_list.c
@@ -258,10 +258,12 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 			return_NULL;
 	}
 
-	if (dm_list_empty(r))
+	if (dm_list_empty(r)) {
 		log_error("No specified PVs have space available.");
+		return NULL;
+	}
 
-	return dm_list_empty(r) ? NULL : r;
+	return r;
 }
 
 struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
@@ -277,7 +279,7 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 	dm_list_init(r);
 
 	dm_list_iterate_items(pvl, pvsl) {
-		if (!(new_pvl = dm_pool_zalloc(mem, sizeof(*new_pvl)))) {
+		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
 			log_error("Unable to allocate physical volume list.");
 			return NULL;
 		}
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3b3e1d373..9c57e8b88 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -356,12 +356,12 @@ static int _get_dev_health(struct logical_volume *lv, uint32_t *kernel_devs,
 
 	if (!lv_raid_dev_count(lv, kernel_devs)) {
 		log_error("Failed to get device count.");
-		return_0;
+		return 0;
 	}
 
 	if (!lv_raid_dev_health(lv, &rh)) {
 		log_error("Failed to get device health.");
-		return_0;
+		return 0;
 	}
 
 	d = (unsigned) strlen(rh);
@@ -1056,7 +1056,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
 					sizeof(*lvl_array) * count * 2))) {
 		log_error("Memory allocation failed.");
-		return_0;
+		return 0;
 	}
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
@@ -2186,7 +2186,7 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 
 	if (!vg_write(vg)) {
 		log_error("Write of VG %s failed.", vg->name);
-		return_0;
+		return 0;
 	}
 
 	if (!(r = (origin_only ? suspend_lv_origin(vg->cmd, lock_lv) :
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 31633987b..0189c365e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1655,7 +1655,7 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 
 	if (lv_raid_has_integrity(lv) && !strcmp(msg, "repair")) {
 		log_error("Use syncaction check to detect and correct integrity checksum mismatches.");
-		return_ECMD_FAILED;
+		return ECMD_FAILED;
 	}
 
 	/* If LV is inactive here, ensure it's not active elsewhere. */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 87539be49..4e27008fa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3976,7 +3976,7 @@ static int _lvconvert_replace_pv_single(struct cmd_context *cmd, struct logical_
 			continue;
 		if (!(tmp_str = grouped_arg_str_value(group->arg_values, replace_ARG, NULL))) {
 			log_error("Failed to get '--replace' argument");
-			return_ECMD_FAILED;
+			return ECMD_FAILED;
 		}
 		if (!(replace_pvs[i++] = dm_pool_strdup(cmd->mem, tmp_str)))
 			return_ECMD_FAILED;
@@ -4192,7 +4192,7 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
 		    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lvname2_orig) < 0) {
        			log_error("vg/lv string alloc failed.");
-			return_ECMD_FAILED;
+			return ECMD_FAILED;
 		}
 
 		/* vglv is now vgname/lvname2 and replaces lvname2_orig */
@@ -5976,7 +5976,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 
 	if (!get_pv_list_for_lv(cmd->mem, lv, &pvs_list)) {
 		log_error("Failed to build list of PVs for %s.", display_lvname(lv));
-		goto_bad;
+		goto bad;
 	}
 
 	dm_list_iterate_items(pvl, &pvs_list) {
@@ -6006,19 +6006,19 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 
 	if (lbs_4k && lbs_512) {
 		log_error("Writecache requires consistent logical block size for LV devices.");
-		goto_bad;
+		goto bad;
 	}
 
 	if (lbs_4k && block_size_setting && (block_size_setting < 4096)) {
 		log_error("Writecache block size %u not allowed with device logical block size 4096.",
 			  block_size_setting);
-		goto_bad;
+		goto bad;
 	}
 
 	if (dm_snprintf(pathname, sizeof(pathname), "%s/%s/%s", cmd->dev_dir,
 			lv->vg->name, lv->name) < 0) {
 		log_error("Path name too long to get LV block size %s", display_lvname(lv));
-		goto_bad;
+		goto bad;
 	}
 
 	if (!sync_local_dev_names(cmd))
@@ -6031,7 +6031,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 			goto skip_fs;
 		}
 		log_error("Device for LV not found to check block size %s", pathname);
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -6102,7 +6102,7 @@ skip_fs:
 		else {
 			log_error("Writecache block size %u cannot be larger than file system block size %u.",
 				  block_size_setting, fs_block_size);
-			goto_bad;
+			goto bad;
 		}
 	}
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 84b8e8003..42fa189c3 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -276,7 +276,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 */
 		if (!(dev = dev_cache_get(cmd, devname, NULL))) {
 			log_error("No device found for %s.", devname);
-			goto_bad;
+			goto bad;
 		}
 
 		/*
@@ -412,7 +412,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 
 		if (!(du = get_du_for_pvid(cmd, pvid))) {
 			log_error("PVID not found in devices file.");
-			goto_bad;
+			goto bad;
 		}
 
 		dm_list_del(&du->list);
@@ -420,7 +420,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		if ((du2 = get_du_for_pvid(cmd, pvid))) {
 			log_error("Multiple devices file entries for PVID %s (%s %s), remove by device name.",
 				  pvid, du->devname, du2->devname);
-			goto_bad;
+			goto bad;
 		}
 
 		if (du->devname && (du->devname[0] != '.')) {
diff --git a/tools/pvck.c b/tools/pvck.c
index 46ef03fb6..2af34dc57 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1720,7 +1720,7 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 		log_print("Override defaults with --settings \"mda_offset=<bytes> mda_size=<bytes>\"");
 	} else {
 		log_error("No mda location.");
-		return_0;
+		return 0;
 	}
 
  search:
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6ade29bfe..fdd8c482f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1456,7 +1456,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!setup_devices(cmd)) {
 		log_error("Failed to set up devices.");
-		return_0;
+		return 0;
 	}
 
 	/*
diff --git a/tools/toollib.c b/tools/toollib.c
index 28bfb8398..c8540b005 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4060,7 +4060,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		 */
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0))) {
 			log_error(INTERNAL_ERROR "No info for pvid");
-			return_ECMD_FAILED;
+			return ECMD_FAILED;
 		}
 
 		vgname = lvmcache_vgname_from_info(info);
@@ -5343,7 +5343,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 */
 	if (must_use_all && !dm_list_empty(&pp->arg_fail)) {
 		log_error("Command requires all devices to be found.");
-		return_0;
+		return 0;
 	}
 
 	/*


