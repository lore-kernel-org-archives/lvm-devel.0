From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 14:04:04 +0000 (UTC)
Subject: master - debug: more stacktrace corrections
Message-ID: <20161125140404.9EB7F60AB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d58074d9fc4a01c5ca99af0ba26a5521a541092
Commit:        1d58074d9fc4a01c5ca99af0ba26a5521a541092
Parent:        2ad66b4e7bf1c88bd57b6d97f9feb07b99ae3e19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 13:46:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 14:58:28 2016 +0100

debug: more stacktrace corrections

Continue previous patch dropping some unneeded stack traces
after printed log_error/warn messages.
---
 lib/activate/dev_manager.c    |    4 ++--
 lib/commands/toolcontext.c    |    2 +-
 lib/config/config.c           |    2 +-
 lib/device/dev-type.c         |    2 +-
 lib/format_text/import_vsn1.c |    2 +-
 lib/metadata/lv_manip.c       |    2 +-
 lib/metadata/metadata.c       |    4 ++--
 lib/metadata/raid_manip.c     |   10 +++++-----
 libdm/libdm-stats.c           |    2 +-
 tools/dmsetup.c               |    6 ++++--
 tools/lvcreate.c              |    2 +-
 tools/pvmove.c                |    4 ++--
 tools/toollib.c               |    8 ++++----
 tools/vgimportclone.c         |   17 ++++++++---------
 14 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1a79c08..642e6a1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -433,13 +433,13 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
 			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
 				log_error("Incorrect snapshot table found");
-				goto_out;
+				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
 		} else if (!strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) {
 			if (!params || sscanf(params, "%d:%d", &major1, &minor1) != 2) {
 				log_error("Incorrect snapshot-origin table found");
-				goto_out;
+				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1);
 		}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index bfb7c1b..394aa4b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -997,7 +997,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	if (!(cn = find_config_tree_array(cmd, devices_scan_CFG, NULL))) {
 		log_error(INTERNAL_ERROR "Unable to find configuration for devices/scan.");
-		return_0;
+		return 0;
 	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
diff --git a/lib/config/config.c b/lib/config/config.c
index 6ad04e5..3e30951 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -389,7 +389,7 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 	    !config_force_check(cmd, CONFIG_STRING, cft_new)) {
 		log_error("Ignoring invalid configuration string.");
 		dm_config_destroy(cft_new);
-		return_0;
+		return 0;
 	}
 
 	if (!(cs = dm_pool_zalloc(cft_new->mem, sizeof(struct config_source)))) {
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 32471aa..cc6777d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1009,7 +1009,7 @@ int udev_dev_is_mpath_component(struct device *dev)
 
 	if (!udev_context) {
 		log_warn("WARNING: No udev context available to check if device %s is multipath component.", dev_name(dev));
-		return_0;
+		return 0;
 	}
 
 	while (1) {
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d2219e4..e11b16b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -732,7 +732,7 @@ static int _read_historical_lvnames(struct format_instance *fid __attribute__((u
 
 	if (!(hlvn = hlvn->child)) {
 		log_error("Empty removed logical volume section.");
-		goto_bad;
+		goto bad;
 	}
 
 	if (!_read_id(&glv->historical->lvid.id[1], hlvn, "id")) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 07ba8ef..e86fb04 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1014,7 +1014,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		*/
 		if (area_reduction != seg->area_len) {
 			log_error("Unable to reduce RAID LV - operation not implemented.");
-			return_0;
+			return 0;
 		} else {
 			if (!lv_remove(lv)) {
 				log_error("Failed to remove RAID image %s",
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a32649f..78028cf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -840,13 +840,13 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 						  (const struct volume_group *) vg,
 						  &max_phys_block_size))) {
 			log_error("PV %s has wrong block size", pv_dev_name(pvl->pv));
-			return_0;
+			return 0;
 		}
 
 		if (!add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
 			log_error("PV %s cannot be added to VG %s.",
 				  pv_dev_name(pvl->pv), vg->name);
-			return_0;
+			return 0;
 		}
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e91667e..dfe1adf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1863,14 +1863,14 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
 	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs, &seg_meta_areas)) {
 		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
-		return_0;
+		return 0;
 	}
 
 	/* Metadata LVs must be cleared before being added to the array */
 	log_debug_metadata("Clearing newly allocated metadata LVs for %s", display_lvname(lv));
 	if (!_clear_lvs(&meta_lvs)) {
 		log_error("Failed to initialize metadata LVs for %s", display_lvname(lv));
-		return_0;
+		return 0;
 	}
 
 	/* Set segment areas for metadata sub_lvs */
@@ -1878,7 +1878,7 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
 	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
 		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));
-		return_0;
+		return 0;
 	}
 
 	return 1;
