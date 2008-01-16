From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:09:35 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080116190935.12526.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:09:35

Modified files:
	lib/metadata   : mirror.c 

Log message:
	reorder funcs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/lib/metadata/mirror.c	2008/01/16 19:00:59	1.53
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:09:35	1.54
@@ -51,6 +51,27 @@
 }
 
 /*
+ * Return a temporary LV for resyncing added mirror image.
+ * Add other mirror legs to lvs list.
+ */
+static struct logical_volume *_find_tmp_mirror(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (!(lv->status & MIRRORED))
+		return NULL;
+
+	seg = first_seg(lv);
+
+	/* Temporary mirror is always area_num == 0 */
+	if (seg_type(seg, 0) == AREA_LV &&
+	    is_temporary_mirror_layer(seg_lv(seg, 0)))
+		return seg_lv(seg, 0);
+
+	return NULL;
+}
+
+/*
  * Returns the number of mirrors of the LV
  */
 uint32_t lv_mirror_count(const struct logical_volume *lv)
@@ -115,6 +136,136 @@
 }
 
 /*
+ * This function writes a new header to the mirror log header to the lv
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct device *dev;
+	char *name;
+	struct { /* The mirror log header */
+		uint32_t magic;
+		uint32_t version;
+		uint64_t nr_regions;
+	} log_header;
+
+	log_header.magic = xlate32(MIRROR_MAGIC);
+	log_header.version = xlate32(MIRROR_DISK_VERSION);
+	log_header.nr_regions = xlate64((uint64_t)-1);
+
+	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
+		log_error("Name allocation failed - log header not written (%s)",
+			lv->name);
+		return 0;
+	}
+
+	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+			 lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - log header not written (%s)", lv->name);
+		return 0;
+	}
+
+	log_verbose("Writing log header to device, %s", lv->name);
+
+	if (!(dev = dev_cache_get(name, NULL))) {
+		log_error("%s: not found: log header not written", name);
+		return 0;
+	}
+
+	if (!dev_open_quiet(dev))
+		return 0;
+
+	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
+		log_error("Failed to write log header to %s", name);
+		dev_close_immediate(dev);
+		return 0;
+	}
+
+	dev_close_immediate(dev);
+
+	return 1;
+}
+
+/*
+ * Initialize mirror log contents
+ */
+static int _init_mirror_log(struct cmd_context *cmd,
+			    struct logical_volume *log_lv, int in_sync,
+			    struct list *tags)
+{
+	struct str_list *sl;
+
+	if (!activation() && in_sync) {
+		log_error("Aborting. Unable to create in-sync mirror log "
+			  "while activation is disabled.");
+		return 0;
+	}
+
+	/* Temporary tag mirror log for activation */
+	list_iterate_items(sl, tags)
+		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
+			log_error("Aborting. Unable to tag mirror log.");
+			return 0;
+		}
+
+	/* store mirror log on disk(s) */
+	if (!vg_write(log_lv->vg))
+		return_0;
+
+	backup(log_lv->vg);
+
+	if (!vg_commit(log_lv->vg))
+		return_0;
+
+	if (!activate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to activate mirror log.");
+		goto revert_new_lv;
+	}
+
+	/* Remove the temporary tags */
+	list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from mirror log.",
+				  sl->str);
+
+	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
+				    in_sync ? -1 : 0)) {
+		log_error("Aborting. Failed to wipe mirror log.");
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (activation() && !_write_log_header(cmd, log_lv)) {
+		log_error("Aborting. Failed to write mirror log header.");
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to deactivate mirror log. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	log_lv->status &= ~VISIBLE_LV;
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Unable to deactivate mirror log LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+revert_new_lv:
+	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
+	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned log LV before retrying.");
+	return 0;
+}
+
+/*
  * Delete independent/orphan LV, it must acquire lock.
  */
 static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv)
