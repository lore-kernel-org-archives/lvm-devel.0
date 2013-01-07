From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  7 Jan 2013 22:35:41 +0000 (UTC)
Subject: master - logging: classify log_debug messages
Message-ID: <20130107223541.36E51A1059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06abb2dd4c78e66529e7e6407db1afb3f0f44d85
Commit:        06abb2dd4c78e66529e7e6407db1afb3f0f44d85
Parent:        7f747a0d739c08eadf319da9c3973f83c97c82af
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 7 22:30:29 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 7 22:30:29 2013 +0000

logging: classify log_debug messages

Place most log_debug() messages into a class.
---
 lib/activate/activate.c         |   44 +++++++-------
 lib/activate/dev_manager.c      |   68 ++++++++++----------
 lib/activate/fs.c               |    2 +-
 lib/cache/lvmcache.c            |   72 +++++++++++-----------
 lib/cache/lvmetad.c             |   32 +++++-----
 lib/device/dev-cache.c          |   36 ++++++------
 lib/device/dev-io.c             |   38 ++++++------
 lib/filters/filter-composite.c  |    2 +-
 lib/filters/filter-md.c         |    6 +-
 lib/filters/filter-mpath.c      |    2 +-
 lib/filters/filter-persistent.c |    4 +-
 lib/filters/filter-regex.c      |    2 +-
 lib/filters/filter-sysfs.c      |    2 +-
 lib/filters/filter.c            |   14 ++--
 lib/format1/disk-rep.c          |   28 ++++----
 lib/format1/format1.c           |   62 +++++++++---------
 lib/format_pool/disk_rep.c      |    8 +-
 lib/format_pool/import_export.c |    8 +-
 lib/format_text/export.c        |    4 +-
 lib/format_text/format-text.c   |   68 ++++++++++----------
 lib/format_text/text_label.c    |   58 +++++++++---------
 lib/label/label.c               |    8 +-
 lib/locking/cluster_locking.c   |    4 +-
 lib/locking/file_locking.c      |    6 +-
 lib/locking/locking.c           |    2 +-
 lib/metadata/lv_manip.c         |   80 ++++++++++++------------
 lib/metadata/merge.c            |   14 ++--
 lib/metadata/metadata.c         |   40 ++++++------
 lib/metadata/pv_manip.c         |   12 ++--
 lib/metadata/pv_map.c           |    4 +-
 lib/metadata/raid_manip.c       |   40 ++++++------
 lib/metadata/replicator_manip.c |    4 +-
 lib/metadata/thin_manip.c       |   14 ++--
 lib/metadata/vg.c               |    8 +-
 lib/mirror/mirrored.c           |    8 +-
 lib/misc/lvm-globals.c          |    8 +-
 lib/misc/lvm-wrappers.c         |    6 +-
 lib/mm/memlock.c                |   44 +++++++-------
 lib/thin/thin.c                 |    6 +-
 libdm/ioctl/libdm-iface.c       |   80 ++++++++++++------------
 libdm/libdm-common.c            |  128 +++++++++++++++++++-------------------
 libdm/libdm-deptree.c           |   46 +++++++-------
 libdm/mm/dbg_malloc.c           |    2 +-
 libdm/mm/pool-debug.c           |   10 ++--
 libdm/mm/pool.c                 |    4 +-
 tools/lvmcmdline.c              |    1 +
 tools/pvscan.c                  |    2 +-
 47 files changed, 571 insertions(+), 570 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 899f409..d71639f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -491,7 +491,7 @@ int target_version(const char *target_name, uint32_t *maj,
                 goto_out;
 
 	if (!dm_task_run(dmt)) {
-		log_debug("Failed to get %s target version", target_name);
+		log_debug_activation("Failed to get %s target version", target_name);
 		/* Assume this was because LIST_VERSIONS isn't supported */
 		*maj = 0;
 		*min = 0;
@@ -698,7 +698,7 @@ int lv_check_transient(struct logical_volume *lv)
 	if (!activation())
 		return 0;
 
-	log_debug("Checking transient status for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking transient status for LV %s/%s", lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -722,7 +722,7 @@ int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 	if (!activation())
 		return 0;
 
-	log_debug("Checking snapshot percent for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking snapshot percent for LV %s/%s", lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -753,7 +753,7 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (!activation())
 		return 0;
 
-	log_debug("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		return_0;
@@ -790,8 +790,8 @@ int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 	if (!activation())
 		return 0;
 
-	log_debug("Checking thin %sdata percent for LV %s/%s",
-		  (metadata) ? "meta" : "", lv->vg->name, lv->name);
+	log_debug_activation("Checking thin %sdata percent for LV %s/%s",
+			     (metadata) ? "meta" : "", lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -816,8 +816,8 @@ int lv_thin_percent(const struct logical_volume *lv,
 	if (!activation())
 		return 0;
 
-	log_debug("Checking thin percent for LV %s/%s",
-		  lv->vg->name, lv->name);
+	log_debug_activation("Checking thin percent for LV %s/%s",
+			     lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -843,8 +843,8 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!activation())
 		return 0;
 
-	log_debug("Checking thin percent for LV %s/%s",
-		  lv->vg->name, lv->name);
+	log_debug_activation("Checking thin percent for LV %s/%s",
+			     lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -973,7 +973,7 @@ int lvs_in_vg_activated(const struct volume_group *vg)
 		if (lv_is_visible(lvl->lv))
 			count += (_lv_active(vg->cmd, lvl->lv) == 1);
 
-	log_debug("Counted %d active LVs in VG %s", count, vg->name);
+	log_debug_activation("Counted %d active LVs in VG %s", count, vg->name);
 
 	return count;
 }
@@ -990,7 +990,7 @@ int lvs_in_vg_opened(const struct volume_group *vg)
 		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 
-	log_debug("Counted %d open LVs in VG %s", count, vg->name);
+	log_debug_activation("Counted %d open LVs in VG %s", count, vg->name);
 
 	return count;
 }
@@ -1265,8 +1265,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (laopts->skip_in_use && lv_info(lv->vg->cmd, lv, 1, &info, 1, 0) &&
 	    (info.open_count != 1)) {
-		log_debug("Skipping unmonitor of opened %s (open:%d)",
-			  lv->name, info.open_count);
+		log_debug_activation("Skipping unmonitor of opened %s (open:%d)",
+				     lv->name, info.open_count);
 		return 1;
 	}
 
@@ -1633,10 +1633,10 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	log_debug("Resuming LV %s/%s%s%s%s.", lv->vg->name, lv->name,
-		  error_if_not_active ? "" : " if active",
-		  laopts->origin_only ? " without snapshots" : "",
-		  laopts->revert ? " (reverting)" : "");
+	log_debug_activation("Resuming LV %s/%s%s%s%s.", lv->vg->name, lv->name,
+			     error_if_not_active ? "" : " if active",
+			     laopts->origin_only ? " without snapshots" : "",
+			     laopts->revert ? " (reverting)" : "");
 
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
@@ -1739,7 +1739,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 		goto out;
 	}
 
-	log_debug("Deactivating %s/%s.", lv->vg->name, lv->name);
+	log_debug_activation("Deactivating %s/%s.", lv->vg->name, lv->name);
 
 	if (!lv_info(cmd, lv, 0, &info, 1, 0))
 		goto_out;
@@ -1849,9 +1849,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
-	log_debug("Activating %s/%s%s%s.", lv->vg->name, lv->name,
-		  laopts->exclusive ? " exclusively" : "",
-		  laopts->read_only ? " read-only" : "");
+	log_debug_activation("Activating %s/%s%s%s.", lv->vg->name, lv->name,
+			     laopts->exclusive ? " exclusively" : "",
+			     laopts->read_only ? " read-only" : "");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3f74c2d..23c25ab 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -252,15 +252,15 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 
 	for (i = 0; images_health[i]; i++)
 		if (images_health[i] != 'A') {
-			log_debug("%s: Mirror image %d marked as failed",
-				  dev_name(dev), i);
+			log_debug_activation("%s: Mirror image %d marked as failed",
+					     dev_name(dev), i);
 			check_for_blocking = 1;
 		}
 
 	if (!check_for_blocking && log_dev) {
 		if (log_health[0] != 'A') {
-			log_debug("%s: Mirror log device marked as failed",
-				  dev_name(dev));
+			log_debug_activation("%s: Mirror log device marked as failed",
+					     dev_name(dev));
 			check_for_blocking = 1;
 		} else {
 			struct device *tmp_dev;
@@ -310,8 +310,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 
 			if (strstr(params, "block_on_error") ||
 			    strstr(params, "handle_errors")) {
-				log_debug("%s: I/O blocked to mirror device",
-					  dev_name(dev));
+				log_debug_activation("%s: I/O blocked to mirror device",
+						     dev_name(dev));
 				goto out;
 			}
 		}
@@ -363,12 +363,12 @@ int device_is_usable(struct device *dev)
 	uuid = dm_task_get_uuid(dmt);
 
 	if (!info.target_count) {
-		log_debug("%s: Empty device %s not usable.", dev_name(dev), name);
+		log_debug_activation("%s: Empty device %s not usable.", dev_name(dev), name);
 		goto out;
 	}
 
 	if (info.suspended && ignore_suspended_devices()) {
-		log_debug("%s: Suspended device %s not usable.", dev_name(dev), name);
+		log_debug_activation("%s: Suspended device %s not usable.", dev_name(dev), name);
 		goto out;
 	}
 
@@ -379,8 +379,8 @@ int device_is_usable(struct device *dev)
 
 		if (target_type && !strcmp(target_type, "mirror") &&
 		    !_ignore_blocked_mirror_devices(dev, start, length, params)) {
-			log_debug("%s: Mirror device %s not usable.",
-				  dev_name(dev), name);
+			log_debug_activation("%s: Mirror device %s not usable.",
+					     dev_name(dev), name);
 			goto out;
 		}
 
@@ -394,8 +394,8 @@ int device_is_usable(struct device *dev)
 		 */
 		if (target_type && !strcmp(target_type, "snapshot-origin") &&
 		    ignore_suspended_devices()) {
-			log_debug("%s: Snapshot-origin device %s not usable.",
-				  dev_name(dev), name);
+			log_debug_activation("%s: Snapshot-origin device %s not usable.",
+					     dev_name(dev), name);
 			goto out;
 		}
 
@@ -406,8 +406,8 @@ int device_is_usable(struct device *dev)
 	/* Skip devices consisting entirely of error targets. */
 	/* FIXME Deal with device stacked above error targets? */
 	if (only_error_target) {
-		log_debug("%s: Error device %s not usable.",
-			  dev_name(dev), name);
+		log_debug_activation("%s: Error device %s not usable.",
+				     dev_name(dev), name);
 		goto out;
 	}
 
@@ -420,8 +420,8 @@ int device_is_usable(struct device *dev)
 			goto_out;
 
 		if (lvname && (is_reserved_lvname(lvname) || *layer)) {
-			log_debug("%s: Reserved internal LV device %s/%s%s%s not usable.",
-				  dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
+			log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
+					     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
 			goto out;
 		}
 	}
@@ -473,7 +473,7 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		return 0;
 	}
 
-	log_debug("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s]", name, dlid);
 	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
 
 	dm_pool_free(mem, name);
@@ -786,7 +786,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			goto_out;
 	}
 
-	log_debug("LV percent: %f", percent_to_float(*overall_percent));
+	log_debug_activation("LV percent: %f", percent_to_float(*overall_percent));
 	r = 1;
 
       out:
@@ -980,7 +980,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	/*
 	 * Try and get some info on this device.
 	 */
-	log_debug("Getting device status percentage for %s", name);
+	log_debug_activation("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
 		       NULL, fail_if_percent_unsupported)))
 		return_0;
@@ -1011,8 +1011,8 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 		return 0;
 	}
 
-	log_debug("Getting device %s status percentage for %s",
-		  target_type, name);
+	log_debug_activation("Getting device %s status percentage for %s",
+			     target_type, name);
 	if (!(_percent(dm, name, dlid, target_type, wait, lv, percent,
 		       event_nr, 0)))
 		return_0;
@@ -1033,13 +1033,13 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	else
 		log_very_verbose("Removing %s", dl->name);
 
-	log_debug("Adding target: %" PRIu64 " %" PRIu64 " %s %s",
+	log_debug_activation("Adding target: %" PRIu64 " %" PRIu64 " %s %s",
 		  extent_size * seg->le, extent_size * seg->len, target, params);
 
-	log_debug("Adding target: 0 %" PRIu64 " snapshot-origin %s",
+	log_debug_activation("Adding target: 0 %" PRIu64 " snapshot-origin %s",
 		  dl->lv->size, params);
-	log_debug("Adding target: 0 %" PRIu64 " snapshot %s", size, params);
-	log_debug("Getting device info for %s", dl->name);
+	log_debug_activation("Adding target: 0 %" PRIu64 " snapshot %s", size, params);
+	log_debug_activation("Getting device info for %s", dl->name);
 
 	/* Rename? */
 		if ((suffix = strrchr(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
@@ -1095,7 +1095,7 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
 		return_0;
 
-	log_debug("Getting thin pool device status for %s.", lv->name);
+	log_debug_activation("Getting thin pool device status for %s.", lv->name);
 
 	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
 		return_0;
@@ -1136,7 +1136,7 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
 		return_0;
 
-	log_debug("Getting device status percentage for %s", name);
+	log_debug_activation("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "thin-pool", 0,
 		       (metadata) ? lv : NULL, percent, NULL, 1)))
 		return_0;
@@ -1159,7 +1159,7 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
-	log_debug("Getting device status percentage for %s", name);
+	log_debug_activation("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "thin", 0,
 		       (mapped) ? NULL : lv, percent, NULL, 1)))
 		return_0;
@@ -1272,7 +1272,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
-	log_debug("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s]", name, dlid);
 	if (!_info(dlid, 1, 0, &info, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
@@ -1588,7 +1588,7 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 	uint32_t s;
 
 	if (!(dtree = dm_tree_create())) {
-		log_debug("Partial dtree creation failed for %s.", lv->name);
+		log_debug_activation("Partial dtree creation failed for %s.", lv->name);
 		return NULL;
 	}
 
@@ -1647,7 +1647,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 				   seg->lv->name, errid)))
 		return_NULL;
 
-	log_debug("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s]", name, dlid);
 	if (!_info(dlid, 1, 0, &info, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
@@ -1958,9 +1958,9 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		       seg_present->segtype->ops->target_name(seg_present, laopts) :
 		       seg_present->segtype->name);
 
-	log_debug("Checking kernel supports %s segment type for %s%s%s",
-		  target_name, seg->lv->name,
-		  layer ? "-" : "", layer ? : "");
+	log_debug_activation("Checking kernel supports %s segment type for %s%s%s",
+			     target_name, seg->lv->name,
+			     layer ? "-" : "", layer ? : "");
 
 	if (seg_present->segtype->ops->target_present &&
 	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 2636ccf..fe53349 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -486,7 +486,7 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 void fs_unlock(void)
 {
 	if (!critical_section()) {
-		log_debug("Syncing device names");
+		log_debug_activation("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
 			stack;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2c431b1..6ef1556 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -141,7 +141,7 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
-	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
+	log_debug_cache("Metadata cache: VG %s wiped.", vginfo->vgname);
 
 	release_vg(vginfo->cached_vg);
 }
@@ -184,9 +184,9 @@ static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 		return;
 	}
 
-	log_debug("Metadata cache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
-		  vginfo->vgname, uuid, size,
-		  precommitted ? ", precommitted" : "");
+	log_debug_cache("Metadata cache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
+			vginfo->vgname, uuid, size,
+			precommitted ? ", precommitted" : "");
 }
 
 static void _update_cache_info_lock_state(struct lvmcache_info *info,
@@ -276,8 +276,8 @@ void lvmcache_commit_metadata(const char *vgname)
 		return;
 
 	if (vginfo->precommitted) {
-		log_debug("Precommitted metadata cache: VG %s upgraded to committed.",
-			  vginfo->vgname);
+		log_debug_cache("Precommitted metadata cache: VG %s upgraded to committed.",
+				vginfo->vgname);
 		vginfo->precommitted = 0;
 	}
 }
@@ -792,9 +792,9 @@ struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname
 out:
 	vginfo->holders++;
 	vginfo->vg_use_count++;
-	log_debug("Using cached %smetadata for VG %s with %u holder(s).",
-		  vginfo->precommitted ? "pre-committed " : "",
-		  vginfo->vgname, vginfo->holders);
+	log_debug_cache("Using cached %smetadata for VG %s with %u holder(s).",
+			vginfo->precommitted ? "pre-committed " : "",
+			vginfo->vgname, vginfo->holders);
 
 	return vg;
 
@@ -806,15 +806,15 @@ bad:
 // #if 0
 int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
 {
-	log_debug("VG %s decrementing %d holder(s) at %p.",
-		  vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
+	log_debug_cache("VG %s decrementing %d holder(s) at %p.",
+			vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
 
 	if (--vginfo->holders)
 		return 0;
 
 	if (vginfo->vg_use_count > 1)
-		log_debug("VG %s reused %d times.",
-			  vginfo->cached_vg->name, vginfo->vg_use_count);
+		log_debug_cache("VG %s reused %d times.",
+				vginfo->cached_vg->name, vginfo->vg_use_count);
 
 	/* Debug perform crc check only when it's been used more then once */
 	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
@@ -1095,7 +1095,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 	if (!vgid) {
 		/* FIXME: unreachable code path */
-		log_debug("lvmcache: %s: clearing VGID", info ? dev_name(info->dev) : vginfo->vgname);
+		log_debug_cache("lvmcache: %s: clearing VGID", info ? dev_name(info->dev) : vginfo->vgname);
 		return 1;
 	}
 
@@ -1108,9 +1108,9 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 	}
 
 	if (!is_orphan_vg(vginfo->vgname))
-		log_debug("lvmcache: %s: setting %s VGID to %s",
-			  (info) ? dev_name(info->dev) : "",
-			  vginfo->vgname, vginfo->vgid);
+		log_debug_cache("lvmcache: %s: setting %s VGID to %s",
+				(info) ? dev_name(info->dev) : "",
+				vginfo->vgname, vginfo->vgid);
 
 	return 1;
 }
@@ -1287,11 +1287,11 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 						dm_list_size(&info2->mdas));
 				else
 					mdabuf[0] = '\0';
-				log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
-					  dev_name(info2->dev),
-					  vgname, orphan_vginfo->vgid[0] ? " (" : "",
-					  orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
-					  orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
+				log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
+						dev_name(info2->dev),
+						vgname, orphan_vginfo->vgid[0] ? " (" : "",
+						orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
+						orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
 			}
 
 			if (!_drop_vginfo(NULL, primary_vginfo))
@@ -1329,13 +1329,13 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			sprintf(mdabuf, " with %u mdas", dm_list_size(&info->mdas));
 		else
 			mdabuf[0] = '\0';
-		log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
-			  dev_name(info->dev),
-			  vgname, vginfo->vgid[0] ? " (" : "",
-			  vginfo->vgid[0] ? vginfo->vgid : "",
-			  vginfo->vgid[0] ? ")" : "", mdabuf);
+		log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
+				dev_name(info->dev),
+				vgname, vginfo->vgid[0] ? " (" : "",
+				vginfo->vgid[0] ? vginfo->vgid : "",
+				vginfo->vgid[0] ? ")" : "", mdabuf);
 	} else
