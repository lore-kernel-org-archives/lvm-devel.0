From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:13 +0000 (GMT)
Subject: dev-next - dev_manager: add lv_raid_status
Message-ID: <20210322153913.F35A8385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9b4acd511beb4d5ba8d0175ad1fb56927d92c03
Commit:        a9b4acd511beb4d5ba8d0175ad1fb56927d92c03
Parent:        e5a600860c1b00cd4199eafe26dbc668f8f583ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 09:50:09 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

dev_manager: add lv_raid_status

Just like with other segtype use this function to get whole
raid status info available per a single ioctl call.

Also it nicely simplifies read of percentage info about
in_sync portion of raid volume.

TODO: drop use of other calls then lv_raid_status call,
since all such calls could already use status - so it just
adds unnecessary duplication.
---
 lib/activate/activate.c          | 133 +++++++++++++++++++--------------------
 lib/activate/activate.h          |   1 +
 lib/activate/dev_manager.c       |  20 ++++--
 lib/activate/dev_manager.h       |   2 +-
 lib/metadata/metadata-exported.h |   5 ++
 5 files changed, 88 insertions(+), 73 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 08afd6f38..8151293c3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -972,35 +972,28 @@ int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent)
 
 int lv_raid_data_offset(const struct logical_volume *lv, uint64_t *data_offset)
 {
-	int r;
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
+	struct lv_status_raid *raid_status;
 
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking raid data offset and dev sectors for LV %s/%s",
 			     lv->vg->name, lv->name);
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
-		return_0;
 
-	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
-		dev_manager_destroy(dm);
-		return_0;
-	}
+	if (!lv_raid_status(lv, &raid_status))
+                return_0;
 
-	*data_offset = status->data_offset;
+	*data_offset = raid_status->raid->data_offset;
 
-	dev_manager_destroy(dm);
+	dm_pool_destroy(raid_status->mem);
 