@@ -3663,13 +3663,13 @@ static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
 	} else if (seg_is_any_raid5(seg_from) &&
 		   segtype_is_any_raid6(*segtype)) {
 			log_error("Conversion not supported.");
-		return_0;
+		return 0;
 
 	/* ... and raid6 -> raid5 */
 	} else if (seg_is_any_raid6(seg_from) &&
 		   segtype_is_any_raid5(*segtype)) {
 			log_error("Conversion not supported.");
-		return_0;
+		return 0;
 	}
 
 	return 1;
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ad3e624..2fc00da 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1841,7 +1841,7 @@ static int _stats_set_aux(struct dm_stats *dms,
 		if (!group_tag) {
 			log_error("Could not build group descriptor for "
 				  "region ID " FMTu64, region_id);
-			goto_bad;
+			goto bad;
 		}
 	}
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e48f0a6..f068293 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -691,9 +691,11 @@ static int _do_usleep_wait(void)
 	if (usleep(this_interval / NSEC_PER_USEC)) {
 		if (errno == EINTR)
 			log_error("Report interval interrupted by signal.");
-		if (errno == EINVAL)
+		else if (errno == EINVAL)
 			log_error("Report interval too short.");
-		return_0;
+		else
+			stack; /* other reason */
+		return 0;
 	}
 
 	if (_count == 2) {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index dbc0708..f70984a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1591,7 +1591,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
 		if (!handle_sanlock_lv(cmd, vg)) {
 			log_error("No space for sanlock lock, extend the internal lvmlock LV.");
-			goto_out;
+			goto out;
 		}
 	}
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 3877562..eef5cc1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -187,12 +187,12 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 
 	if (!(sublv = find_lv(lv->vg, sublv_name))) {
 		log_error("Can't find sub LV %s?", sublv_name);
-		return_0;
+		return 0;
 	}
 
 	if (!get_pv_list_for_lv(lv->vg->cmd->mem, sublv, &untrim_list)) {
 		log_error("Can't find PVs for sub LV %s?", sublv_name);
-		return_0;
+		return 0;
 	}
 
 	dm_list_iterate(pvh1, &untrim_list) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 9763362..3562937 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2474,7 +2474,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!(final_lvl = dm_pool_zalloc(cmd->mem, sizeof(struct lv_list)))) {
 			log_error("Failed to allocate final LV list item.");
 			ret_max = ECMD_FAILED;
-			goto_out;
+			goto out;
 		}
 		final_lvl->lv = lvl->lv;
 		dm_list_add(&final_lvs, &final_lvl->list);
@@ -4710,7 +4710,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs.");
-		goto_out;
+		goto out;
 	}
 
 	/*
@@ -4742,7 +4742,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	if (dm_list_empty(&pp->arg_process)) {
 		log_debug("No devices to process.");
-		goto_bad;
+		goto bad;
 	}
 
 do_command:
@@ -4789,7 +4789,7 @@ do_command:
 
 		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, &consistent))) {
 			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
-			goto_bad;
+			goto bad;
 		}
 
 		dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 09b3a7c..b23b14e 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -75,12 +75,12 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 
 	if (vg_is_exported(vg) && !vp->import_vg) {
 		log_error("VG %s is exported, use the --import option.", vg->name);
-		goto_bad;
+		goto bad;
 	}
 
 	if (vg_status(vg) & PARTIAL_VG) {
 		log_error("VG %s is partial, it must be complete.", vg->name);
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -121,7 +121,7 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 			log_error("PV with UUID %s is part of VG %s, but is not included in the devices to import.",
 				   uuid, vg->name);
 			log_error("All PVs in the VG must be imported together.");
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -130,7 +130,7 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 			/* device arg is not in the VG. */
 			log_error("Device %s was not found in VG %s.", dev_name(vd->dev), vg->name);
 			log_error("The devices to import must match the devices in the VG.");
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -245,7 +245,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 
 	if (vp.found_args != argc) {
 		log_error("Failed to find all devices.");
-		goto_out;
+		goto out;
 	}
 
 	/*
@@ -256,12 +256,12 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_iterate_items(vd, &vp.arg_import) {
 		if (!(info = lvmcache_info_from_pvid(vd->dev->pvid, NULL, 0))) {
 			log_error("Failed to find PVID for device %s in lvmcache.", dev_name(vd->dev));
-			goto_out;
+			goto out;
 		}
 
 		if (!(vgname = lvmcache_vgname_from_info(info))) {
 			log_error("Failed to find VG name for device %s in lvmcache.", dev_name(vd->dev));
-			goto_out;
+			goto out;
 		}
 
 		if (!vp.old_vgname) {
@@ -270,7 +270,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 		} else {
 			if (strcmp(vp.old_vgname, vgname)) {
 				log_error("Devices must be from the same VG.");
-				goto_out;
+				goto out;
 			}
 		}
 	}
@@ -360,4 +360,3 @@ out:
 
 	return ret;
 }
-