-		log_debug("lvmcache: initialised VG %s", vgname);
+		log_debug_cache("lvmcache: initialised VG %s", vgname);
 
 	return 1;
 }
@@ -1347,9 +1347,9 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 		return 1;
 
 	if ((info->vginfo->status & EXPORTED_VG) != (vgstatus & EXPORTED_VG))
-		log_debug("lvmcache: %s: VG %s %s exported",
-			  dev_name(info->dev), info->vginfo->vgname,
-			  vgstatus & EXPORTED_VG ? "now" : "no longer");
+		log_debug_cache("lvmcache: %s: VG %s %s exported",
+				dev_name(info->dev), info->vginfo->vgname,
+				vgstatus & EXPORTED_VG ? "now" : "no longer");
 
 	info->vginfo->status = vgstatus;
 
@@ -1369,8 +1369,8 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 		return 0;
 	}
 
-	log_debug("lvmcache: %s: VG %s: Set creation host to %s.",
-		  dev_name(info->dev), info->vginfo->vgname, creation_host);
+	log_debug_cache("lvmcache: %s: VG %s: Set creation host to %s.",
+			dev_name(info->dev), info->vginfo->vgname, creation_host);
 
 	return 1;
 }
@@ -1519,9 +1519,9 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 					  dev_name(existing->dev));
 		}
 		if (strcmp(pvid_s, existing->dev->pvid)) 
-			log_debug("Updating pvid cache to %s (%s) from %s (%s)",
-				  pvid_s, dev_name(dev),
-				  existing->dev->pvid, dev_name(existing->dev));
+			log_debug_cache("Updating pvid cache to %s (%s) from %s (%s)",
+					pvid_s, dev_name(dev),
+					existing->dev->pvid, dev_name(existing->dev));
 		/* Switch over to new preferred device */
 		existing->dev = dev;
 		info = existing;
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index db33553..9b54174 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -53,8 +53,8 @@ static void _lvmetad_connect()
 
 	_lvmetad = lvmetad_open(_lvmetad_socket);
 	if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
-		log_debug("Successfully connected to lvmetad on fd %d.",
-			  _lvmetad.socket_fd);
+		log_debug_lvmetad("Successfully connected to lvmetad on fd %d.",
+				  _lvmetad.socket_fd);
 		_lvmetad_connected = 1;
 	}
 }
@@ -81,7 +81,7 @@ int lvmetad_active(void)
 		_lvmetad_connect();
 
 	if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
-		log_debug("Failed to connect to lvmetad: %s.", strerror(_lvmetad.error));
+		log_debug_lvmetad("Failed to connect to lvmetad: %s.", strerror(_lvmetad.error));
 
 	return _lvmetad_connected;
 }
@@ -156,7 +156,7 @@ retry:
 
 static int _token_update(void)
 {
-	log_debug("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
+	log_debug_lvmetad("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
 	daemon_reply repl = _lvmetad_send("token_update", NULL);
 
 	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
@@ -323,12 +323,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	if (vgid) {
 		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 			return_NULL;
-		log_debug("Asking lvmetad for VG %s (%s)", uuid, vgname ? : "name unknown");
+		log_debug_lvmetad("Asking lvmetad for VG %s (%s)", uuid, vgname ? : "name unknown");
 		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
-		log_debug("Asking lvmetad for VG %s", vgname);
+		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 	}
 
@@ -439,7 +439,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!(vgmeta = _export_vg_to_config_tree(vg)))
 		return_0;
 
-	log_debug("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
+	log_debug_lvmetad("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
 	reply = _lvmetad_send("vg_update", "vgname = %s", vg->name,
 			      "metadata = %t", vgmeta, NULL);
 	dm_config_destroy(vgmeta);
@@ -492,7 +492,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
-	log_debug("Telling lvmetad to remove VGID %s (%s)", uuid, vg->name);
+	log_debug_lvmetad("Telling lvmetad to remove VGID %s (%s)", uuid, vg->name);
 	reply = _lvmetad_send("vg_remove", "uuid = %s", uuid, NULL);
 	result = _lvmetad_handle_reply(reply, "remove VG", vg->name, NULL);
 
@@ -514,7 +514,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
 		return_0;
 
-	log_debug("Asking lvmetad for PV %s", uuid);
+	log_debug_lvmetad("Asking lvmetad for PV %s", uuid);
 	reply = _lvmetad_send("pv_lookup", "uuid = %s", uuid, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", "", found))
 		goto_out;
@@ -545,7 +545,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	if (!lvmetad_active())
 		return_0;
 
-	log_debug("Asking lvmetad for PV on %s", dev_name(dev));
+	log_debug_lvmetad("Asking lvmetad for PV on %s", dev_name(dev));
 	reply = _lvmetad_send("pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
 		goto_out;
@@ -573,7 +573,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	if (!lvmetad_active())
 		return 1;
 
-	log_debug("Asking lvmetad for complete list of known PVs");
+	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
 	reply = _lvmetad_send("pv_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
 		daemon_reply_destroy(reply);
@@ -600,7 +600,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	if (!lvmetad_active())
 		return 1;
 
-	log_debug("Asking lvmetad for complete list of known VGs");
+	log_debug_lvmetad("Asking lvmetad for complete list of known VGs");
 	reply = _lvmetad_send("vg_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
 		daemon_reply_destroy(reply);
@@ -738,7 +738,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 			return_0;
 		}
 
-		log_debug("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
+		log_debug_lvmetad("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
 		reply = _lvmetad_send("pv_found",
 				      "pvmeta = %t", pvmeta,
 				      "vgname = %s", vg->name,
@@ -750,7 +750,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		 * There is no VG metadata stored on this PV.
 		 * It might or might not be an orphan.
 		 */
-		log_debug("Telling lvmetad to store PV %s (%s)", dev_name(dev), uuid);
+		log_debug_lvmetad("Telling lvmetad to store PV %s (%s)", dev_name(dev), uuid);
 		reply = _lvmetad_send("pv_found", "pvmeta = %t", pvmeta, NULL);
 	}
 
@@ -798,7 +798,7 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
          *        the whole stack from top to bottom (not yet upstream).
          */
 
-	log_debug("Telling lvmetad to forget any PV on %s", pv_name);
+	log_debug_lvmetad("Telling lvmetad to forget any PV on %s", pv_name);
 	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
@@ -925,7 +925,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 		return 0;
 	}
 
-	log_debug("Telling lvmetad to clear its cache");
+	log_debug_lvmetad("Telling lvmetad to clear its cache");
 	reply = _lvmetad_send("pv_clear_all", NULL);
 	if (!_lvmetad_handle_reply(reply, "clear info about all PVs", "", NULL))
 		r = 0;
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 2b2d32b..9905045 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -137,7 +137,7 @@ void dev_set_preferred_name(struct str_list *sl, struct device *dev)
 	if (_cache.preferred_names_matcher)
 		return;
 
-	log_debug("%s: New preferred name", sl->str);
+	log_debug_devs("%s: New preferred name", sl->str);
 	dm_list_del(&sl->list);
 	dm_list_add_h(&dev->aliases, &sl->list);
 }
@@ -315,7 +315,7 @@ static int _add_alias(struct device *dev, const char *path)
 	/* Is name already there? */
 	dm_list_iterate_items(strl, &dev->aliases) {
 		if (!strcmp(strl->str, path)) {
-			log_debug("%s: Already in device cache", path);
+			log_debug_devs("%s: Already in device cache", path);
 			return 1;
 		}
 	}
@@ -325,11 +325,11 @@ static int _add_alias(struct device *dev, const char *path)
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
 		prefer_old = _compare_paths(path, oldpath);
-		log_debug("%s: Aliased to %s in device cache%s",
-			  path, oldpath, prefer_old ? "" : " (preferred name)");
+		log_debug_devs("%s: Aliased to %s in device cache%s",
+			       path, oldpath, prefer_old ? "" : " (preferred name)");
 
 	} else
-		log_debug("%s: Added to device cache", path);
+		log_debug_devs("%s: Added to device cache", path);
 
 	if (prefer_old)
 		dm_list_add(&dev->aliases, &sl->list);
@@ -464,7 +464,7 @@ static int _insert_file(const char *path)
 	}
 
 	if (!S_ISREG(info.st_mode)) {
-		log_debug("%s: Not a regular file", path);
+		log_debug_devs("%s: Not a regular file", path);
 		return 0;
 	}
 
@@ -563,13 +563,13 @@ static void _insert_dirs(struct dm_list *dirs)
 	dm_list_iterate_items(dl, &_cache.dirs) {
 		if (with_udev) {
 			if (!_insert_udev_dir(udev, dl->dir))
-				log_debug("%s: Failed to insert devices from "
-					  "udev-managed directory to device "
-					  "cache fully", dl->dir);
+				log_debug_devs("%s: Failed to insert devices from "
+					       "udev-managed directory to device "
+					       "cache fully", dl->dir);
 		}
 		else if (!_insert_dir(dl->dir))
-			log_debug("%s: Failed to insert devices to "
-				  "device cache fully", dl->dir);
+			log_debug_devs("%s: Failed to insert devices to "
+				       "device cache fully", dl->dir);
 	}
 }
 
@@ -613,7 +613,7 @@ static int _insert(const char *path, int rec, int check_with_udev_db)
 		}
 
 		if (S_ISLNK(info.st_mode)) {
-			log_debug("%s: Symbolic link to directory", path);
+			log_debug_devs("%s: Symbolic link to directory", path);
 			return 0;
 		}
 
@@ -622,7 +622,7 @@ static int _insert(const char *path, int rec, int check_with_udev_db)
 
 	} else {		/* add a device */
 		if (!S_ISBLK(info.st_mode)) {
-			log_debug("%s: Not a block device", path);
+			log_debug_devs("%s: Not a block device", path);
 			return 0;
 		}
 
@@ -869,9 +869,9 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 				log_sys_error("stat", name);
 		}
 		if (quiet)
-			log_debug("Path %s no longer valid for device(%d,%d)",
-				  name, (int) MAJOR(dev->dev),
-				  (int) MINOR(dev->dev));
+			log_debug_devs("Path %s no longer valid for device(%d,%d)",
+				       name, (int) MAJOR(dev->dev),
+				       (int) MINOR(dev->dev));
 		else
 			log_warn("Path %s no longer valid for device(%d,%d)",
 				 name, (int) MAJOR(dev->dev),
@@ -891,8 +891,8 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 		}
 
 		/* Scanning issues this inappropriately sometimes. */
-		log_debug("Aborting - please provide new pathname for what "
-			  "used to be %s", name);
+		log_debug_devs("Aborting - please provide new pathname for what "
+			       "used to be %s", name);
 		return NULL;
 	}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 3bb9d65..2846caf 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -134,7 +134,7 @@ static int _get_block_size(struct device *dev, unsigned int *size)
 			log_sys_error("ioctl BLKBSZGET", name);
 			return 0;
 		}
-		log_debug("%s: block size is %u bytes", name, dev->block_size);
+		log_debug_devs("%s: block size is %u bytes", name, dev->block_size);
 	}
 
 	*size = (unsigned int) dev->block_size;
