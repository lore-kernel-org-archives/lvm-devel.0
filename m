From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:10 +0200
Subject: [PATCH 10/12] Replicator: replicator_manip changes
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <e339296ee3af1266b2c42402be4cf7e72421421f.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Changes for replicator_manip.c source file.

Adding new API functions.

Lots of lines for log creation are copied from mirror code and then
are adapted for _slog. Code is done with hope we could share same
parametrized code later for both targets - mirror and replicator.
But with recent changes to mirrored logs it is a harder task.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/replicator_manip.c |  806 +++++++++++++++++++++++++++++++++++----
 1 files changed, 741 insertions(+), 65 deletions(-)

diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index b3a2fff..c6000aa 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -15,19 +15,25 @@
 #include "lib.h"
 #include "locking.h"
 #include "metadata.h"
+#include "defaults.h"
 #include "segtype.h"
 #include "toolcontext.h"
+#include "activate.h"
+#include "archiver.h"
+#include "lv_alloc.h"
+#include "str_list.h"
 
 /* Add lv as replicator_dev device */
-int replicator_dev_add_rimage(struct replicator_device *rdev,
-			      struct logical_volume *lv)
+static int _replicator_device_add_rimage(struct replicator_device *rdev,
+					 struct logical_volume *lv)
 {
 	if (!lv || !rdev)
 		return_0;
 
 	if (lv_is_rimage(lv)) {
+
 		log_error("Logical volume %s is already part of other "
-			  "replicator.", lv->name);
+			  "replicator.   %p  %p", lv->name, lv->rdevice, rdev);
 		return 0;
 	}
 
@@ -39,13 +45,14 @@ int replicator_dev_add_rimage(struct replicator_device *rdev,
 
 	lv_set_hidden(lv);
 	lv->rdevice = rdev;
+	rdev->replicator_dev->lv->rdevice = rdev;
 	rdev->lv = lv;
 
 	return add_seg_to_segs_using_this_lv(lv, rdev->replicator_dev);
 }
 
 /* Remove lv from replicator_dev device */
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev)
+static struct logical_volume *_replicator_device_remove_rimage(struct replicator_device *rdev)
 {
 	struct logical_volume *lv;
 
@@ -64,8 +71,8 @@ struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rd
 	return lv;
 }
 
