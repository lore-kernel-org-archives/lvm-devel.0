From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 May 2010 15:32:25 -0000
Subject: LVM2 lib/activate/activate.c lib/activate/acti ...
Message-ID: <20100524153225.8939.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-24 15:32:21

Modified files:
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	                 mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	test           : t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair.sh test-utils.sh 
	tools          : lvconvert.c pvmove.c 
Added files:
	test           : t-lvconvert-repair-transient.sh 

Log message:
	Account for mirror transient status when doing lvconvert --repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.344&r2=1.345
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.204&r2=1.205
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/lib/activate/activate.c	2010/05/21 14:34:02	1.169
+++ LVM2/lib/activate/activate.c	2010/05/24 15:32:20	1.170
@@ -478,6 +478,28 @@
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
+int lv_check_transient(struct logical_volume *lv)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!activation())
+		return 0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+		return_0;
+
+	if (!(r = dev_manager_transient(dm, lv)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
+/*
+ * Returns 1 if percent set, else 0 on failure.
+ */
 int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
 			percent_range_t *percent_range)
 {
--- LVM2/lib/activate/activate.h	2010/05/13 18:38:38	1.67
+++ LVM2/lib/activate/activate.h	2010/05/24 15:32:20	1.68
@@ -78,6 +78,7 @@
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv);
 
+int lv_check_transient(struct logical_volume *lv);
 /*
  * Returns 1 if percent has been set, else 0.
  */
--- LVM2/lib/activate/dev_manager.c	2010/05/24 09:04:27	1.194
+++ LVM2/lib/activate/dev_manager.c	2010/05/24 15:32:20	1.195
@@ -543,6 +543,68 @@
 	return 0;
 }
 
+int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
+{
+	int r = 0;
+	struct dm_task *dmt;
+	struct dm_info info;
+	void *next = NULL;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	char *dlid = NULL;
+	const struct dm_list *segh = &lv->segments;
+	struct lv_segment *seg = NULL;
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+		return_0;
+
+	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length, &type,
+					  &params);
+		if (lv) {
+			if (!(segh = dm_list_next(&lv->segments, segh))) {
+				log_error("Number of segments in active LV %s "
+					  "does not match metadata", lv->name);
+				goto out;
+			}
+			seg = dm_list_item(segh, struct lv_segment);
+		}
+
+		if (!type || !params)
+			continue;
+
+		if (seg->segtype->ops->check_transient_status &&
+		    !seg->segtype->ops->check_transient_status(seg, params))
+			goto_out;
+
+	} while (next);
+
+	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+		log_error("Number of segments in active LV %s does not "
+			  "match metadata", lv->name);
+		goto out;
+	}
+
+	r = 1;
+
+      out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 /*
  * dev_manager implementation.
  */
--- LVM2/lib/activate/dev_manager.h	2010/02/24 20:00:56	1.32
+++ LVM2/lib/activate/dev_manager.h	2010/05/24 15:32:20	1.33
@@ -57,6 +57,7 @@
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv);
 
 int dev_manager_mknodes(const struct logical_volume *lv);
 
--- LVM2/lib/metadata/metadata-exported.h	2010/05/21 14:07:17	1.151
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/24 15:32:20	1.152
@@ -754,7 +754,8 @@
 			   uint32_t split_count, struct dm_list *removable_pvs);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
-		      struct dm_list *pvs, uint64_t status_mask);
+		      int (*is_removable)(struct logical_volume *, void *),
+		      void *removable_baton, uint64_t status_mask);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
@@ -769,7 +770,8 @@
 			    struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
-			 struct dm_list *removable_pvs, unsigned remove_log);
+			 int (*is_removable)(struct logical_volume *, void *),
+			 void *removable_baton, unsigned remove_log);
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t stripes, uint32_t stripe_size, uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
--- LVM2/lib/metadata/metadata.c	2010/05/21 12:45:19	1.344
+++ LVM2/lib/metadata/metadata.c	2010/05/24 15:32:20	1.345
@@ -2117,7 +2117,7 @@
  * propagated transitively, so LVs referencing other LVs are marked
  * partial as well, if any of their referenced LVs are marked partial.
  */