@@ -314,8 +314,8 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
 	discard_range[0] = offset_bytes;
 	discard_range[1] = size_bytes;
 
-	log_debug("Discarding %" PRIu64 " bytes offset %" PRIu64 " bytes on %s.",
-		  size_bytes, offset_bytes, dev_name(dev));
+	log_debug_devs("Discarding %" PRIu64 " bytes offset %" PRIu64 " bytes on %s.",
+		       size_bytes, offset_bytes, dev_name(dev));
 	if (ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
 		log_error("%s: BLKDISCARD ioctl@offset %" PRIu64 " size %" PRIu64 " failed: %s.",
 			  dev_name(dev), offset_bytes, size_bytes, strerror(errno));
@@ -431,8 +431,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		}
 
 		if (dev->open_count && !need_excl) {
-			log_debug("%s already opened read-only. Upgrading "
-				  "to read-write.", dev_name(dev));
+			log_debug_devs("%s already opened read-only. Upgrading "
+				       "to read-write.", dev_name(dev));
 			dev->open_count++;
 		}
 
@@ -442,7 +442,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	if (critical_section())
 		/* FIXME Make this log_error */
 		log_verbose("dev_open(%s) called while suspended",
-			 dev_name(dev));
+			    dev_name(dev));
 
 	if (dev->flags & DEV_REGULAR)
 		name = dev_name(dev);
@@ -471,7 +471,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 			flags &= ~O_DIRECT;
 			if ((dev->fd = open(name, flags, 0777)) >= 0) {
 				dev->flags &= ~DEV_O_DIRECT;
-				log_debug("%s: Not using O_DIRECT", name);
+				log_debug_devs("%s: Not using O_DIRECT", name);
 				goto opened;
 			}
 		}
@@ -518,10 +518,10 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 
 	dm_list_add(&_open_devices, &dev->open_list);
 
-	log_debug("Opened %s %s%s%s", dev_name(dev),
-		  dev->flags & DEV_OPENED_RW ? "RW" : "RO",
-		  dev->flags & DEV_OPENED_EXCL ? " O_EXCL" : "",
-		  dev->flags & DEV_O_DIRECT ? " O_DIRECT" : "");
+	log_debug_devs("Opened %s %s%s%s", dev_name(dev),
+		       dev->flags & DEV_OPENED_RW ? "RW" : "RO",
+		       dev->flags & DEV_OPENED_EXCL ? " O_EXCL" : "",
+		       dev->flags & DEV_O_DIRECT ? " O_DIRECT" : "");
 
 	return 1;
 }
@@ -574,7 +574,7 @@ static void _close(struct device *dev)
 	dev->block_size = -1;
 	dm_list_del(&dev->open_list);
 
-	log_debug("Closed %s", dev_name(dev));
+	log_debug_devs("Closed %s", dev_name(dev));
 
 	if (dev->flags & DEV_ALLOCED) {
 		dm_free((void *) dm_list_item(dev->aliases.n, struct str_list)->
@@ -602,8 +602,8 @@ static int _dev_close(struct device *dev, int immediate)
 		dev->open_count--;
 
 	if (immediate && dev->open_count)
-		log_debug("%s: Immediate close attempt while still referenced",
-			  dev_name(dev));
+		log_debug_devs("%s: Immediate close attempt while still referenced",
+			       dev_name(dev));
 
 	/* Close unless device is known to belong to a locked VG */
 	if (immediate ||
@@ -756,12 +756,12 @@ int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
 		return_0;
 
 	if ((offset % SECTOR_SIZE) || (len % SECTOR_SIZE))
-		log_debug("Wiping %s at %" PRIu64 " length %" PRIsize_t,
-			  dev_name(dev), offset, len);
+		log_debug_devs("Wiping %s at %" PRIu64 " length %" PRIsize_t,
+			       dev_name(dev), offset, len);
 	else
-		log_debug("Wiping %s at sector %" PRIu64 " length %" PRIsize_t
-			  " sectors", dev_name(dev), offset >> SECTOR_SHIFT,
-			  len >> SECTOR_SHIFT);
+		log_debug_devs("Wiping %s at sector %" PRIu64 " length %" PRIsize_t
+			       " sectors", dev_name(dev), offset >> SECTOR_SHIFT,
+			       len >> SECTOR_SHIFT);
 
 	memset(buffer, value, sizeof(buffer));
 	while (1) {
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 3ed8787..2298000 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -28,7 +28,7 @@ static int _and_p(struct dev_filter *f, struct device *dev)
 		filters++;
 	}
 
-	log_debug("Using %s", dev_name(dev));
+	log_debug_devs("Using %s", dev_name(dev));
 
 	return 1;
 }
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index d57489d..6f289b0 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -29,13 +29,13 @@ static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 	ret = dev_is_md(dev, NULL);
 
 	if (ret == 1) {
-		log_debug("%s: Skipping md component device", dev_name(dev));
+		log_debug_devs("%s: Skipping md component device", dev_name(dev));
 		return 0;
 	}
 
 	if (ret < 0) {
-		log_debug("%s: Skipping: error in md component detection",
-			  dev_name(dev));
+		log_debug_devs("%s: Skipping: error in md component detection",
+			       dev_name(dev));
 		return 0;
 	}
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 61a62d7..2d171e6 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -160,7 +160,7 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 static int _ignore_mpath(struct dev_filter *f, struct device *dev)
 {
 	if (dev_is_mpath(f, dev) == 1) {
-		log_debug("%s: Skipping mpath component device", dev_name(dev));
+		log_debug_devs("%s: Skipping mpath component device", dev_name(dev));
 		return 0;
 	}
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index d00a99a..bec396b 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -282,7 +282,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 
 	/* Cached BAD? */
 	if (l == PF_BAD_DEVICE) {
-		log_debug("%s: Skipping (cached)", dev_name(dev));
+		log_debug_devs("%s: Skipping (cached)", dev_name(dev));
 		return 0;
 	}
 
@@ -295,7 +295,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 					return 0;
 				}
 		if (!device_is_usable(dev)) {
-			log_debug("%s: Skipping unusable device", dev_name(dev));
+			log_debug_devs("%s: Skipping unusable device", dev_name(dev));
 			return 0;
 		}
 		return pf->real->passes_filter(pf->real, dev);
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 3221195..7172c93 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -170,7 +170,7 @@ static int _accept_p(struct dev_filter *f, struct device *dev)
 	}
 
 	if (rejected)
-		log_debug("%s: Skipping (regex)", dev_name(dev));
+		log_debug_devs("%s: Skipping (regex)", dev_name(dev));
 
 	/*
 	 * pass everything that doesn't match
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index ebd16a2..a075f36 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -274,7 +274,7 @@ static int _accept_p(struct dev_filter *f, struct device *dev)
 		return 1;
 
 	if (!_set_lookup(ds, dev->dev)) {
-		log_debug("%s: Skipping (sysfs)", dev_name(dev));
+		log_debug_devs("%s: Skipping (sysfs)", dev_name(dev));
 		return 0;
 	} else
 		return 1;
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index e335045..6981b94 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -105,31 +105,31 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((un
 
 	/* Is this a recognised device type? */
 	if (!_partitions[MAJOR(dev->dev)].max_partitions) {
-		log_debug("%s: Skipping: Unrecognised LVM device type %"
-			  PRIu64, name, (uint64_t) MAJOR(dev->dev));
+		log_debug_devs("%s: Skipping: Unrecognised LVM device type %"
+			       PRIu64, name, (uint64_t) MAJOR(dev->dev));
 		return 0;
 	}
 
 	/* Check it's accessible */
 	if (!dev_open_readonly_quiet(dev)) {
-		log_debug("%s: Skipping: open failed", name);
+		log_debug_devs("%s: Skipping: open failed", name);
 		return 0;
 	}
 
 	/* Check it's not too small */
 	if (!dev_get_size(dev, &size)) {
-		log_debug("%s: Skipping: dev_get_size failed", name);
+		log_debug_devs("%s: Skipping: dev_get_size failed", name);
 		goto out;
 	}
 
 	if (size < pv_min_size()) {
-		log_debug("%s: Skipping: Too small to hold a PV", name);
+		log_debug_devs("%s: Skipping: Too small to hold a PV", name);
 		goto out;
 	}
 
 	if (is_partitioned_dev(dev)) {
-		log_debug("%s: Skipping: Partition table signature found",
-			  name);
+		log_debug_devs("%s: Skipping: Partition table signature found",
+			       name);
 		goto out;
 	}
 
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 0143ea0..ce6cda1 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -535,8 +535,8 @@ static int _write_vgd(struct disk_list *data)
 	struct vg_disk *vgd = &data->vgd;
 	uint64_t pos = data->pvd.vg_on_disk.base;
 
-	log_debug("Writing %s VG metadata to %s at %" PRIu64 " len %" PRIsize_t,
-		  data->pvd.vg_name, dev_name(data->dev), pos, sizeof(*vgd));
+	log_debug_metadata("Writing %s VG metadata to %s at %" PRIu64 " len %" PRIsize_t,
+			   data->pvd.vg_name, dev_name(data->dev), pos, sizeof(*vgd));
 
 	_xlate_vgd(vgd);
 	if (!dev_write(data->dev, pos, sizeof(*vgd), vgd))
@@ -560,9 +560,9 @@ static int _write_uuids(struct disk_list *data)
 			return 0;
 		}
 
-		log_debug("Writing %s uuidlist to %s at %" PRIu64 " len %d",
-			  data->pvd.vg_name, dev_name(data->dev),
-			  pos, NAME_LEN);
+		log_debug_metadata("Writing %s uuidlist to %s at %" PRIu64 " len %d",
+				   data->pvd.vg_name, dev_name(data->dev),
+				   pos, NAME_LEN);
 
 		if (!dev_write(data->dev, pos, NAME_LEN, ul->uuid))
 			return_0;
@@ -575,9 +575,9 @@ static int _write_uuids(struct disk_list *data)
 
 static int _write_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 {
-	log_debug("Writing %s LV %s metadata to %s at %" PRIu64 " len %"
-		  PRIsize_t, disk->vg_name, disk->lv_name, dev_name(dev),
-		  pos, sizeof(*disk));
+	log_debug_metadata("Writing %s LV %s metadata to %s at %" PRIu64 " len %"
+			   PRIsize_t, disk->vg_name, disk->lv_name, dev_name(dev),
+			   pos, sizeof(*disk));
 
 	_xlate_lvd(disk);
 	if (!dev_write(dev, pos, sizeof(*disk), disk))
@@ -621,9 +621,9 @@ static int _write_extents(struct disk_list *data)
 	struct pe_disk *extents = data->extents;
 	uint64_t pos = data->pvd.pe_on_disk.base;
 
-	log_debug("Writing %s extents metadata to %s at %" PRIu64 " len %"
-		  PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
-		  pos, len);
+	log_debug_metadata("Writing %s extents metadata to %s at %" PRIu64 " len %"
+			   PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
+			   pos, len);
 
 	_xlate_extents(extents, data->pvd.pe_total);
 	if (!dev_write(data->dev, pos, len, extents))
@@ -656,9 +656,9 @@ static int _write_pvd(struct disk_list *data)
 
 	memcpy(buf, &data->pvd, sizeof(struct pv_disk));
 
-	log_debug("Writing %s PV metadata to %s at %" PRIu64 " len %"
-		  PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
-		  pos, size);
+	log_debug_metadata("Writing %s PV metadata to %s at %" PRIu64 " len %"
+			   PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
+			   pos, size);
 
 	_xlate_pvd((struct pv_disk *) buf);
 	if (!dev_write(data->dev, pos, size, buf)) {
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 50626b5..bf5333e 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -67,35 +67,35 @@ static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 		else if (memcmp(&first->vgd, &dl->vgd, sizeof(first->vgd))) {
 			log_error("VG data differs between PVs %s and %s",
 				  dev_name(first->dev), dev_name(dl->dev));
-			log_debug("VG data on %s: %s %s %" PRIu32 " %" PRIu32
-				  "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-				  PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
-				  " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-				  PRIu32 " %" PRIu32 " %" PRIu32,
-				  dev_name(first->dev), first->vgd.vg_uuid,
-				  first->vgd.vg_name_dummy,
-				  first->vgd.vg_number, first->vgd.vg_access,
-				  first->vgd.vg_status, first->vgd.lv_max,
-				  first->vgd.lv_cur, first->vgd.lv_open,
-				  first->vgd.pv_max, first->vgd.pv_cur,
-				  first->vgd.pv_act, first->vgd.dummy,
-				  first->vgd.vgda, first->vgd.pe_size,
-				  first->vgd.pe_total, first->vgd.pe_allocated,
-				  first->vgd.pvg_total);
-			log_debug("VG data on %s: %s %s %" PRIu32 " %" PRIu32
-				  "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-				  PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
-				  " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-				  PRIu32 " %" PRIu32 " %" PRIu32,
-				  dev_name(dl->dev), dl->vgd.vg_uuid,
-				  dl->vgd.vg_name_dummy, dl->vgd.vg_number,
-				  dl->vgd.vg_access, dl->vgd.vg_status,
-				  dl->vgd.lv_max, dl->vgd.lv_cur,
-				  dl->vgd.lv_open, dl->vgd.pv_max,
-				  dl->vgd.pv_cur, dl->vgd.pv_act, dl->vgd.dummy,
-				  dl->vgd.vgda, dl->vgd.pe_size,
-				  dl->vgd.pe_total, dl->vgd.pe_allocated,
-				  dl->vgd.pvg_total);
+			log_debug_metadata("VG data on %s: %s %s %" PRIu32 " %" PRIu32
+					   "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
+					   PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
+					   " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
+					   PRIu32 " %" PRIu32 " %" PRIu32,
+					   dev_name(first->dev), first->vgd.vg_uuid,
+					   first->vgd.vg_name_dummy,
+					   first->vgd.vg_number, first->vgd.vg_access,
+					   first->vgd.vg_status, first->vgd.lv_max,
+					   first->vgd.lv_cur, first->vgd.lv_open,
+					   first->vgd.pv_max, first->vgd.pv_cur,
+					   first->vgd.pv_act, first->vgd.dummy,
+					   first->vgd.vgda, first->vgd.pe_size,
+					   first->vgd.pe_total, first->vgd.pe_allocated,
+					   first->vgd.pvg_total);
+			log_debug_metadata("VG data on %s: %s %s %" PRIu32 " %" PRIu32
+					   "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
+					   PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
+					   " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
+					   PRIu32 " %" PRIu32 " %" PRIu32,
+					   dev_name(dl->dev), dl->vgd.vg_uuid,
+					   dl->vgd.vg_name_dummy, dl->vgd.vg_number,
+					   dl->vgd.vg_access, dl->vgd.vg_status,
+					   dl->vgd.lv_max, dl->vgd.lv_cur,
+					   dl->vgd.lv_open, dl->vgd.pv_max,
+					   dl->vgd.pv_cur, dl->vgd.pv_act, dl->vgd.dummy,
+					   dl->vgd.vgda, dl->vgd.pe_size,
+					   dl->vgd.pe_total, dl->vgd.pe_allocated,
+					   dl->vgd.pvg_total);
 			dm_list_del(pvh);
 			return 0;
 		}
@@ -168,8 +168,8 @@ static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
 		goto_out;
 
 	add_pvl_to_vgs(vg, pvl);
-	log_debug("%s: partial VG, allocated missing PV using %d extents.",
-		  vg->name, pvl->pv->pe_count);
+	log_debug_metadata("%s: partial VG, allocated missing PV using %d extents.",
+			   vg->name, pvl->pv->pe_count);
 
 	return 1;
 out:
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index a140384..c4afefe 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -91,11 +91,11 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 
 	get_pool_pv_uuid(&pvid, pd);
 	id_write_format(&pvid, uuid, ID_LEN + 7);
-	log_debug("Calculated uuid %s for %s", uuid, dev_name(dev));
+	log_debug_metadata("Calculated uuid %s for %s", uuid, dev_name(dev));
 
 	get_pool_vg_uuid(&vgid, pd);
 	id_write_format(&vgid, uuid, ID_LEN + 7);
-	log_debug("Calculated uuid %s for %s", uuid, pd->pl_pool_name);
+	log_debug_metadata("Calculated uuid %s for %s", uuid, pd->pl_pool_name);
 
 	if (!(info = lvmcache_add(l, (char *) &pvid, dev, pd->pl_pool_name,
 				  (char *) &vgid, 0)))
@@ -369,8 +369,8 @@ int read_pool_pds(const struct format_type *fmt, const char *vg_name,
 
 		full_scan++;
 		if (full_scan > 1) {
-			log_debug("No devices for vg %s found in cache",
-				  vg_name);
+			log_debug_metadata("No devices for vg %s found in cache",
+					   vg_name);
 			return 0;
 		}
 		lvmcache_label_scan(fmt->cmd, full_scan);
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 480fa1c..6ef0757 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -77,8 +77,8 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 			return_0;
 
 		get_pool_lv_uuid(lv->lvid.id, &pl->pd);
-		log_debug("Calculated lv uuid for lv %s: %s", lv->name,
-			  lv->lvid.s);
+		log_debug_metadata("Calculated lv uuid for lv %s: %s", lv->name,
+				   lv->lvid.s);
 
 		lv->status |= VISIBLE_LV | LVM_READ | LVM_WRITE;
 		lv->major = POOL_MAJOR;
@@ -167,8 +167,8 @@ static const char *_cvt_sptype(uint32_t sptype)
 			break;
 		}
 	}
-	log_debug("Found sptype %X and converted it to %s",
-		  sptype, sptype_names[i].name);
+	log_debug_metadata("Found sptype %X and converted it to %s",
+			   sptype, sptype_names[i].name);
 	return sptype_names[i].name;
 }
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 70c1aa6..d68daf5 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -119,8 +119,8 @@ static int _extend_buffer(struct formatter *f)
 {
 	char *newbuf;
 
-	log_debug("Doubling metadata output buffer to %" PRIu32,
-		  f->data.buf.size * 2);
+	log_debug_metadata("Doubling metadata output buffer to %" PRIu32,
+			   f->data.buf.size * 2);
 	if (!(newbuf = dm_realloc(f->data.buf.start,
 				   f->data.buf.size * 2))) {
 		log_error("Buffer reallocation failed.");
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 227289f..24fd318 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -427,8 +427,8 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 	else
-		log_debug("Volume group name found in metadata does "
-			  "not match expected name %s.", vgname);
+		log_debug_metadata("Volume group name found in metadata does "
+				   "not match expected name %s.", vgname);
 
       bad:
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)))
@@ -495,7 +495,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(area, mdah, vgname, &precommitted))) {
-		log_debug("VG %s not found on %s", vgname, dev_name(area->dev));
+		log_debug_metadata("VG %s not found on %s", vgname, dev_name(area->dev));
 		goto out;
 	}
 
