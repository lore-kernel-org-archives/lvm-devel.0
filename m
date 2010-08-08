From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:25 +0200
Subject: [PATCH 13/25] Replicator: replicator_manip changes
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <4ef967069361b74dafe928a5b018b2865f9afeb4.1281256235.git.zkabelac@redhat.com>
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
 lib/metadata/replicator_manip.c | 1257 +++++++++++++++++++++++++++++++--------
 1 files changed, 1024 insertions(+), 233 deletions(-)

diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 272ceac..b690019 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -15,244 +15,741 @@
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
+
+static const struct {
+	const char name[8];
+	int value;
+} policy_table[] = {
+	{ "sync", DM_REPLICATOR_SYNC },
+	{ "warn", DM_REPLICATOR_ASYNC_WARN },
+	{ "stall", DM_REPLICATOR_ASYNC_STALL },
+	{ "drop", DM_REPLICATOR_ASYNC_DROP },
+	{ "fail", DM_REPLICATOR_ASYNC_FAIL }
+};
 
-/* Add lv as replicator_dev device */
-int replicator_dev_add_rimage(struct replicator_device *rdev,
-			      struct logical_volume *lv)
+/**
+ * Tests whether LV is member of an active replicator.
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is member of an active replicator,
+ *		0 otherwise.
+ */
+int lv_is_active_replicated(const struct logical_volume *lv)
 {
-	if (!lv || !rdev)
-		return_0;
+	return (lv_is_replicated(lv) &&
+		lv->rdevice &&
+		lv->rdevice->rsite &&
+		lv->rdevice->rsite->state == REPLICATOR_STATE_ACTIVE);
+}
 