-static int _vg_mark_partial_lvs(struct volume_group *vg)
+int vg_mark_partial_lvs(struct volume_group *vg)
 {
 	struct logical_volume *lv;
 	struct lv_list *lvl;
@@ -2654,7 +2654,7 @@
 		if (vg_missing_pv_count(correct_vg)) {
 			log_verbose("There are %d physical volumes missing.",
 				    vg_missing_pv_count(correct_vg));
-			_vg_mark_partial_lvs(correct_vg);
+			vg_mark_partial_lvs(correct_vg);
 		}
 		*consistent = 1;
 		return correct_vg;
@@ -2945,7 +2945,7 @@
 	if (vg_missing_pv_count(correct_vg)) {
 		log_verbose("There are %d physical volumes missing.",
 			    vg_missing_pv_count(correct_vg));
-		_vg_mark_partial_lvs(correct_vg);
+		vg_mark_partial_lvs(correct_vg);
 	}
 
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
--- LVM2/lib/metadata/metadata.h	2010/05/21 12:43:02	1.204
+++ LVM2/lib/metadata/metadata.h	2010/05/24 15:32:20	1.205
@@ -383,5 +383,7 @@
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
+int vg_mark_partial_lvs(struct volume_group *vg);
+int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 #endif
--- LVM2/lib/metadata/mirror.c	2010/05/14 15:19:43	1.117
+++ LVM2/lib/metadata/mirror.c	2010/05/24 15:32:20	1.118
@@ -435,14 +435,17 @@
 }
 
 /* Check if mirror image LV is removable with regard to given removable_pvs */
-static int _is_mirror_image_removable(struct logical_volume *mimage_lv,
-				      struct dm_list *removable_pvs)
+int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton)
 {
 	struct physical_volume *pv;
 	struct lv_segment *seg;
 	int pv_found;
 	struct pv_list *pvl;
 	uint32_t s;
+	struct dm_list *removable_pvs = baton;
+
+	if (!baton || dm_list_empty(removable_pvs))
+		return 1;
 
 	dm_list_iterate_items(seg, &mimage_lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
@@ -508,7 +511,7 @@
 			sub_lv = seg_lv(mirrored_seg, i);
 
 			if (!is_temporary_mirror_layer(sub_lv) &&
-			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
+			    is_mirror_image_removable(sub_lv, removable_pvs)) {
 				if (!shift_mirror_images(mirrored_seg, i))
 					return_0;
 				count--;
@@ -754,13 +757,13 @@
  */
 static int _remove_mirror_images(struct logical_volume *lv,
 				 uint32_t num_removed,
-				 struct dm_list *removable_pvs,
+				 int (*is_removable)(struct logical_volume *, void *),
+				 void *removable_baton,
 				 unsigned remove_log, unsigned collapse,
 				 uint32_t *removed)
 {
 	uint32_t m;
 	int32_t s;
-	int removable_pvs_specified;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *temp_layer_lv = NULL;
@@ -770,9 +773,6 @@
 	struct lv_list *lvl;
 	struct dm_list tmp_orphan_lvs;
 
-	removable_pvs_specified = (removable_pvs &&
-				   !dm_list_empty(removable_pvs)) ? 1 : 0;
-
 	if (removed)
 		*removed = 0;
 
@@ -781,38 +781,32 @@
 			 old_area_count, old_area_count - num_removed,
 			 remove_log ? " and no log volume" : "");
 
-	if (collapse &&
-	    (removable_pvs_specified || (old_area_count - num_removed != 1))) {
+	if (collapse && (old_area_count - num_removed != 1)) {
 		log_error("Incompatible parameters to _remove_mirror_images");
 		return 0;
 	}
 
 	/* Move removable_pvs to end of array */
-	if (removable_pvs_specified) {
-		for (s = mirrored_seg->area_count - 1;
-		     s >= 0 && old_area_count - new_area_count < num_removed;
-		     s--) {
-			sub_lv = seg_lv(mirrored_seg, s);
-
-			if (!is_temporary_mirror_layer(sub_lv) &&
-			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
-				/*
-				 * Check if the user is trying to pull the
-				 * primary mirror image when the mirror is
-				 * not in-sync.
-				 */
-				if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
-				    !(lv->status & PARTIAL_LV)) {
-					log_error("Unable to remove primary mirror image while mirror is not in-sync");
-					return_0;
-				}
-				if (!shift_mirror_images(mirrored_seg, s))
-					return_0;
-				new_area_count--;
+	for (s = mirrored_seg->area_count - 1;
+	     s >= 0 && old_area_count - new_area_count < num_removed;
+	     s--) {
+		sub_lv = seg_lv(mirrored_seg, s);
+		if (!is_temporary_mirror_layer(sub_lv) &&
+		    is_removable(sub_lv, removable_baton)) {
+			/*
+			 * Check if the user is trying to pull the
+			 * primary mirror image when the mirror is
+			 * not in-sync.
+			 */
+			if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
+			    !(lv->status & PARTIAL_LV)) {
+				log_error("Unable to remove primary mirror image while mirror is not in-sync");
+				return_0;
 			}
+			if (!shift_mirror_images(mirrored_seg, s))
+				return_0;
+			new_area_count--;
 		}
-		if (num_removed && old_area_count == new_area_count)
-			return 1;
 	}
 
 	/*
@@ -822,6 +816,9 @@
 	 */
 	new_area_count = old_area_count - num_removed;
 
+	if (num_removed && old_area_count == new_area_count)
+		return 1;
+
 	/* Remove mimage LVs from the segment */
 	dm_list_init(&tmp_orphan_lvs);
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
@@ -956,7 +953,8 @@
  * Remove the number of mirror images from the LV
  */
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
-			 struct dm_list *removable_pvs, unsigned remove_log)
+			 int (*is_removable)(struct logical_volume *, void *),
+			 void *removable_baton, unsigned remove_log)
 {
 	uint32_t num_removed, removed_once, r;
 	uint32_t existing_mirrors = lv_mirror_count(lv);
@@ -972,7 +970,8 @@
 			removed_once = first_seg(next_lv)->area_count - 1;
 
 		if (!_remove_mirror_images(next_lv, removed_once,
-					   removable_pvs, remove_log, 0, &r))
+					   is_removable, removable_baton,
+					   remove_log, 0, &r))
 			return_0;
 
 		if (r < removed_once) {
@@ -999,6 +998,11 @@
 	return 1;
 }
 
+static int _no_removable_images(struct logical_volume *lv __attribute((unused)),
+				void *baton __attribute((unused))) {
+	return 0;
+}
+
 /*
  * Collapsing temporary mirror layers.
  *
@@ -1031,7 +1035,7 @@
 
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
-					   NULL, 1, 1, NULL)) {
+					   _no_removable_images, NULL, 1, 1, NULL)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}
@@ -1156,7 +1160,8 @@
 	init_mirror_in_sync(in_sync);
 
 	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors - num_mirrors,
-				  removable_pvs, remove_log, 0, NULL);
+				  is_mirror_image_removable, removable_pvs,
+				  remove_log, 0, NULL);
 	if (!r)
 		/* Unable to remove bad devices */
 		return 0;
@@ -1549,7 +1554,7 @@
 	}
 
 	if (!remove_mirror_images(lv, lv_mirror_count(lv),
-				  removable_pvs, 1U))
+				  is_mirror_image_removable, removable_pvs, 1U))
 		return_0;
 
 	return 1;
