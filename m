From: Milan Broz <mbroz@redhat.com>
Date: Tue, 23 Feb 2010 14:46:55 +0100
Subject: [PATCH 1/2] Always query device by uuid only.
Message-ID: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2 devices have always UUID set even if imported from lvm1 metadata.

Patch removes name argument from dev_manager_info call and converts
all activation related calls to use query by UUID.

Also it simplifies mknode call (which is the only user on mknodes parameter).
---
 lib/activate/activate.c    |   48 ++++++++++++++-----------------------------
 lib/activate/dev_manager.c |   33 ++++++++++++++++++++----------
 lib/activate/dev_manager.h |    3 +-
 3 files changed, 39 insertions(+), 45 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 433c8cc..3c7105b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -440,28 +440,18 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 /*
  * Returns 1 if info structure populated, else 0 on failure.
  */
-static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int with_mknodes,
-		    struct lvinfo *info, int with_open_count, int with_read_ahead, unsigned by_uuid_only)
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
+	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
-	char *name = NULL;
 
 	if (!activation())
 		return 0;
 
-	if (!by_uuid_only &&
-	    !(name = build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, 0, with_open_count,
+			      with_read_ahead, &dminfo, &info->read_ahead))
 		return_0;
 
-	log_debug("Getting device info for %s", name);
-	if (!dev_manager_info(lv->vg->cmd->mem, name, lv, with_mknodes,
-			      with_open_count, with_read_ahead, &dminfo,
-			      &info->read_ahead)) {
-		if (name)
-			dm_pool_free(cmd->mem, name);
-		return_0;
-	}
-
 	info->exists = dminfo.exists;
 	info->suspended = dminfo.suspended;
 	info->open_count = dminfo.open_count;
@@ -471,18 +461,9 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
-	if (name)
-		dm_pool_free(cmd->mem, name);
-
 	return 1;
 }
 
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
-	    int with_open_count, int with_read_ahead)
-{
-	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
-}
-
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
@@ -492,7 +473,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 1);
+	r = lv_info(cmd, lv, info, with_open_count, with_read_ahead);
 	vg_release(lv->vg);
 
 	return r;
@@ -558,12 +539,11 @@ int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
 	return r;
 }
 
-static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv,
-		      unsigned by_uuid_only)
+static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct lvinfo info;
 
-	if (!_lv_info(cmd, lv, 0, &info, 0, 0, by_uuid_only)) {
+	if (!lv_info(cmd, lv, &info, 0, 0)) {
 		stack;
 		return -1;
 	}
@@ -657,7 +637,7 @@ static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lv_is_visible(lvl->lv))
-			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
+			count += (_lv_active(vg->cmd, lvl->lv) == 1);
 	}
 
 	return count;
@@ -700,7 +680,7 @@ int lv_is_active(struct logical_volume *lv)
 {
 	int ret;
 
-	if (_lv_active(lv->vg->cmd, lv, 0))
+	if (_lv_active(lv->vg->cmd, lv))
 		return 1;
 
 	if (!vg_is_clustered(lv->vg))
@@ -1182,7 +1162,7 @@ int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exc
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
-	struct lvinfo info;
+	struct dm_info dminfo;
 	int r = 1;
 
 	if (!lv) {
@@ -1191,10 +1171,14 @@ int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 		return r;
 	}
 
-	if (!_lv_info(cmd, lv, 1, &info, 0, 0, 0))
+	if (!activation())
+		return 0;
+
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, 1,
+			      0, 0, &dminfo, NULL))
 		return_0;
 
-	if (info.exists) {
+	if (dminfo.exists) {
 		if (lv_is_visible(lv))
 			r = dev_manager_lv_mknodes(lv);
 	} else
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index bbf95a3..84f94ff 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -123,12 +123,14 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 {
 	int r = 0;
 	struct dm_task *dmt;
-	int dmtask;
 
-	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
-
-	if (!(dmt = _setup_task(name, dlid, 0, dmtask, major, minor)))
-		return_0;
+	if (mknodes) {
+		if (!(dmt = _setup_task(name, dlid, 0, DM_DEVICE_MKNODES, major, minor)))
+			return_0;
+	} else {
+		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_INFO, major, minor)))
+			return_0;
+	}
 
 	if (!with_open_count)
 		if (!dm_task_no_open_count(dmt))
@@ -235,20 +237,29 @@ static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 	return _info_run(NULL, NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
-int dev_manager_info(struct dm_pool *mem, const char *name,
-		     const struct logical_volume *lv, int with_mknodes,
-		     int with_open_count, int with_read_ahead,
+int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+		     int with_mknodes, int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead)
 {
-	const char *dlid;
+	const char *dlid, *name;
+	int r;
+
+	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
+		log_error("name build failed for %s", lv->name);
+		return 0;
+	}
 
 	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
 
-	return _info(name, dlid, with_mknodes, with_open_count, with_read_ahead,
-		     info, read_ahead);
+	log_debug("Getting device info for %s", name);
+	r = _info(NULL, dlid, with_mknodes, with_open_count,
+		  with_read_ahead, info, read_ahead);
+
+	dm_pool_free(mem, (char*)name);
+	return r;
 }
 
 static const struct dm_info *_cached_info(struct dm_pool *mem,
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 5333544..86c978f 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -40,8 +40,7 @@ void dev_manager_exit(void);
  * (eg, an origin is created before its snapshot, but is not
  * unsuspended until the snapshot is also created.)
  */
-int dev_manager_info(struct dm_pool *mem, const char *name,
-		     const struct logical_volume *lv,
+int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     int mknodes, int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
-- 
1.7.0