-	if (lv_is_rimage(lv)) {
-		log_error("Logical volume %s is already part of other "
+/**
+ * Tests whether LV is replicator control device.
+ * (Segment-less LV could be also replicator.)
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is replicator control device,
+ *		0 otherwise.
+ */
+int lv_is_replicator(const struct logical_volume *lv)
+{
+	return ((lv->status & REPLICATOR) &&
+		(dm_list_empty(&lv->segments) ||
+		 seg_is_replicator(first_seg(lv))));
+}
+
+/**
+ * Tests whether LV is replicated device.
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is replicated device,
+ *		0 otherwise.
+ */
+int lv_is_replicated(const struct logical_volume *lv)
+{
+	return ((lv->status & REPLICATOR) &&
+		!dm_list_empty(&lv->segments) &&
+		seg_is_replicated(first_seg(lv)));
+}
+
+/**
+ * Tests whether LV is replicated rimage device.
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is replicated rimage device,
+ *		0 otherwise.
+ */
+int lv_is_rimage(const struct logical_volume *lv)
+{
+	return (!lv_is_replicated(lv) &&
+		(lv->rdevice && lv->rdevice->lv == lv));
+}
+
+/**
+ * Tests whether LV is replicator log device.
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is replicator log device,
+ *		0 otherwise.
+ */
+int lv_is_rlog(const struct logical_volume *lv)
+{
+	return (lv->status & REPLICATOR_LOG);
+}
+
+/**
+ * Tests whether LV is replicator sync log device.
+ *
+ * \param lv    Logical volume for testing
+ *
+ * \return	Returns 1 if the lv is replicator sync log device,
+ *		0 otherwise.
+ */
+int lv_is_slog(const struct logical_volume *lv)
+{
+	return (lv->rdevice && lv->rdevice->slog == lv);
+}
+
+/**
+ * Returns local site from replicator.
+ */
+struct replicator_site *find_local_site_in_replicator(const struct logical_volume *replicator)
+{
+	struct replicator_site *rsite;
+
+	dm_list_iterate_items(rsite, &replicator->rsites)
+		if (rsite->site_index == 0)
+			return rsite;
+
+	return NULL;
+}
+
+/**
+ * Returns site with name site_name from replicator.
+ */
+struct replicator_site *find_site_in_replicator(const struct logical_volume *replicator,
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
+
+/**
+ * Returns first replicated LV in site in case the LV is replicated
+ * or replicator, NULL otherwise
+ */
+struct logical_volume *first_replicated(const struct logical_volume *lv)
+{
+	struct replicated_device *rdev;
+	struct replicator_site *rsite;
+	const struct logical_volume *replicator;
+
+	if (lv_is_replicated(lv))
+		replicator = first_seg(lv)->replicator;
+	else if (lv_is_replicator(lv))
+		replicator = lv;
+	else {
+		log_error(INTERNAL_ERROR "Logical volume %s is not "
 			  "replicator.", lv->name);
+		return NULL;
+	}
+
+	if ((rsite = find_local_site_in_replicator(replicator)))
+		dm_list_iterate_items(rdev, &rsite->rdevices)
+			return rdev->replicated_seg->lv;
+
+	return NULL;
+}
+
+/* Add lv as replicated device */
+static int _replicated_device_add_rimage(struct replicated_device *rdev,
+					 struct logical_volume *lv)
+{
+	if (lv_is_rimage(lv)) {
+		log_error(INTERNAL_ERROR "Logical volume %s is used by replicator %s.",
+			  lv->name, lv->rdevice->rsite->replicator->name);
 		return 0;
 	}
 
 	if (rdev->lv) {
-		log_error("Logical volume %s can not be attached to an "
-			  "already defined replicator device", lv->name);
+		log_error(INTERNAL_ERROR "Logical volume %s cannot be attached to an "
+			  "already defined replicated device.", lv->name);
 		return 0;
 	}
 
 	lv_set_hidden(lv);
 	lv->rdevice = rdev;
+	rdev->replicated_seg->lv->rdevice = rdev;
 	rdev->lv = lv;
 
-	return add_seg_to_segs_using_this_lv(lv, rdev->replicator_dev);
+	return add_seg_to_segs_using_this_lv(lv, rdev->replicated_seg);
 }
 
-/* Remove lv from replicator_dev device */
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev)
+/* Remove lv from replicated device */
+static struct logical_volume *_replicated_device_remove_rimage(struct replicated_device *rdev)
 {
-	struct logical_volume *lv;
+	struct logical_volume *rimage = rdev->lv;
 
-	if (!rdev || !rdev->lv)
-		return_NULL;
+	if (!rimage || !lv_is_rimage(rimage)) {
+		log_error(INTERNAL_ERROR "Replicated device in site %s "
+			  "does not have rimage.", rdev->rsite->name);
+		return NULL;
+	}
 
-	lv = rdev->lv;
-	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
+	if (!remove_seg_from_segs_using_this_lv(rimage, rdev->replicated_seg))
 		return_NULL;
 
-	/* FIXME: - check for site references */
 	rdev->lv = NULL;
-	lv->rdevice = NULL;
-	lv_set_visible(lv);
+	rimage->rdevice = NULL;
+	lv_set_visible(rimage);
 
-	return lv;
+	return rimage;
 }
 
-int replicator_dev_add_slog(struct replicator_device *rdev,
-			    struct logical_volume *slog)
+static int _replicated_device_add_slog(struct replicated_device *rdev,
+				       struct logical_volume *slog)
 {
-	if (!slog || !rdev)
-		return_0;
-
-	if (rdev->slog) {
-		log_error("Replicator device in site %s already has sync log.",
-			  rdev->rsite->name);
+	if (lv_is_slog(slog)) {
+		log_error(INTERNAL_ERROR "Logical volume %s cannot be used.",
+			  slog->name);
 		return 0;
 	}
 
-	if (slog->rdevice) {
-		log_error("Sync log %s is already used by replicator %s.",
-			  slog->name, slog->rdevice->rsite->replicator->name);
+	if (rdev->slog) {
+		log_error(INTERNAL_ERROR "Replicated device in site %s has "
+			  "sync log %s.", rdev->rsite->name, rdev->slog->name);
 		return 0;
 	}
 
+	if (!add_seg_to_segs_using_this_lv(slog, rdev->replicated_seg))
+		return_0;
+
 	lv_set_hidden(slog);
-	slog->rdevice = rdev;
 	rdev->slog = slog;
+	slog->rdevice = rdev;
 
-	return add_seg_to_segs_using_this_lv(slog, rdev->replicator_dev);
+	return 1;
 }
 
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev)
+static struct logical_volume *_replicated_device_remove_slog(struct replicated_device *rdev)
 {
-	struct logical_volume *lv;
+	struct logical_volume *slog = rdev->slog;
 
-	if (!rdev)
+	if (!slog || !lv_is_slog(slog)) {
+		log_error(INTERNAL_ERROR "Replicated device in site %s "
+			  "does not have sync log.", rdev->rsite->name);
+		return NULL;
+	}
+
+	slog->rdevice = NULL;
+	rdev->slog = NULL;
+	lv_set_visible(slog);
+
+	if (!remove_seg_from_segs_using_this_lv(slog, rdev->replicated_seg))
 		return_NULL;
 
-	lv = rdev->slog;
-	if (!lv) {
-		log_error("Replicator device in site %s does not have sync log.",
-			  rdev->rsite->name);
+	return slog;
+}
+
+static char *_replicated_device_slog_name(struct logical_volume *replicator,
+					  unsigned site_index,
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
+		log_error("Error in name creation.");
+		return NULL;
+	}
+
+	return name;
+}
+
+int replicator_add_rlog(struct lv_segment *replicator_seg,
+			struct logical_volume *rlog_lv)
+{
+	if (lv_is_rlog(rlog_lv)) {
+		log_error(INTERNAL_ERROR "Logical volume %s cannot be used.",
+			  rlog_lv->name);
+		return 0;
+	}
+
+	if (!add_seg_to_segs_using_this_lv(rlog_lv, replicator_seg))
+		return_0;
+
+	lv_set_hidden(rlog_lv);
+	rlog_lv->status |= REPLICATOR_LOG;
+	replicator_seg->rlog_lv = rlog_lv;
+
+	return 1;
+}
+
+struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg)
+{
+	struct logical_volume *rlog_lv = replicator_seg->rlog_lv;
+
+	if (!rlog_lv || !lv_is_rlog(rlog_lv)) {
+		log_error(INTERNAL_ERROR "Replicator %s does not have rlog.",
+			  replicator_seg->lv->name);
 		return NULL;
 	}
 
-	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
+	replicator_seg->rlog_lv = NULL;
+	rlog_lv->status &= ~REPLICATOR_LOG;
+	lv_set_visible(rlog_lv);
+
+	if (!remove_seg_from_segs_using_this_lv(rlog_lv, replicator_seg))
 		return_NULL;
 
-	rdev->slog = NULL;
-	lv->rdevice = NULL;
-	lv_set_visible(lv);
+	return rlog_lv;
+}
+
+/**
+ *
+ */
+int replicator_site_add_device(struct replicator_site *rsite,
+			       struct lv_segment *replicated_seg,
+			       const char *name,
+			       struct logical_volume *rimage,
+			       uint32_t slog_core,
+			       struct logical_volume *slog,
+			       uint64_t device_index)
+{
+	struct dm_pool *mem = replicated_seg->lv->vg->vgmem;
+	struct replicated_device *rdev;
+
+	if (!(rdev = dm_pool_zalloc(mem, sizeof(*rdev)))) {
+		log_error("Allocation of replicated device failed.");
+		return 0;
+	}
+
+	if (!(rdev->name = dm_pool_strdup(mem, name))) {
+		log_error("Allocation of replicated device name failed.");
+		return 0;
+	}
+
+	log_very_verbose("Created %s/%s", rsite->name, rdev->name);
+
+	rdev->rsite = rsite;
+	rdev->replicated_seg = replicated_seg;
+	rdev->device_index = device_index;
+	rdev->slog_core = slog_core;
+
+	dm_list_add(&rsite->rdevices, &rdev->list);// linked site list
 
-	return lv;
+	if (rimage && !_replicated_device_add_rimage(rdev, rimage))
+		return_0;
+
+	if (slog_core && slog) {
+		log_error("Either slog or corelog must be used.");
+		return 0;
+	}
+
+	if (slog && !_replicated_device_add_slog(rdev, slog))
+		return_0;
+
+	return 1;
 }
 
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
-				  struct lv_segment *replicator_dev_seg)
+static int _replicator_site_remove_device(struct replicated_device *rdev)
 {
-	if (!replicator_lv)
+	if (rdev->lv && !_replicated_device_remove_rimage(rdev))
 		return_0;
 
-	if (!(replicator_lv->status & REPLICATOR)) {
-		dm_list_init(&replicator_lv->rsites);
-		lv_set_hidden(replicator_lv);
-		replicator_lv->status |= REPLICATOR;
+	if (rdev->slog && !_replicated_device_remove_slog(rdev))
+		return_0;
+
+	dm_list_del(&rdev->list);
+
+	return 1;
+}
+
+struct replicator_site *replicator_add_site(struct logical_volume *replicator,
+					    const char *site_name)
+{
+	struct replicator_site *rsite;
+
+	if (find_site_in_replicator(replicator, site_name)) {
+		log_error("Site name %s already exists.", site_name);
+		return NULL;
 	}
 
-	if (!replicator_dev_seg)
-		return 1;
+	if (!(rsite = dm_pool_zalloc(replicator->vg->vgmem,
+				     sizeof(*rsite)))) {
+		log_error("Allocation of replicator site failed.");
+		return NULL;
+	}
 
-	if (replicator_dev_seg->replicator) {
-		log_error("Replicator device %s is already part of replicator.",
-			  replicator_dev_seg->lv->name);
-		return 0;
+	if (!(rsite->name = dm_pool_strdup(replicator->vg->vgmem,
+					   site_name))) {
+		log_error("Allocation of replicator site name failed.");
+		return NULL;
 	}
 
-	replicator_dev_seg->replicator = replicator_lv;
+	rsite->replicator = replicator;
+	dm_list_init(&rsite->rdevices);
+	dm_list_add(&replicator->rsites, &rsite->list);
+
+	return rsite;
+}
+
+static int _replicator_remove_site(struct replicator_site *rsite)
+{
+	struct replicated_device *rdev, *trdev;
+
+	dm_list_iterate_items_safe(rdev, trdev, &rsite->rdevices)
+		if (!_replicator_site_remove_device(rdev))
+			return_0;
+
+	dm_list_del(&rsite->list);
+
+	return 1;
+}
 
-	return add_seg_to_segs_using_this_lv(replicator_lv, replicator_dev_seg);
+
+void replicator_init(struct logical_volume *replicator)
+{
+	if (!lv_is_replicator(replicator)) {
+		dm_list_init(&replicator->rsites);
+		lv_set_hidden(replicator);
+		replicator->status |= REPLICATOR;
+	}
 }
 
 /**
- * Returns rimage ?? lv upon succeful detach of device
- * entire LV entry should be removed by this crootall ??
+ * Connects replicated segment to replicator.
+ *
+ * \param replicator
+ * \param replicated_seg
  */
-struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *replicator_dev_seg)
+int replicator_add_replicated_seg(struct logical_volume *replicator,
+				  struct lv_segment *replicated_seg)
 {
-	struct logical_volume *lv = NULL;
+	replicator_init(replicator);
 
-	log_error("FIXME: not implemented.");
-#if 0
-	/* FIXME: - this is going to be complex.... */
-	if (!replicator_dev_seg)
-		return_NULL;
+	if (replicated_seg->replicator) {
+		log_error(INTERNAL_ERROR "Replicated device %s is already "
+			  "part of replicator.", replicated_seg->lv->name);
+		return 0;
+	}
 
-	/* if slog or rimage - exit */
+	replicated_seg->replicator = replicator;
+	replicated_seg->rlog_lv = NULL;
+	replicated_seg->lv->status |= REPLICATOR;
 
-	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
-		return_NULL;
+	if (!add_seg_to_segs_using_this_lv(replicator, replicated_seg))
+		return_0;
 
-	replicator_seg->rlog_lv = NULL;
-	lv->status &= ~REPLICATOR_LOG;
-	lv_set_visible(lv);
-#endif
+	return 1;
+}
 
-	return lv;
+/**
+ * Returns rimage LV upon succeful detach of device
+ * entire LV entry should be removed by this call ??
+ */
+static int _replicator_remove_replicated_seg(struct lv_segment *replicated_seg)
+{
+	struct replicator_site *rsite;
+	struct replicated_device *rdev;
+	struct logical_volume *replicator = replicated_seg->replicator;
+	uint64_t device_index = replicated_seg->lv->rdevice->device_index;
+
+	dm_list_iterate_items(rsite, &replicator->rsites) {
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->device_index != device_index)
+				continue;
+			if (!_replicator_site_remove_device(rdev))
+				return_0;
+			/* no need for iterate_items_safe - 1 device per site */
+			break;
+		}
+	}
+
+	if (!remove_seg_from_segs_using_this_lv(replicator, replicated_seg))
+		return_0;
+
+	replicated_seg->lv->status &= ~REPLICATOR;
+	replicated_seg->rlog_lv = NULL;
+	replicated_seg->replicator = NULL;
+
+	return 1;
 }
 
