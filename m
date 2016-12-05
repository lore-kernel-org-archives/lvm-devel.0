From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:26 +0000 (UTC)
Subject: master - cleanup: indent and messsages updates
Message-ID: <20161205161526.839066036D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81ef4eb4f887381d67546884be5a717030fb505a
Commit:        81ef4eb4f887381d67546884be5a717030fb505a
Parent:        69c79ed2f486a9092cdf1586fcf320634e3cd44d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 14:53:35 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

cleanup: indent and messsages updates

---
 lib/activate/activate.c    |    4 ++
 lib/activate/dev_manager.c |   77 +++++++++++++++++++++++++-------------------
 lib/metadata/lv.c          |    1 +
 3 files changed, 49 insertions(+), 33 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3128f36..b4c8a2c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -655,6 +655,10 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 				      &maj, &min, &patchlevel);
 }
 
+/*
+ * When '*info' is NULL, returns 1 only when LV is active.
+ * When '*info' != NULL, returns 1 when info structure is populated.
+ */
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		    int use_layer, struct lvinfo *info,
 		    const struct lv_segment *seg,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index af7f5d8..6a8e487 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -136,6 +136,7 @@ static struct dm_task *_setup_task_run(int task, struct dm_info *info,
 
 out:
 	dm_task_destroy(dmt);
+
 	return NULL;
 }
 
@@ -236,7 +237,7 @@ static int _info_run(info_type_t type, const char *dlid,
 			with_flush = 0;
 			break;
 		default:
-			log_error(INTERNAL_ERROR "_info_run: unhandled info type");
+			log_error(INTERNAL_ERROR "_info_run: unhandled info type.");
 			return 0;
 	}
 
@@ -274,6 +275,7 @@ static int _info_run(info_type_t type, const char *dlid,
 
       out:
 	dm_task_destroy(dmt);
+
 	return r;
 }
 
@@ -326,14 +328,14 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 
 	for (i = 0; i < sm->dev_count; ++i)
 		if (sm->devs[i].health != DM_STATUS_MIRROR_ALIVE) {
-			log_debug_activation("%s: Mirror image %d marked as failed",
+			log_debug_activation("%s: Mirror image %d marked as failed.",
 					     dev_name(dev), i);
 			check_for_blocking = 1;
 		}
 
 	if (!check_for_blocking && sm->log_count) {
 		if (sm->logs[0].health != DM_STATUS_MIRROR_ALIVE) {
-			log_debug_activation("%s: Mirror log device marked as failed",
+			log_debug_activation("%s: Mirror log device marked as failed.",
 					     dev_name(dev));
 			check_for_blocking = 1;
 		} else {
@@ -382,7 +384,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			     (p[15] == '\0' || p[15] == ' ')) ||
 			    ((p = strstr(params, " handle_errors")) &&
 			     (p[14] == '\0' || p[14] == ' '))) {
-				log_debug_activation("%s: I/O blocked to mirror device",
+				log_debug_activation("%s: I/O blocked to mirror device.",
 						     dev_name(dev));
 				goto out;
 			}
@@ -447,6 +449,7 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 
 out:
 	dm_task_destroy(dmt);
+
 	return r;
 }
 
@@ -735,7 +738,7 @@ int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		goto_out;
 	}
 
-	log_debug_activation("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s].", name, dlid);
 	r = _info(cmd, dlid, with_open_count, with_read_ahead,
 		  dminfo, read_ahead, seg_status);
 out:
@@ -874,7 +877,8 @@ bad:
 	return (device_id == id);
 }
 