@@ -1929,7 +1934,9 @@
  */
 int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
 		      struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t log_count, struct dm_list *pvs,
+		      uint32_t mirrors, uint32_t log_count,
+		      int (*is_removable)(struct logical_volume *, void *),
+		      void *removable_baton,
 		      uint64_t status_mask)
 {
 	uint32_t new_mirrors;
@@ -1957,7 +1964,8 @@
 	if (seg_type(seg, 0) == AREA_LV &&
 	    seg_lv(seg, 0)->status & MIRROR_IMAGE)
 		return remove_mirror_images(lv, new_mirrors + 1,
-					    pvs, log_count ? 1U : 0);
+					    is_removable, removable_baton,
+					    log_count ? 1U : 0);
 
 	/* MIRROR_BY_SEG */
 	if (log_count) {
--- LVM2/lib/metadata/segtype.h	2010/05/24 09:04:27	1.29
+++ LVM2/lib/metadata/segtype.h	2010/05/24 15:32:21	1.30
@@ -82,6 +82,7 @@
                                 struct dm_tree_node *node, uint64_t len,
                                 uint32_t *pvmove_mirror_count);
 	int (*target_status_compatible) (const char *type);
+	int (*check_transient_status) (struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
 			       percent_range_t *percent_range,
 			       struct dm_pool * mem,
--- LVM2/lib/mirror/mirrored.c	2010/04/14 13:01:42	1.67
+++ LVM2/lib/mirror/mirrored.c	2010/05/24 15:32:21	1.68
@@ -239,6 +239,117 @@
 	return 1;
 }
 