-int replicator_dev_add_slog(struct replicator_device *rdev,
-			    struct logical_volume *slog)
+static int _replicator_device_add_slog(struct replicator_device *rdev,
+				       struct logical_volume *slog)
 {
 	if (!slog || !rdev)
 		return_0;
@@ -89,15 +96,14 @@ int replicator_dev_add_slog(struct replicator_device *rdev,
 	return add_seg_to_segs_using_this_lv(slog, rdev->replicator_dev);
 }
 
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev)
+static struct logical_volume *_replicator_device_remove_slog(struct replicator_device *rdev)
 {
 	struct logical_volume *lv;
 
 	if (!rdev)
 		return_NULL;
 
-	lv = rdev->slog;
-	if (!lv) {
+	if (!(lv = rdev->slog)) {
 		log_error("Replicator device in site %s does not have sync log.",
 			  rdev->rsite->name);
 		return NULL;
@@ -113,16 +119,40 @@ struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev
 	return lv;
 }
 
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
+static char *_replicator_device_slog_name(struct logical_volume *replicator,
+                                          unsigned site_index,
+					  uint64_t device_index)
+{
+	char *name;
+	size_t len = strlen(replicator->name) + 12 + 22 + 10;
+
+	if (!(name = dm_pool_zalloc(replicator->vg->vgmem, len))) {
+		log_error("Allocation of slog name failed.");
+		return NULL;
+	}
+
+	if (!dm_snprintf(name, len, "%s_%u_%" PRIu64 "_slog", replicator->name,
+			 site_index, device_index) < 0) {
+		log_error("Error in name creation");
+		return NULL;
+	}
+
+        return name;
+}
+
+/*
+ * Connection of NULL lv_segment will turn LV into replicator LV
+ */
+int replicator_add_replicator_dev(struct logical_volume *replicator,
 				  struct lv_segment *replicator_dev_seg)
 {
-	if (!replicator_lv)
+	if (!replicator)
 		return_0;
 
-	if (!(replicator_lv->status & REPLICATOR)) {
-		dm_list_init(&replicator_lv->rsites);
-		lv_set_hidden(replicator_lv);
-		replicator_lv->status |= REPLICATOR;
+	if (!(replicator->status & REPLICATOR)) {
+		dm_list_init(&replicator->rsites);
+		lv_set_hidden(replicator);
+		replicator->status |= REPLICATOR;
 	}
 
 	if (!replicator_dev_seg)
@@ -134,9 +164,11 @@ int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
 		return 0;
 	}
 
-	replicator_dev_seg->replicator = replicator_lv;
+	replicator_dev_seg->replicator = replicator;
+	replicator_dev_seg->rlog_lv = NULL;
+	replicator_dev_seg->lv->status |= REPLICATOR;
 
-	return add_seg_to_segs_using_this_lv(replicator_lv, replicator_dev_seg);
+	return add_seg_to_segs_using_this_lv(replicator, replicator_dev_seg);
 }
 
 /**
@@ -145,25 +177,25 @@ int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
  */
 struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *replicator_dev_seg)
 {
-	struct logical_volume *lv = NULL;
-
-	log_error("FIXME: not implemented.");
-#if 0
-	/* FIXME: - this is going to be complex.... */
 	if (!replicator_dev_seg)
 		return_NULL;
 
-	/* if slog or rimage - exit */
+	if (!_replicator_device_remove_rimage(replicator_dev_seg->lv->rdevice)) {
+		log_error("Can not release rimage device");
+                return NULL;
+	}
 
-	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
+	if (!remove_seg_from_segs_using_this_lv(replicator_dev_seg->replicator, replicator_dev_seg))
 		return_NULL;
 
-	replicator_seg->rlog_lv = NULL;
-	lv->status &= ~REPLICATOR_LOG;
-	lv_set_visible(lv);
-#endif
+	dm_list_del(&replicator_dev_seg->lv->rdevice->list);
 
-	return lv;
+	replicator_dev_seg->lv->status &= ~REPLICATOR;
+	replicator_dev_seg->rlog_lv = NULL;
+	replicator_dev_seg->replicator = NULL;
+	lv_set_visible(replicator_dev_seg->lv);
+
+	return replicator_dev_seg->lv;
 }
 
 int replicator_add_rlog(struct lv_segment *replicator_seg,
@@ -207,52 +239,232 @@ struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg)
 	return lv;
 }
 
+struct replicator_site *replicator_add_site(struct logical_volume *replicator,
+					    const char *site_name)
+{
+	struct replicator_site *rsite;
+
+	if (find_site_in_replicator(replicator, site_name)) {
+		log_error("Site name %s already exists.", site_name);
+		return NULL;
+	}
+
+	if (!(rsite = dm_pool_zalloc(replicator->vg->vgmem,
+				     sizeof(*rsite)))) {
+		log_error("Allocation of replicator site failed.");
+		return NULL;
+	}
+
+	if (!(rsite->name = dm_pool_strdup(replicator->vg->vgmem,
+					   site_name))) {
+		log_error("Allocation of replicator site name failed.");
+		return NULL;
+	}
+
+	rsite->replicator = replicator;
+	dm_list_init(&rsite->rdevices);
+	dm_list_add(&replicator->rsites, &rsite->list);
+
+	return rsite;
+}
+
+int replicator_remove_site(struct replicator_site *rsite)
+{
+	log_error("FIXME: replicator_remove_site implementation is missing.");
+	dm_list_del(&rsite->list);
+
+	return 1;
+}
+
+int replicator_site_add_device(struct replicator_site *rsite,
+			       struct lv_segment *replicator_dev_seg,
+			       const char *name,
+			       struct logical_volume *rimage_lv,
+			       uint32_t slog_core,
+			       struct logical_volume *slog,
+			       uint64_t device_index)
+{
+	struct dm_pool *mem = replicator_dev_seg->lv->vg->vgmem;
+	struct replicator_device *rdev;
+
+	if (!(rdev = dm_pool_zalloc(mem, sizeof(*rdev)))) {
+		log_error("Allocation of replicator device failed.");
+		return 0;
+	}
+
+	if (!(rdev->name = dm_pool_strdup(mem, name))) {
+		log_error("Allocation of replicator device name failed.");
+		return 0;
+	}
+
+	log_very_verbose("Created %s/%s", rsite->name, name);
+
+	rdev->rsite = rsite;
+	rdev->replicator_dev = replicator_dev_seg;
+	rdev->device_index = device_index;
+	rdev->slog_core = slog_core;
+
+	dm_list_add(&rsite->rdevices, &rdev->list);// linked site list
+
+	if (rimage_lv && !_replicator_device_add_rimage(rdev, rimage_lv))
+		return_0;
+
+	if (slog_core && slog) {
+		log_error("Either slog or corelog must be used.");
+		return 0;
+	}
+
+	if (slog && !_replicator_device_add_slog(rdev, slog))
+		return_0;
+
+	return 1;
+}
+
+int replicator_site_remove_device(struct replicator_device *rdev)
+{
+	dm_list_del(&rdev->list);
+
+	return 1;
+}
 
