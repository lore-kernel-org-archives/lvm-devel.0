From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Mar 2007 21:08:26 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20070308210826.22625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-08 21:08:25

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	tools          : vgrename.c 

Log message:
	Fix vgrename active LV check to ignore differing vgids.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.579&r2=1.580
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2007/03/08 19:58:04	1.579
+++ LVM2/WHATS_NEW	2007/03/08 21:08:25	1.580
@@ -1,5 +1,6 @@
 Version 2.02.23 - 
 ====================================
+  Fix vgrename active LV check to ignore differing vgids.
   Remove no-longer-used uuid_out parameter from activation info functions.
   Fix two more segfaults if an empty config file section encountered.
   Move .cache file into a new /etc/lvm/cache directory by default.
--- LVM2/lib/activate/activate.c	2007/01/24 23:43:27	1.120
+++ LVM2/lib/activate/activate.c	2007/03/08 21:08:25	1.121
@@ -168,6 +168,10 @@
 {
 	return 0;
 }
+int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
+{
+	return 0;
+}
 int lvs_in_vg_opened(struct volume_group *vg)
 {
 	return 0;
@@ -421,21 +425,23 @@
  * Returns 1 if info structure populated, else 0 on failure.
  */
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int with_mknodes,
-		    struct lvinfo *info, int with_open_count)
+		    struct lvinfo *info, int with_open_count, unsigned by_uuid_only)
 {
 	struct dm_info dminfo;
-	char *name;
+	char *name = NULL;
 
 	if (!activation())
 		return 0;
 
-	if (!(name = build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
+	if (!by_uuid_only &&
+	    !(name = build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
 	log_debug("Getting device info for %s", name);
 	if (!dev_manager_info(lv->vg->cmd->mem, name, lv, with_mknodes,
 			      with_open_count, &dminfo)) {
-		dm_pool_free(cmd->mem, name);
+		if (name)
+			dm_pool_free(cmd->mem, name);
 		return_0;
 	}
 
@@ -448,14 +454,16 @@
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
-	dm_pool_free(cmd->mem, name);
+	if (name)
+		dm_pool_free(cmd->mem, name);
+
 	return 1;
 }
 
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
 	    int with_open_count)
 {
-	return _lv_info(cmd, lv, 0, info, with_open_count);
+	return _lv_info(cmd, lv, 0, info, with_open_count, 0);
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
@@ -466,7 +474,7 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	return _lv_info(cmd, lv, 0, info, with_open_count);
+	return _lv_info(cmd, lv, 0, info, with_open_count, 0);
 }
 
 /*
@@ -519,11 +527,12 @@
 	return r;
 }
 
-static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv,
+		      unsigned by_uuid_only)
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 0)) {
+	if (!_lv_info(cmd, lv, 0, &info, 0, by_uuid_only)) {
 		stack;
 		return -1;
 	}
@@ -607,7 +616,7 @@
  * These two functions return the number of visible LVs in the state,
  * or -1 on error.
  */
-int lvs_in_vg_activated(struct volume_group *vg)
+static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
 {
 	struct lv_list *lvl;
 	int count = 0;
@@ -617,12 +626,22 @@
 
 	list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & VISIBLE_LV)
-			count += (_lv_active(vg->cmd, lvl->lv) == 1);
+			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
 	}
 
 	return count;
 }
 
+int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
+{
+	return _lvs_in_vg_activated(vg, 1);
+}
+
+int lvs_in_vg_activated(struct volume_group *vg)
+{
+	return _lvs_in_vg_activated(vg, 0);
+}
+
 int lvs_in_vg_opened(struct volume_group *vg)
 {
 	struct lv_list *lvl;
@@ -973,7 +992,7 @@
 		return r;
 	}
 
-	if (!_lv_info(cmd, lv, 1, &info, 0))
+	if (!_lv_info(cmd, lv, 1, &info, 0, 0))
 		return_0;
 
 	if (info.exists)
--- LVM2/lib/activate/activate.h	2007/01/25 21:22:30	1.54
+++ LVM2/lib/activate/activate.h	2007/03/08 21:08:25	1.55
@@ -83,6 +83,7 @@
  * Return number of LVs in the VG that are active.
  */
 int lvs_in_vg_activated(struct volume_group *vg);
+int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
 int lvs_in_vg_opened(struct volume_group *vg);
 
 
--- LVM2/tools/vgrename.c	2006/09/02 01:18:17	1.41
+++ LVM2/tools/vgrename.c	2007/03/08 21:08:25	1.42
@@ -118,7 +118,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (lvs_in_vg_activated(vg_old)) {
+	if (lvs_in_vg_activated_by_uuid_only(vg_old)) {
 		unlock_vg(cmd, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);