+static int _mirrored_transient_status(struct lv_segment *seg, char *params)
+{
+	int i, j;
+	struct logical_volume *lv = seg->lv;
+	struct lvinfo info;
+	char *p = NULL;
+	char **args, **log_args;
+	struct logical_volume **images;
+	struct logical_volume *log;
+	int num_devs, log_argc;
+	int failed = 0;
+	char *status;
+
+	log_error("Mirrored transient status: \"%s\"", params);
+
+	/* number of devices */
+	if (!dm_split_words(params, 1, 0, &p))
+		return_0;
+
+	if (!(num_devs = atoi(p)))
+		return_0;
+
+	p += strlen(p) + 1;
+
+	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Unexpectedly many (%d) mirror images in %s.",
+			  num_devs, lv->name);
+		return_0;
+	}
+
+	args = alloca((num_devs + 5) * sizeof(char *));
+	images = alloca(num_devs * sizeof(struct logical_volume *));
+
+	if (dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
+		return_0;
+
+	log_argc = atoi(args[3 + num_devs]);
+	log_args = alloca(log_argc * sizeof(char *));
+
+	if (log_argc > 16) {
+		log_error("Unexpectedly many (%d) log arguments in %s.",
+			  log_argc, lv->name);
+		return_0;
+	}
+
+
+	if (dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
+			   log_argc, 0, log_args) < log_argc)
+		return_0;
+
+	if (num_devs != seg->area_count) {
+		log_error("Active mirror has a wrong number of mirror images!");
+		log_error("Metadata says %d, kernel says %d.", seg->area_count, num_devs);
+		return_0;
+	}
+
+	if (!strcmp(log_args[0], "disk")) {
+		char buf[32];
+		log = first_seg(lv)->log_lv;
+		lv_info(lv->vg->cmd, log, &info, 0, 0);
+		log_debug("Found mirror log at %d:%d", info.major, info.minor);
+		sprintf(buf, "%d:%d", info.major, info.minor);
+		if (strcmp(buf, log_args[1])) {
+			log_error("Mirror log mismatch. Metadata says %s, kernel says %s.",
+				  buf, log_args[1]);
+			return_0;
+		}
+		log_very_verbose("Status of log (%s): %s", buf, log_args[2]);
+		if (log_args[2][0] != 'A') {
+			log->status |= PARTIAL_LV;
+			++failed;
+		}
+	}
+
+	for (i = 0; i < num_devs; ++i)
+		images[i] = NULL;
+
+	for (i = 0; i < seg->area_count; ++i) {
+		char buf[32];
+		lv_info(lv->vg->cmd, seg_lv(seg, i), &info, 0, 0);
+		log_debug("Found mirror leg at %d:%d", info.major, info.minor);
+		sprintf(buf, "%d:%d", info.major, info.minor);
+		for (j = 0; j < num_devs; ++j) {
+			if (!strcmp(buf, args[j])) {
+			    log_debug("Match: metadata image %d matches kernel image %d", i, j);
+			    images[j] = seg_lv(seg, i);
+			}
+		}
+	}
+
+	status = args[2 + num_devs];
+
+	for (i = 0; i < num_devs; ++i) {
+		if (!images[i]) {
+			log_error("Failed to find image %d (%s).", i, args[i]);
+			return_0;
+		}
+		log_very_verbose("Status of image %d: %c", i, status[i]);
+		if (status[i] != 'A') {
+			images[i]->status |= PARTIAL_LV;
+			++failed;
+		}
+	}
+
+	/* update PARTIAL_LV flags across the VG */
+	if (failed)
+		vg_mark_partial_lvs(lv->vg);
+
+	return 1;
+}
+
 static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 		    struct dm_tree_node *node, uint32_t area_count, uint32_t region_size)
 {
@@ -564,6 +675,7 @@
 	.add_target_line = _mirrored_add_target_line,
 	.target_percent = _mirrored_target_percent,
 	.target_present = _mirrored_target_present,
+	.check_transient_status = _mirrored_transient_status,
 #ifdef DMEVENTD
 	.target_monitored = _target_monitored,
 	.target_monitor_events = _target_monitor_events,
/cvs/lvm2/LVM2/test/t-lvconvert-repair-transient.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-transient.sh
+++ -	2010-05-24 15:32:24.865853000 +0000
@@ -0,0 +1,26 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+prepare_vg 5
+
+# fail multiple devices
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+disable_dev $dev2 $dev4
+mkfs.ext3 $DM_DEV_DIR/$vg/4way
+enable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 4way
+lvchange -a n $vg/4way
--- LVM2/test/t-lvconvert-repair-policy.sh	2010/04/14 13:51:58	1.4
+++ LVM2/test/t-lvconvert-repair-policy.sh	2010/05/24 15:32:21	1.5
@@ -32,40 +32,49 @@
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.
-disable_dev $dev1
+aux disable_dev $dev1
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 check linear $vg mirror
-cleanup $dev1
+aux cleanup $dev1
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
-disable_dev $dev1
+aux disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | grep mirror_mlog
-cleanup $dev1
+aux cleanup $dev1
 
 # Fail a leg of a mirror (use old name for policy specification)
 # Expected result: Mirror (leg replaced)
-disable_dev $dev1
+aux disable_dev $dev1
 repair 'activation { mirror_device_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | grep mirror_mlog
-cleanup $dev1
+aux cleanup $dev1
 
 # Fail a leg of a mirror w/ no available spare
 # Expected result: 2-way with corelog
-disable_dev $dev2 $dev4
+aux disable_dev $dev2 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | not grep mirror_mlog
-cleanup $dev2 $dev4
+aux cleanup $dev2 $dev4
 
 # Fail the log device of a mirror w/ no available spare
 # Expected result: mirror w/ corelog
-disable_dev $dev3 $dev4
-lvconvert --repair --use-policies --config 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
+aux disable_dev $dev3 $dev4
+repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
 check mirror $vg mirror
 lvs | not grep mirror_mlog
+aux cleanup $dev3 $dev4
+
+# Fail the log device with a remove policy
+# Expected result: mirror w/ corelog
+lvchange -a y $vg/mirror
+aux disable_dev $dev3 $dev4
+repair 'activation { mirror_log_fault_policy = "remove" }'
+check mirror $vg mirror core
+lvs | not grep mirror_mlog
 cleanup $dev3 $dev4
--- LVM2/test/t-lvconvert-repair.sh	2010/04/14 13:51:58	1.7
+++ LVM2/test/t-lvconvert-repair.sh	2010/05/24 15:32:21	1.8
@@ -11,38 +11,59 @@
 
 . ./test-utils.sh
 
-prepare_vg 5
 
 # fail multiple devices
 
-lvcreate -m 3 --ig -L 1 -n 4way $vg
+aux prepare_vg 5
+lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
 disable_dev $dev2 $dev4
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 enable_dev $dev2 $dev4
-check mirror $vg 4way
-lvchange -a n $vg/4way
-
-vgremove -ff $vg
-vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
+check mirror $vg 4way $dev5
 
+aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg
 disable_dev $dev1 $dev2
 echo n | lvconvert --repair $vg/3way
+check linear $vg 3way
 lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
 enable_dev $dev1 $dev2
 check linear $vg 3way
-lvchange -a n $vg/3way
+
+# fail just log and get it removed
+
+aux prepare_vg 5
+lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
+disable_dev $dev4
+echo n | lvconvert --repair $vg/3way
+check mirror $vg 3way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+enable_dev $dev4
+
+aux prepare_vg 5
+lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
+disable_dev $dev3
+echo n | lvconvert --repair $vg/2way
+check mirror $vg 2way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+vgreduce --removemissing $vg
+enable_dev $dev3
 
 # fail single devices
 
-vgremove -ff $vg
-vgcreate -c n $vg $dev1 $dev2 $dev3
+aux prepare_vg 5
+vgreduce $vg $dev4
 
 lvcreate -m 1 --ig -L 1 -n mirror $vg
-
 lvchange -a n $vg/mirror
 vgextend $vg $dev4
 disable_dev $dev1
--- LVM2/test/test-utils.sh	2010/05/14 14:56:40	1.43
+++ LVM2/test/test-utils.sh	2010/05/24 15:32:21	1.44
@@ -373,6 +373,7 @@
     level = 9
     file = "$TESTDIR/debug.log"
     overwrite = 1
+    activation = 1
   }
   backup {
     backup = 0
--- LVM2/tools/lvconvert.c	2010/04/28 17:41:30	1.133
+++ LVM2/tools/lvconvert.c	2010/05/24 15:32:21	1.134
@@ -15,6 +15,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lv_alloc.h"
+#include "metadata.h"
 
 struct lvconvert_params {
 	int snapshot;
@@ -603,6 +604,12 @@
 	return failed_pvs;
 }
 
+static int _is_partial_lv(struct logical_volume *lv,
+			  void *baton __attribute((unused)))
+{
+	return lv->status & PARTIAL_LV;
+}
+
 /*
  * Walk down the stacked mirror LV to the original mirror LV.
  */
@@ -727,7 +734,7 @@
 	}
 
 	/* Reducing redundancy of the log */
