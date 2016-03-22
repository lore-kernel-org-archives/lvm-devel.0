From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Mar 2016 17:47:00 +0000 (UTC)
Subject: master - activate: Use macros for target and module names.
Message-ID: <20160322174700.A957960E99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1216efdf152043bd04e8db170b5b3fb569bef329
Commit:        1216efdf152043bd04e8db170b5b3fb569bef329
Parent:        94f78e0183e2517199e19d0473a7d5480660db0a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 22 17:46:15 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 22 17:46:15 2016 +0000

activate: Use macros for target and module names.

---
 WHATS_NEW                                         |    1 +
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    3 +-
 lib/activate/activate.h                           |   24 +++++++++++++++
 lib/activate/dev_manager.c                        |   32 ++++++++++----------
 lib/cache_segtype/cache.c                         |    6 ++--
 lib/error/errseg.c                                |    6 ++--
 lib/metadata/snapshot_manip.c                     |    2 +-
 lib/mirror/mirrored.c                             |   12 ++++----
 lib/raid/raid.c                                   |    4 +-
 lib/snapshot/snapshot.c                           |   14 ++++----
 lib/striped/striped.c                             |    4 +-
 lib/zero/zero.c                                   |    4 +-
 12 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 029405d..32528a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.148 - 
 ==================================
+  Replace hard-coded module and target names with macros.
   Add pv_major and pv_minor report fields.
   Detect and warn about mismatch between devices used and assumed for an LV.
 
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 25d1063..ee10874 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -15,6 +15,7 @@
 #include "lib.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
+#include "activate.h"	/* For TARGET_NAME* */
 
 /* FIXME Reformat to 80 char lines. */
 
@@ -137,7 +138,7 @@ void process_event(struct dm_task *dmt,
 			continue;
 		}
 
-		if (strcmp(target_type, "mirror")) {
+		if (strcmp(target_type, TARGET_NAME_MIRROR)) {
 			log_info("%s has unmirrored portion.", device);
 			continue;
 		}
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 74afb95..64c026e 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -239,4 +239,28 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check);
  */
 void fs_unlock(void);
 
+#define TARGET_NAME_CACHE "cache"
+#define TARGET_NAME_ERROR "error"
+#define TARGET_NAME_ERROR_OLD "erro"	/* Truncated in older kernels */
+#define TARGET_NAME_LINEAR "linear"
+#define TARGET_NAME_MIRROR "mirror"
+#define TARGET_NAME_RAID "raid"
+#define TARGET_NAME_SNAPSHOT "snapshot"
+#define TARGET_NAME_SNAPSHOT_MERGE "snapshot-merge"
+#define TARGET_NAME_SNAPSHOT_ORIGIN "snapshot-origin"
+#define TARGET_NAME_STRIPED "striped"
+#define TARGET_NAME_THIN "thin"
+#define TARGET_NAME_THIN_POOL "thin-pool"
+#define TARGET_NAME_ZERO "zero"
+
+#define MODULE_NAME_CLUSTERED_MIRROR "clog"
+#define MODULE_NAME_CACHE TARGET_NAME_CACHE
+#define MODULE_NAME_ERROR TARGET_NAME_ERROR
+#define MODULE_NAME_LOG_CLUSTERED "log-clustered"
+#define MODULE_NAME_LOG_USERSPACE "log-userspace"
+#define MODULE_NAME_MIRROR TARGET_NAME_MIRROR
+#define MODULE_NAME_SNAPSHOT TARGET_NAME_SNAPSHOT
+#define MODULE_NAME_RAID TARGET_NAME_RAID
+#define MODULE_NAME_ZERO TARGET_NAME_ZERO
+
 #endif
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8e56b7a..5761ede 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -130,9 +130,9 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	 * linear/striped, old snapshots and raids have proper
 	 * segment selected for status!
 	 */
-	if (strcmp(target_name, "cache") &&
-	    strcmp(target_name, "thin-pool") &&
-	    strcmp(target_name, "thin"))
+	if (strcmp(target_name, TARGET_NAME_CACHE) &&
+	    strcmp(target_name, TARGET_NAME_THIN_POOL) &&
+	    strcmp(target_name, TARGET_NAME_THIN))
 		return 1;
 
 	if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
