From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:20 +0000 (UTC)
Subject: master - dev_manager: extend setup_task
Message-ID: <20161205161520.551F1602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5163b8f697191caf13ae8192781f65b3f6335e74
Commit:        5163b8f697191caf13ae8192781f65b3f6335e74
Parent:        e2c7e0ad1196cc9323b63807ed199bcf4b10807c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 14:56:32 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:11:49 2016 +0100

dev_manager: extend setup_task

Integrate also query for inactive table and
handle dm_task_run() and dm_task_get_info()
(thus switching to setup_task_run)

Add one exception case for DM_DEVICE_TARGET_MSG.

This allows further shortening and simplification of all
other users of this function.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |  185 ++++++++++++++++----------------------------
 2 files changed, 67 insertions(+), 119 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index df4c49e..eb64542 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Better API for internal function _setup_task_run.
   Avoid using lv_has_target_type() call within lv_info_with_seg_status.
   Simplify internal lv_info_with_seg_status API.
   Decide which status is needed in one place for lv_info_with_seg_status.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a72d5a9..a90b6c0 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -81,12 +81,16 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
 
 /*
  * Low level device-layer operations.
+ *
+ * Unless task is DM_DEVICE_TARGET_MSG, also calls dm_task_run()
  */
-static struct dm_task *_setup_task(const char *name, const char *uuid,
-				   uint32_t *event_nr, int task,
-				   uint32_t major, uint32_t minor,
-				   int with_open_count,
-				   int with_flush)
+static struct dm_task *_setup_task_run(int task, struct dm_info *info,
+				       const char *name, const char *uuid,
+				       uint32_t *event_nr,
+				       uint32_t major, uint32_t minor,
+				       int with_open_count,
+				       int with_flush,
+				       int query_inactive)
 {
 	struct dm_task *dmt;
 
@@ -108,14 +112,29 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 	if (activation_checks() && !dm_task_enable_checks(dmt))
 		goto_out;
 
+	if (query_inactive && !dm_task_query_inactive_table(dmt)) {
+		log_error("Failed to set query_inactive_table.");
+		goto out;
+	}
+
 	if (!with_open_count && !dm_task_no_open_count(dmt))
 		log_warn("WARNING: Failed to disable open_count.");
 
 	if (!with_flush && !dm_task_no_flush(dmt))
 		log_warn("WARNING: Failed to set no_flush.");
 
+	if (task == DM_DEVICE_TARGET_MSG)
+		return dmt; /* TARGET_MSG needs more local tweaking before task_run() */
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (info && !dm_task_get_info(dmt, info))
+		goto_out;
+
 	return dmt;
-      out:
+
+out:
 	dm_task_destroy(dmt);
 	return NULL;
 }
@@ -225,16 +244,11 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 			return 0;
 	}
 
-	if (!(dmt = _setup_task((type == MKNODES) ? name : NULL, dlid, 0, dmtask,
-				major, minor, with_open_count, with_flush)))
+	if (!(dmt = _setup_task_run(dmtask, dminfo,
+				    (type == MKNODES) ? name : NULL, dlid, 0,
+				    major, minor, with_open_count, with_flush, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, dminfo))
-		goto_out;
-
 	if (with_read_ahead && dminfo->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
@@ -357,11 +371,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	 * We avoid another system call if we can, but if a device is
 	 * dead, we have no choice but to look up the table too.
 	 */
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
-		goto_out;
-
-	if (!dm_task_run(dmt))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, NULL, NULL, NULL, NULL,
+				    MAJOR(dev->dev), MINOR(dev->dev), 0, 1, 0)))
 		goto_out;
 
 	do {
@@ -397,22 +408,15 @@ static int _device_is_suspended(int major, int minor)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
-	int r = 0;
 
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_INFO,
-				major, minor, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_INFO, &info,
+				    NULL, NULL, NULL,
+				    major, minor, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt) ||
-	    !dm_task_get_info(dmt, &info)) {
-		log_error("Failed to get info for device %d:%d", major, minor);
-		goto out;
-	}
-
-	r = info.exists && info.suspended;
-out:
 	dm_task_destroy(dmt);