@@ -390,27 +541,6 @@
 }
 
 /*
- * Return a temporary LV for resyncing added mirror image.
- * Add other mirror legs to lvs list.
- */
-static struct logical_volume *_find_tmp_mirror(struct logical_volume *lv)
-{
-	struct lv_segment *seg;
-
-	if (!(lv->status & MIRRORED))
-		return NULL;
-
-	seg = first_seg(lv);
-
-	/* Temporary mirror is always area_num == 0 */
-	if (seg_type(seg, 0) == AREA_LV &&
-	    is_temporary_mirror_layer(seg_lv(seg, 0)))
-		return seg_lv(seg, 0);
-
-	return NULL;
-}
-
-/*
  * Collapsing temporary mirror layers.
  *
  * When mirrors are added to already-mirrored LV, a temporary mirror layer
@@ -926,136 +1056,6 @@
 	return 1;
 }
 
-/*
- * This function writes a new header to the mirror log header to the lv
- *
- * Returns: 1 on success, 0 on failure
- */
-static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	struct device *dev;
-	char *name;
-	struct { /* The mirror log header */
-		uint32_t magic;
-		uint32_t version;
-		uint64_t nr_regions;
-	} log_header;
-
-	log_header.magic = xlate32(MIRROR_MAGIC);
-	log_header.version = xlate32(MIRROR_DISK_VERSION);
-	log_header.nr_regions = xlate64((uint64_t)-1);
-
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - log header not written (%s)",
-			lv->name);
-		return 0;
-	}
-
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - log header not written (%s)", lv->name);
-		return 0;
-	}
-
-	log_verbose("Writing log header to device, %s", lv->name);
-
-	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: log header not written", name);
-		return 0;
-	}
-
-	if (!dev_open_quiet(dev))
-		return 0;
-
-	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		log_error("Failed to write log header to %s", name);
-		dev_close_immediate(dev);
-		return 0;
-	}
-
-	dev_close_immediate(dev);
-
-	return 1;
-}
-
-/*
- * Initialize mirror log contents
- */
-static int _init_mirror_log(struct cmd_context *cmd,
-			    struct logical_volume *log_lv, int in_sync,
-			    struct list *tags)
-{
-	struct str_list *sl;
-
-	if (!activation() && in_sync) {
-		log_error("Aborting. Unable to create in-sync mirror log "
-			  "while activation is disabled.");
-		return 0;
-	}
-
-	/* Temporary tag mirror log for activation */
-	list_iterate_items(sl, tags)
-		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
-			log_error("Aborting. Unable to tag mirror log.");
-			return 0;
-		}
-
-	/* store mirror log on disk(s) */
-	if (!vg_write(log_lv->vg))
-		return_0;
-
-	backup(log_lv->vg);
-
-	if (!vg_commit(log_lv->vg))
-		return_0;
-
-	if (!activate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to activate mirror log.");
-		goto revert_new_lv;
-	}
-
-	/* Remove the temporary tags */
-	list_iterate_items(sl, tags)
-		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
-				  sl->str);
-
-	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
-				    in_sync ? -1 : 0)) {
-		log_error("Aborting. Failed to wipe mirror log.");
-		goto deactivate_and_revert_new_lv;
-	}
-
-	if (activation() && !_write_log_header(cmd, log_lv)) {
-		log_error("Aborting. Failed to write mirror log header.");
-		goto deactivate_and_revert_new_lv;
-	}
-
-	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to deactivate mirror log. "
-			  "Manual intervention required.");
-		return 0;
-	}
-
-	log_lv->status &= ~VISIBLE_LV;
-
-	return 1;
-
-deactivate_and_revert_new_lv:
-	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Unable to deactivate mirror log LV. "
-			  "Manual intervention required.");
-		return 0;
-	}
-
-revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned log LV before retrying.");
-	return 0;
-}
-
 static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 						 struct alloc_handle *ah,
 						 alloc_policy_t alloc,