@@ -354,7 +354,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					  &target_type, &params);
 		if ((s == start) && (l == length) &&
 		    target_type && params) {
-			if (strcmp(target_type, "mirror"))
+			if (strcmp(target_type, TARGET_NAME_MIRROR))
 				goto_out;
 
 			if (((p = strstr(params, " block_on_error")) &&
@@ -430,13 +430,13 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-		if (!target_type || !strcmp(target_type, "snapshot")) {
+		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
 			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
 				log_error("Incorrect snapshot table found");
 				goto_out;
 			}
 			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
-		} else if (!strcmp(target_type, "snapshot-origin")) {
+		} else if (!strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) {
 			if (!params || sscanf(params, "%d:%d", &major1, &minor1) != 2) {
 				log_error("Incorrect snapshot-origin table found");
 				goto_out;
@@ -604,7 +604,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
-		if (check.check_blocked && target_type && !strcmp(target_type, "mirror")) {
+		if (check.check_blocked && target_type && !strcmp(target_type, TARGET_NAME_MIRROR)) {
 			if (ignore_lvm_mirrors()) {
 				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
 				goto out;
@@ -639,20 +639,20 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		 * in a stack - use proper dm tree to check this instead.
 		 */
 		if (check.check_suspended && target_type &&
-		    (!strcmp(target_type, "snapshot") || !strcmp(target_type, "snapshot-origin")) &&
+		    (!strcmp(target_type, TARGET_NAME_SNAPSHOT) || !strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) &&
 		    _ignore_suspended_snapshot_component(dev)) {
 			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
 		}
 
 		/* TODO: extend check struct ? */
-		if (target_type && !strcmp(target_type, "thin") &&
+		if (target_type && !strcmp(target_type, TARGET_NAME_THIN) &&
 		    !_ignore_unusable_thins(dev)) {
 			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
 		}
 
-		if (target_type && strcmp(target_type, "error"))
+		if (target_type && strcmp(target_type, TARGET_NAME_ERROR))
 			only_error_target = 0;
 	} while (next);
 
@@ -1160,7 +1160,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	/*
 	 * Try and get some info on this device.
 	 */
-	if (!_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+	if (!_percent(dm, name, dlid, TARGET_NAME_SNAPSHOT, 0, NULL, percent,
 		      NULL, fail_if_percent_unsupported))
 		return_0;
 
@@ -1318,7 +1318,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
-	if (!type || strcmp(type, "cache")) {
+	if (!type || strcmp(type, TARGET_NAME_CACHE)) {
 		log_error("Expected cache segment type but got %s instead",
 			  type ? type : "NULL");
 		goto out;
@@ -1412,7 +1412,7 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "thin-pool", 0,
+	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN_POOL, 0,
 		       (metadata) ? lv : NULL, percent, NULL, 1)))
 		return_0;
 
@@ -1473,7 +1473,7 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (!target_type || strcmp(target_type, "thin")) {
+	if (!target_type || strcmp(target_type, TARGET_NAME_THIN)) {
 		log_error("Unexpected target type %s found for thin %s.",
 			  target_type, display_lvname(lv));
 		goto out;
@@ -2217,7 +2217,7 @@ static int _add_error_area(struct dev_manager *dm, struct dm_tree_node *node,
 	char *dlid;
 	uint64_t extent_size = seg->lv->vg->extent_size;
 
-	if (!strcmp(dm->cmd->stripe_filler, "error")) {
+	if (!strcmp(dm->cmd->stripe_filler, TARGET_NAME_ERROR)) {
 		/*
 		 * FIXME, the tree pointer is first field of dm_tree_node, but
 		 * we don't have the struct definition available.
@@ -2690,7 +2690,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		     dinfo->open_count)) {
 			if (seg_is_thin_volume(seg) ||
 			    /* FIXME Is there anything simpler to check for instead? */
-			    !lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
+			    !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))
 				laopts->no_merging = 1;
 		}
 	}
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index a645756..a65892e 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -230,10 +230,10 @@ static int _target_present(struct cmd_context *cmd,
 	if (!_cache_checked) {
 		_cache_checked = 1;
 
-		if (!(_cache_present = target_present(cmd, "cache", 1)))
+		if (!(_cache_present = target_present(cmd, TARGET_NAME_CACHE, 1)))
 			return 0;
 
-		if (!target_version("cache", &maj, &min, &patchlevel))
+		if (!target_version(TARGET_NAME_CACHE, &maj, &min, &patchlevel))
 			return_0;
 
 		if ((maj < 1) ||
@@ -294,7 +294,7 @@ static int _modules_needed(struct dm_pool *mem,
 			   const struct lv_segment *seg __attribute__((unused)),
 			   struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "cache")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_CACHE)) {
 		log_error("String list allocation failed for cache module.");
 		return 0;
 	}
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index c489b0a..6b355fc 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -55,8 +55,8 @@ static int _errseg_target_present(struct cmd_context *cmd,
 	/* Reported truncated in older kernels */
 	if (!_errseg_checked) {
 		_errseg_checked = 1;
-		_errseg_present = target_present(cmd, "error", 0) ||
-			target_present(cmd, "erro", 0);
+		_errseg_present = target_present(cmd, TARGET_NAME_ERROR, 0) ||
+			target_present(cmd, TARGET_NAME_ERROR_OLD, 0);
 	}
 
 	return _errseg_present;
@@ -66,7 +66,7 @@ static int _errseg_modules_needed(struct dm_pool *mem,
 				  const struct lv_segment *seg __attribute__((unused)),
 				  struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "error")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_ERROR)) {
 		log_error("error module string list allocation failed");
 		return 0;
 	}
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e8a4dc5..d28d7c1 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -301,7 +301,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		 * - IMPORTANT: avoids preload if inactivate merge is pending
 		 */
 		if (lv_has_target_type(origin->vg->vgmem, origin, NULL,
-				       "snapshot-merge")) {
+				       TARGET_NAME_SNAPSHOT_MERGE)) {
 			/*
 			 * preload origin to:
 			 * - allow proper release of -cow
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 2572182..c4ba70a 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -404,7 +404,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	if (!_mirrored_checked) {
 		_mirrored_checked = 1;
 
-		if (!(_mirrored_present = target_present(cmd, "mirror", 1)))
+		if (!(_mirrored_present = target_present(cmd, TARGET_NAME_MIRROR, 1)))
 			return 0;
 
 		/*
@@ -421,7 +421,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 		 */
 		/* FIXME Move this into libdevmapper */
 
-		if (target_version("mirror", &maj, &min, &patchlevel) &&
+		if (target_version(TARGET_NAME_MIRROR, &maj, &min, &patchlevel) &&
 		    maj == 1 &&
 		    ((min >= 1) ||
 		     (min == 0 && driver_version(vsn, sizeof(vsn)) &&
@@ -445,9 +445,9 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 			if (!uname(&uts) &&
 			    (sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) == 3) &&
 			    KERNEL_VERSION(kmaj, kmin, krel) < KERNEL_VERSION(2, 6, 31)) {
-				if (module_present(cmd, "log-clustered"))
+				if (module_present(cmd, MODULE_NAME_LOG_CLUSTERED))
 				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
-			} else if (module_present(cmd, "log-userspace"))
+			} else if (module_present(cmd, MODULE_NAME_LOG_USERSPACE))
 				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 
 			if (!(_mirror_attributes & MIRROR_LOG_CLUSTERED))
@@ -510,12 +510,12 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 		return_0;
 
 	if (vg_is_clustered(seg->lv->vg) &&
-	    !str_list_add(mem, modules, "clog")) {
+	    !str_list_add(mem, modules, MODULE_NAME_CLUSTERED_MIRROR)) {
 		log_error("cluster log string list allocation failed");
 		return 0;
 	}
 
-	if (!str_list_add(mem, modules, "mirror")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_MIRROR)) {
 		log_error("mirror string list allocation failed");
 		return 0;
 	}
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 36f455d..67c355a 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -322,7 +322,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 	if (!_raid_checked) {
 		_raid_checked = 1;
 
-		if (!(_raid_present = target_present(cmd, "raid", 1)))
+		if (!(_raid_present = target_present(cmd, TARGET_NAME_RAID, 1)))
 			return 0;
 
 		if (!target_version("raid", &maj, &min, &patchlevel))
@@ -347,7 +347,7 @@ static int _raid_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute__((unused)),
 				struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "raid")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_RAID)) {
 		log_error("raid module string list allocation failed");
 		return 0;
 	}
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index e443d60..a80f283 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -29,7 +29,7 @@ static const char *_snap_target_name(const struct lv_segment *seg,
 				     const struct lv_activate_opts *laopts)
 {
 	if (!laopts->no_merging && (seg->status & MERGING))
-		return "snapshot-merge";
+		return TARGET_NAME_SNAPSHOT_MERGE;
 
 	return lvseg_name(seg);
 }
@@ -99,7 +99,7 @@ static int _snap_text_export(const struct lv_segment *seg, struct formatter *f)
 #ifdef DEVMAPPER_SUPPORT
 static int _snap_target_status_compatible(const char *type)
 {
-	return (strcmp(type, "snapshot-merge") == 0);
+	return (strcmp(type, TARGET_NAME_SNAPSHOT_MERGE) == 0);
 }
 
 static int _snap_target_percent(void **target_state __attribute__((unused)),
@@ -151,11 +151,11 @@ static int _snap_target_present(struct cmd_context *cmd,
 	if (!_snap_checked) {
 		_snap_checked = 1;
 
-		if (!(_snap_present = target_present(cmd, "snapshot", 1) &&
-		      target_present(cmd, "snapshot-origin", 0)))
+		if (!(_snap_present = target_present(cmd, TARGET_NAME_SNAPSHOT, 1) &&
+		      target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0)))
 			return 0;
 
-		if (target_version("snapshot", &maj, &min, &patchlevel) &&
+		if (target_version(TARGET_NAME_SNAPSHOT, &maj, &min, &patchlevel) &&
 		    (maj > 1 ||
 		     (maj == 1 && (min >= 12 || (min == 10 && patchlevel >= 2)))))
 			_snap_attrs |= SNAPSHOT_FEATURE_FIXED_LEAK;
@@ -169,7 +169,7 @@ static int _snap_target_present(struct cmd_context *cmd,
 	/* TODO: test everything at once */
 	if (_snap_present && seg && (seg->status & MERGING)) {
 		if (!_snap_merge_checked) {
-			_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
+			_snap_merge_present = target_present(cmd, TARGET_NAME_SNAPSHOT_MERGE, 0);
 			_snap_merge_checked = 1;
 		}
 		return _snap_merge_present;
@@ -218,7 +218,7 @@ static int _snap_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute__((unused)),
 				struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "snapshot")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_SNAPSHOT)) {
 		log_error("snapshot string list allocation failed");
 		return 0;
 	}
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 83ba606..530e48e 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -197,8 +197,8 @@ static int _striped_target_present(struct cmd_context *cmd,
 
 	if (!_striped_checked) {
 		_striped_checked = 1;
-		_striped_present = target_present(cmd, "linear", 0) &&
-			target_present(cmd, "striped", 0);
+		_striped_present = target_present(cmd, TARGET_NAME_LINEAR, 0) &&
+			target_present(cmd, TARGET_NAME_STRIPED, 0);
 	}
 
 	return _striped_present;
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index c4c3f84..fc021cd 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -50,7 +50,7 @@ static int _zero_target_present(struct cmd_context *cmd,
 
 	if (!_zero_checked) {
 		_zero_checked = 1;
-		_zero_present = target_present(cmd, "zero", 1);
+		_zero_present = target_present(cmd, TARGET_NAME_ZERO, 1);
 	}
 
 	return _zero_present;
@@ -60,7 +60,7 @@ static int _zero_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute__((unused)),
 				struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "zero")) {
+	if (!str_list_add(mem, modules, MODULE_NAME_ZERO)) {
 		log_error("zero module string list allocation failed");
 		return 0;
 	}


