From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:14:57 +0000 (GMT)
Subject: main - dev_manager: status check with info check included
Message-ID: <20210318181457.BEEEA3844031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5a600860c1b00cd4199eafe26dbc668f8f583ff
Commit:        e5a600860c1b00cd4199eafe26dbc668f8f583ff
Parent:        a60c8748eac2e6f047532b6d106492d120860608
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 11:20:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

dev_manager: status check with info check included

Reduce ioctl count and avoid separate info check,
when we can get the same info from status ioctl.

When devmanager calls return 0, then the exists value 0
means the reason of failure is missing device in table.
In such case we avoid stack trace.

Swap the flush parameter for the vdo status function
to match thin pool status.
---
 lib/activate/activate.c    | 78 ++++++++++++++++-----------------------------
 lib/activate/dev_manager.c | 79 +++++++++++++++++++++++++++-------------------
 lib/activate/dev_manager.h | 13 ++++----
 3 files changed, 80 insertions(+), 90 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 93ab30424..08afd6f38 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1216,6 +1216,7 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 {
 	struct dev_manager *dm;
 	struct lv_segment *cache_seg;
+	int exists;
 
 	if (lv_is_cache_pool(cache_lv)) {
 		if (dm_list_empty(&cache_lv->segs_using_this_lv) ||
@@ -1233,21 +1234,14 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 		return 0;
 	}
 
-	if (!lv_info(cache_lv->vg->cmd, cache_lv, 1, NULL, 0, 0)) {
-		log_error("Cannot check status for locally inactive cache volume %s.",
-			  display_lvname(cache_lv));
-		return 0;
-	}
-
-	log_debug_activation("Checking status for cache volume %s.",
-			     display_lvname(cache_lv));
-
 	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
 		return_0;
 
-	if (!dev_manager_cache_status(dm, cache_lv, status)) {
+	if (!dev_manager_cache_status(dm, cache_lv, status, &exists)) {
 		dev_manager_destroy(dm);
-		return_0;
+		if (exists)
+			stack;
+		return 0;
 	}
 	/* User has to call dm_pool_destroy(status->mem)! */
 
@@ -1258,19 +1252,16 @@ int lv_thin_pool_status(const struct logical_volume *lv, int flush,
 			struct lv_status_thin_pool **thin_pool_status)
 {
 	struct dev_manager *dm;
-
-	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return 0;
-
-	log_debug_activation("Checking thin pool status for LV %s.",
-			     display_lvname(lv));
+	int exists;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!dev_manager_thin_pool_status(dm, lv, flush, thin_pool_status)) {
+	if (!dev_manager_thin_pool_status(dm, lv, flush, thin_pool_status, &exists)) {
 		dev_manager_destroy(dm);
-		return_0;
+		if (exists)
+			stack;
+		return 0;
 	}
 
 	/* User has to call dm_pool_destroy(thin_pool_status->mem)! */
@@ -1282,19 +1273,16 @@ int lv_thin_status(const struct logical_volume *lv, int flush,
 		   struct lv_status_thin **thin_status)
 {
 	struct dev_manager *dm;
-
-	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
-		return 0;
-
-	log_debug_activation("Checking thin status for LV %s.",
-			     display_lvname(lv));
+	int exists;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!dev_manager_thin_status(dm, lv, flush, thin_status)) {
+	if (!dev_manager_thin_status(dm, lv, flush, thin_status, &exists)) {
 		dev_manager_destroy(dm);
-		return_0;
+		if (exists)
+			stack;
+		return 0;
 	}
 
 	/* User has to call dm_pool_destroy(thin_status->mem)! */
@@ -1304,20 +1292,16 @@ int lv_thin_status(const struct logical_volume *lv, int flush,
 
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
 {
-	int r;
 	struct dev_manager *dm;
-
-	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
-		return 0;
-
-	log_debug_activation("Checking device id for LV %s.",
-			     display_lvname(lv));
+	int exists;
+	int r;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_device_id(dm, lv, device_id)))
-		stack;
+	if (!(r = dev_manager_thin_device_id(dm, lv, device_id, &exists)))
+		if (exists)
+			stack;
 
 	dev_manager_destroy(dm);
 
@@ -1334,28 +1318,22 @@ int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
 int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 		       struct lv_status_vdo **vdo_status)
 {
-	int r = 0;
 	struct dev_manager *dm;
-
-	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return 0;
-
-	log_debug_activation("Checking VDO pool status for LV %s.",
-			     display_lvname(lv));
+	int exists;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
 		return_0;
 
-	if (!dev_manager_vdo_pool_status(dm, lv, vdo_status, flush))
-		goto_out;
+	if (!dev_manager_vdo_pool_status(dm, lv, flush, vdo_status, &exists)) {
+		dev_manager_destroy(dm);
+		if (exists)
+			stack;
+		return 0;
+	}
 
 	/* User has to call dm_pool_destroy(vdo_status->mem) */
-	r = 1;
-out:
-	if (!r)
-		dev_manager_destroy(dm);
 
-	return r;
+	return 1;
 }
 
 int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index aa88e6868..40b9ef31d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1558,7 +1558,7 @@ out:
 
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     struct lv_status_cache **status)
+			     struct lv_status_cache **status, int *exists)
 {
 	int r = 0;
 	const char *dlid;
@@ -1569,14 +1569,18 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	char *params = NULL;
 	struct dm_status_cache *c;
 
+	*exists = -1;
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking status for cache volume %s.",
+			     display_lvname(lv));
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
@@ -1621,7 +1625,7 @@ out:
 
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv, int flush,
-				 struct lv_status_thin_pool **status)
+				 struct lv_status_thin_pool **status, int *exists)
 {
 	struct dm_status_thin_pool *dm_status;
 	const char *dlid;
@@ -1632,6 +1636,10 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	char *params = NULL;
 	int r = 0;
 
+	*exists = -1;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin_pool))))
+		return_0;
+
 	/* Build dlid for the thin pool layer */
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
@@ -1639,8 +1647,11 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking thin pool status for LV %s.",
+			     display_lvname(lv));
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
@@ -1653,9 +1664,6 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!dm_get_status_thin_pool(dm->mem, params, &dm_status))
 		goto_out;
 
