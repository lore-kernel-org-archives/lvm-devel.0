From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 10:36:35 +0000 (UTC)
Subject: master - lvrename: support renaming historical logical volumes
Message-ID: <20160304103635.ED3A960D47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27245d97e57bb42b83aa240979aa6febf9096264
Commit:        27245d97e57bb42b83aa240979aa6febf9096264
Parent:        b114b4d723129998b1578410b0b054bebfef1817
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 11:36:24 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 11:36:24 2016 +0100

lvrename: support renaming historical logical volumes

---
 lib/metadata/lv_manip.c |   37 ++++++++++++-------
 tools/lvrename.c        |   92 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 95 insertions(+), 34 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 136d232..9b51b6d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4196,6 +4196,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names = { .old = lv->name };
+	int old_lv_is_historical = lv_is_historical(lv);
 	int historical;
 
 	/*
@@ -4210,7 +4211,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_name_is_used_in_vg(vg, new_name, &historical)) {
 		log_error("%sLogical Volume \"%s\" already exists in "
-			  "volume group \"%s\"", historical ? "historical " : "",
+			  "volume group \"%s\"", historical ? "Historical " : "",
 			  new_name, vg->name);
 		return 0;
 	}
@@ -4223,23 +4224,31 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	if (update_mda && !archive(vg))
 		return_0;
 
-	if (!(lv_names.new = dm_pool_strdup(cmd->mem, new_name))) {
-		log_error("Failed to allocate space for new name.");
-		return 0;
-	}
+	if (old_lv_is_historical) {
+		/* historical LVs don't have sub LVs */
+		lv->this_glv->historical->name = lv->name = new_name;
+		if (update_mda &&
+		    (!vg_write(vg) || !vg_commit(vg)))
+			return_0;
+	} else {
+		if (!(lv_names.new = dm_pool_strdup(cmd->mem, new_name))) {
+			log_error("Failed to allocate space for new name.");
+			return 0;
+		}
 
-	/* rename sub LVs */
-	if (!for_each_sub_lv_except_pools(lv, _rename_cb, (void *) &lv_names))
-		return_0;
+		/* rename sub LVs */
+		if (!for_each_sub_lv_except_pools(lv, _rename_cb, (void *) &lv_names))
+			return_0;
 
-	/* rename main LV */
-	lv->name = lv_names.new;
+		/* rename main LV */
+		lv->name = lv_names.new;
 
-	if (lv_is_cow(lv))
-		lv = origin_from_cow(lv);
+		if (lv_is_cow(lv))
+			lv = origin_from_cow(lv);
 
-	if (update_mda && !lv_update_and_reload((struct logical_volume *)lv_lock_holder(lv)))
-		return_0;
+		if (update_mda && !lv_update_and_reload((struct logical_volume *)lv_lock_holder(lv)))
+			return_0;
+	}
 
 	return 1;
 }
diff --git a/tools/lvrename.c b/tools/lvrename.c
index e37d8aa..56c19fd 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -16,34 +16,64 @@
 #include "tools.h"
 
 struct lvrename_params {
+	int historical;
 	const char *lv_name_old;
 	const char *lv_name_new;
 };
 
+/*
+ * Dummy LV to represent historical LV.
+ */
+static struct logical_volume _historical_lv = {
+        .name = "",
+        .major = -1,
+        .minor = -1,
+        .snapshot_segs = DM_LIST_HEAD_INIT(_historical_lv.snapshot_segs),
+        .segments = DM_LIST_HEAD_INIT(_historical_lv.segments),
+        .tags = DM_LIST_HEAD_INIT(_historical_lv.tags),
+        .segs_using_this_lv = DM_LIST_HEAD_INIT(_historical_lv.segs_using_this_lv),
+        .indirect_glvs = DM_LIST_HEAD_INIT(_historical_lv.indirect_glvs),
+        .hostname = "",
+};
+
 static int _lvrename_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct lvrename_params *lp = (struct lvrename_params *) handle->custom_handle;
-	struct lv_list *lvl;
+	struct generic_logical_volume *glv;
+	struct logical_volume *lv;
 	int ret = ECMD_FAILED;
 