@@ -516,10 +516,10 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 				     wrap, calc_crc, rlocn->checksum, &when,
 				     &desc)))
 		goto_out;
-	log_debug("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
-		  PRIu64, vg->name, precommitted ? "pre-commit " : "",
-		  vg->seqno, dev_name(area->dev),
-		  area->start + rlocn->offset, rlocn->size);
+	log_debug_metadata("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
+			   PRIu64, vg->name, precommitted ? "pre-commit " : "",
+			   vg->seqno, dev_name(area->dev),
+			   area->start + rlocn->offset, rlocn->size);
 
 	if (precommitted)
 		vg->status |= PRECOMMITTED;
@@ -625,9 +625,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
-	log_debug("Writing %s metadata to %s at %" PRIu64 " len %" PRIu64,
-		  vg->name, dev_name(mdac->area.dev), mdac->area.start +
-		  mdac->rlocn.offset, mdac->rlocn.size - new_wrap);
+	log_debug_metadata("Writing %s metadata to %s at %" PRIu64 " len %" PRIu64,
+			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
+			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap);
 
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
@@ -636,9 +636,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto_out;
 
 	if (new_wrap) {
-               log_debug("Writing metadata to %s at %" PRIu64 " len %" PRIu64,
-			  dev_name(mdac->area.dev), mdac->area.start +
-			  MDA_HEADER_SIZE, new_wrap);
+		log_debug_metadata("Writing metadata to %s at %" PRIu64 " len %" PRIu64,
+				  dev_name(mdac->area.dev), mdac->area.start +
+				  MDA_HEADER_SIZE, new_wrap);
 
 		if (!dev_write(mdac->area.dev,
 			       mdac->area.start + MDA_HEADER_SIZE,
@@ -730,13 +730,13 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug("%sCommitting %s metadata (%u) to %s header at %"
+		log_debug_metadata("%sCommitting %s metadata (%u) to %s header at %"
 			  PRIu64, precommit ? "Pre-" : "", vg->name, vg->seqno,
 			  dev_name(mdac->area.dev), mdac->area.start);
 	} else
-		log_debug("Wiping pre-committed %s metadata from %s "
-			  "header at %" PRIu64, vg->name,
-			  dev_name(mdac->area.dev), mdac->area.start);
+		log_debug_metadata("Wiping pre-committed %s metadata from %s "
+				   "header at %" PRIu64, vg->name,
+				   dev_name(mdac->area.dev), mdac->area.start);
 
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
@@ -862,7 +862,7 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 			  read_path, vgname);
 		return NULL;
 	} else
-		log_debug("Read volume group %s from %s", vg->name, read_path);
+		log_debug_metadata("Read volume group %s from %s", vg->name, read_path);
 
 	return vg;
 }
@@ -929,7 +929,7 @@ static int _vg_write_file(struct format_instance *fid __attribute__((unused)),
 		return 0;
 	}
 
-	log_debug("Writing %s metadata to %s", vg->name, temp_file);
+	log_debug_metadata("Writing %s metadata to %s", vg->name, temp_file);
 
 	if (!text_vg_export_file(vg, tc->desc, fp)) {
 		log_error("Failed to write metadata to %s.", temp_file);
@@ -949,7 +949,7 @@ static int _vg_write_file(struct format_instance *fid __attribute__((unused)),
 		return_0;
 
 	if (rename(temp_file, tc->path_edit)) {
-		log_debug("Renaming %s to %s", temp_file, tc->path_edit);
+		log_debug_metadata("Renaming %s to %s", temp_file, tc->path_edit);
 		log_error("%s: rename to %s failed: %s", temp_file,
 			  tc->path_edit, strerror(errno));
 		return 0;
@@ -968,13 +968,13 @@ static int _vg_commit_file_backup(struct format_instance *fid __attribute__((unu
 		log_verbose("Test mode: Skipping committing %s metadata (%u)",
 			    vg->name, vg->seqno);
 		if (unlink(tc->path_edit)) {
-			log_debug("Unlinking %s", tc->path_edit);
+			log_debug_metadata("Unlinking %s", tc->path_edit);
 			log_sys_error("unlink", tc->path_edit);
 			return 0;
 		}
 	} else {
-		log_debug("Committing %s metadata (%u)", vg->name, vg->seqno);
-		log_debug("Renaming %s to %s", tc->path_edit, tc->path_live);
+		log_debug_metadata("Committing %s metadata (%u)", vg->name, vg->seqno);
+		log_debug_metadata("Renaming %s to %s", tc->path_edit, tc->path_live);
 		if (rename(tc->path_edit, tc->path_live)) {
 			log_error("%s: rename to %s failed: %s", tc->path_edit,
 				  tc->path_live, strerror(errno));
@@ -1008,7 +1008,7 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 		len = slash - tc->path_live;
 		strncpy(new_name, tc->path_live, len);
 		strcpy(new_name + len, vg->name);
-		log_debug("Renaming %s to %s", tc->path_live, new_name);
+		log_debug_metadata("Renaming %s to %s", tc->path_live, new_name);
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename");
 		else {
@@ -1186,11 +1186,11 @@ const char *vgname_from_mda(const struct format_type *fmt,
 		goto_out;
 	}
 
-	log_debug("%s: Found metadata at %" PRIu64 " size %" PRIu64
-		  " (in area at %" PRIu64 " size %" PRIu64
-		  ") for %s (%s)",
-		  dev_name(dev_area->dev), dev_area->start + rlocn->offset,
-		  rlocn->size, dev_area->start, dev_area->size, vgname, uuid);
+	log_debug_metadata("%s: Found metadata at %" PRIu64 " size %" PRIu64
+			   " (in area at %" PRIu64 " size %" PRIu64
+			   ") for %s (%s)",
+			   dev_name(dev_area->dev), dev_area->start + rlocn->offset,
+			   rlocn->size, dev_area->start, dev_area->size, vgname, uuid);
 
 	if (mda_free_sectors) {
 		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
@@ -1320,11 +1320,11 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 			continue;
 
 		mdac = (struct mda_context *) mda->metadata_locn;
-		log_debug("Creating metadata area on %s at sector %"
-			  PRIu64 " size %" PRIu64 " sectors",
-			  dev_name(mdac->area.dev),
-			  mdac->area.start >> SECTOR_SHIFT,
-			  mdac->area.size >> SECTOR_SHIFT);
+		log_debug_metadata("Creating metadata area on %s at sector %"
+				   PRIu64 " size %" PRIu64 " sectors",
+				   dev_name(mdac->area.dev),
+				   mdac->area.start >> SECTOR_SHIFT,
+				   mdac->area.size >> SECTOR_SHIFT);
 
 		// if fmt is not the same as info->fmt we are in trouble
 		lvmcache_add_mda(info, mdac->area.dev,
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index f53aa0d..9d50334 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -123,32 +123,32 @@ static int _text_write(struct label *label, void *buf)
 		 !xlate64(pvhdr->disk_areas_xl[mda2].size))
 		mda2 = 0;
 
-	log_debug("%s: Preparing PV label header %s size %" PRIu64 " with"
-		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
-		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
-		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
-		  dev_name(lvmcache_device(info)), buffer, lvmcache_device_size(info),
-		  (da1 > -1) ? " da1 (" : "",
-		  (da1 > -1) ? 1 : 0,
-		  (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
-		  (da1 > -1) ? "s, " : "",
-		  (da1 > -1) ? 1 : 0,
-		  (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].size) >> SECTOR_SHIFT : 0,
-		  (da1 > -1) ? "s)" : "",
-		  mda1 ? " mda1 (" : "",
-		  mda1 ? 1 : 0,
-		  mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].offset) >> SECTOR_SHIFT : 0,
-		  mda1 ? "s, " : "",
-		  mda1 ? 1 : 0,
-		  mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].size) >> SECTOR_SHIFT : 0,
-		  mda1 ? "s)" : "",
-		  mda2 ? " mda2 (" : "",
-		  mda2 ? 1 : 0,
-		  mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].offset) >> SECTOR_SHIFT : 0,
-		  mda2 ? "s, " : "",
-		  mda2 ? 1 : 0,
-		  mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].size) >> SECTOR_SHIFT : 0,
-		  mda2 ? "s)" : "");
+	log_debug_metadata("%s: Preparing PV label header %s size %" PRIu64 " with"
+			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
+			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
+			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
+			   dev_name(lvmcache_device(info)), buffer, lvmcache_device_size(info),
+			   (da1 > -1) ? " da1 (" : "",
+			   (da1 > -1) ? 1 : 0,
+			   (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
+			   (da1 > -1) ? "s, " : "",
+			   (da1 > -1) ? 1 : 0,
+			   (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].size) >> SECTOR_SHIFT : 0,
+			   (da1 > -1) ? "s)" : "",
+			   mda1 ? " mda1 (" : "",
+			   mda1 ? 1 : 0,
+			   mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].offset) >> SECTOR_SHIFT : 0,
+			   mda1 ? "s, " : "",
+			   mda1 ? 1 : 0,
+			   mda1 ? xlate64(pvhdr->disk_areas_xl[mda1].size) >> SECTOR_SHIFT : 0,
+			   mda1 ? "s)" : "",
+			   mda2 ? " mda2 (" : "",
+			   mda2 ? 1 : 0,
+			   mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].offset) >> SECTOR_SHIFT : 0,
+			   mda2 ? "s, " : "",
+			   mda2 ? 1 : 0,
+			   mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].size) >> SECTOR_SHIFT : 0,
+			   mda2 ? "s)" : "");
 
 	if (da1 < 0) {
 		log_error(INTERNAL_ERROR "%s label header currently requires "
@@ -294,9 +294,9 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 	if (mda_is_ignored(mda)) {
-		log_debug("Ignoring mda on device %s at offset %"PRIu64,
-			  dev_name(mdac->area.dev),
-			  mdac->area.start);
+		log_debug_metadata("Ignoring mda on device %s at offset %"PRIu64,
+				   dev_name(mdac->area.dev),
+				   mdac->area.start);
 		if (!dev_close(mdac->area.dev))
 			stack;
 		return 1;
diff --git a/lib/label/label.c b/lib/label/label.c
index b1124fc..a38ba68 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -112,7 +112,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 
 	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
 		      LABEL_SCAN_SIZE, readbuf)) {
-		log_debug("%s: Failed to read label area", dev_name(dev));
+		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
 
@@ -208,7 +208,7 @@ int label_remove(struct device *dev)
 	dev_flush(dev);
 
 	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, readbuf)) {
-		log_debug("%s: Failed to read label area", dev_name(dev));
+		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
 
@@ -263,7 +263,7 @@ int label_read(struct device *dev, struct label **result,
 	int r = 0;
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, 1))) {
-		log_debug("Using cached label for %s", dev_name(dev));
+		log_debug_devs("Using cached label for %s", dev_name(dev));
 		*result = lvmcache_get_label(info);
 		return 1;
 	}
@@ -329,7 +329,7 @@ int label_write(struct device *dev, struct label *label)
 		 PRIu32 ".", dev_name(dev), label->sector,
 		 xlate32(lh->offset_xl));
 	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
-		log_debug("Failed to write label to %s", dev_name(dev));
+		log_debug_devs("Failed to write label to %s", dev_name(dev));
 		r = 0;
 	}
 
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index f9d6328..01a47b0 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -560,8 +560,8 @@ int query_resource(const char *resource, int *mode)
 		if (decode_lock_type(response[i].response) > *mode)
 			*mode = decode_lock_type(response[i].response);
 
