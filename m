From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:34 +0000 (UTC)
Subject: master - setup_task: add with_flush
Message-ID: <20160527134734.C27136050D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4f8d1165cfed1a3d62b4b11fd46302fb7e9563c
Commit:        a4f8d1165cfed1a3d62b4b11fd46302fb7e9563c
Parent:        26889b3bb636b5655620f25c38db2c6759bf708d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 13:45:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

setup_task: add with_flush

To get better control when flushing is used add extra arg when
setting up dm task.

By default now check dm device status without flush.
(At this moment this should effect only thin and cache volumes).

Also switch dev_manager_thin_pool_status() to use more
readable 'flush' parameter instead of 'no_flush'.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |   63 +++++++++++++++++++-------------------------
 lib/activate/dev_manager.h |    2 +-
 4 files changed, 30 insertions(+), 38 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa352a2..44be410 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Extend setup_task() to preset flushing for dm_task object.
   When checking LV is a merging COW, validate its a COW LV first.
   Correcting value in copy_percent() for 100%.
   Update vgreduce to use process_each_vg.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1ef83d3..d5e416d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1202,7 +1202,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_pool_status(dm, lv, &status, 1)))
+	if (!(r = dev_manager_thin_pool_status(dm, lv, &status, 0)))
 		stack;
 	else
 		*transaction_id = status->transaction_id;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 32295fb..63cfe9c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -85,7 +85,8 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
 static struct dm_task *_setup_task(const char *name, const char *uuid,
 				   uint32_t *event_nr, int task,
 				   uint32_t major, uint32_t minor,
-				   int with_open_count)
+				   int with_open_count,
+				   int with_flush)
 {
 	struct dm_task *dmt;
 
@@ -110,6 +111,9 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 	if (!with_open_count && !dm_task_no_open_count(dmt))
 		log_warn("WARNING: Failed to disable open_count.");
 
+	if (!with_flush && !dm_task_no_flush(dmt))
+		log_warn("WARNING: Failed to set no_flush.");
+
 	return dmt;
       out:
 	dm_task_destroy(dmt);
@@ -192,6 +196,7 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 	uint64_t target_start, target_length;
 	char *target_name, *target_params, *params_to_process = NULL;
 	uint32_t extent_size;
+	int with_flush = 1; /* TODO: arg for _info_run */
 
 	switch (type) {
 		case INFO:
@@ -199,6 +204,7 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 			break;
 		case STATUS:
 			dmtask = DM_DEVICE_STATUS;
+			with_flush = 0;
 			break;
 		case MKNODES:
 			dmtask = DM_DEVICE_MKNODES;
@@ -209,7 +215,7 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 	}
 
 	if (!(dmt = _setup_task((type == MKNODES) ? name : NULL, dlid, 0, dmtask,
-				major, minor, with_open_count)))
+				major, minor, with_open_count, with_flush)))
 		return_0;
 
 	if (!dm_task_run(dmt))
@@ -338,7 +344,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	 * dead, we have no choice but to look up the table too.
 	 */
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0)))
+				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
 		goto_out;
 
 	if (!dm_task_run(dmt))
@@ -380,7 +386,7 @@ static int _device_is_suspended(int major, int minor)
 	int r = 0;
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_INFO,
-				major, minor, 0)))
+				major, minor, 0, 0)))
 		return_0;
 
 	if (!dm_task_run(dmt) ||
@@ -405,7 +411,7 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 	int r = 0;
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0)))
+				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
 		return_0;
 
 	if (!dm_task_run(dmt)) {
@@ -452,7 +458,7 @@ static int _ignore_unusable_thins(struct device *dev)
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
-				MAJOR(dev->dev), MINOR(dev->dev), 0)))
+				MAJOR(dev->dev), MINOR(dev->dev), 0, 1)))
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
@@ -468,12 +474,9 @@ static int _ignore_unusable_thins(struct device *dev)
 	dm_task_destroy(dmt);
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
-				major, minor, 0)))
+				major, minor, 0, 0)))
 		goto_out;
 
-	if (!dm_task_no_flush(dmt))
-		log_warn("Can't set no_flush.");
-
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device.");
 		goto out;
@@ -528,13 +531,9 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 	int r = 0;
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
-				MAJOR(dev->dev), MINOR(dev->dev), 0)))
+				MAJOR(dev->dev), MINOR(dev->dev), 0, 0)))
 		return_0;
 
-	/* Non-blocking status read */
-	if (!dm_task_no_flush(dmt))
-		log_warn("WARNING: Can't set no_flush for dm status.");
-
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device");
 		goto out;
@@ -797,7 +796,7 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
 		goto_bad;
 
 	if (!dm_task_run(dmt))
@@ -810,7 +809,7 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 	if (info.inactive_table) {
 		dm_task_destroy(dmt);
 
-		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
+		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
 			goto_bad;
 
 		if (!dm_task_query_inactive_table(dmt))
@@ -855,7 +854,7 @@ static int _thin_lv_has_device_id(struct dm_pool *mem, const struct logical_volu
 	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
 		goto_bad;
 
 	if (!dm_task_run(dmt))
@@ -868,7 +867,7 @@ static int _thin_lv_has_device_id(struct dm_pool *mem, const struct logical_volu
 	if (info.inactive_table) {
 		dm_task_destroy(dmt);
 
-		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
+		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
 			goto_bad;
 
 		if (!dm_task_query_inactive_table(dmt))
@@ -981,14 +980,9 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		return_0;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0)))
+				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0, 0)))
 		return_0;
 
-	/* No freeze on overfilled thin-pool, read existing slightly outdated data */
-	if (segtype_is_thin(segtype) &&
-	    !dm_task_no_flush(dmt))
-		log_warn("Can't set no_flush flag."); /* Non fatal */
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -1103,7 +1097,7 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0, 0)))
+	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0, 0, 0)))
 		return_0;
 
 	if (!dm_task_run(dmt))
@@ -1299,7 +1293,7 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
 		return_0;
 
 	if (!dm_task_run(dmt))
@@ -1358,7 +1352,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0, 0, 1)))
 		return_0;
 
 	if (!dm_task_set_message(dmt, msg))
@@ -1393,7 +1387,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, 0)))
 		return_0;
 
 	if (!dm_task_run(dmt))
@@ -1442,7 +1436,7 @@ out:
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
-				 int noflush)
+				 int flush)
 {
 	const char *dlid;
 	struct dm_task *dmt;
@@ -1456,12 +1450,9 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0, flush)))
 		return_0;
 
-	if (noflush && !dm_task_no_flush(dmt))
-		log_warn("Can't set no_flush.");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -1543,7 +1534,7 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0, 1)))
 		return_0;
 
 	if (!dm_task_run(dmt))
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 3744a61..ba198f5 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -69,7 +69,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
-				 int noflush);
+				 int flush);
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
 				  int metadata, dm_percent_t *percent);


