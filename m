From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:12:37 +0000 (UTC)
Subject: master - dev_manager: enhance dev_manager_info to acquire LV segment status if requested, add lv_info_with_seg_status fn
Message-ID: <20141111121237.C3D1961079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2c1024f6ac7e22ac5c010a267d0c1df331ee416
Commit:        a2c1024f6ac7e22ac5c010a267d0c1df331ee416
Parent:        7f90ad84c1f9bbc51a833b7ebb6459842405de52
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 4 15:00:32 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 13:04:02 2014 +0100

dev_manager: enhance dev_manager_info to acquire LV segment status if requested, add lv_info_with_seg_status fn

---
 lib/activate/activate.c    |   42 ++++++++++---
 lib/activate/activate.h    |    5 ++
 lib/activate/dev_manager.c |  140 ++++++++++++++++++++++++++++++++++++-------
 lib/activate/dev_manager.h |    4 +-
 tools/reporter.c           |    2 +
 5 files changed, 160 insertions(+), 33 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 93f9b9c..2843e61 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -617,17 +617,12 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 	return target_version(target_name, &maj, &min, &patchlevel);
 }
 
-/*
- * Returns 1 if info structure populated, else 0 on failure.
- * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
- */
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
-	    struct lvinfo *info, int with_open_count, int with_read_ahead)
+static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
+		    int use_layer, struct lvinfo *info, struct lv_seg_status *seg_status,
+		    int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
 
-	if (!activation())
-		return 0;
 	/*
 	 * If open_count info is requested and we have to be sure our own udev
 	 * transactions are finished
@@ -648,7 +643,8 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	if (!dev_manager_info(cmd->mem, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
-			      &dminfo, (info) ? &info->read_ahead : NULL))
+			      &dminfo, (info) ? &info->read_ahead : NULL,
+			      seg_status))
 		return_0;
 
 	if (!info)
@@ -666,6 +662,19 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	return 1;
 }
 
+/*
+ * Returns 1 if info structure populated, else 0 on failure.
+ * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
+ */
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
+	    struct lvinfo *info, int with_open_count, int with_read_ahead)
+{
+	if (!activation())
+		return 0;
+
+	return _lv_info(cmd, lv, use_layer, info, NULL, with_open_count, with_read_ahead);
+}
+
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
@@ -681,6 +690,21 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 	return r;
 }
 