-		log_debug("Lock held for %s, node %s : %s", resource,
-			  response[i].node, response[i].response);
+		log_debug_locking("Lock held for %s, node %s : %s", resource,
+				  response[i].node, response[i].response);
 	}
 
 	_cluster_free_request(response, num_responses);
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 7755ae4..2b7bfe2 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -48,7 +48,7 @@ static void _undo_flock(const char *file, int fd)
 {
 	struct stat buf1, buf2;
 
-	log_debug("_undo_flock %s", file);
+	log_debug_locking("_undo_flock %s", file);
 	if (!flock(fd, LOCK_NB | LOCK_EX) &&
 	    !stat(file, &buf1) &&
 	    !fstat(fd, &buf2) &&
@@ -137,8 +137,8 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 	int old_errno;
 	struct stat buf1, buf2;
 
-	log_debug("_do_flock %s %c%c",
-		  file, operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
+	log_debug_locking("_do_flock %s %c%c", file,
+			  operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
 	do {
 		if ((*fd > -1) && close(*fd))
 			log_sys_error("close", file);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 7aa519b..6f31ba8 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -426,7 +426,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 
 
 	if (flags == LCK_NONE) {
-		log_debug(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
+		log_debug_locking(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
 		return 1;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 35a75ff..c1437eb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1039,8 +1039,8 @@ static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_are
 		}
 
 		pvnames = dm_pool_end_object(mem);
-		log_debug("Parallel PVs at LE %" PRIu32 " length %" PRIu32 ": %s",
-			  spvs->le, spvs->len, pvnames);
+		log_debug_alloc("Parallel PVs at LE %" PRIu32 " length %" PRIu32 ": %s",
+				spvs->le, spvs->len, pvnames);
 		dm_pool_free(mem, pvnames);
 	}
 
@@ -1168,12 +1168,12 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 			aa[s].pe = pva->start;
 			aa[s].len = ah->log_len;
 
-			log_debug("Allocating parallel metadata area %" PRIu32
-				  " on %s start PE %" PRIu32
-				  " length %" PRIu32 ".",
-				  (s - (ah->area_count + ah->parity_count)),
-				  pv_dev_name(aa[s].pv), aa[s].pe,
-				  ah->log_len);
+			log_debug_alloc("Allocating parallel metadata area %" PRIu32
+					" on %s start PE %" PRIu32
+					" length %" PRIu32 ".",
+					(s - (ah->area_count + ah->parity_count)),
+					pv_dev_name(aa[s].pv), aa[s].pe,
+					ah->log_len);
 
 			consume_pv_area(pva, ah->log_len);
 			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
@@ -1187,9 +1187,9 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 		aa[s].pv = pva->map->pv;
 		aa[s].pe = pva->start;
 
-		log_debug("Allocating parallel area %" PRIu32
-			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
-			  s, pv_dev_name(aa[s].pv), aa[s].pe, aa[s].len);
+		log_debug_alloc("Allocating parallel area %" PRIu32
+				" on %s start PE %" PRIu32 " length %" PRIu32 ".",
+				s, pv_dev_name(aa[s].pv), aa[s].pe, aa[s].len);
 
 		consume_pv_area(pva, aa[s].len);
 
@@ -1366,8 +1366,8 @@ static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn
 			if (!str_list_match_list(&pv1->tags, &pv2->tags, &tag_matched))
 				continue;
 			else {
-				log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
-					  tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
+				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+						tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
 				return 1;
 			}
 		}
@@ -1376,8 +1376,8 @@ static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn
 		    !str_list_match_item(&pv2->tags, str))
 			continue;
 		else {
-			log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
-				  str, pv_dev_name(pv1), pv_dev_name(pv2));
+			log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+					str, pv_dev_name(pv1), pv_dev_name(pv2));
 			return 1;
 		}
 	}
@@ -1407,11 +1407,11 @@ static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct
 static void _reserve_area(struct pv_area_used *area_used, struct pv_area *pva, uint32_t required,
 			  uint32_t ix_pva, uint32_t unreserved)
 {
-	log_debug("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
-		  " length %" PRIu32 " leaving %" PRIu32 ".",
-		  area_used->pva ? "Changing   " : "Considering", 
-		  ix_pva - 1, area_used->pva ? "to" : "as", 
-		  dev_name(pva->map->pv->dev), pva->start, required, unreserved);
+	log_debug_alloc("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
+			" length %" PRIu32 " leaving %" PRIu32 ".",
+			area_used->pva ? "Changing   " : "Considering", 
+			ix_pva - 1, area_used->pva ? "to" : "as", 
+			dev_name(pva->map->pv->dev), pva->start, required, unreserved);
 
 	area_used->pva = pva;
 	area_used->used = required;
@@ -1717,13 +1717,13 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
-	log_debug("Still need %" PRIu32 " total extents:",
-		parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
-	log_debug("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
-		  " parity) parallel areas of %" PRIu32 " extents each",
-		  parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
-	log_debug("  %" PRIu32 " %ss of %" PRIu32 " extents each",
-		  metadata_count, metadata_type, metadata_size);
+	log_debug_alloc("Still need %" PRIu32 " total extents:",
+			parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
+	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
+			" parity) parallel areas of %" PRIu32 " extents each",
+			parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
+	log_debug_alloc("  %" PRIu32 " %ss of %" PRIu32 " extents each",
+			metadata_count, metadata_type, metadata_size);
 }
 /*
  * Returns 1 regardless of whether any space was found, except on error.
@@ -1756,8 +1756,8 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 		ix_offset = ah->area_count;
 
 	if (alloc_parms->alloc == ALLOC_NORMAL || (alloc_parms->flags & A_CLING_TO_ALLOCED))
-		log_debug("Cling_to_allocated is %sset",
-			  alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
+		log_debug_alloc("Cling_to_allocated is %sset",
+				alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 
 	_clear_areas(alloc_state);
 	_reset_unreserved(pvms);
@@ -1767,9 +1767,9 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 	/* ix holds the number of areas found on other PVs */
 	do {
 		if (log_iteration_count) {
-			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, devices_needed, alloc_state->log_area_count_still_needed);
+			log_debug_alloc("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, devices_needed, alloc_state->log_area_count_still_needed);
 		} else if (iteration_count)
-			log_debug("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
+			log_debug_alloc("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
 
 		/*
 		 * Provide for escape from the loop if no progress is made.
@@ -1889,12 +1889,12 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 	/* Sort the areas so we allocate from the biggest */
 	if (log_iteration_count) {
 		if (ix > devices_needed + 1) {
-			log_debug("Sorting %u log areas", ix - devices_needed);
+			log_debug_alloc("Sorting %u log areas", ix - devices_needed);
 			qsort(alloc_state->areas + devices_needed, ix - devices_needed, sizeof(*alloc_state->areas),
 			      _comp_area);
 		}
 	} else if (ix > 1) {
-		log_debug("Sorting %u areas", ix);
+		log_debug_alloc("Sorting %u areas", ix);
 		qsort(alloc_state->areas + ix_offset, ix, sizeof(*alloc_state->areas),
 		      _comp_area);
 	}
@@ -2107,7 +2107,7 @@ static int _allocate(struct alloc_handle *ah,
 		if (alloc == ALLOC_CLING_BY_TAGS && !ah->cling_tag_list_cn)
 			continue;
 		old_allocated = alloc_state.allocated;
-		log_debug("Trying allocation using %s policy.", get_alloc_string(alloc));
+		log_debug_alloc("Trying allocation using %s policy.", get_alloc_string(alloc));
 
 		if (!_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
 			goto_out;
@@ -3273,7 +3273,7 @@ void lv_set_visible(struct logical_volume *lv)
 
 	lv->status |= VISIBLE_LV;
 
-	log_debug("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
+	log_debug_metadata("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
 }
 
 void lv_set_hidden(struct logical_volume *lv)
@@ -3283,7 +3283,7 @@ void lv_set_hidden(struct logical_volume *lv)
 
 	lv->status &= ~VISIBLE_LV;
 
-	log_debug("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
+	log_debug_metadata("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
 }
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -3999,10 +3999,10 @@ static int _match_seg_area_to_pe_range(struct lv_segment *seg, uint32_t s,
 			continue;
 
 		/* FIXME Missing context in this message - add LV/seg details */
-		log_debug("Matched PE range %s:%" PRIu32 "-%" PRIu32 " against "
-			  "%s %" PRIu32 " len %" PRIu32, dev_name(pvl->pv->dev),
-			  per->start, per_end, dev_name(seg_dev(seg, s)),
-			  seg_pe(seg, s), seg->area_len);
+		log_debug_alloc("Matched PE range %s:%" PRIu32 "-%" PRIu32 " against "
+				"%s %" PRIu32 " len %" PRIu32, dev_name(pvl->pv->dev),
+				per->start, per_end, dev_name(seg_dev(seg, s)),
+				seg_pe(seg, s), seg->area_len);
 
 		return 1;
 	}
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f7c05a2..a4563f8 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -474,9 +474,9 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 			if (!set_lv_segment_area_lv(split_seg, s, seg_lv(seg, s),
 						    seg_le(seg, s) + seg->area_len, 0))
 				return_0;
-			log_debug("Split %s:%u[%u] at %u: %s LE %u", lv->name,
-				  seg->le, s, le, seg_lv(seg, s)->name,
-				  seg_le(split_seg, s));
+			log_debug_alloc("Split %s:%u[%u] at %u: %s LE %u", lv->name,
+					seg->le, s, le, seg_lv(seg, s)->name,
+					seg_le(split_seg, s));
 			break;
 
 		case AREA_PV:
@@ -488,10 +488,10 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 						     seg->area_len,
 						 split_seg, s)))
 				return_0;
-			log_debug("Split %s:%u[%u] at %u: %s PE %u", lv->name,
-				  seg->le, s, le,
-				  dev_name(seg_dev(seg, s)),
-				  seg_pe(split_seg, s));
+			log_debug_alloc("Split %s:%u[%u] at %u: %s PE %u", lv->name,
+					seg->le, s, le,
+					dev_name(seg_dev(seg, s)),
+					seg_pe(split_seg, s));
 			break;
 
 		case AREA_UNASSIGNED:
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a472b18..0b774ac 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1078,7 +1078,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
 		return NULL;
 	}
 
-	log_debug("Selected %" PRIu32 " random bits from %" PRIu32 ": %s", num_set_bits, num_bits, (char *) dm_pool_end_object(mem));
+	log_debug_metadata("Selected %" PRIu32 " random bits from %" PRIu32 ": %s", num_set_bits, num_bits, (char *) dm_pool_end_object(mem));
 
 	return bs;
 }
@@ -1090,9 +1090,9 @@ static int _vg_ignore_mdas(struct volume_group *vg, uint32_t num_to_ignore)
 	dm_bitset_t mda_to_ignore_bs;
 	int r = 1;
 
-	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
-		  "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
-		  vg->name, mda_used_count, vg_mda_count(vg), vg_mda_copies(vg), num_to_ignore);
+	log_debug_metadata("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
+			   "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
+			   vg->name, mda_used_count, vg_mda_count(vg), vg_mda_copies(vg), num_to_ignore);
 
 	if (!num_to_ignore)
 		return 1;
@@ -1131,9 +1131,9 @@ static int _vg_unignore_mdas(struct volume_group *vg, uint32_t num_to_unignore)
 	if (!num_to_unignore)
 		return 1;
 
-	log_debug("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
-		  "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
-		  vg->name, mda_used_count, mda_count, vg_mda_copies(vg), num_to_unignore);
+	log_debug_metadata("Adjusting ignored mdas for %s: %" PRIu32 " of %" PRIu32 " mdas in use "
+			   "but %" PRIu32 " required.  Changing %" PRIu32 " mda.",
+			   vg->name, mda_used_count, mda_count, vg_mda_copies(vg), num_to_unignore);
 
 	if (!(mda_to_unignore_bs = _bitset_with_random_bits(vg->vgmem, mda_free_count,
 							    num_to_unignore, &vg->cmd->rand_seed)))
@@ -2247,7 +2247,7 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 		_lv_postorder((struct logical_volume *)lv, _lv_read_ahead_single, &_read_ahead);
 
 	if (read_ahead) {
-		log_debug("Calculated readahead of LV %s is %u", lv->name, _read_ahead);
+		log_debug_metadata("Calculated readahead of LV %s is %u", lv->name, _read_ahead);
 		*read_ahead = _read_ahead;
 	}
 }
@@ -3104,7 +3104,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 						return_NULL;
 					}
 
-					log_debug("Empty mda found for VG %s.", vgname);
+					log_debug_metadata("Empty mda found for VG %s.", vgname);
 
 					if (inconsistent_mdas)
 						continue;
@@ -3120,8 +3120,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 			/* If the check passed, let's update VG and recalculate pvids */
 			if (!inconsistent_pvs) {
-				log_debug("Updating cache for PVs without mdas "
-					  "in VG %s.", vgname);
+				log_debug_metadata("Updating cache for PVs without mdas "
+						   "in VG %s.", vgname);
 				/*
 				 * If there is no precommitted metadata, committed metadata
 				 * is read and stored in the cache even if use_precommitted is set
@@ -3138,8 +3138,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		fid->ref_count++;
 		if (dm_list_size(&correct_vg->pvs) !=
 		    dm_list_size(pvids) + vg_missing_pv_count(correct_vg)) {
-			log_debug("Cached VG %s had incorrect PV list",
-				  vgname);
+			log_debug_metadata("Cached VG %s had incorrect PV list",
+					   vgname);
 
 			if (critical_section())
 				inconsistent = 1;
@@ -3151,8 +3151,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (is_missing_pv(pvl->pv))
 				continue;
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
-				log_debug("Cached VG %s had incorrect PV list",
-					  vgname);
+				log_debug_metadata("Cached VG %s had incorrect PV list",
+						   vgname);
 				release_vg(correct_vg);
 				correct_vg = NULL;
 				break;
@@ -3287,7 +3287,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			 */
 			dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 				if (mda->status & MDA_INCONSISTENT) {
-					log_debug("Checking inconsistent MDA: %s", dev_name(mda_get_device(mda)));
+					log_debug_metadata("Checking inconsistent MDA: %s", dev_name(mda_get_device(mda)));
 					dm_list_iterate_items(pvl, &correct_vg->pvs) {
 						if (mda_get_device(mda) == pvl->pv->dev &&
 						    (pvl->pv->status & MISSING_PV))
@@ -4471,10 +4471,10 @@ void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
 	else
 		return;	/* No change */
 
-	log_debug("%s ignored flag for mda %s at offset %" PRIu64 ".", 
-		  mda_ignored ? "Setting" : "Clearing",
-		  mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
-		  mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
+	log_debug_metadata("%s ignored flag for mda %s at offset %" PRIu64 ".", 
+			   mda_ignored ? "Setting" : "Clearing",
+			   mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
+			   mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
 }
 
 int mdas_empty_or_ignored(struct dm_list *mdas)
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index d04ecab..83aa9af 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -232,8 +232,8 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 		discard_area_reduction--;
 	}
 
-	log_debug("Discarding %" PRIu32 " extents offset %" PRIu64 " sectors on %s.",
-		  discard_area_reduction, discard_offset_sectors, dev_name(peg->pv->dev));
+	log_debug_alloc("Discarding %" PRIu32 " extents offset %" PRIu64 " sectors on %s.",
+			discard_area_reduction, discard_offset_sectors, dev_name(peg->pv->dev));
 	if (discard_area_reduction &&
 	    !dev_discard_blocks(peg->pv->dev, discard_offset_sectors << SECTOR_SHIFT,
 				discard_area_reduction * (uint64_t) peg->pv->vg->extent_size * SECTOR_SIZE))
@@ -344,10 +344,10 @@ int check_pv_segments(struct volume_group *vg)
 			s = peg->lv_area;
 
 			/* FIXME Remove this next line eventually */
-			log_debug("%s %u: %6u %6u: %s(%u:%u)",
-				  pv_dev_name(pv), segno++, peg->pe, peg->len,
-				  peg->lvseg ? peg->lvseg->lv->name : "NULL",
-				  peg->lvseg ? peg->lvseg->le : 0, s);
+			log_debug_alloc("%s %u: %6u %6u: %s(%u:%u)",
+					pv_dev_name(pv), segno++, peg->pe, peg->len,
+					peg->lvseg ? peg->lvseg->lv->name : "NULL",
+					peg->lvseg ? peg->lvseg->le : 0, s);
 			/* FIXME Add details here on failure instead */
 			if (start_pe != peg->pe) {
 				log_error("Gap in pvsegs: %u, %u",
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 48a601e..4423a7d 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -50,8 +50,8 @@ static int _create_single_area(struct dm_pool *mem, struct pv_map *pvm,
 	if (!(pva = dm_pool_zalloc(mem, sizeof(*pva))))
 		return_0;
 
-	log_debug("Allowing allocation on %s start PE %" PRIu32 " length %"
-		  PRIu32, pv_dev_name(pvm->pv), start, length);
+	log_debug_alloc("Allowing allocation on %s start PE %" PRIu32 " length %"
+			PRIu32, pv_dev_name(pvm->pv), start, length);
 	pva->map = pvm;
 	pva->start = start;
 	pva->count = length;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b902d3d..3031506 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -161,12 +161,12 @@ static int _lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 
 	dm_list_iterate_items(pvl, pvs)
 		if (_lv_is_on_pv(lv, pvl->pv)) {
-			log_debug("%s is on %s", lv->name,
-				  pv_dev_name(pvl->pv));
+			log_debug_metadata("%s is on %s", lv->name,
+					   pv_dev_name(pvl->pv));
 			return 1;
 		} else
-			log_debug("%s is not on %s", lv->name,
-				  pv_dev_name(pvl->pv));
+			log_debug_metadata("%s is not on %s", lv->name,
+					   pv_dev_name(pvl->pv));
 	return 0;
 }
 
@@ -182,8 +182,8 @@ static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
 		return 0;
 	}
 
-	log_debug("Getting list of PVs that %s/%s is on:",
-		  lv->vg->name, lv->name);
+	log_debug_metadata("Getting list of PVs that %s/%s is on:",
+			   lv->vg->name, lv->name);
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
@@ -200,8 +200,8 @@ static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
 			}
 
 			pvl->pv = seg_pv(seg, s);
-			log_debug("  %s/%s is on %s", lv->vg->name, lv->name,
-				  pv_dev_name(pvl->pv));
+			log_debug_metadata("  %s/%s is on %s", lv->vg->name, lv->name,
+					   pv_dev_name(pvl->pv));
 			dm_list_add(pvs, &pvl->list);
 		}
 	}
@@ -340,7 +340,7 @@ static int _clear_lvs(struct dm_list *lv_list)
 	struct volume_group *vg = NULL;
 
 	if (dm_list_empty(lv_list)) {
-		log_debug(INTERNAL_ERROR "Empty list of LVs given for clearing");
+		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing");
 		return 1;
 	}
 
@@ -774,8 +774,8 @@ to be left for these sub-lvs.
 
 	/* Set segment areas for metadata sub_lvs */
 	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug("Adding %s to %s",
-			  lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s",
+				   lvl->lv->name, lv->name);
 		lvl->lv->status &= status_mask;
 		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
@@ -791,8 +791,8 @@ to be left for these sub-lvs.
 
 	/* Set segment areas for data sub_lvs */
 	dm_list_iterate_items(lvl, &data_lvs) {
-		log_debug("Adding %s to %s",
-			  lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s",
+				   lvl->lv->name, lv->name);
 		lvl->lv->status &= status_mask;
 		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
@@ -1468,8 +1468,8 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	}
 
 	for (s = 0; s < seg->area_count; s++) {
-		log_debug("Allocating new metadata LV for %s",
-			  seg_lv(seg, s)->name);
+		log_debug_metadata("Allocating new metadata LV for %s",
+				   seg_lv(seg, s)->name);
 		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv))) {
 			log_error("Failed to allocate metadata LV for %s in %s",
 				  seg_lv(seg, s)->name, lv->name);
@@ -1478,14 +1478,14 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		dm_list_add(&meta_lvs, &(lvl_array[s].list));
 	}
 
-	log_debug("Clearing newly allocated metadata LVs");
+	log_debug_metadata("Clearing newly allocated metadata LVs");
 	if (!_clear_lvs(&meta_lvs)) {
 		log_error("Failed to initialize metadata LVs");
 		return 0;
 	}
 
 	if (seg->log_lv) {
-		log_debug("Removing mirror log, %s", seg->log_lv->name);
+		log_debug_metadata("Removing mirror log, %s", seg->log_lv->name);
 		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
 			log_error("Failed to remove mirror log");
 			return 0;
@@ -1496,7 +1496,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	s = 0;
 
 	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug("Adding %s to %s", lvl->lv->name, lv->name);
+		log_debug_metadata("Adding %s to %s", lvl->lv->name, lv->name);
 
 		/* Images are known to be in-sync */
 		lvl->lv->status &= ~LV_REBUILD;
@@ -1524,14 +1524,14 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		}
 
 		sprintf(new_name, "%s_rimage_%u", lv->name, s);
-		log_debug("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
+		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
 		seg_lv(seg, s)->name = new_name;
 		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
 		seg_lv(seg, s)->status |= RAID_IMAGE;
 	}
 	init_mirror_in_sync(1);
 
-	log_debug("Setting new segtype for %s", lv->name);
+	log_debug_metadata("Setting new segtype for %s", lv->name);
 	seg->segtype = new_segtype;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 2853e50..f264c7c 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -568,7 +568,7 @@ int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs)
 	dm_list_iterate_items(cvl, cmd_vgs) {
 		cvl->vg = vg_read(cmd, cvl->vg_name, cvl->vgid, cvl->flags);
 		if (vg_read_error(cvl->vg)) {
-			log_debug("Failed to vg_read %s", cvl->vg_name);
+			log_debug_metadata("Failed to vg_read %s", cvl->vg_name);
 			return 0;
 		}
 		cvl->vg->cmd_vgs = cmd_vgs;	/* Make it usable in VG */
@@ -621,7 +621,7 @@ int find_replicator_vgs(struct logical_volume *lv)
 			break;
 		}
 
-		log_debug("VG: %s added as missing.", rsite->vg_name);
+		log_debug_metadata("VG: %s added as missing.", rsite->vg_name);
 		lv->vg->cmd_missing_vgs++;
 	}
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e2762a0..016f776 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -89,8 +89,8 @@ int detach_pool_lv(struct lv_segment *seg)
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			if (tmsg->u.lv == seg->lv) {
-				log_debug("Discarding message for LV %s.",
-					  tmsg->u.lv->name);
+				log_debug_metadata("Discarding message for LV %s.",
+						   tmsg->u.lv->name);
 				dm_list_del(&tmsg->list);
 				no_update = 1; /* Replacing existing */
 			}