-	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin_pool))))
-		goto_out;
-
 	(*status)->mem = dm->mem;
 	(*status)->thin_pool = dm_status;
 
@@ -1678,7 +1686,7 @@ out:
 
 int dev_manager_thin_status(struct dev_manager *dm,
 			    const struct logical_volume *lv, int flush,
-			    struct lv_status_thin **status)
+			    struct lv_status_thin **status, int *exists)
 {
 	struct dm_status_thin *dm_status;
 	const char *dlid;
@@ -1690,14 +1698,21 @@ int dev_manager_thin_status(struct dev_manager *dm,
 	uint64_t csize;
 	int r = 0;
 
+	*exists = -1;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin))))
+		return_0;
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking thin status for LV %s.",
+			     display_lvname(lv));
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
@@ -1710,9 +1725,6 @@ int dev_manager_thin_status(struct dev_manager *dm,
 	if (!dm_get_status_thin(dm->mem, params, &dm_status))
 		goto_out;
 
-	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin))))
-		goto_out;
-
 	(*status)->mem = dm->mem;
 	(*status)->thin = dm_status;
 
@@ -1745,7 +1757,7 @@ out:
  */
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
-			       uint32_t *device_id)
+			       uint32_t *device_id, int *exists)
 {
 	const char *dlid;
 	struct dm_task *dmt;
@@ -1755,6 +1767,7 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	const char *layer = lv_layer(lv);
 	int r = 0;
 
+	*exists = -1;
 	if (lv_is_merging_origin(lv) && !lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		/* If the merge has already happened, that table
 		 * can already be using correct LV without -real layer */
@@ -1767,8 +1780,11 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 1, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking device id for LV %s.",
+			     display_lvname(lv));
 
 	if (dm_get_next_target(dmt, NULL, &start, &length,
 			       &target_type, &params)) {
@@ -1797,11 +1813,9 @@ out:
 }
 
 int dev_manager_vdo_pool_status(struct dev_manager *dm,
-				const struct logical_volume *lv,
-				struct lv_status_vdo **vdo_status,
-				int flush)
+				const struct logical_volume *lv, int flush,
+				struct lv_status_vdo **status, int *exists)
 {
-	struct lv_status_vdo *status;
 	const char *dlid;
 	struct dm_info info;
 	uint64_t start, length;
@@ -1810,12 +1824,9 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 	char *params = NULL;
 	int r = 0;
 
-	*vdo_status = NULL;
-
-	if (!(status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_vdo)))) {
-		log_error("Cannot allocate VDO status structure.");
-		return 0;
-	}
+	*exists = -1;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_vdo))))
+		return_0;
 
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
@@ -1823,8 +1834,11 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking VDO pool status for LV %s.",
+			     display_lvname(lv));
 
 	if (dm_get_next_target(dmt, NULL, &start, &length, &type, &params)) {
 		log_error("More then one table line found for %s.",
@@ -1838,11 +1852,10 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (!parse_vdo_pool_status(dm->mem, lv, params, status))
+	if (!parse_vdo_pool_status(dm->mem, lv, params, *status))
 		goto_out;
 
-	status->mem = dm->mem;
-	*vdo_status = status;
+	(*status)->mem = dm->mem;
 
 	r = 1;
 out:
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 557418201..dcd08818d 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -68,20 +68,19 @@ int dev_manager_writecache_message(struct dev_manager *dm,
                                    const char *msg);
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     struct lv_status_cache **status);
+			     struct lv_status_cache **status, int *exists);
 int dev_manager_thin_status(struct dev_manager *dm,
 			    const struct logical_volume *lv, int flush,
-			    struct lv_status_thin **status);
+			    struct lv_status_thin **status, int *exists);
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
-			       uint32_t *device_id);
+			       uint32_t *device_id, int *exist);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv, int flush,
-				 struct lv_status_thin_pool **status);
+				 struct lv_status_thin_pool **status, int *exists);
 int dev_manager_vdo_pool_status(struct dev_manager *dm,
-				const struct logical_volume *lv,
-				struct lv_status_vdo **vdo_status,
-				int flush);
+				const struct logical_volume *lv, int flush,
+				struct lv_status_vdo **status, int *exists);
 int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,