-	return r;
+	return 1;
 }
 
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 {
-	int r;
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
+	int r = 1;
+	struct lv_status_raid *raid_status;
 
 	*dev_health = NULL;
 
@@ -1010,25 +1003,23 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	log_debug_activation("Checking raid device health for LV %s.",
 			     display_lvname(lv));
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
-		return_0;
+	if (!lv_raid_status(lv, &raid_status))
+                return_0;
 
-	if (!(r = dev_manager_raid_status(dm, lv, &status)) ||
-	    !(*dev_health = dm_pool_strdup(lv->vg->cmd->mem,
-					   status->dev_health))) {
-		dev_manager_destroy(dm);
-		return_0;
+	if (!(*dev_health = dm_pool_strdup(lv->vg->cmd->mem,
+					  raid_status->raid->dev_health))) {
+		stack;
+                r = 0;
 	}
 
-	dev_manager_destroy(dm);
+	dm_pool_destroy(raid_status->mem);
 
 	return r;
 }
 
 int lv_raid_dev_count(const struct logical_volume *lv, uint32_t *dev_cnt)
 {
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
+	struct lv_status_raid *raid_status;
 
 	*dev_cnt = 0;
 
@@ -1037,24 +1028,20 @@ int lv_raid_dev_count(const struct logical_volume *lv, uint32_t *dev_cnt)
 
 	log_debug_activation("Checking raid device count for LV %s/%s",
 			     lv->vg->name, lv->name);
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
-		return_0;
 
-	if (!dev_manager_raid_status(dm, lv, &status)) {
-		dev_manager_destroy(dm);
+	if (!lv_raid_status(lv, &raid_status))
 		return_0;
-	}
-	*dev_cnt = status->dev_count;
 
-	dev_manager_destroy(dm);
+	*dev_cnt = raid_status->raid->dev_count;
+
+	dm_pool_destroy(raid_status->mem);
 
 	return 1;
 }
 
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 {
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
+	struct lv_status_raid *raid_status;
 
 	*cnt = 0;
 
@@ -1064,25 +1051,20 @@ int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 	log_debug_activation("Checking raid mismatch count for LV %s.",
 			     display_lvname(lv));
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+	if (!lv_raid_status(lv, &raid_status))
 		return_0;
 
-	if (!dev_manager_raid_status(dm, lv, &status)) {
-		dev_manager_destroy(dm);
-		return_0;
-	}
-	*cnt = status->mismatch_count;
+	*cnt = raid_status->raid->mismatch_count;
 
-	dev_manager_destroy(dm);
+	dm_pool_destroy(raid_status->mem);
 
 	return 1;
 }
 
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 {
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
-	char *action;
+	struct lv_status_raid *raid_status;
+	int r = 1;
 
 	*sync_action = NULL;
 
@@ -1092,30 +1074,27 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 	log_debug_activation("Checking raid sync_action for LV %s.",
 			     display_lvname(lv));
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+	if (!lv_raid_status(lv, &raid_status))
 		return_0;
 
 	/* status->sync_action can be NULL if dm-raid version < 1.5.0 */
-	if (!dev_manager_raid_status(dm, lv, &status) ||
-	    !status->sync_action ||
-	    !(action = dm_pool_strdup(lv->vg->cmd->mem,
-				      status->sync_action))) {
-		dev_manager_destroy(dm);
-		return_0;
+	if (!raid_status->raid->sync_action ||
+	    !(*sync_action = dm_pool_strdup(lv->vg->cmd->mem,
+					    raid_status->raid->sync_action))) {
+		stack;
+		r = 0;
 	}
 
-	*sync_action = action;
-
-	dev_manager_destroy(dm);
+	dm_pool_destroy(raid_status->mem);
 
-	return 1;
+	return r;
 }
 
 int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
+	struct lv_status_raid *raid_status;
+	struct dev_manager *dm = NULL;
 	int r = 0;
-	struct dev_manager *dm;
-	struct dm_status_raid *status;
 
 	if (!seg_is_raid(first_seg(lv))) {
 		/*
@@ -1140,16 +1119,10 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		return 0;
 	}
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+	if (!lv_raid_status(lv, &raid_status))
 		return_0;
 
-	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
-		log_error("Failed to retrieve status of %s.",
-			  display_lvname(lv));
-		goto out;
-	}
-
-	if (!status->sync_action) {
+	if (!raid_status->raid->sync_action) {
 		log_error("Kernel driver does not support this action: %s", msg);
 		goto out;
 	}
@@ -1171,19 +1144,43 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		log_error("\"%s\" is not a supported sync operation.", msg);
 		goto out;
 	}
-	if (strcmp(status->sync_action, "idle")) {
+	if (strcmp(raid_status->raid->sync_action, "idle")) {
 		log_error("%s state is currently \"%s\".  Unable to switch to \"%s\".",
-			  display_lvname(lv), status->sync_action, msg);
+			  display_lvname(lv), raid_status->raid->sync_action, msg);
 		goto out;
 	}
 
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
 	r = dev_manager_raid_message(dm, lv, msg);
 out:
-	dev_manager_destroy(dm);
+	if (dm)
+		dev_manager_destroy(dm);
+	dm_pool_destroy(raid_status->mem);
 
 	return r;
 }
 
+int lv_raid_status(const struct logical_volume *lv, struct lv_status_raid **status)
+{
+	struct dev_manager *dm;
+	int exists;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_raid_status(dm, lv, status, &exists)) {
+		dev_manager_destroy(dm);
+		if (exists)
+			stack;
+		return 0;
+	}
+	/* User has to call dm_pool_destroy(status->mem)! */
+
+	return 1;
+}
+
 int lv_writecache_message(const struct logical_volume *lv, const char *msg)
 {
 	int r = 0;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4c9328a66..edd385aef 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -188,6 +188,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
+int lv_raid_status(const struct logical_volume *lv, struct lv_status_raid **status);
 int lv_writecache_message(const struct logical_volume *lv, const char *msg);
 int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 40b9ef31d..98917dc38 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1437,7 +1437,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 
 int dev_manager_raid_status(struct dev_manager *dm,
 			    const struct logical_volume *lv,
-			    struct dm_status_raid **status)
+			    struct lv_status_raid **status, int *exists)
 {
 	int r = 0;
 	const char *dlid;
@@ -1447,6 +1447,11 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	char *type = NULL;
 	char *params = NULL;
 	const char *layer = lv_layer(lv);
+	struct dm_status_raid *sr;
+
+	*exists = -1;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
+		return_0;
 
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
@@ -1454,8 +1459,11 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		return_0;
 
-	if (!info.exists)
-		goto_out;
+	if (!(*exists = info.exists))
+		goto out;
+
+	log_debug_activation("Checking raid status for volume %s.",
+			     display_lvname(lv));
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
@@ -1467,9 +1475,13 @@ int dev_manager_raid_status(struct dev_manager *dm,
 
 	/* FIXME Check there's only one target */
 
-	if (!dm_get_status_raid(dm->mem, params, status))
+	if (!dm_get_status_raid(dm->mem, params, &sr))
 		goto_out;
 
+	(*status)->mem = dm->mem; /* User has to destroy this mem pool later */
+	(*status)->raid = sr;
+	(*status)->in_sync = dm_make_percent(sr->insync_regions, sr->total_regions);
+
 	r = 1;
 out:
 	dm_task_destroy(dmt);
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index dcd08818d..27092f2b9 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -59,7 +59,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 			       dm_percent_t *percent, uint32_t *event_nr);
 int dev_manager_raid_status(struct dev_manager *dm,
 			    const struct logical_volume *lv,
-			    struct dm_status_raid **status);
+			    struct lv_status_raid **status, int *exists);
 int dev_manager_raid_message(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     const char *msg);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 874088993..8ae067ebc 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1239,6 +1239,11 @@ int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
 /* ++  metadata/raid_manip.c */
+struct lv_status_raid {
+	struct dm_pool *mem;
+	struct dm_status_raid *raid;
+	dm_percent_t in_sync;
+};
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,