-	return remove_mirror_images(log_lv, log_count, operable_pvs, 1U);
+	return remove_mirror_images(log_lv, log_count, is_mirror_image_removable, operable_pvs, 1U);
 }
 
 /*
@@ -913,6 +920,34 @@
 	return 1;
 }
 
+static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to lock %s", lv->name);
+		vg_revert(lv->vg);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, lv))
+			stack;
+		return_0;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", lv->name);
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		return 0;
+	}
+	return 1;
+}
+
 /*
  * _lvconvert_mirrors_aux
  *
@@ -1005,6 +1040,16 @@
 		}
 
 		/*
+		 * Is there already a convert in progress?  We do not
+		 * currently allow more than one.
+		 */
+		if (find_temporary_mirror(lv) || (lv->status & CONVERTING)) {
+			log_error("%s is already being converted.  Unable to start another conversion.",
+				  lv->name);
+			return 0;
+		}
+
+		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
@@ -1064,7 +1109,7 @@
 						    nmc, operable_pvs))
 				return 0;
 		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
-					      operable_pvs, 0))
+					      is_mirror_image_removable, operable_pvs, 0))
 			return_0;
 
 		goto out; /* Just in case someone puts code between */
@@ -1084,29 +1129,8 @@
 
 out_skip_log_convert:
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-
-	if (!vg_write(lv->vg))
-		return_0;
-
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
-		goto_out;
-	}
-
-	log_very_verbose("Updating \"%s\" in kernel", lv->name);
-
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		goto out;
-	}
+	if (!_reload_lv(cmd, lv))
+		return 0;
 
 	return 1;
 }