@@ -186,10 +186,10 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 
 	dm_list_add(&pool_seg->thin_messages, &tmsg->list);
 
-	log_debug("Added %s message",
-		  (type == DM_THIN_MESSAGE_CREATE_SNAP ||
-		   type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
-		  (type == DM_THIN_MESSAGE_DELETE) ? "delete" : "unknown");
+	log_debug_metadata("Added %s message",
+			   (type == DM_THIN_MESSAGE_CREATE_SNAP ||
+			   type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
+			   (type == DM_THIN_MESSAGE_DELETE) ? "delete" : "unknown");
 
 	return 1;
 }
@@ -306,7 +306,7 @@ uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
 		return 0;
 	}
 
-	log_debug("Found free pool device_id %u.", max_id);
+	log_debug_metadata("Found free pool device_id %u.", max_id);
 
 	return max_id;
 }
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 2897d42..a868df7 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -56,7 +56,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
-	log_debug("Allocated VG %s at %p.", vg->name, vg);
+	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
 
 	return vg;
 }
@@ -71,7 +71,7 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
-	log_debug("Freeing VG %s at %p.", vg->name, vg);
+	log_debug_mem("Freeing VG %s at %p.", vg->name, vg);
 
 	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
@@ -260,8 +260,8 @@ int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
 	vg->mda_copies = mda_copies;
 
 	/* FIXME Use log_verbose when this is due to specific cmdline request. */
-	log_debug("Setting mda_copies to %"PRIu32" for VG %s",
-		    mda_copies, vg->name);
+	log_debug_metadata("Setting mda_copies to %"PRIu32" for VG %s",
+			   mda_copies, vg->name);
 
 	return 1;
 }
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 7ce8475..23a6371 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -187,7 +187,7 @@ static int _mirrored_target_percent(void **target_state,
 		*target_state = _mirrored_init_target(mem, cmd);
 
 	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
-	log_debug("Mirror status: %s", params);
+	log_debug_activation("Mirror status: %s", params);
 
 	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
 		log_error("Failure parsing mirror status mirror count: %s",
@@ -288,7 +288,7 @@ static int _mirrored_transient_status(struct lv_segment *seg, char *params)
 				  log->name);
 			return 0;
 		}
-		log_debug("Found mirror log at %d:%d", info.major, info.minor);
+		log_debug_activation("Found mirror log at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		if (strcmp(buf, log_args[1])) {
 			log_error("Mirror log mismatch. Metadata says %s, kernel says %s.",
@@ -312,11 +312,11 @@ static int _mirrored_transient_status(struct lv_segment *seg, char *params)
 				  seg_lv(seg, i)->name);
 			return 0;
 		}
-		log_debug("Found mirror image at %d:%d", info.major, info.minor);
+		log_debug_activation("Found mirror image at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		for (j = 0; j < num_devs; ++j) {
 			if (!strcmp(buf, args[j])) {
-			    log_debug("Match: metadata image %d matches kernel image %d", i, j);
+			    log_debug_activation("Match: metadata image %d matches kernel image %d", i, j);
 			    images[j] = seg_lv(seg, i);
 			}
 		}
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 35d87ff..3c5d545 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -136,9 +136,9 @@ void init_is_static(unsigned value)
 void init_udev_checking(int checking)
 {
 	if ((_udev_checking = checking))
-		log_debug("LVM udev checking enabled");
+		log_debug_activation("LVM udev checking enabled");
 	else
-		log_debug("LVM udev checking disabled");
+		log_debug_activation("LVM udev checking disabled");
 }
 
 void init_retry_deactivation(int retry)
@@ -149,9 +149,9 @@ void init_retry_deactivation(int retry)
 void init_activation_checks(int checks)
 {
 	if ((_activation_checks = checks))
-		log_debug("LVM activation checks enabled");
+		log_debug_activation("LVM activation checks enabled");
 	else
-		log_debug("LVM activation checks disabled");
+		log_debug_activation("LVM activation checks disabled");
 }
 
 void init_dev_disable_after_error_count(int value)
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 6cffae3..a96cd98 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -46,12 +46,12 @@ int udev_is_running(void)
 	int r;
 
 	if (!_udev) {
-		log_debug(_no_context_msg);
+		log_debug_activation(_no_context_msg);
 		goto bad;
 	}
 
 	if (!(udev_queue = udev_queue_new(_udev))) {
-		log_debug("Could not get udev state.");
+		log_debug_activation("Could not get udev state.");
 		goto bad;
 	}
 
@@ -61,7 +61,7 @@ int udev_is_running(void)
 	return r;
 
 bad:
-	log_debug("Assuming udev is not running.");
+	log_debug_activation("Assuming udev is not running.");
 	return 0;
 }
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 6d0996a..6defa66 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -171,15 +171,15 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 
 	/* Select readable maps */
 	if (fr != 'r') {
-		log_debug("%s area unreadable %s : Skipping.", lock_str, line);
+		log_debug_mem("%s area unreadable %s : Skipping.", lock_str, line);
 		return 1;
 	}
 
 	/* always ignored areas */
 	for (i = 0; i < sizeof(_ignore_maps) / sizeof(_ignore_maps[0]); ++i)
 		if (strstr(line + pos, _ignore_maps[i])) {
-			log_debug("%s ignore filter '%s' matches '%s': Skipping.",
-				  lock_str, _ignore_maps[i], line);
+			log_debug_mem("%s ignore filter '%s' matches '%s': Skipping.",
+				      lock_str, _ignore_maps[i], line);
 			return 1;
 		}
 
@@ -188,8 +188,8 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 		/* If no blacklist configured, use an internal set */
 		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
 			if (strstr(line + pos, _blacklist_maps[i])) {
-				log_debug("%s default filter '%s' matches '%s': Skipping.",
-					  lock_str, _blacklist_maps[i], line);
+				log_debug_mem("%s default filter '%s' matches '%s': Skipping.",
+					      lock_str, _blacklist_maps[i], line);
 				return 1;
 			}
 	} else {
@@ -197,8 +197,8 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0])
 				continue;
 			if (strstr(line + pos, cv->v.str)) {
-				log_debug("%s_filter '%s' matches '%s': Skipping.",
-					  lock_str, cv->v.str, line);
+				log_debug_mem("%s_filter '%s' matches '%s': Skipping.",
+					      lock_str, cv->v.str, line);
 				return 1;
 			}
 		}
@@ -213,8 +213,8 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 
 #endif
 	*mstats += sz;
-	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s", lock_str,
-		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
+	log_debug_mem("%s %10ldKiB %12lx - %12lx %c%c%c%c%s", lock_str,
+		      ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
 
 	if (lock == LVM_MLOCK) {
 		if (mlock((const void*)from, sz) < 0) {
@@ -299,8 +299,8 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 		line = line_end + 1;
 	}
 
-	log_debug("%socked %ld bytes",
-		  (lock == LVM_MLOCK) ? "L" : "Unl", (long)*mstats);
+	log_debug_mem("%socked %ld bytes",
+		      (lock == LVM_MLOCK) ? "L" : "Unl", (long)*mstats);
 
 	return ret;
 }
@@ -367,8 +367,8 @@ static void _unlock_mem(struct cmd_context *cmd)
 					  (long)_mstats, (long)unlock_mstats);
 			else
 				/* FIXME Believed due to incorrect use of yes_no_prompt while locks held */
-				log_debug("Suppressed internal error: Maps lock %ld < unlock %ld, a one-page difference.",
-					  (long)_mstats, (long)unlock_mstats);
+				log_debug_mem("Suppressed internal error: Maps lock %ld < unlock %ld, a one-page difference.",
+					      (long)_mstats, (long)unlock_mstats);
 		}
 	}
 