-	return r;
+
+	return (info.exists && info.suspended);
 }
 
 static int _ignore_suspended_snapshot_component(struct device *dev)
@@ -424,15 +428,11 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 	int major1, minor1, major2, minor2;
 	int r = 0;
 
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, NULL,
+				    NULL, NULL, NULL,
+				    MAJOR(dev->dev), MINOR(dev->dev), 0, 1, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of snapshot or snapshot origin device.");
-		goto out;
-	}
-
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
@@ -471,14 +471,10 @@ static int _ignore_unusable_thins(struct device *dev)
 	if (!(mem = dm_pool_create("unusable_thins", 128)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, NULL, NULL, NULL, NULL,
+				    MAJOR(dev->dev), MINOR(dev->dev), 0, 1, 0)))
 		goto_out;
 
-	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of mapped device.");
-		goto out;
-	}
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 	if (!params || sscanf(params, "%d:%d", &major, &minor) != 2) {
 		log_error("Failed to get thin-pool major:minor for thin device %d:%d.",
@@ -487,15 +483,10 @@ static int _ignore_unusable_thins(struct device *dev)
 	}
 	dm_task_destroy(dmt);
 
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
-				major, minor, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, NULL, NULL, NULL, NULL,
+				    major, minor, 0, 0, 0)))
 		goto_out;
 
-	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of mapped device.");
-		goto out;
-	}
-
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 	if (!dm_get_status_thin_pool(mem, params, &status))
 		goto_out;
@@ -544,18 +535,10 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 	int only_error_target = 1;
 	int r = 0;
 
-	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
-				MAJOR(dev->dev), MINOR(dev->dev), 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, NULL, NULL,
+				    MAJOR(dev->dev), MINOR(dev->dev), 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of mapped device");
-		goto out;
-	}
-
-	if (!dm_task_get_info(dmt, &info))
-		goto_out;
-
 	if (!info.exists)
 		goto out;
 
@@ -810,29 +793,20 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		goto_bad;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	/* If there is a preloaded table, use that in preference. */
 	if (info.inactive_table) {
 		dm_task_destroy(dmt);
 
-		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
+		if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 1)))
 			goto_bad;
 
-		if (!dm_task_query_inactive_table(dmt))
-			goto_out;
-
-		if (!dm_task_run(dmt))
-			goto_out;
-
-		if (!dm_task_get_info(dmt, &info) || !info.exists || !info.inactive_table)
+		if (!info.exists || !info.inactive_table)
 			goto_out;
 	}
 
@@ -868,29 +842,20 @@ static int _thin_lv_has_device_id(struct dm_pool *mem, const struct logical_volu
 	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 1, 0)))
 		goto_bad;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	/* If there is a preloaded table, use that in preference. */
 	if (info.inactive_table) {
 		dm_task_destroy(dmt);
 
-		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
+		if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 1, 1)))
 			goto_bad;
 
-		if (!dm_task_query_inactive_table(dmt))
-			goto_out;
-
-		if (!dm_task_run(dmt))
-			goto_out;
-
-		if (!dm_task_get_info(dmt, &info) || !info.exists || !info.inactive_table)
+		if (!info.exists || !info.inactive_table)
 			goto_out;
 	}
 
@@ -993,14 +958,11 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
 		return_0;
 
-	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0, 0)))
+	if (!(dmt = _setup_task_run(wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, &info,
+				    name, dlid, event_nr, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	if (event_nr)
@@ -1111,13 +1073,10 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, NULL, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	do {
@@ -1307,13 +1266,10 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
@@ -1366,7 +1322,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0, 0, 1)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TARGET_MSG, NULL, NULL, dlid, 0, 0, 0, 0, 1, 0)))
 		return_0;
 
 	if (!dm_task_set_message(dmt, msg))
@@ -1401,13 +1357,10 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
@@ -1465,13 +1418,10 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, flush)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
@@ -1549,13 +1499,10 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 1, 0)))
 		return_0;
 
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!info.exists)
 		goto_out;
 
 	if (dm_get_next_target(dmt, NULL, &start, &length,