-#if 0
 /*
- * Create new LV to pretend the original LV
- * this target will have a 'replicator' segment
+ * Create new layered LV over the original LV
+ * this target will have a 'replicator-dev' segment
  */
-int lv_add_replicator(struct logical_volume *origin, const char *rep_suffix)
+int lv_add_replicator_dev(struct logical_volume *replicator,
+			  struct logical_volume *lv)
 {
-	struct logical_volume *rep_lv;
-	char *name;
-	size_t slen;
+	const struct segment_type *segtype;
+	struct logical_volume *rimage_lv;
+	struct logical_volume *slog;
+	struct lv_segment *seg;
+	struct replicator_site *rsite;
+	const char *slog_name;
+	uint64_t dev_idx = first_seg(replicator)->rdevice_index_highest;
 
-	if (!(name = strstr(origin->name, rep_suffix))) {
-		log_error("Failed to find replicator suffix %s in LV name %s",
-			  rep_suffix, origin->name);
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "replicator-dev")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(lv->vg->cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
 		return 0;
 	}
-	slen = (size_t)(name - origin->name);
-	name = alloca(slen + 1);
-	memcpy(name, origin->name, slen);
-	name[slen] = 0;
 
-	if ((rep_lv = find_lv(origin->vg, name))) {
-		rep_lv->status |= VIRTUAL;
-		return 1;
+	/* If replicator does not have any site defined, add local default site */
+	if (dm_list_empty(&replicator->rsites)) {
+		if (!replicator_add_site(replicator, DEFAULT_REPLICATOR_LOCAL_SITE_NAME))
+			return_0;
+		first_seg(replicator)->rsite_index_highest++;
 	}
 
-	if (!(rep_lv = lv_create_empty(name, &origin->lvid,
-				       LVM_READ | LVM_WRITE | VISIBLE_LV,
-				       ALLOC_INHERIT, origin->vg)))
-		return_0;
+	first_seg(replicator)->rdevice_index_highest++;
+	dm_list_iterate_items(rsite, &replicator->rsites) {
+		if (rsite->site_index == 0) {
+			if (!(rimage_lv = insert_layer_for_lv(lv->vg->cmd, lv, 0, "_rimage")))
+				return_0;
+
+			seg = first_seg(lv);
+			seg->segtype = segtype; /* switch to replicator-dev */
 
-	if (!lv_add_virtual_segment(rep_lv, 0, origin->le_count,
-				    get_segtype_from_string(origin->vg->cmd,
-							    "error")))
+			if (!replicator_add_replicator_dev(replicator, seg))
+				return_0;
+
+			if (!replicator_site_add_device(rsite, seg, rimage_lv->name,
+							rimage_lv, 0, NULL, dev_idx))
+				return_0;
+		} else {
+			// FIXME: corelog support missing
+			slog_name = _replicator_device_slog_name(replicator, rsite->site_index,
+								 dev_idx);
+			if (!(slog = find_lv(lv->vg, slog_name))) {
+				log_error("Cannot find slog LV %s for %s/%s",
+					  slog_name, rsite->name, lv->name);
+				return 0;
+			}
+
+			if (!replicator_site_add_device(rsite, seg, lv->name,
+							NULL, 0, slog, dev_idx))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
+int lv_remove_replicator_dev(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+	struct replicator_device *rdev, *trdev;
+	struct logical_volume *replicator = first_seg(lv)->replicator;
+	uint64_t device_index = lv->rdevice->device_index;
+
+	dm_list_iterate_items(rsite, &replicator->rsites) {
+		if (rsite->site_index == 0)
+			continue;
+		dm_list_iterate_items_safe(rdev, trdev, &rsite->rdevices) {
+			if (rdev->device_index != device_index)
+				continue;
+			if (!_replicator_device_remove_slog(rdev))
+				return_0;
+			dm_list_del(&rdev->list);
+		}
+	}
+
+	if (!replicator_remove_replicator_dev(first_seg(lv)))
 		return_0;
 
-	rep_lv->status |= VIRTUAL;
 	return 1;
 }
 
-int lv_remove_replicator(struct logical_volume *lv)
+int lv_add_replicator_site(struct logical_volume *replicator,
+			   const struct replicator_site *rsite)
 {
+	struct replicator_site *nrsite;
+
+	if (find_site_in_replicator(replicator, rsite->name)) {
+		log_error("Site %s already exists.", rsite->name);
+		return 0;
+	}
+
+	if (!(nrsite = replicator_add_site(replicator, rsite->name)))
+		return_0;
+
+	if (rsite->vg_name &&
+	    !(nrsite->vg_name = dm_pool_strdup(replicator->vg->vgmem,
+					       rsite->vg_name))) {
+		log_error("Allocation of replicator site vg_name failed.");
+		return 0;
+	}
+
+	nrsite->site_index = first_seg(replicator)->rsite_index_highest++;
+	nrsite->op_mode = rsite->op_mode;
+	nrsite->fall_behind_data = rsite->fall_behind_data;
+	nrsite->fall_behind_ios = rsite->fall_behind_ios;
+	nrsite->fall_behind_timeout = rsite->fall_behind_timeout;
+
 	return 1;
 }
-#endif
+
+int lv_remove_replicator_site(struct logical_volume *replicator,
+			      const char *site_name)
+{
+	log_error("FIXME remove replicator site.");
+	return 0;
+}
+
+struct replicator_site *find_site_in_replicator(struct logical_volume *replicator,
+						const char *site_name)
+{
+	struct replicator_site *rsite;
+
+	dm_list_iterate_items(rsite, &replicator->rsites)
+		if (strcmp(rsite->name, site_name) == 0)
+			return rsite;
+
+	return NULL;
+}
 
 /*
  * Check all replicator structures:
@@ -266,7 +478,7 @@ int check_replicator_segment(const struct lv_segment *rseg)
 {
 	struct replicator_site *rsite, *rsiteb;
 	struct replicator_device *rdev, *rdevb;
-        struct logical_volume *lv = rseg->lv;
+	struct logical_volume *lv = rseg->lv;
 	int r = 1;
 
 	if (vg_is_clustered(lv->vg)) {
@@ -356,8 +568,8 @@ int check_replicator_segment(const struct lv_segment *rseg)
 					  rsite->name);
 				r = 0;
 			}
-			if (rsite->site_index > rseg->rsite_index_highest) {
-				log_error("Site index %d > %d (too high) "
+			if (rsite->site_index >= rseg->rsite_index_highest) {
+				log_error("Site index %d >= %d (too high) "
 					  "for replicator site %s/%s.",
 					  rsite->site_index,
 					  rseg->rsite_index_highest,
@@ -367,6 +579,20 @@ int check_replicator_segment(const struct lv_segment *rseg)
 		}
 
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->rsite->site_index == 0) {
+				if (strcasecmp(rdev->name,
+					       rdev->replicator_dev->lv->name) == 0) {
+					log_error("Self referenced device name "
+						  "%s detected for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
+			} else if (!rdev->slog && !rdev->slog_core) {
+				log_error("Undefined slog for %s/%s "
+					  " for replicator %s.",
+					  rdev->rsite->name, rdev->name, lv->name);
+				r = 0;
+			}
 			dm_list_iterate_items(rdevb, &rsite->rdevices) {
 				if (rdev == rdevb)
 					break;
@@ -376,6 +602,13 @@ int check_replicator_segment(const struct lv_segment *rseg)
 						  rdev->slog->name, lv->name);
 					r = 0;
 				}
+				if (strcasecmp(rdev->name,
+					       rdevb->replicator_dev->lv->name) == 0) {
+					log_error("Internal self reference device"
+						  "name %s detected for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
 				if (strcasecmp(rdev->name, rdevb->name) == 0) {
 					log_error("Duplicate device name %s "
 						  "detected for replicator %s.",
@@ -390,9 +623,9 @@ int check_replicator_segment(const struct lv_segment *rseg)
 						  lv->name, rsite->name);
 					r = 0;
 				}
-				if (rdev->device_index > rseg->rdevice_index_highest) {
+				if (rdev->device_index >= rseg->rdevice_index_highest) {
 					log_error("Device index %" PRIu64
-						  " > %" PRIu64 " (too high) "
+						  " >= %" PRIu64 " (too high) "
 						  "for replicator site %s/%s.",
 						  rdev->device_index,
 						  rseg->rdevice_index_highest,
@@ -411,7 +644,7 @@ int check_replicator_segment(const struct lv_segment *rseg)
  */
 int lv_is_active_replicator_dev(const struct logical_volume *lv)
 {
-	return ((lv->status & REPLICATOR) &&
+	return (lv_is_replicator_dev(lv) &&
 		lv->rdevice &&
 		lv->rdevice->rsite &&
 		lv->rdevice->rsite->state == REPLICATOR_STATE_ACTIVE);
@@ -442,7 +675,8 @@ int lv_is_replicator_dev(const struct logical_volume *lv)
  */
 int lv_is_rimage(const struct logical_volume *lv)
 {
-	return (lv->rdevice && lv->rdevice->lv == lv);
+	return (!lv_is_replicator_dev(lv) &&
+		(lv->rdevice && lv->rdevice->lv == lv));
 }
 
 /**
@@ -646,13 +880,13 @@ int lv_read_replicator_vgs(struct logical_volume *lv)
 	struct replicator_site *rsite;
 	struct volume_group *vg;
 
-	if (!lv_is_replicator_dev(lv))
+	if (!lv_is_active_replicator_dev(lv))
 		return 1;
 
 	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
 		if (!rsite->vg_name)
 			continue;
-		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0); // READ_WITHOUT_LOCK
+		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, READ_WITHOUT_LOCK);
 		if (vg_read_error(vg)) {
 			log_error("Unable to read volume group %s",
 				  rsite->vg_name);
@@ -691,3 +925,445 @@ void lv_release_replicator_vgs(struct logical_volume *lv)
 			rsite->vg = NULL;
 		}
 }
+
+static int _write_replicator_header(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	return 1;
+}
+
+/*
+ * Initialize log contents
+ *
+ * log_name = "mirror log", "replicator sync log"
+ */
+static int _init_log(struct cmd_context *cmd,
+		     struct logical_volume *log_lv, int in_sync,
+		     struct dm_list *tags, int remove_on_failure,
+		     const char *log_name,
+		     int (*write_header) (struct cmd_context *cmd,
+					  struct logical_volume *lv))
+{
+	struct str_list *sl;
+	struct lvinfo info;
+	uint64_t orig_status = log_lv->status;
+	int was_active = 0;
+
+	if (!activation() && in_sync) {
+		log_error("Aborting. Unable to create in-sync %s "
+			  "while activation is disabled.", log_name);
+		return 0;
+	}
+
+	/* If the LV is active, deactivate it first. */
+	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+		(void)deactivate_lv(cmd, log_lv);
+		/*
+		 * FIXME: workaround to fail early
+		 * Ensure that log is really deactivated because deactivate_lv
+		 * on cluster do not fail if there is log_lv with different UUID.
+		 */
+		if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+			log_error("Aborting. Unable to deactivate %s.",
+				  log_name);
+			goto revert_new_lv;
+		}
+		was_active = 1;
+	}
+
+	/* Temporary make it visible for set_lv() */
+	lv_set_visible(log_lv);
+
+	/* Temporary tag mirror log for activation */
+	dm_list_iterate_items(sl, tags)
+		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
+			log_error("Aborting. Unable to tag %s.", log_name);
+			goto activate_lv;
+		}
+
+	/* store mirror log on disk(s) */
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
+		goto activate_lv;
+
+	backup(log_lv->vg);
+
+	if (!activate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to activate %s.", log_name);
+		goto revert_new_lv;
+	}
+
+	/* Remove the temporary tags */
+	dm_list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from %s.",
+				  log_name, sl->str);
+
+	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
+				    in_sync ? -1 : 0)) {
+		log_error("Aborting. Failed to wipe %s.", log_name);
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (activation() && !write_header(cmd, log_lv)) { /* FIXME */
+		log_error("Aborting. Failed to write %s header.", log_name);
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Aborting. Failed to deactivate %s. "
+			  "Manual intervention required.", log_name);
+		return 0;
+	}
+
+	lv_set_hidden(log_lv);
+
+	if (was_active && !activate_lv(cmd, log_lv))
+		return_0;
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Unable to deactivate %s LV. "
+			  "Manual intervention required.", log_name);
+		return 0;
+	}
+
+revert_new_lv:
+	log_lv->status = orig_status;
+
+	dm_list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from %s.",
+				  log_name, sl->str);
+
+	if (remove_on_failure && !lv_remove(log_lv)) {
+		log_error("Manual intervention may be required to remove "
+			  "abandoned log LV before retrying.");
+		return 0;
+	}
+
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
+		log_error("Manual intervention may be required to "
+			  "remove/restore abandoned log LV before retrying.");
+	else
+		backup(log_lv->vg);
+
+activate_lv:
+	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
+		return_0;
+
+	return 0;
+}
+
+#if 0
+static int _init_replicator_log(struct cmd_context *cmd,
+				struct logical_volume *log_lv, int in_sync,
+				struct dm_list *tags, int remove_on_failure)
+{
+	if (!_init_log(cmd, log_lv, in_sync, tags, remove_on_failure,
+		       "replicator log", _write_replicator_header))
+		return_0;
+
+	return 1;
+}
+#endif
+
+static int _init_replicator_sync_log(struct cmd_context *cmd,
+				     struct logical_volume *log_lv, int in_sync,
+				     struct dm_list *tags, int remove_on_failure)
+{
+	if (!_init_log(cmd, log_lv, in_sync, tags, remove_on_failure,
+		       "sync log", _write_replicator_header))
+		return_0;
+
+	return 1;
+}
+
+/* Could be shared with mirror */
+static struct logical_volume *_create_log(struct logical_volume *lv,
+					  struct alloc_handle *ah,
+					  alloc_policy_t alloc,
+					  const char *lv_name,
+					  const char *suffix,
+					  uint64_t status)
+{
+	struct logical_volume *log_lv;
+	char *log_name;
+	size_t len;
+
+	len = strlen(lv_name) + 32;
+	if (!(log_name = alloca(len))) {
+		log_error("log_name allocation failed.");
+		return NULL;
+	}
+
+	if (dm_snprintf(log_name, len, "%s%s", lv_name, suffix) < 0) {
+		log_error("log_name allocation failed.");
+		return NULL;
+	}
+
+	if (!(log_lv = lv_create_empty(log_name, NULL,
+				       VISIBLE_LV | LVM_READ | LVM_WRITE,
+				       alloc, lv->vg)))
+		return_NULL;
+
+	if (!lv_add_log_segment(ah, 0, log_lv, status))
+		return_NULL;
+
+	return log_lv;
+}
+
+#if 0
+static struct logical_volume *_set_up_replicator_log(struct cmd_context *cmd,
+						     struct alloc_handle *ah,
+						     struct logical_volume *lv,
+						     uint32_t log_size __attribute((unused)),
+						     alloc_policy_t alloc,
+						     int in_sync)
+{
+	struct logical_volume *log_lv;
+	const char *suffix, *c;
+	char *lv_name;
+	size_t len;
+	struct lv_segment *seg;
+
+	//init_mirror_in_sync(in_sync);
+
+	/* Replicator log name is lv_name + suffix, determined as the following:
+	 *   1. suffix is:
+	 *        o "_rlog" for the original replicator LV.
+	 *        o "_rlogtmp_%d" for temporary mirror LV,
+	 *   2. lv_name is:
+	 *        o lv->name, if the log is temporary
+	 *        o otherwise, the top-level LV name
+	 */
+	seg = first_seg(lv);
+	if (seg_type(seg, 0) == AREA_LV &&
+	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER)) {
+		lv_name = lv->name;
+		suffix = "_rlogtmp_%d";
+	} else if ((c = strstr(lv->name, MIRROR_SYNC_LAYER))) {
+		len = (size_t)(c - lv->name + 1);
+		if (!(lv_name = alloca(len)) ||
+		    !dm_snprintf(lv_name, len, "%s", lv->name)) {
+			log_error("replicator log name allocation failed");
+			return 0;
+		}
+		suffix = "_rlog";
+	} else {
+		lv_name = lv->name;
+		suffix = "_rlog";
+	}
+
+	if (!(log_lv = _create_log(lv, ah, alloc, lv_name, suffix, REPLICATOR_LOG))) {
+		log_error("Failed to create replicator log.");
+		return NULL;
+	}
+
+	if (!_init_replicator_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
+		log_error("Failed to initialise replicator log.");
+		return NULL;
+	}
+
+	return log_lv;
+}
+#endif
+
+static struct logical_volume *_set_up_sync_log(struct cmd_context *cmd,
+					       struct alloc_handle *ah,
+					       struct logical_volume *replicator,
+                                               unsigned site_index,
+					       uint64_t device_index,
+					       alloc_policy_t alloc,
+					       int in_sync)
+{
+	struct logical_volume *log_lv;
+	const char *suffix = "";
+	char *lv_name;
+
+	if (!(lv_name = _replicator_device_slog_name(replicator, site_index, device_index)))
+		return_NULL;
+
+	if (!(log_lv = _create_log(replicator, ah, alloc, lv_name, suffix,
+				   REPLICATOR_LOG))) {
+		log_error("Failed to create replicator sync log.");
+		return NULL;
+	}
+
+	if (!_init_replicator_sync_log(cmd, log_lv, in_sync, &replicator->tags, 1)) {
+		log_error("Failed to initialise replicator sync log.");
+		return NULL;
+	}
+
+	return log_lv;
+}
+
+int lv_add_sync_log(struct logical_volume *replicator,
+		    unsigned site_index,
+		    uint64_t device_index,
+		    struct dm_list *allocatable_pvs,
+		    alloc_policy_t alloc)
+{
+	struct cmd_context *cmd = replicator->vg->cmd;
+	const struct segment_type *segtype;
+	struct alloc_handle *ah;
+	uint32_t region_size;
+	int in_sync;
+	int r = 1;
+
+	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
+		return 0;
+	}
+
+	region_size = adjusted_mirror_region_size(replicator->vg->extent_size,
+						  replicator->le_count,
+						  first_seg(replicator)->region_size);
+
+	/* allocate destination extents */
+	ah = allocate_extents(replicator->vg, NULL, segtype,
+			      0, 0, 1, region_size, 0,
+			      allocatable_pvs, alloc, NULL);
+	if (!ah) {
+		log_error("Unable to allocate extents for replicator sync log.");
+		return 0;
+	}
+
+	/* check sync status */
+	in_sync = 0;
+
+	if (!_set_up_sync_log(cmd, ah, replicator, site_index, device_index,
+			      alloc, in_sync)) {
+                stack;
+		r = 0;
+	}
+
+	alloc_destroy(ah);
+
+        return r;
+}
+
+int vg_prepare_replicator(struct volume_group *vg,
+			  const struct lvcreate_params *lp)
+{
+	struct logical_volume *replicator;
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	unsigned site_index;
+	uint64_t device_index;
+
+	if (lp->replicator_dev || lp->rsite.name) {
+		if (!(replicator = find_lv(vg, lp->replicator))) {
+			log_error("Replicator \"%s\" not found.", lp->replicator);
+			return 0;
+		}
+
+		if (lp->replicator_dev) {
+			device_index = first_seg(replicator)->rdevice_index_highest;
+			dm_list_iterate_items(rsite, &replicator->rsites) {
+				if (rsite->site_index != 0 &&
+				    !lv_add_sync_log(replicator,
+						     rsite->site_index,
+						     device_index,
+						     lp->pvh, lp->alloc))
+					return_0;
+			}
+		}
+		if (lp->rsite.name) {
+			site_index = first_seg(replicator)->rsite_index_highest;
+			dm_list_iterate_items(rsite, &replicator->rsites) {
+				if (rsite->site_index != 0)
+					continue;
+
+				dm_list_iterate_items(rdev, &rsite->rdevices) {
+					if (!lv_add_sync_log(replicator,
+							     site_index,
+							     rdev->device_index,
+							     lp->pvh, lp->alloc))
+						return_0;
+				}
+			}
+		}
+	}
+
+	/* For site creation - no new LV will created */
+	if (lp->rsite.name && strlen(lp->replicator)) {
+		if (!(replicator = find_lv(vg, lp->replicator))) {
+			log_error("Replicator %s does not exists",
+				  lp->replicator);
+			return 0;
+		}
+		if (!lv_add_replicator_site(replicator, &lp->rsite))
+			return_0;
+
+		if (!archive(vg))
+			return_0;
+
+		/* store vg on disk(s) */
+		if (!vg_write(vg) || !vg_commit(vg))
+			return_0;
+
+		backup(vg);
+	}
+
+	return 1;
+}
+
+int vg_add_replicator(struct logical_volume *replicator,
+		      const char *rlog_type,
+		      uint32_t region_size)
+{
+	const struct segment_type *segtype;
+	float sync_percent;
+	percent_range_t percent_range;
+	struct logical_volume *rlog_lv;
+	struct lv_segment *repseg;
+	struct lvinfo info;
+
+	/*
+	 * We are unable to convert the log of inactive cluster replictors
+	 */
+	if (vg_is_clustered(replicator->vg)
+	    && !(lv_info(replicator->vg->cmd, replicator, &info, 0, 0) &&
+		 info.exists)) {
+		log_error("Replicator in this VG is not supported.");
+		return 0;
+	}
+
+	if (!(segtype = get_segtype_from_string(replicator->vg->cmd,
+						"replicator")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(replicator->vg->cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
+		return 0;
+	}
+
+	if (!(rlog_lv = insert_layer_for_lv(replicator->vg->cmd,
+					    replicator, 0, "_rlog"))) {
+		log_error("Failed to insert replicator _rlog");
+		return 0;
+	}
+
+	repseg = first_seg(replicator);
+	repseg->segtype = segtype;
+
+	repseg->rlog_type = rlog_type; //"ringbuffer";
+	repseg->rdevice_index_highest = 0;
+	repseg->rsite_index_highest = 0;
+	repseg->region_size = region_size;
+
+	replicator_add_replicator_dev(replicator, NULL);
+
+	if (!replicator_add_rlog(repseg, rlog_lv))
+		return_0;
+
+	return 1;
+}
-- 
1.7.1