@@ -380,8 +380,8 @@ static void _unlock_mem(struct cmd_context *cmd)
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
-	log_debug("Lock:   Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
-		  _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
+	log_debug_mem("Lock:   Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
+		      _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (!_mem_locked &&
 	    ((_critical_section + _memlock_count_daemon) == 1)) {
 		_mem_locked = 1;
@@ -391,8 +391,8 @@ static void _lock_mem_if_needed(struct cmd_context *cmd)
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	log_debug("Unlock: Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
-		  _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
+	log_debug_mem("Unlock: Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
+		      _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (_mem_locked &&
 	    !_critical_section &&
 	    !_memlock_count_daemon) {
@@ -405,7 +405,7 @@ void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
 	if (!_critical_section) {
 		_critical_section = 1;
-		log_debug("Entering critical section (%s).", reason);
+		log_debug_mem("Entering critical section (%s).", reason);
 	}
 
 	_lock_mem_if_needed(cmd);
@@ -415,7 +415,7 @@ void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
 	if (_critical_section && !dm_get_suspended_counter()) {
 		_critical_section = 0;
-		log_debug("Leaving critical section (%s).", reason);
+		log_debug_mem("Leaving critical section (%s).", reason);
 	}
 }
 
@@ -436,7 +436,7 @@ void memlock_inc_daemon(struct cmd_context *cmd)
 	++_memlock_count_daemon;
 	if (_memlock_count_daemon == 1 && _critical_section > 0)
                 log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
-	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
+	log_debug_mem("memlock_count_daemon inc to %d", _memlock_count_daemon);
 	_lock_mem_if_needed(cmd);
 }
 
@@ -445,7 +445,7 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 	if (!_memlock_count_daemon)
 		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
-	log_debug("memlock_count_daemon dec to %d", _memlock_count_daemon);
+	log_debug_mem("memlock_count_daemon dec to %d", _memlock_count_daemon);
 	_unlock_mem_if_possible(cmd);
 }
 
@@ -465,7 +465,7 @@ void memlock_init(struct cmd_context *cmd)
 
 void memlock_reset(void)
 {
-	log_debug("memlock reset.");
+	log_debug_mem("memlock reset.");
 	_mem_locked = 0;
 	_critical_section = 0;
 	_memlock_count_daemon = 0;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 14eb096..3f74588 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -328,7 +328,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					return 0;
 				}
 			}
-			log_debug("Thin pool create_%s %s.", (!origin) ? "thin" : "snap", lmsg->u.lv->name);
+			log_debug_activation("Thin pool create_%s %s.", (!origin) ? "thin" : "snap", lmsg->u.lv->name);
 			if (!dm_tree_node_add_thin_pool_message(node,
 								(!origin) ? lmsg->type : DM_THIN_MESSAGE_CREATE_SNAP,
 								first_seg(lmsg->u.lv)->device_id,
@@ -336,7 +336,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				return_0;
 			break;
 		case DM_THIN_MESSAGE_DELETE:
-			log_debug("Thin pool delete %u.", lmsg->u.delete_id);
+			log_debug_activation("Thin pool delete %u.", lmsg->u.delete_id);
 			if (!dm_tree_node_add_thin_pool_message(node,
 								lmsg->type,
 								lmsg->u.delete_id, 0))
@@ -350,7 +350,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 
 	if (!dm_list_empty(&seg->thin_messages)) {
 		/* Messages were passed, modify transaction_id as the last one */
-		log_debug("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id);
+		log_debug_activation("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id);
 		if (!dm_tree_node_add_thin_pool_message(node,
 							DM_THIN_MESSAGE_SET_TRANSACTION_ID,
 							seg->transaction_id - 1,
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 9e78e1c..b6f9d09 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -756,9 +756,9 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 	}
 
 	if (r) {
-		log_debug("New device uuid mangled [%s]: %s --> %s",
-			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
-			  newuuid, mangled_uuid);
+		log_debug_activation("New device uuid mangled [%s]: %s --> %s",
+				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+				     newuuid, mangled_uuid);
 		newuuid = mangled_uuid;
 	}
 
@@ -1505,8 +1505,8 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 	 */
 	if (info.suspended) {
 		if (!device)
-			log_debug("Attempting to suspend a device that is already suspended "
-				  "(%u:%u)", info.major, info.minor);
+			log_debug_activation("Attempting to suspend a device that is already suspended "
+					     "(%u:%u)", info.major, info.minor);
 		else
 			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
 				  "that uses already-suspended device (%u:%u)", 
@@ -1584,8 +1584,8 @@ static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
 		return_0;
 
 	if ((r = unmangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0) {
-		log_debug("_do_dm_ioctl_unmangle_string: failed to "
-			  "unmangle %s \"%s\"", str_name, str);
+		log_debug_activation("_do_dm_ioctl_unmangle_string: failed to "
+				     "unmangle %s \"%s\"", str_name, str);
 		return 0;
 	} else if (r)
 		memcpy(str, buf, strlen(buf) + 1);
@@ -1680,15 +1680,15 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		 * libdevmapper's node and symlink creation code.
 		 */
 		if (!dmt->cookie_set && dm_udev_get_sync_support()) {
-			log_debug("Cookie value is not set while trying to call %s "
-				  "ioctl. Please, consider using libdevmapper's udev "
-				  "synchronisation interface or disable it explicitly "
-				  "by calling dm_udev_set_sync_support(0).",
-				  dmt->type == DM_DEVICE_RESUME ? "DM_DEVICE_RESUME" :
-				  dmt->type == DM_DEVICE_REMOVE ? "DM_DEVICE_REMOVE" :
-								  "DM_DEVICE_RENAME");
-			log_debug("Switching off device-mapper and all subsystem related "
-				  "udev rules. Falling back to libdevmapper node creation.");
+			log_debug_activation("Cookie value is not set while trying to call %s "
+					     "ioctl. Please, consider using libdevmapper's udev "
+					     "synchronisation interface or disable it explicitly "
+					     "by calling dm_udev_set_sync_support(0).",
+					     dmt->type == DM_DEVICE_RESUME ? "DM_DEVICE_RESUME" :
+					     dmt->type == DM_DEVICE_REMOVE ? "DM_DEVICE_REMOVE" :
+									     "DM_DEVICE_RENAME");
+			log_debug_activation("Switching off device-mapper and all subsystem related "
+					     "udev rules. Falling back to libdevmapper node creation.");
 			/*
 			 * Disable general dm and subsystem rules but keep
 			 * dm disk rules if not flagged out explicitly before.
@@ -1700,28 +1700,28 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		}
 	}
 
-	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
-		  _cmd_data_v4[dmt->type].name,
-		  dmt->new_uuid ? "UUID " : "",
-		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
-		  dmt->newname ? dmt->newname : "",
-		  dmt->major > 0 ? "(" : "",
-		  dmt->major > 0 ? dmt->major : 0,
-		  dmt->major > 0 ? ":" : "",
-		  dmt->minor > 0 ? dmt->minor : 0,
-		  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
-		  dmt->major > 0 ? ") " : "",
-		  dmt->no_open_count ? 'N' : 'O',
-		  dmt->no_flush ? 'N' : 'F',
-		  dmt->read_only ? "R" : "",
-		  dmt->skip_lockfs ? "S " : "",
-		  dmt->retry_remove ? "T " : "",
-		  dmt->secure_data ? "W " : "",
-		  dmt->query_inactive_table ? "I " : "",
-		  dmt->enable_checks ? "C" : "",
-		  dmt->sector, _sanitise_message(dmt->message),
-		  dmi->data_size, retry_repeat_count);
+	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
+			     "%s%c%c%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
+			     _cmd_data_v4[dmt->type].name,
+			     dmt->new_uuid ? "UUID " : "",
+			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
+			     dmt->newname ? dmt->newname : "",
+			     dmt->major > 0 ? "(" : "",
+			     dmt->major > 0 ? dmt->major : 0,
+			     dmt->major > 0 ? ":" : "",
+			     dmt->minor > 0 ? dmt->minor : 0,
+			     dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+			     dmt->major > 0 ? ") " : "",
+			     dmt->no_open_count ? 'N' : 'O',
+			     dmt->no_flush ? 'N' : 'F',
+			     dmt->read_only ? "R" : "",
+			     dmt->skip_lockfs ? "S " : "",
+			     dmt->retry_remove ? "T " : "",
+			     dmt->secure_data ? "W " : "",
+			     dmt->query_inactive_table ? "I " : "",
+			     dmt->enable_checks ? "C" : "",
+			     dmt->sector, _sanitise_message(dmt->message),
+			     dmi->data_size, retry_repeat_count);
 #ifdef DM_IOCTLS
 	if (ioctl(_control_fd, command, dmi) < 0 &&
 	    dmt->expected_errno != errno) {
@@ -1754,8 +1754,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 
 	if (ioctl_with_uevent && dm_udev_get_sync_support() &&
 	    !_check_uevent_generated(dmi)) {
-		log_debug("Uevent not generated! Calling udev_complete "
-			  "internally to avoid process lock-up.");
+		log_debug_activation("Uevent not generated! Calling udev_complete "
+				     "internally to avoid process lock-up.");
 		_udev_complete(dmt);
 	}
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 3d95093..4736b59 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -206,7 +206,7 @@ int dm_get_library_version(char *version, size_t size)
 void inc_suspended(void)
 {
 	_suspended_dev_counter++;
-	log_debug("Suspended device counter increased to %d", _suspended_dev_counter);
+	log_debug_activation("Suspended device counter increased to %d", _suspended_dev_counter);
 }
 
 void dec_suspended(void)
@@ -217,7 +217,7 @@ void dec_suspended(void)
 	}
 
 	_suspended_dev_counter--;
-	log_debug("Suspended device counter reduced to %d", _suspended_dev_counter);
+	log_debug_activation("Suspended device counter reduced to %d", _suspended_dev_counter);
 }
 
 int dm_get_suspended_counter(void)
@@ -466,8 +466,8 @@ int unmangle_string(const char *str, const char *str_name, size_t len,
 
 		if (str[i] == '\\' && str[i+1] == 'x') {
 			if (!sscanf(&str[i+2], "%2x%s", &code, str_rest)) {
-				log_debug("Hex encoding mismatch detected in %s \"%s\" "
-					  "while trying to unmangle it.", str_name, str);
+				log_debug_activation("Hex encoding mismatch detected in %s \"%s\" "
+						     "while trying to unmangle it.", str_name, str);
 				goto out;
 			}
 			buf[j] = (unsigned char) code;
@@ -514,9 +514,9 @@ static int _dm_task_set_name(struct dm_task *dmt, const char *name,
 
 	/* Store mangled_dev_name only if it differs from dev_name! */
 	if (r) {
-		log_debug("Device name mangled [%s]: %s --> %s",
-			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
-			  name, mangled_name);
+		log_debug_activation("Device name mangled [%s]: %s --> %s",
+				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+				     name, mangled_name);
 		if (!(dmt->mangled_dev_name = dm_strdup(mangled_name))) {
 			log_error("_dm_task_set_name: dm_strdup(%s) failed", mangled_name);
 			return 0;
@@ -704,9 +704,9 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 	}
 
 	if (r) {
-		log_debug("New device name mangled [%s]: %s --> %s",
-			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
-			  newname, mangled_name);
+		log_debug_activation("New device name mangled [%s]: %s --> %s",
+				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+				     newname, mangled_name);
 		newname = mangled_name;
 	}
 
@@ -742,9 +742,9 @@ int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 	}
 
 	if (r) {
-		log_debug("Device uuid mangled [%s]: %s --> %s",
-			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
-			  uuid, mangled_uuid);
+		log_debug_activation("Device uuid mangled [%s]: %s --> %s",
+				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+				     uuid, mangled_uuid);
 
 		if (!(dmt->mangled_uuid = dm_strdup(mangled_uuid))) {
 			log_error("dm_task_set_uuid: dm_strdup(%s) failed", mangled_uuid);
@@ -842,14 +842,14 @@ static int _selabel_lookup(const char *path, mode_t mode,
 	}
 
 	if (selabel_lookup(_selabel_handle, scontext, path, mode)) {
-		log_debug("selabel_lookup failed for %s: %s",
-			  path, strerror(errno));
+		log_debug_activation("selabel_lookup failed for %s: %s",
+				     path, strerror(errno));
 		return 0;
 	}
 #else
 	if (matchpathcon(path, mode, scontext)) {
-		log_debug("matchpathcon failed for %s: %s",
-			  path, strerror(errno));
+		log_debug_activation("matchpathcon failed for %s: %s",
+				     path, strerror(errno));
 		return 0;
 	}
 #endif
@@ -869,10 +869,10 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 		if (!_selabel_lookup(path, mode, &scontext))
 			return_0;
 
-		log_debug("Preparing SELinux context for %s to %s.", path, scontext);
+		log_debug_activation("Preparing SELinux context for %s to %s.", path, scontext);
 	}
 	else
-		log_debug("Resetting SELinux context to default value.");
+		log_debug_activation("Resetting SELinux context to default value.");
 
 	if (setfscreatecon(scontext) < 0) {
 		log_sys_error("setfscreatecon", path);
@@ -896,7 +896,7 @@ int dm_set_selinux_context(const char *path, mode_t mode)
 	if (!_selabel_lookup(path, mode, &scontext))
 		return_0;
 
-	log_debug("Setting SELinux context for %s to %s.", path, scontext);
+	log_debug_activation("Setting SELinux context for %s to %s.", path, scontext);
 
 	if ((lsetfilecon(path, scontext) < 0) && (errno != ENOTSUP)) {
 		log_sys_error("lsetfilecon", path);
@@ -969,7 +969,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 		return 0;
 	}
 
-	log_debug("Created %s", path);
+	log_debug_activation("Created %s", path);
 
 	return 1;
 }
@@ -992,7 +992,7 @@ static int _rm_dev_node(const char *dev_name, int warn_if_udev_failed)
 		return 0;
 	}
 
-	log_debug("Removed %s", path);
+	log_debug_activation("Removed %s", path);
 
 	return 1;
 }
@@ -1049,7 +1049,7 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 		return 0;
 	}
 
-	log_debug("Renamed %s to %s", oldpath, newpath);
+	log_debug_activation("Renamed %s to %s", oldpath, newpath);
 
 	return 1;
 }
@@ -1097,8 +1097,8 @@ int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor
 			} else {
 				buf[len] = 0; /* kill \n and ensure \0 */
 				*read_ahead = atoi(buf) * 2;
-				log_debug("%s (%d:%d): read ahead is %" PRIu32,
-					  dev_name, major, minor, *read_ahead);
+				log_debug_activation("%s (%d:%d): read ahead is %" PRIu32,
+						     dev_name, major, minor, *read_ahead);
 			}
 
 			if (close(fd))
@@ -1129,7 +1129,7 @@ int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor
 		r = 0;
 	} else {
 		*read_ahead = (uint32_t) read_ahead_long;
-		log_debug("%s: read ahead is %" PRIu32, dev_name, *read_ahead);
+		log_debug_activation("%s: read ahead is %" PRIu32, dev_name, *read_ahead);
 	}
 
 	if (close(fd))
@@ -1147,8 +1147,8 @@ static int _set_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
 	int fd;
 	long read_ahead_long = (long) read_ahead;
 
-	log_debug("%s (%d:%d): Setting read ahead to %" PRIu32, dev_name,
-		  major, minor, read_ahead);
+	log_debug_activation("%s (%d:%d): Setting read ahead to %" PRIu32, dev_name,
+			     major, minor, read_ahead);
 
 	/*
 	 * If we know the device number, use sysfs if we can.
@@ -1221,7 +1221,7 @@ static int _set_dev_node_read_ahead(const char *dev_name,
 			return_0;
 
 		if (current_read_ahead > read_ahead) {
-			log_debug("%s: retaining kernel read ahead of %" PRIu32
+			log_debug_activation("%s: retaining kernel read ahead of %" PRIu32
 				  " (requested %" PRIu32 ")",           
 				  dev_name, current_read_ahead, read_ahead);
 			return 1;
@@ -1332,19 +1332,19 @@ static void _log_node_op(const char *action_str, struct node_op_parms *nop)
 
 	switch (nop->type) {
 	case NODE_ADD:
-		log_debug("%s: %s NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o%s%s",
-			  nop->dev_name, action_str, nop->major, nop->minor, nop->uid, nop->gid, nop->mode,
-			  rely, verify);
+		log_debug_activation("%s: %s NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o%s%s",
+				     nop->dev_name, action_str, nop->major, nop->minor, nop->uid, nop->gid, nop->mode,
+				     rely, verify);
 		break;
 	case NODE_DEL:
-		log_debug("%s: %s NODE_DEL%s%s", nop->dev_name, action_str, rely, verify);
+		log_debug_activation("%s: %s NODE_DEL%s%s", nop->dev_name, action_str, rely, verify);
 		break;
 	case NODE_RENAME:
-		log_debug("%s: %s NODE_RENAME to %s%s%s", nop->old_name, action_str, nop->dev_name, rely, verify);
+		log_debug_activation("%s: %s NODE_RENAME to %s%s%s", nop->old_name, action_str, nop->dev_name, rely, verify);
 		break;
 	case NODE_READ_AHEAD:
-		log_debug("%s: %s NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32 ")%s%s",
-			  nop->dev_name, action_str, nop->read_ahead, nop->read_ahead_flags, rely, verify);
+		log_debug_activation("%s: %s NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32 ")%s%s",
+				     nop->dev_name, action_str, nop->read_ahead, nop->read_ahead_flags, rely, verify);
 		break;
 	default:
 		; /* NOTREACHED */
@@ -1507,8 +1507,8 @@ static int _canonicalize_and_set_dir(const char *src, const char *suffix, size_t
 	const char *slash;
 
 	if (*src != '/') {
-		log_debug("Invalid directory value, %s: "
-			  "not an absolute name.", src);
+		log_debug_activation("Invalid directory value, %s: "
+				     "not an absolute name.", src);
 		return 0;
 	}
 
@@ -1516,7 +1516,7 @@ static int _canonicalize_and_set_dir(const char *src, const char *suffix, size_t
 	slash = src[len-1] == '/' ? "" : "/";
 
 	if (dm_snprintf(dir, max_len, "%s%s%s", src, slash, suffix ? suffix : "") < 0) {
-		log_debug("Invalid directory value, %s: name too long.", src);
+		log_debug_activation("Invalid directory value, %s: name too long.", src);
 		return 0;
 	}
 
@@ -1915,8 +1915,8 @@ static int _check_udev_is_running(void)
 	}
 
 	if (!(r = udev_queue_get_udev_is_active(udev_queue)))
-		log_debug("Udev is not running. "
-			  "Not using udev synchronisation code.");
+		log_debug_activation("Udev is not running. "
+				     "Not using udev synchronisation code.");
 
 	udev_queue_unref(udev_queue);
 	udev_unref(udev);
@@ -1959,9 +1959,9 @@ int dm_udev_get_sync_support(void)
 void dm_udev_set_checking(int checking)
 {
 	if ((_udev_checking = checking))
-		log_debug("DM udev checking enabled");
+		log_debug_activation("DM udev checking enabled");
 	else
-		log_debug("DM udev checking disabled");
+		log_debug_activation("DM udev checking disabled");
 }
 
 int dm_udev_get_checking(void)
@@ -2024,7 +2024,7 @@ static int _udev_notify_sem_inc(uint32_t cookie, int semid)
 		return 0;		
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
 		  cookie, semid, val);
 
 	return 1;
@@ -2059,8 +2059,8 @@ static int _udev_notify_sem_dec(uint32_t cookie, int semid)
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) decremented to %d",
-		  cookie, semid, val - 1);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) decremented to %d",
+			     cookie, semid, val - 1);
 
 	return 1;
 }
@@ -2074,8 +2074,8 @@ static int _udev_notify_sem_destroy(uint32_t cookie, int semid)
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) destroyed", cookie,
-		  semid);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) destroyed", cookie,
+			     semid);
 
 	return 1;
 }
