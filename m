From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Feb 2010 13:55:03 +0100
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <4B8513D9.5060107@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>	<20100223203902.GA31973@redhat.com>	<4B8511AB.3080305@redhat.com>
	<4B8513D9.5060107@redhat.com>
Message-ID: <4B8521A7.6090803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


> sigh. Either I am idiot or split of mknodes and info dm calls
> in _info_run is confusing (or both).
>
>   
I would prefer something like this (on top of my previous 2 patches):

Separate mknodes to dev_manager_mknodes function.

All info calls uses now uuid only.

Remove confusing with_mknodes paramater.

Move all nodes handling logic inside dev_manager.
---
 lib/activate/activate.c    |   13 +--------
 lib/activate/dev_manager.c |   59 ++++++++++++++++++++++++++------------------
 lib/activate/dev_manager.h |    5 +--
 3 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index dcdad73..4e43131 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -444,7 +444,7 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (!activation())
 		return 0;
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, 0, with_open_count,
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
 		return_0;
 
@@ -1148,7 +1148,6 @@ int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exc
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
-	struct dm_info dminfo;
 	int r = 1;
 
 	if (!lv) {
@@ -1160,15 +1159,7 @@ int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 	if (!activation())
 		return 0;
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, 1,
-			      0, 0, &dminfo, NULL))
-		return_0;
-
-	if (dminfo.exists) {
-		if (lv_is_visible(lv))
-			r = dev_manager_lv_mknodes(lv);
-	} else
-		r = dev_manager_lv_rmnodes(lv);
+	r = dev_manager_mknodes(lv);
 
 	fs_unlock();
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 84f94ff..70c0b04 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -207,27 +207,18 @@ int device_is_usable(dev_t dev)
 	return r;
 }
 
-static int _info(const char *name, const char *dlid, int mknodes,
-		 int with_open_count, int with_read_ahead,
+static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {
 	int r = 0;
 
-	if (!mknodes && dlid && *dlid) {
-		if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
-			      with_read_ahead, 0, 0)) &&
-	    	    info->exists)
-			return 1;
-		else if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
-				   read_ahead, 0, with_open_count,
-				   with_read_ahead, 0, 0)) &&
-			 info->exists)
-			return 1;
-	}
-
-	if (name)
-		return _info_run(name, NULL, info, read_ahead, mknodes,
-				 with_open_count, with_read_ahead, 0, 0);
+	if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
+			   with_read_ahead, 0, 0)) && info->exists)
+		return 1;
+	else if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
+				read_ahead, 0, with_open_count,
+				with_read_ahead, 0, 0)) && info->exists)
+		return 1;
 
 	return r;
 }
@@ -238,7 +229,7 @@ static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 }
 
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
-		     int with_mknodes, int with_open_count, int with_read_ahead,
+		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead)
 {
 	const char *dlid, *name;
@@ -254,9 +245,8 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		return 0;
 	}
 
-	log_debug("Getting device info for %s", name);
-	r = _info(NULL, dlid, with_mknodes, with_open_count,
-		  with_read_ahead, info, read_ahead);
+	log_debug("Getting device info for %s [%s]", name, dlid);
+	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
 
 	dm_pool_free(mem, (char*)name);
 	return r;
@@ -755,7 +745,7 @@ static int _belong_to_vg(const char *vgname, const char *name)
 /*  NEW CODE STARTS HERE */
 /*************************/
 
-int dev_manager_lv_mknodes(const struct logical_volume *lv)
+static int dev_manager_lv_mknodes(const struct logical_volume *lv)
 {
 	char *name;
 
@@ -766,11 +756,32 @@ int dev_manager_lv_mknodes(const struct logical_volume *lv)
 	return fs_add_lv(lv, name);
 }
 
-int dev_manager_lv_rmnodes(const struct logical_volume *lv)
+static int dev_manager_lv_rmnodes(const struct logical_volume *lv)
 {
 	return fs_del_lv(lv);
 }
 
+int dev_manager_mknodes(const struct logical_volume *lv)
+{
+	struct dm_info dminfo;
+	const char *name;
+	int r = 0;
+
+	if (!(name = build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
+		return_0;
+
+	if ((r = _info_run(name, NULL, &dminfo, NULL, 1, 0, 0, 0, 0))) {
+		if (dminfo.exists) {
+			if (lv_is_visible(lv))
+				r = dev_manager_lv_mknodes(lv);
+		} else
+			r = dev_manager_lv_rmnodes(lv);
+	}
+
+	dm_pool_free(lv->vg->cmd->mem, (char*)name);
+	return r;
+}
+
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			       struct logical_volume *lv, const char *layer)
 {
@@ -785,7 +796,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
-	if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
+	if (!_info(dlid, 1, 0, &info, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 86c978f..e946aaf 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -41,7 +41,7 @@ void dev_manager_exit(void);
  * unsuspended until the snapshot is also created.)
  */
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
-		     int mknodes, int with_open_count, int with_read_ahead,
+		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
@@ -58,8 +58,7 @@ int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 
-int dev_manager_lv_mknodes(const struct logical_volume *lv);
-int dev_manager_lv_rmnodes(const struct logical_volume *lv);
+int dev_manager_mknodes(const struct logical_volume *lv);
 
 /*
  * Put the desired changes into effect.