+int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
+			   const struct lv_segment *lv_seg, int use_layer,
+			   struct lv_with_info_and_seg_status *lvdm,
+			   int with_open_count, int with_read_ahead)
+{
+	if (!activation())
+		return 0;
+
+	if (!_lv_info(cmd, lv, use_layer, lvdm->info, lvdm->seg_status,
+		      with_open_count, with_read_ahead))
+		return 0;
+
+	return 1;
+}
+
 #define OPEN_COUNT_CHECK_RETRIES 25
 #define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
 
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ab5e69d..86c53f5 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -118,6 +118,11 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
+int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
+			    const struct lv_segment *lv_seg, int use_layer,
+			    struct lv_with_info_and_seg_status *lvdm,
+			    int with_open_count, int with_read_ahead);
+
 int lv_check_not_in_use(const struct logical_volume *lv);
 
 /*
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2651ec8..5a07fad 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -106,32 +106,122 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 	return NULL;
 }
 
-static int _info_run(const char *name, const char *dlid, struct dm_info *info,
-		     uint32_t *read_ahead, int mknodes, int with_open_count,
-		     int with_read_ahead, uint32_t major, uint32_t minor)
+static int _get_segment_status_from_target_params(const char *target_name,
+						  const char *params,
+						  struct lv_seg_status *seg_status)
+{
+	struct segment_type *segtype;
+
+	/* FIXME: linear is also represented as striped with stripe count 1.
+		  We're not reporting linear or striped status anyway, so
+		  just skip the error here till this is properly resolved.*/
+	if (!strcmp(target_name, "linear") || !strcmp(target_name, "striped"))
+		return 1;
+
+	segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name);
+
+	if (segtype != seg_status->seg->segtype) {
+		log_error(INTERNAL_ERROR "_get_segment_status_from_target_params: "
+			  "segment type %s found does not match expected segment type %s",
+			   segtype->name, seg_status->seg->segtype->name);
+		return 0;
+	}
+
+	if (!strcmp(segtype->name, "cache")) {
+		if (!dm_get_status_cache(seg_status->mem, params,
+			(struct dm_status_cache **) &seg_status->status))
+				return_0;
+			seg_status->type = SEG_STATUS_CACHE;
+	} else if (!strcmp(segtype->name, "raid")) {
+		if (!dm_get_status_raid(seg_status->mem, params,
+			(struct dm_status_raid **) &seg_status->status))
+				return_0;
+			seg_status->type = SEG_STATUS_RAID;
+	} else if (!strcmp(segtype->name, "thin")) {
+		if (!dm_get_status_thin(seg_status->mem, params,
+			(struct dm_status_thin **) &seg_status->status))
+				return_0;
+			seg_status->type = SEG_STATUS_THIN;
+	} else if (!strcmp(segtype->name, "thin-pool")) {
+		if (!dm_get_status_thin_pool(seg_status->mem, params,
+			(struct dm_status_thin_pool **) &seg_status->status))
+				return_0;
+			seg_status->type = SEG_STATUS_THIN_POOL;
+	} else if (!strcmp(segtype->name, "snapshot")) {
+		if (!dm_get_status_snapshot(seg_status->mem, params,
+			(struct dm_status_snapshot **) &seg_status->status))
+				return_0;
+		seg_status->type = SEG_STATUS_SNAPSHOT;
+	}
+
+	return 1;
+}
+
+typedef enum {
+	INFO,	/* DM_DEVICE_INFO ioctl */
+	STATUS, /* DM_DEVICE_STATUS ioctl */
+	MKNODES
+} info_type_t;
+
+static int _info_run(info_type_t type, const char *name, const char *dlid,
+		     struct dm_info *dminfo, uint32_t *read_ahead,
+		     struct lv_seg_status *seg_status,
+		     int with_open_count, int with_read_ahead,
+		     uint32_t major, uint32_t minor)
 {
 	int r = 0;
 	struct dm_task *dmt;
 	int dmtask;
+	void *target = NULL;
+	uint64_t target_start, target_length;
+	char *target_name, *target_params, *params_to_process = NULL;
+	uint32_t extent_size;
+
+	switch (type) {
+		case INFO:
+			dmtask = DM_DEVICE_INFO;
+			break;
+		case STATUS:
+			dmtask = DM_DEVICE_STATUS;
+			break;
+		case MKNODES:
+			dmtask = DM_DEVICE_MKNODES;
+			break;
+	}
 
-	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
-
-	if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor,
-				with_open_count)))
+	if (!(dmt = _setup_task(type != MKNODES ? name : NULL, dlid, 0, dmtask,
+				major, minor, with_open_count)))
 		return_0;
 
 	if (!dm_task_run(dmt))
 		goto_out;
 
-	if (!dm_task_get_info(dmt, info))
+	if (!dm_task_get_info(dmt, dminfo))
 		goto_out;
 
-	if (with_read_ahead && info->exists) {
+	if (with_read_ahead && dminfo->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
 	} else if (read_ahead)
 		*read_ahead = DM_READ_AHEAD_NONE;
 
+	if (type == STATUS) {
+		extent_size = seg_status->seg->lv->vg->extent_size;
+		do {
+			target = dm_get_next_target(dmt, target, &target_start,
+						    &target_length, &target_name, &target_params);
+			if ((seg_status->seg->le * extent_size == target_start) &&
+			    (seg_status->seg->len * extent_size == target_length)) {
+				params_to_process = target_params;
+				break;
+			}
+		} while (target);
+
+		if (params_to_process &&
+		    !_get_segment_status_from_target_params(target_name, params_to_process, seg_status))
+			goto_out;
+	}
+
 	r = 1;
 
       out:
@@ -476,7 +566,8 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 }
 
 static int _info(const char *dlid, int with_open_count, int with_read_ahead,
-		 struct dm_info *info, uint32_t *read_ahead)
+		 struct dm_info *dminfo, uint32_t *read_ahead,
+		 struct lv_seg_status *seg_status)
 {
 	int r = 0;
 	char old_style_dlid[sizeof(UUID_PREFIX) + 2 * ID_LEN];
@@ -484,8 +575,8 @@ static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 	unsigned i = 0;
 
 	/* Check for dlid */
-	if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
-			   with_read_ahead, 0, 0)) && info->exists)
+	if ((r = _info_run(seg_status ? STATUS : INFO, NULL, dlid, dminfo, read_ahead,
+			   seg_status, with_open_count, with_read_ahead, 0, 0)) && dminfo->exists)
 		return 1;
 
 	/* Check for original version of dlid before the suffixes got added in 2.02.106 */