-int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t extent_size, int use_linear_target, const char *vgname, const char *lvname)
+int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t extent_size,
+			     int use_linear_target, const char *vgname, const char *lvname)
 {
 	uint32_t page_size;
 
@@ -895,10 +899,12 @@ int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t
 			if (!dm_tree_node_add_striped_target(node, size, extent_size))
 				return_0;
 			return 1;
-		} else
-			/* Some exotic cases are unsupported by striped. */
-			log_warn("WARNING: Using linear target for %s/%s: Striped requires extent size (%" PRIu32 " sectors) >= page size (%" PRIu32 ").",
-				 vgname, lvname, extent_size, page_size);
+		}
+
+		/* Some exotic cases are unsupported by striped. */
+		log_warn("WARNING: Using linear target for %s/%s: Striped requires extent size "
+			 "(" FMTu32 " sectors) >= page size (" FMTu32 ").",
+			 vgname, lvname, extent_size, page_size);
 	}
 
 	/*
@@ -1148,6 +1154,7 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 
       bad:
 	dm_pool_destroy(mem);
+
 	return NULL;
 }
 
@@ -1236,10 +1243,10 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	log_debug_activation("Getting device %s status percentage for %s",
+	log_debug_activation("Getting device %s status percentage for %s.",
 			     target_type, name);
-	if (!_percent(dm, name, dlid, target_type, wait, lv, percent,
-		      event_nr, 0))
+
+	if (!_percent(dm, name, dlid, target_type, wait, lv, percent, event_nr, 0))
 		return_0;
 
 	return 1;
@@ -1269,9 +1276,9 @@ int dev_manager_raid_status(struct dev_manager *dm,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
-	if (!type || strcmp(type, "raid")) {
-		log_error("Expected raid segment type but got %s instead",
-			  type ? type : "NULL");
+	if (!type || strcmp(type, TARGET_NAME_RAID)) {
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_RAID, type ? type : "NULL");
 		goto out;
 	}
 
@@ -1297,7 +1304,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	const char *layer = lv_layer(lv);
 
 	if (!lv_is_raid(lv)) {
-		log_error(INTERNAL_ERROR "%s is not a RAID logical volume",
+		log_error(INTERNAL_ERROR "%s is not a RAID logical volume.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -1310,7 +1317,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	    strcmp(msg, "check") &&
 	    strcmp(msg, "repair") &&
 	    strcmp(msg, "reshape")) {
-		log_error(INTERNAL_ERROR "Unknown RAID message: %s", msg);
+		log_error(INTERNAL_ERROR "Unknown RAID message: %s.", msg);
 		return 0;
 	}
 
@@ -1361,8 +1368,8 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (!type || strcmp(type, TARGET_NAME_CACHE)) {
-		log_error("Expected cache segment type but got %s instead",
-			  type ? type : "NULL");
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_CACHE, type ? type : "NULL");
 		goto out;
 	}
 
@@ -1448,7 +1455,8 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	log_debug_activation("Getting device status percentage for %s", name);
+	log_debug_activation("Getting device status percentage for %s.", name);
+
 	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN_POOL, 0,
 		       (metadata) ? lv : NULL, percent, NULL, 1)))
 		return_0;
@@ -1472,6 +1480,7 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
+
 	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN, 0,
 		       (mapped) ? NULL : lv, percent, NULL, 1)))
 		return_0;
@@ -1706,7 +1715,8 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	log_debug_activation("Getting device info for %s [%s]", name, dlid);
+	log_debug_activation("Getting device info for %s [%s].", name, dlid);
+
 	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
@@ -1723,7 +1733,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (info.exists && ((int) info.minor != lv->minor)) {
 			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
-				  "(%" PRIu32 ":%" PRIu32")",
+				  "(%" PRIu32 ":%" PRIu32").",
 				  display_lvname(lv), lv->major, lv->minor,
 				  info.major, info.minor);
 			return 0;
@@ -1731,7 +1741,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!info.exists && _info_by_dev(lv->major, lv->minor, &info2) &&
 		    info2.exists) {
 			log_error("The requested major:minor pair "
-				  "(%" PRIu32 ":%" PRIu32") is already used",
+				  "(%" PRIu32 ":%" PRIu32") is already used.",
 				  lv->major, lv->minor);
 			return 0;
 		}
@@ -1739,7 +1749,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
 							_get_udev_flags(dm, lv, layer, 0, 0))) {
-		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
+		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.",
 			  info.major, info.minor);
 		return 0;
 	}
@@ -1868,7 +1878,7 @@ static int _pool_callback(struct dm_tree_node *node,
 	for (cv = cn->v; cv && args < 16; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Invalid string in config file: "
-				  "global/%s_check_options",
+				  "global/%s_check_options.",
 				  data->global);
 			return 0;
 		}
@@ -2491,7 +2501,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 
 	if (!seg->segtype->ops->add_target_line) {
 		log_error(INTERNAL_ERROR "_emit_target cannot handle "
-			  "segment type %s", seg->segtype->name);
+			  "segment type %s.", seg->segtype->name);
 		return 0;
 	}
 
@@ -2947,11 +2957,11 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 
 		if (name && lvlayer->old_name && *lvlayer->old_name && strcmp(name, lvlayer->old_name)) {
 			if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &old_vgname, &old_lvname, &old_layer)) {
-				log_error("_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
+				log_error("_create_lv_symlinks: Couldn't split up old device name %s.", lvlayer->old_name);
 				return 0;
 			}
 			if (!dm_split_lvm_name(dm->mem, name, &new_vgname, &new_lvname, &new_layer)) {
-				log_error("_create_lv_symlinks: Couldn't split up new device name %s", name);
+				log_error("_create_lv_symlinks: Couldn't split up new device name %s.", name);
 				return 0;
 			}
 			if (!fs_rename_lv(lvlayer->lv, name, old_vgname, old_lvname))
@@ -3079,7 +3089,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		return_0;
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
-		log_error("Lost dependency tree root node");
+		log_error("Lost dependency tree root node.");
 		goto out_no_root;
 	}
 
@@ -3226,14 +3236,14 @@ int dev_manager_device_uses_vg(struct device *dev,
 	int r = 1;
 
 	if (!(dtree = dm_tree_create())) {
-		log_error("partial dtree creation failed");
+		log_error("Failed to create partial dtree.");
 		return r;
 	}
 
 	dm_tree_set_optional_uuid_suffixes(dtree, &uuid_suffix_list[0]);
 
 	if (!dm_tree_add_dev(dtree, (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev))) {
-		log_error("Failed to add device %s (%" PRIu32 ":%" PRIu32") to dtree",
+		log_error("Failed to add device %s (%" PRIu32 ":%" PRIu32") to dtree.",
 			  dev_name(dev), (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev));
 		goto out;
 	}
@@ -3242,7 +3252,7 @@ int dev_manager_device_uses_vg(struct device *dev,
 	memcpy(dlid + sizeof(UUID_PREFIX) - 1, &vg->id.uuid[0], sizeof(vg->id));
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
-		log_error("Lost dependency tree root node");
+		log_error("Lost dependency tree root node.");
 		goto out;
 	}
 
@@ -3253,5 +3263,6 @@ int dev_manager_device_uses_vg(struct device *dev,
 
 out:
 	dm_tree_free(dtree);
+
 	return r;
 }
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 081df71..4a9fed7 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -258,6 +258,7 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 	ret = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, &status);
 bad:
 	dm_pool_destroy(status.seg_status.mem);
+
 	return ret;
 }
 


