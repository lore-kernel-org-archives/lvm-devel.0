From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Feb 2010 20:00:57 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20100224200057.31140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-02-24 20:00:56

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c dev_manager.h 

Log message:
	Always query device by uuid only.
	
	lvm2 devices have always UUID set even if imported from lvm1 metadata.
	
	Patch removes name argument from dev_manager_info call and converts
	all activation related calls to use query by UUID.
	
	Also it simplifies mknode call (which is the only user on mknodes parameter).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1437&r2=1.1438
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2010/02/24 18:21:15	1.1437
+++ LVM2/WHATS_NEW	2010/02/24 20:00:56	1.1438
@@ -1,5 +1,7 @@
 Version 2.02.62 -
 ====================================
+  Run device info query device by uuid only.
+  Don't touch /dev in vgmknodes if activation is disabled.
   Update lvm2app.h Doxygen comments and add lvm2app Doxygen config file.
   Update nightly tests and lvm2app unit tests to cover tags.
   Add lvm2app functions lvm_{vg|lv}_{get|add|remove}_tag() functions.
--- LVM2/lib/activate/activate.c	2010/01/27 13:23:57	1.164
+++ LVM2/lib/activate/activate.c	2010/02/24 20:00:56	1.165
@@ -440,28 +440,18 @@
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
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, with_open_count,
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
@@ -471,18 +461,9 @@
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
@@ -492,7 +473,7 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 1);
+	r = lv_info(cmd, lv, info, with_open_count, with_read_ahead);
 	vg_release(lv->vg);
 
 	return r;
@@ -558,12 +539,11 @@
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
@@ -657,7 +637,7 @@
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lv_is_visible(lvl->lv))
-			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
+			count += (_lv_active(vg->cmd, lvl->lv) == 1);
 	}
 
 	return count;
@@ -700,7 +680,7 @@
 {
 	int ret;
 
-	if (_lv_active(lv->vg->cmd, lv, 0))
+	if (_lv_active(lv->vg->cmd, lv))
 		return 1;
 
 	if (!vg_is_clustered(lv->vg))
@@ -1182,7 +1162,6 @@
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
-	struct lvinfo info;
 	int r = 1;
 
 	if (!lv) {
@@ -1191,14 +1170,10 @@
 		return r;
 	}
 
-	if (!_lv_info(cmd, lv, 1, &info, 0, 0, 0))
-		return_0;
+	if (!activation())
+		return 1;
 
-	if (info.exists) {
-		if (lv_is_visible(lv))
-			r = dev_manager_lv_mknodes(lv);
-	} else
-		r = dev_manager_lv_rmnodes(lv);
+	r = dev_manager_mknodes(lv);
 
 	fs_unlock();
 
--- LVM2/lib/activate/dev_manager.c	2010/02/23 15:49:52	1.182
+++ LVM2/lib/activate/dev_manager.c	2010/02/24 20:00:56	1.183
@@ -127,7 +127,7 @@
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
 
-	if (!(dmt = _setup_task(name, dlid, 0, dmtask, major, minor)))
+	if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor)))
 		return_0;
 
 	if (!with_open_count)
@@ -205,27 +205,18 @@
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
@@ -235,20 +226,28 @@
 	return _info_run(NULL, NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
-int dev_manager_info(struct dm_pool *mem, const char *name,
-		     const struct logical_volume *lv, int with_mknodes,
+int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     int with_open_count, int with_read_ahead,
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
+	log_debug("Getting device info for %s [%s]", name, dlid);
+	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
+
+	dm_pool_free(mem, (char*)name);
+	return r;
 }
 
 static const struct dm_info *_cached_info(struct dm_pool *mem,
@@ -744,7 +743,7 @@
 /*  NEW CODE STARTS HERE */
 /*************************/
 
-int dev_manager_lv_mknodes(const struct logical_volume *lv)
+static int _dev_manager_lv_mknodes(const struct logical_volume *lv)
 {
 	char *name;
 
@@ -755,11 +754,32 @@
 	return fs_add_lv(lv, name);
 }
 
-int dev_manager_lv_rmnodes(const struct logical_volume *lv)
+static int _dev_manager_lv_rmnodes(const struct logical_volume *lv)
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
+				r = _dev_manager_lv_mknodes(lv);
+		} else
+			r = _dev_manager_lv_rmnodes(lv);
+	}
+
+	dm_pool_free(lv->vg->cmd->mem, (char*)name);
+	return r;
+}
+
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			       struct logical_volume *lv, const char *layer)
 {
@@ -774,7 +794,7 @@
 		return_0;
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
-	if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
+	if (!_info(dlid, 1, 0, &info, NULL)) {
 		log_error("Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
@@ -1309,11 +1329,11 @@
 			continue;
 		}
 		if (lv_is_visible(lvlayer->lv)) {
-			if (!dev_manager_lv_mknodes(lvlayer->lv))
+			if (!_dev_manager_lv_mknodes(lvlayer->lv))
 				r = 0;
 			continue;
 		}
-		if (!dev_manager_lv_rmnodes(lvlayer->lv))
+		if (!_dev_manager_lv_rmnodes(lvlayer->lv))
 			r = 0;
 	}
 
--- LVM2/lib/activate/dev_manager.h	2010/01/15 22:58:25	1.31
+++ LVM2/lib/activate/dev_manager.h	2010/02/24 20:00:56	1.32
@@ -40,9 +40,8 @@
  * (eg, an origin is created before its snapshot, but is not
  * unsuspended until the snapshot is also created.)
  */
-int dev_manager_info(struct dm_pool *mem, const char *name,
-		     const struct logical_volume *lv,
-		     int mknodes, int with_open_count, int with_read_ahead,
+int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
@@ -59,8 +58,7 @@
 			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 
-int dev_manager_lv_mknodes(const struct logical_volume *lv);
-int dev_manager_lv_rmnodes(const struct logical_volume *lv);
+int dev_manager_mknodes(const struct logical_volume *lv);
 
 /*
  * Put the desired changes into effect.