@@ -496,16 +587,17 @@ static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 
 			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
 			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
-			if ((r = _info_run(NULL, old_style_dlid, info, read_ahead, 0, with_open_count,
-					   with_read_ahead, 0, 0)) && info->exists)
+			if ((r = _info_run(seg_status ? STATUS : INFO, NULL, old_style_dlid, dminfo,
+					   read_ahead, seg_status, with_open_count,
+					   with_read_ahead, 0, 0)) && dminfo->exists)
 				return 1;
 		}
 	}
 
 	/* Check for dlid before UUID_PREFIX was added */
-	if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
-				read_ahead, 0, with_open_count,
-				with_read_ahead, 0, 0)) && info->exists)
+	if ((r = _info_run(seg_status ? STATUS : INFO, NULL, dlid + sizeof(UUID_PREFIX) - 1,
+				dminfo, read_ahead, seg_status, with_open_count,
+				with_read_ahead, 0, 0)) && dminfo->exists)
 		return 1;
 
 	return r;
@@ -513,13 +605,14 @@ static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 {
-	return _info_run(NULL, NULL, info, NULL, 0, 0, 0, major, minor);
+	return _info_run(INFO, NULL, NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     const char *layer,
 		     int with_open_count, int with_read_ahead,
-		     struct dm_info *info, uint32_t *read_ahead)
+		     struct dm_info *dminfo, uint32_t *read_ahead,
+		     struct lv_seg_status *seg_status)
 {
 	char *dlid, *name;
 	int r;
@@ -536,7 +629,8 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 	}
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
+	r = _info(dlid, with_open_count, with_read_ahead,
+		  dminfo, read_ahead, seg_status);
 out:
 	dm_pool_free(mem, name);
 
@@ -1447,7 +1541,7 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if ((r = _info_run(name, NULL, &dminfo, NULL, 1, 0, 0, 0, 0))) {
+	if ((r = _info_run(MKNODES, name, NULL, &dminfo, NULL, NULL, 0, 0, 0, 0))) {
 		if (dminfo.exists) {
 			if (lv_is_visible(lv))
 				r = _dev_manager_lv_mknodes(lv);
@@ -1589,7 +1683,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	if (!_info(dlid, 1, 0, &info, NULL)) {
+	if (!_info(dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
@@ -2078,7 +2172,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 		return_NULL;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
-	if (!_info(dlid, 1, 0, &info, NULL)) {
+	if (!_info(dlid, 1, 0, &info, NULL, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index f4f989c..bfc6c02 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -25,6 +25,7 @@ struct cmd_context;
 struct dev_manager;
 struct dm_info;
 struct device;
+struct lv_seg_status;
 
 int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts);
 
@@ -47,7 +48,8 @@ void dev_manager_exit(void);
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     const char *layer,
 		     int with_open_count, int with_read_ahead,
-		     struct dm_info *info, uint32_t *read_ahead);
+		     struct dm_info *dminfo, uint32_t *read_ahead,
+		     struct lv_seg_status *seg_status);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 dm_percent_t *percent);
diff --git a/tools/reporter.c b/tools/reporter.c
index d8c19eb..8fe5698 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -59,6 +59,8 @@ static void _get_lv_info_for_report(struct cmd_context *cmd,
 static void _get_lv_info_with_segment_status_for_report(struct cmd_context *cmd,
 							struct lv_with_info_and_seg_status *lvdm)
 {
+	if (!lv_info_with_seg_status(cmd, lvdm->seg_status->seg->lv, lvdm->seg_status->seg, 0, lvdm, 1, 1))
+		lvdm->info->exists = 0;
 }
 
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,