-	if (!(lvl = find_lv_in_vg(vg, lp->lv_name_old))) {
-		log_error("Existing logical volume \"%s\" not found in "
-			  "volume group \"%s\"", lp->lv_name_old, vg_name);
-		goto bad;
-	}
+	if (!lp->historical) {
+		if (!(lv = find_lv(vg, lp->lv_name_old))) {
+			log_error("Existing logical volume \"%s\" not found in "
+				  "volume group \"%s\"", lp->lv_name_old, vg_name);
+			goto bad;
+		}
 
-	if (lv_is_raid_image(lvl->lv) || lv_is_raid_metadata(lvl->lv)) {
-		log_error("Cannot rename a RAID %s directly",
-			  lv_is_raid_image(lvl->lv) ? "image" :
-			  "metadata area");
-		goto bad;
-	}
+		if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) {
+			log_error("Cannot rename a RAID %s directly",
+				  lv_is_raid_image(lv) ? "image" :
+				  "metadata area");
+			goto bad;
+		}
+
+		if (lv_is_raid_with_tracking(lv)) {
+			log_error("Cannot rename %s while it is tracking a split image",
+				  lv->name);
+			goto bad;
+		}
+	} else {
+		if (!(glv = find_historical_glv(vg, lp->lv_name_old, 0, NULL))) {
+			log_error("Existing historical logical volume \"%s\" not found in "
+				  "volume group \"%s\"", lp->lv_name_old, vg_name);
+			goto bad;
+		}
 
-	if (lv_is_raid_with_tracking(lvl->lv)) {
-		log_error("Cannot rename %s while it is tracking a split image",
-			  lvl->lv->name);
-		goto bad;
+		_historical_lv.vg = vg;
+		_historical_lv.name = lp->lv_name_old;
+		_historical_lv.this_glv = glv;
+		lv = &_historical_lv;
 	}
 
 	/*
@@ -55,14 +85,16 @@ static int _lvrename_single(struct cmd_context *cmd, const char *vg_name,
 	 * lock request acquires the LV lock (or fails).  The transient lock
 	 * is automatically released when the command exits.
 	 */
-	if (!lockd_lv(cmd, lvl->lv, "ex", 0))
+	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_bad;
 
-	if (!lv_rename(cmd, lvl->lv, lp->lv_name_new))
+	if (!lv_rename(cmd, lv, lp->lv_name_new))
 		goto_bad;
 
-	log_print_unless_silent("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
-				lp->lv_name_old, lp->lv_name_new, vg_name);
+	log_print_unless_silent("Renamed \"%s%s\" to \"%s%s\" in volume group \"%s\"",
+				lp->historical ? HISTORICAL_LV_PREFIX : "", lp->lv_name_old,
+				lp->historical ? HISTORICAL_LV_PREFIX : "", lp->lv_name_new,
+				vg_name);
 
 	ret = ECMD_PROCESSED;
 bad:
@@ -80,9 +112,12 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	size_t maxlen;
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
+	int historical = 0;
 	char *st;
 	int ret;
 
+	cmd->include_historical_lvs = 1;
+
 	if (argc == 3) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		lv_name_old = argv[1];
@@ -123,6 +158,21 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if ((st = strrchr(lv_name_new, '/')))
 		lv_name_new = st + 1;
 
+	if (!strncmp(lv_name_old, HISTORICAL_LV_PREFIX, strlen(HISTORICAL_LV_PREFIX))) {
+		lv_name_old = lv_name_old + strlen(HISTORICAL_LV_PREFIX);
+		historical = 1;
+	}
+
+	if (!strncmp(lv_name_new, HISTORICAL_LV_PREFIX, strlen(HISTORICAL_LV_PREFIX))) {
+		if (historical)
+			lv_name_new = lv_name_old + strlen(HISTORICAL_LV_PREFIX);
+		else {
+			log_error("Old name references live LV while "
+				  "new name is for historical LV.");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
 	/* Check sanity of new name */
 	maxlen = NAME_LEN - strlen(vg_name) - 3;
 	if (strlen(lv_name_new) > maxlen) {
@@ -152,6 +202,8 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	lp.historical = historical;
+
 	if (!(lp.lv_name_old = dm_pool_strdup(cmd->mem, lv_name_old)))
 		return ECMD_FAILED;
 