@@ -1139,6 +1163,8 @@
 	cmd->partial_activation = 1;
 	lp->need_polling = 0;
 
+	lv_check_transient(lv); /* TODO check this in lib for all commands? */
+
 	if (!(lv->status & PARTIAL_LV)) {
 		log_error("%s is consistent. Nothing to repair.", lv->name);
 		return 1;
@@ -1195,11 +1221,13 @@
 	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
 		return 0;
 
-	/*
-	 * Remove all failed_pvs
-	 */
-	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
-				    lp->mirrors, new_log_count))
+	if (failed_mirrors) {
+		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
+				       _is_partial_lv, NULL, 0))
+			return 0;
+	}
+
+	if (!_reload_lv(cmd, lv))
 		return 0;
 
 	/*
@@ -1209,6 +1237,13 @@
 	if (replace_mirrors)
 		lp->mirrors = old_mimage_count;
 
+	/*
+	 * It does not make sense to replace the log if the volume is no longer
+	 * a mirror.
+	 */
+	if (!replace_mirrors && lp->mirrors == 1)
+		replace_log = 0;
+
 	log_count = replace_log ? old_log_count : new_log_count;
 
 	while (replace_mirrors || replace_log) {
@@ -1226,10 +1261,10 @@
 		}
 	}
 
-	if (lp->mirrors != old_mimage_count)
+	if (replace_mirrors && lp->mirrors != old_mimage_count)
 		log_warn("WARNING: Failed to replace %d of %d images in volume %s",
 			 old_mimage_count - lp->mirrors, old_mimage_count, lv->name);
-	if (log_count != old_log_count)
+	if (replace_log && log_count != old_log_count)
 		log_warn("WARNING: Failed to replace %d of %d logs in volume %s",
 			 old_log_count - log_count, old_log_count, lv->name);
 
--- LVM2/tools/pvmove.c	2010/04/09 01:00:11	1.76
+++ LVM2/tools/pvmove.c	2010/05/24 15:32:21	1.77
@@ -292,7 +292,7 @@
 
 	/* Update metadata to remove mirror segments and break dependencies */
 	dm_list_init(&lvs_completed);
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, NULL, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
 		return 0;