-int replicator_add_rlog(struct lv_segment *replicator_seg,
-			struct logical_volume *rlog_lv)
+/*
+ * Create new layered LV over the original LV
+ * this target will have a replicated segment
+ */
+int lv_add_replicated(struct logical_volume *replicator,
+		      struct logical_volume *lv)
 {
-	if (!rlog_lv)
+	const struct segment_type *segtype;
+	struct logical_volume *rimage;
+	struct logical_volume *slog;
+	struct lv_segment *seg;
+	struct replicator_site *rsite;
+	const char *slog_name;
+	uint64_t dev_idx = first_seg(replicator)->rdevice_index_highest;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "replicated")))
 		return_0;
 
-	if (rlog_lv->status & REPLICATOR_LOG) {
-		log_error("Rlog device %s is already used.", rlog_lv->name);
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(lv->vg->cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel.", segtype->name);
 		return 0;
 	}
 
-	lv_set_hidden(rlog_lv);
-	rlog_lv->status |= REPLICATOR_LOG;
-	replicator_seg->rlog_lv = rlog_lv;
+	/* If replicator does not have any site defined, add local default site */
+	if (dm_list_empty(&replicator->rsites)) {
+		if (!replicator_add_site(replicator, DEFAULT_REPLICATOR_LOCAL_SITE_NAME))
+			return_0;
+		first_seg(replicator)->rsite_index_highest++;
+	}
+
+	first_seg(replicator)->rdevice_index_highest++;
+	dm_list_iterate_items(rsite, &replicator->rsites) {
+		if (rsite->site_index == 0) {
+			if (!(rimage = insert_layer_for_lv(lv->vg->cmd, lv, 0, "_rimage")))
+				return_0;
+
+			seg = first_seg(lv);
+			seg->segtype = segtype; /* switch to replicated */
+
+			if (!replicator_add_replicated_seg(replicator, seg))
+				return_0;
+
+			if (!replicator_site_add_device(rsite, seg, rimage->name,
+							rimage, 0, NULL, dev_idx))
+				return_0;
+		} else {
+			// FIXME: corelog support missing
+			slog_name = _replicated_device_slog_name(replicator, rsite->site_index,
+								 dev_idx);
+			if (!(slog = find_lv(lv->vg, slog_name))) {
+				log_error("Cannot find slog LV %s for %s/%s",
+					  slog_name, rsite->name, lv->name);
+				return 0;
+			}
 
-	return add_seg_to_segs_using_this_lv(rlog_lv, replicator_seg);
+			if (!replicator_site_add_device(rsite, seg, lv->name,
+							NULL, 0, slog, dev_idx))
+				return_0;
+		}
+	}
+
+	return 1;
 }
 
-struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg)
+int lv_remove_replicated(struct logical_volume *lv)
 {
-	struct logical_volume *lv;
+	/* FIXME: collect all removed devices */
+	if (!_replicator_remove_replicated_seg(first_seg(lv)))
+		return_0;
 
-	if (!replicator_seg)
+	return 1;
+}
+
+int lv_add_replicator_site(struct logical_volume *replicator,
+			   const struct replicator_site *rsite)
+{
+	struct replicator_site *nrsite;
+
+	if (!lv_is_replicator(replicator)) {
+		log_error(INTERNAL_ERROR "Logical volume %s is not a "
+			  "replicator.", replicator->name);
+		return 0;
+	}
+
+	if (!(nrsite = replicator_add_site(replicator, rsite->name)))
 		return_0;
 
-	if (!(lv = replicator_seg->rlog_lv)) {
-		log_error("Replog segment %s does not have rlog.",
-			  replicator_seg->lv->name);
-		return NULL;
+	if (rsite->vg_name &&
+	    !(nrsite->vg_name = dm_pool_strdup(replicator->vg->vgmem,
+					       rsite->vg_name))) {
+		log_error("Allocation of replicator site vg_name failed.");
+		return 0;
 	}
 
-	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
-		return_NULL;
+	nrsite->site_index = first_seg(replicator)->rsite_index_highest++;
+	nrsite->policy = rsite->policy;
+	nrsite->fall_behind_ios = rsite->fall_behind_ios;
+	nrsite->fall_behind_size = rsite->fall_behind_size;
+	nrsite->fall_behind_timeout = rsite->fall_behind_timeout;
 
-	replicator_seg->rlog_lv = NULL;
-	lv->status &= ~REPLICATOR_LOG;
-	lv_set_visible(lv);
+	return 1;
+}
+
+int lv_remove_replicator_site(struct logical_volume *replicator,
+			      const char *site_name)
+{
+	struct replicator_site *rsite, *trsite;
 
-	return lv;
+	if (!(rsite = find_site_in_replicator(replicator, site_name))) {
+		log_error(INTERNAL_ERROR "Replicator %s does not contain "
+			  "site %s.", site_name, replicator->name);
+		return 0;
+	}
+
+	if (!_replicator_remove_site(rsite))
+		return_0;
+
+	/* When the local site is removed, all remote sites must be removed */
+	if (rsite->site_index == 0) {
+		dm_list_iterate_items_safe(rsite, trsite, &replicator->rsites)
+			if (!_replicator_remove_site(rsite))
+				return_0;
+	}
+
+	return 1;
 }
 
+int vg_prearrange_replicator(struct volume_group *vg,
+			     const struct lvcreate_params *lp)
+{
+	struct logical_volume *replicator = NULL;
+	struct replicator_site *rsite;
+	struct replicated_device *rdev;
+	unsigned site_index;
+	uint64_t device_index;
 
-#if 0
-/*
- * Create new LV to pretend the original LV
- * this target will have a 'replicator' segment
- */
-int lv_add_replicator(struct logical_volume *origin, const char *rep_suffix)
+	if (lp->replicated || lp->rsite.name)
+		if (!(replicator = find_lv(vg, lp->replicator))) {
+			log_error("Replicator %s not found.", lp->replicator);
+			return 0;
+		}
+
+	if (lp->replicated) {
+		device_index = first_seg(replicator)->rdevice_index_highest;
+		dm_list_iterate_items(rsite, &replicator->rsites) {
+			if (rsite->site_index != 0 &&
+			    !lv_add_sync_log(replicator,
+					     rsite->site_index,
+					     device_index,
+					     lp->pvh, lp->alloc))
+				return_0;
+		}
+	}
+
+	if (lp->rsite.name) {
+		site_index = first_seg(replicator)->rsite_index_highest;
+		dm_list_iterate_items(rsite, &replicator->rsites) {
+			if (rsite->site_index != 0)
+				continue;
+
+			dm_list_iterate_items(rdev, &rsite->rdevices) {
+				if (!lv_add_sync_log(replicator,
+						     site_index,
+						     rdev->device_index,
+						     lp->pvh, lp->alloc))
+					return_0;
+			}
+		}
+
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
 {
-	struct logical_volume *rep_lv;
-	char *name;
-	size_t slen;
+	const struct segment_type *segtype;
+	//float sync_percent;
+	//percent_range_t percent_range;
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
 
-	if (!(name = strstr(origin->name, rep_suffix))) {
-		log_error("Failed to find replicator suffix %s in LV name %s",
-			  rep_suffix, origin->name);
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(replicator->vg->cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel.", segtype->name);
 		return 0;
 	}
-	slen = (size_t)(name - origin->name);
-	name = alloca(slen + 1);
-	memcpy(name, origin->name, slen);
-	name[slen] = 0;
 
-	if ((rep_lv = find_lv(origin->vg, name))) {
-		rep_lv->status |= VIRTUAL;
-		return 1;
+	if (!(rlog_lv = insert_layer_for_lv(replicator->vg->cmd,
+					    replicator, 0, "_rlog"))) {
+		log_error("Failed to insert replicator _rlog.");
+		return 0;
 	}
 
-	if (!(rep_lv = lv_create_empty(name, &origin->lvid,
-				       LVM_READ | LVM_WRITE | VISIBLE_LV,
-				       ALLOC_INHERIT, origin->vg)))
-		return_0;
+	repseg = first_seg(replicator);
+	repseg->segtype = segtype;
 
-	if (!lv_add_virtual_segment(rep_lv, 0, origin->le_count,
-				    get_segtype_from_string(origin->vg->cmd,
-							    "error")))
+	repseg->rlog_type = rlog_type; //"ringbuffer";
+	repseg->rdevice_index_highest = 0;
+	repseg->rsite_index_highest = 0;
+	repseg->region_size = region_size;
+
+	replicator_init(replicator);
+
+	if (!replicator_add_rlog(repseg, rlog_lv))
 		return_0;
 
-	rep_lv->status |= VIRTUAL;
 	return 1;
 }
 
-int lv_remove_replicator(struct logical_volume *lv)
+int vg_remove_replicator(struct logical_volume *replicator)
 {
+	/* FIXME: replace heads with error targets first */
+	if (!suspend_lv(replicator->vg->cmd, replicator)) {
+		log_error("Failed to suspend %s.",
+			  replicator->name);
+		return 0;
+	}
+
 	return 1;
 }
-#endif
 
 /*
  * Check all replicator structures:
@@ -265,8 +762,8 @@ int lv_remove_replicator(struct logical_volume *lv)
 int check_replicator_segment(const struct lv_segment *rseg)
 {
 	struct replicator_site *rsite, *rsiteb;
-	struct replicator_device *rdev, *rdevb;
-        struct logical_volume *lv = rseg->lv;
+	struct replicated_device *rdev, *rdevb;
+	struct logical_volume *lv = rseg->lv;
 	int r = 1;
 
 	if (vg_is_clustered(lv->vg)) {
@@ -282,51 +779,51 @@ int check_replicator_segment(const struct lv_segment *rseg)
 	}
 
 	dm_list_iterate_items(rsite, &lv->rsites) {
-		if (rsite->op_mode == DM_REPLICATOR_SYNC) {
-			if (rsite->fall_behind_timeout) {
-				log_error("Defined fall_behind_timeout="
-					  "%d for sync replicator %s/%s.",
-					  rsite->fall_behind_timeout, lv->name,
-					  rsite->name);
-				r = 0;
-			}
+		if (rsite->policy == DM_REPLICATOR_SYNC) {
 			if (rsite->fall_behind_ios) {
 				log_error("Defined fall_behind_ios="
 					  "%d for sync replicator %s/%s.",
 					  rsite->fall_behind_ios, lv->name, rsite->name);
 				r = 0;
 			}
-			if (rsite->fall_behind_data) {
-				log_error("Defined fall_behind_data="
+			if (rsite->fall_behind_size) {
+				log_error("Defined fall_behind_size="
 					  "%" PRIu64 " for sync replicator %s/%s.",
-					  rsite->fall_behind_data, lv->name, rsite->name);
+					  rsite->fall_behind_size, lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_timeout) {
+				log_error("Defined fall_behind_timeout="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_timeout, lv->name,
+					  rsite->name);
 				r = 0;
 			}
 		} else {
-			if (rsite->fall_behind_timeout && rsite->fall_behind_ios) {
-				log_error("Defined fall_behind_timeout and"
-					  " fall_behind_ios for async replicator %s/%s.",
+			if (rsite->fall_behind_ios && rsite->fall_behind_size) {
+				log_error("Defined fall behind ios and size "
+					  "for asynchronous replicator %s/%s.",
 					  lv->name, rsite->name);
 				r = 0;
 			}
-			if (rsite->fall_behind_timeout && rsite->fall_behind_data) {
-				log_error("Defined fall_behind_timeout and"
-					  " fall_behind_data for async replicator %s/%s.",
+			if (rsite->fall_behind_ios && rsite->fall_behind_timeout) {
+				log_error("Defined fall behind ios and timeout "
+					  "for asynchronous replicator %s/%s.",
 					  lv->name, rsite->name);
 				r = 0;
 			}
-			if (rsite->fall_behind_ios && rsite->fall_behind_data) {
-				log_error("Defined fall_behind_ios and"
-					  " fall_behind_data for async replicator %s/%s.",
+			if (rsite->fall_behind_size && rsite->fall_behind_timeout) {
+				log_error("Defined fall behind size and timeout "
+					  "for asynchronous replicator %s/%s.",
 					  lv->name, rsite->name);
 				r = 0;
 			}
 			if (!rsite->fall_behind_ios &&
-			    !rsite->fall_behind_data &&
+			    !rsite->fall_behind_size &&
 			    !rsite->fall_behind_timeout) {
-				log_error("fall_behind_timeout,"
-					  " fall_behind_ios and fall_behind_data are"
-					  " undefined for async replicator %s/%s.",
+				log_error("For asynchronous replicator %s/%s on of "
+					  "fall_behind_ios, fall_behind_size "
+					  "or fall_behind_timeout needs to be defined.",
 					  lv->name, rsite->name);
 				r = 0;
 			}
@@ -335,16 +832,16 @@ int check_replicator_segment(const struct lv_segment *rseg)
 			if (rsite == rsiteb)
 				break;
 			if (strcasecmp(rsite->name, rsiteb->name) == 0) {
-				log_error("Duplicate site name "
-					  "%s detected for replicator %s.",
+				log_error("Duplicate site name %s "
+					  "detected for replicator %s.",
 					  rsite->name, lv->name);
 				r = 0;
 			}
 			if ((rsite->vg_name && rsiteb->vg_name &&
 			     strcasecmp(rsite->vg_name, rsiteb->vg_name) == 0) ||
 			    (!rsite->vg_name && !rsiteb->vg_name)) {
-				log_error("Duplicate VG name "
-					  "%s detected for replicator %s.",
+				log_error("Duplicate VG name %s "
+					  "detected for replicator %s.",
 					  (rsite->vg_name) ? rsite->vg_name : "<local>",
 					  lv->name);
 				r = 0;
@@ -356,8 +853,8 @@ int check_replicator_segment(const struct lv_segment *rseg)
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
@@ -367,6 +864,20 @@ int check_replicator_segment(const struct lv_segment *rseg)
 		}
 
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			if (rdev->rsite->site_index == 0) {
+				if (strcasecmp(rdev->name,
+					       rdev->replicated_seg->lv->name) == 0) {
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
@@ -376,6 +887,13 @@ int check_replicator_segment(const struct lv_segment *rseg)
 						  rdev->slog->name, lv->name);
 					r = 0;
 				}
+				if (strcasecmp(rdev->name,
+					       rdevb->replicated_seg->lv->name) == 0) {
+					log_error("Internal self reference device "
+						  "name %s detected for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
 				if (strcasecmp(rdev->name, rdevb->name) == 0) {
 					log_error("Duplicate device name %s "
 						  "detected for replicator %s.",
@@ -390,9 +908,9 @@ int check_replicator_segment(const struct lv_segment *rseg)
 						  lv->name, rsite->name);
 					r = 0;
 				}
-				if (rdev->device_index > rseg->rdevice_index_highest) {
-					log_error("Device index %" PRIu64
-						  " > %" PRIu64 " (too high) "
+				if (rdev->device_index >= rseg->rdevice_index_highest) {
+					log_error("Device index %" PRIu64 " >= %"
+						  PRIu64 " (too high) "
 						  "for replicator site %s/%s.",
 						  rdev->device_index,
 						  rseg->rdevice_index_highest,
@@ -406,78 +924,29 @@ int check_replicator_segment(const struct lv_segment *rseg)
 	return r;
 }
 
-/**
- * Is this segment part of active replicator
- */
-int lv_is_active_replicator_dev(const struct logical_volume *lv)
+int replicator_site_set_policy(struct replicator_site *rsite, const char *policy)
 {
-	return ((lv->status & REPLICATOR) &&
-		lv->rdevice &&
-		lv->rdevice->rsite &&
-		lv->rdevice->rsite->state == REPLICATOR_STATE_ACTIVE);
-}
+	int i;
 
-/**
- * Is this LV replicator control device
- */
-int lv_is_replicator(const struct logical_volume *lv)
-{
-	return ((lv->status & REPLICATOR) &&
-		!dm_list_empty(&lv->segments) &&
-		seg_is_replicator(first_seg(lv)));
-}
-
-/**
- * Is this LV replicator device
- */
-int lv_is_replicator_dev(const struct logical_volume *lv)
-{
-	return ((lv->status & REPLICATOR) &&
-		!dm_list_empty(&lv->segments) &&
-		seg_is_replicator_dev(first_seg(lv)));
-}
-
-/**
- * Is this LV replicated origin lv
- */
-int lv_is_rimage(const struct logical_volume *lv)
-{
-	return (lv->rdevice && lv->rdevice->lv == lv);
-}
-
-/**
- * Is this LV rlog
- */
-int lv_is_rlog(const struct logical_volume *lv)
-{
-	return (lv->status & REPLICATOR_LOG);
-}
+	for (i = 0; i < sizeof(policy_table) / sizeof(policy_table[0]); ++i)
+		if (strcasecmp(policy, policy_table[i].name) == 0) {
+			rsite->policy = policy_table[i].value;
+			return 1;
+		}
 
-/**
- * Is this LV sync log
- */
-int lv_is_slog(const struct logical_volume *lv)
-{
-	return (lv->rdevice && lv->rdevice->slog == lv);
+	log_error("Unknown policy: %s", policy);
+	return 0;
 }
 
-/**
- * Returns first replicator-dev in site in case the LV is replicator-dev,
- * NULL otherwise
- */
-struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
+const char *replicator_site_get_policy(const struct replicator_site *rsite)
 {
-	struct replicator_device *rdev;
-	struct replicator_site *rsite;
+	int i;
 
-	if (lv_is_replicator_dev(lv))
-		dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
-			dm_list_iterate_items(rdev, &rsite->rdevices)
-				return rdev->replicator_dev->lv;
-			break;
-		}
+	for (i = 0; i < sizeof(policy_table) / sizeof(policy_table[0]); ++i)
+		if (rsite->policy == policy_table[i].value)
+			return policy_table[i].name;
 
-	return NULL;
+        return NULL;
 }
 
 /**
@@ -616,7 +1085,7 @@ int find_replicator_vgs(struct logical_volume *lv, uint32_t flags)
 	if ((flags & LCK_TYPE_MASK) == LCK_READ)
 		return 1; /* no need to check for remote vgs */
 
-	if (!lv_is_replicator_dev(lv))
+	if (!lv_is_replicated(lv))
 		return 1;
 
 	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
@@ -645,17 +1114,17 @@ int find_replicator_vgs(struct logical_volume *lv, uint32_t flags)
  */
 int lv_read_replicator_vgs(struct logical_volume *lv)
 {
-	struct replicator_device *rdev;
 	struct replicator_site *rsite;
+	struct replicated_device *rdev;
 	struct volume_group *vg;
 
-	if (!lv_is_replicator_dev(lv))
+	if (!lv_is_active_replicated(lv))
 		return 1;
 
 	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
 		if (!rsite->vg_name)
 			continue;
-		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0); // READ_WITHOUT_LOCK
+		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, READ_WITHOUT_LOCK);
 		if (vg_read_error(vg)) {
 			log_error("Unable to read volume group %s",
 				  rsite->vg_name);
@@ -685,7 +1154,7 @@ void lv_release_replicator_vgs(struct logical_volume *lv)
 {
 	struct replicator_site *rsite;
 
-	if (!lv_is_replicator_dev(lv))
+	if (!lv_is_replicated(lv))
 		return;
 
 	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
@@ -694,3 +1163,325 @@ void lv_release_replicator_vgs(struct logical_volume *lv)
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
+	if (!(lv_name = _replicated_device_slog_name(replicator, site_index, device_index)))
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
+		stack;
+		r = 0;
+	}
+
+	alloc_destroy(ah);
+
+	return r;
+}
-- 
1.7.2.1