@@ -2132,8 +2132,8 @@ static int _udev_notify_sem_create(uint32_t *cookie, int *semid)
 		}
 	} while (!base_cookie);
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) created",
-		  gen_cookie, gen_semid);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) created",
+			     gen_cookie, gen_semid);
 
 	sem_arg.val = 1;
 
@@ -2152,8 +2152,8 @@ static int _udev_notify_sem_create(uint32_t *cookie, int *semid)
 		goto bad;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
-		  gen_cookie, gen_semid, val);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
+			     gen_cookie, gen_semid, val);
 
 	if (close(fd))
 		stack;
@@ -2257,16 +2257,16 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to "
-		  "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, semid, _task_type_disp(dmt->type), dmt->type, 
-		  (flags & DM_UDEV_DISABLE_DM_RULES_FLAG) ? " DISABLE_DM_RULES" : "",
-		  (flags & DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) ? " DISABLE_SUBSYSTEM_RULES" : "",
-		  (flags & DM_UDEV_DISABLE_DISK_RULES_FLAG) ? " DISABLE_DISK_RULES" : "",
-		  (flags & DM_UDEV_DISABLE_OTHER_RULES_FLAG) ? " DISABLE_OTHER_RULES" : "",
-		  (flags & DM_UDEV_LOW_PRIORITY_FLAG) ? " LOW_PRIORITY" : "",
-		  (flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK) ? " DISABLE_LIBRARY_FALLBACK" : "",
-		  (flags & DM_UDEV_PRIMARY_SOURCE_FLAG) ? " PRIMARY_SOURCE" : "",
-		  flags);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) assigned to "
+			     "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, semid, _task_type_disp(dmt->type), dmt->type, 
+			     (flags & DM_UDEV_DISABLE_DM_RULES_FLAG) ? " DISABLE_DM_RULES" : "",
+			     (flags & DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) ? " DISABLE_SUBSYSTEM_RULES" : "",
+			     (flags & DM_UDEV_DISABLE_DISK_RULES_FLAG) ? " DISABLE_DISK_RULES" : "",
+			     (flags & DM_UDEV_DISABLE_OTHER_RULES_FLAG) ? " DISABLE_OTHER_RULES" : "",
+			     (flags & DM_UDEV_LOW_PRIORITY_FLAG) ? " LOW_PRIORITY" : "",
+			     (flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK) ? " DISABLE_LIBRARY_FALLBACK" : "",
+			     (flags & DM_UDEV_PRIMARY_SOURCE_FLAG) ? " PRIMARY_SOURCE" : "",
+			     flags);
 
 	return 1;
 
@@ -2315,8 +2315,8 @@ static int _udev_wait(uint32_t cookie)
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) waiting for zero",
-		  cookie, semid);
+	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) waiting for zero",
+			     cookie, semid);
 
 repeat_wait:
 	if (semop(semid, &sb, 1) < 0) {
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e4a574d..9e313d4 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -541,10 +541,10 @@ void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags
 	struct dm_info *dinfo = &dnode->info;
 
 	if (udev_flags != dnode->udev_flags)
-		log_debug("Resetting %s (%" PRIu32 ":%" PRIu32
-			  ") udev_flags from 0x%x to 0x%x",
-			  dnode->name, dinfo->major, dinfo->minor,
-			  dnode->udev_flags, udev_flags);
+		log_debug_activation("Resetting %s (%" PRIu32 ":%" PRIu32
+				     ") udev_flags from 0x%x to 0x%x",
+				     dnode->name, dinfo->major, dinfo->minor,
+				     dnode->udev_flags, udev_flags);
 	dnode->udev_flags = udev_flags;
 }
 
@@ -927,8 +927,8 @@ static int _node_has_closed_parents(struct dm_tree_node *node,
 			continue;
 
 		if (info.open_count) {
-			log_debug("Node %s %d:%d has open_count %d", uuid_prefix,
-				  dinfo->major, dinfo->minor, info.open_count);
+			log_debug_activation("Node %s %d:%d has open_count %d", uuid_prefix,
+					     dinfo->major, dinfo->minor, info.open_count);
 			return 0;
 		}
 	}
@@ -1263,13 +1263,13 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RESUME))) {
-		log_debug("Suspend dm_task creation failed for %s.", name);
+		log_debug_activation("Suspend dm_task creation failed for %s.", name);
 		return 0;
 	}
 
 	/* FIXME Kernel should fill in name on return instead */
 	if (!dm_task_set_name(dmt, name)) {
-		log_debug("Failed to set device name for %s resumption.", name);
+		log_debug_activation("Failed to set device name for %s resumption.", name);
 		goto out;
 	}
 
@@ -1376,7 +1376,7 @@ static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t
 		goto out;
 	}
 
-	log_debug("Thin pool transaction id: %" PRIu64 " status: %s.", *transaction_id, params);
+	log_debug_activation("Thin pool transaction id: %" PRIu64 " status: %s.", *transaction_id, params);
 
 	r = 1;
 out:
@@ -1474,7 +1474,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 		return_0;
 
 	if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len)) {
-		log_debug("UUID \"%s\" does not match.", uuid);
+		log_debug_activation("UUID \"%s\" does not match.", uuid);
 		return 1;
 	}
 
@@ -2321,10 +2321,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		break;
 	}
 
-	log_debug("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
-		  " %" PRIu64 " %s %s", major, minor,
-		  *seg_start, seg->size, target_type_is_raid ? "raid" :
-		  dm_segtypes[seg->type].target, params);
+	log_debug_activation("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
+			     " %" PRIu64 " %s %s", major, minor,
+			     *seg_start, seg->size, target_type_is_raid ? "raid" :
+			     dm_segtypes[seg->type].target, params);
 
 	if (!dm_task_add_target(dmt, *seg_start, seg->size,
 				target_type_is_raid ? "raid" :
@@ -2362,8 +2362,8 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 		if (ret >= 0)
 			return ret;
 
-		log_debug("Insufficient space in params[%" PRIsize_t
-			  "] for target parameters.", paramsize);
+		log_debug_activation("Insufficient space in params[%" PRIsize_t
+				     "] for target parameters.", paramsize);
 
 		paramsize *= 2;
 	} while (paramsize < MAX_TARGET_PARAMSIZE);
@@ -2428,11 +2428,11 @@ static int _load_node(struct dm_tree_node *dnode)
 			if (!existing_table_size && dnode->props.delay_resume_if_new)
 				dnode->props.size_changed = 0;
 
-			log_debug("Table size changed from %" PRIu64 " to %"
-				  PRIu64 " for %s (%" PRIu32 ":%" PRIu32 ").%s",
-				  existing_table_size, seg_start, dnode->name,
-				  dnode->info.major, dnode->info.minor,
-				  dnode->props.size_changed ? "" : " (Ignoring.)");
+			log_debug_activation("Table size changed from %" PRIu64 " to %"
+					     PRIu64 " for %s (%" PRIu32 ":%" PRIu32 ").%s",
+					     existing_table_size, seg_start, dnode->name,
+					     dnode->info.major, dnode->info.minor,
+					     dnode->props.size_changed ? "" : " (Ignoring.)");
 		}
 	}
 
@@ -3096,8 +3096,8 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
 		devsize += mseg->size;
 		if (devsize > max_metadata_size) {
-			log_debug("Ignoring %" PRIu64 " of device.",
-				  devsize - max_metadata_size);
+			log_debug_activation("Ignoring %" PRIu64 " of device.",
+					     devsize - max_metadata_size);
 			mseg->size -= (devsize - max_metadata_size);
 			devsize = max_metadata_size;
 			/* FIXME: drop remaining segs */
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index d37083f..a2a6b76 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -117,7 +117,7 @@ void *dm_malloc_aux_debug(size_t s, const char *file, int line)
 	if (_mem_stats.bytes > _mem_stats.mbytes)
 		_mem_stats.mbytes = _mem_stats.bytes;
 
-	/* log_debug("Allocated: %u %u %u", nb->id, _mem_stats.blocks_allocated,
+	/* log_debug_mem("Allocated: %u %u %u", nb->id, _mem_stats.blocks_allocated,
 		  _mem_stats.bytes); */
 #ifdef VALGRIND_POOL
 	VALGRIND_MAKE_MEM_UNDEFINED(nb + 1, s);
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index 7f9a0e4..3bd6cab 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -62,7 +62,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 	mem->orig_pool = mem;
 
 #ifdef DEBUG_POOL
-	log_debug("Created mempool %s", name);
+	log_debug_mem("Created mempool %s", name);
 #endif
 
 	dm_list_add(&_dm_pools, &mem->list);
@@ -91,10 +91,10 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 static void _pool_stats(struct dm_pool *p, const char *action)
 {
 #ifdef DEBUG_POOL
-	log_debug("%s mempool %s: %u/%u bytes, %u/%u blocks, "
-		  "%u allocations)", action, p->name, p->stats.bytes,
-		  p->stats.maxbytes, p->stats.blocks_allocated,
-		  p->stats.blocks_max, p->stats.block_serialno);
+	log_debug_mem("%s mempool %s: %u/%u bytes, %u/%u blocks, "
+		      "%u allocations)", action, p->name, p->stats.bytes,
+		      p->stats.maxbytes, p->stats.blocks_allocated,
+		      p->stats.blocks_max, p->stats.block_serialno);
 #else
 	;
 #endif
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index b81a9b6..fd08307 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -141,7 +141,7 @@ int dm_pool_lock(struct dm_pool *p, int crc)
 
 	p->locked = 1;
 
-	log_debug("Pool %s is locked.", p->name);
+	log_debug_mem("Pool %s is locked.", p->name);
 
 	return 1;
 }
@@ -172,7 +172,7 @@ int dm_pool_unlock(struct dm_pool *p, int crc)
 	if (!_pool_protect(p, PROT_READ | PROT_WRITE))
 		return_0;
 
-	log_debug("Pool %s is unlocked.", p->name);
+	log_debug_mem("Pool %s is unlocked.", p->name);
 
 	if (crc && (p->crc != _pool_crc(p))) {
 		log_error(INTERNAL_ERROR "Pool %s crc mismatch.", p->name);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6d6537b..c37ae25 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -971,6 +971,7 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 static void _apply_settings(struct cmd_context *cmd)
 {
 	init_debug(cmd->current_settings.debug);
+	init_debug_classes_logged(cmd->default_settings.debug_classes);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_silent(cmd->current_settings.silent);
 	init_test(cmd->current_settings.test);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 1e844c5..ff5ced2 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -148,7 +148,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	/* TODO: Remove this once lvmetad + cluster supported! */
 	if (find_config_tree_int(cmd, "global/locking_type", 1) == 3 ||
 	    !find_config_tree_int(cmd, "global/use_lvmetad", 0)) {
-		log_debug("_pvscan_lvmetad: immediate return");
+		log_debug_lvmetad("_pvscan_lvmetad: immediate return");
 		return ret;
 	}
 


