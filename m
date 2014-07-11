From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:22 +0000 (UTC)
Subject: master - pool: move code to pool source file
Message-ID: <20140711113422.39EB861381@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=120bd2d6b13fb7a297ff6cfc9fe59c0b241ab46f
Commit:        120bd2d6b13fb7a297ff6cfc9fe59c0b241ab46f
Parent:        4db5d78cefa99c053ba1f0bf73aa0eb55cafb279
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 8 15:19:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:57:25 2014 +0200

pool: move code to pool source file

More code is used commonly for all pool types (cache & thin)
---
 lib/metadata/pool_manip.c |  233 +++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/thin_manip.c |  230 --------------------------------------------
 2 files changed, 233 insertions(+), 230 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index ab52ff1..e32b109 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -23,6 +23,7 @@
 #include "segtype.h"
 #include "lv_alloc.h"
 #include "defaults.h"
+#include "display.h"
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
@@ -41,6 +42,26 @@ int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 	return add_seg_to_segs_using_this_lv(metadata_lv, pool_seg);
 }
 
+int detach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume **metadata_lv)
+{
+	struct logical_volume *lv = pool_seg->metadata_lv;
+
+	if (!lv ||
+	    !lv_is_pool_metadata(lv) ||
+	    !remove_seg_from_segs_using_this_lv(lv, pool_seg)) {
+		log_error(INTERNAL_ERROR "Logical volume %s is not valid pool.",
+			  display_lvname(pool_seg->lv));
+		return 0;
+	}
+
+	lv_set_visible(lv);
+	lv->status &= ~(THIN_POOL_METADATA | CACHE_POOL_METADATA);
+	*metadata_lv = lv;
+	pool_seg->metadata_lv = NULL;
+
+	return 1;
+}
+
 int attach_pool_data_lv(struct lv_segment *pool_seg,
 			struct logical_volume *pool_data_lv)
 {
@@ -326,3 +347,215 @@ bad:
 
 	return 0;
 }
+
+struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
+					   const char *name, uint32_t read_ahead,
+					   uint32_t stripes, uint32_t stripe_size,
+					   uint64_t size, alloc_policy_t alloc,
+					   struct dm_list *pvh)
+{
+	struct logical_volume *metadata_lv;
+	/* FIXME: Make lvm2api usable */
+	struct lvcreate_params lvc = {
+		.activate = CHANGE_ALY,
+		.alloc = alloc,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = pvh,
+		.read_ahead = read_ahead,
+		.stripe_size = stripe_size,
+		.stripes = stripes,
+		.zero = 1,
+	};
+
+	dm_list_init(&lvc.tags);
+
+	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
+					      pool_lv->vg->extent_size)))
+		return_0;
+
+	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+		return_0;
+
+	/* FIXME: allocate properly space for metadata_lv */
+
+	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
+		return_0;
+
+	if (!lv_rename_update(pool_lv->vg->cmd, metadata_lv, name, 0))
+		return_0;
+
+	return metadata_lv;
+}
+
+static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg,
+							 uint32_t extents,
+							 struct dm_list *pvh)
+{
+	struct logical_volume *lv;
+
+	/* FIXME: Make lvm2api usable */
+	struct lvcreate_params lp = {
+		.activate = CHANGE_ALY,
+		.alloc = ALLOC_INHERIT,
+		.extents = extents,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = pvh ? : &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_AUTO,
+		.stripes = 1,
+		.zero = 1,
+		.temporary = 1,
+	};
+
+	dm_list_init(&lp.tags);
+
+	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
+		return_0;
+
+	/* FIXME: Maybe using silent mode ? */
+	if (!(lv = lv_create_single(vg, &lp)))
+		return_0;
+
+	/* Spare LV should not be active */
+	if (!deactivate_lv_local(vg->cmd, lv)) {
+		log_error("Unable to deactivate pool metadata spare LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (!vg_set_pool_metadata_spare(lv))
+		return_0;
+
+	return lv;
+}
+
+/*
+ * Create/resize pool metadata spare LV
+ * Caller does vg_write(), vg_commit() with pool creation
+ * extents is 0, max size is determined
+ */
+int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
+			       struct dm_list *pvh, int poolmetadataspare)
+{
+	struct logical_volume *lv = vg->pool_metadata_spare_lv;
+	uint32_t seg_mirrors;
+	struct lv_segment *seg;
+	const struct lv_list *lvl;
+
+	if (!extents)
+		/* Find maximal size of metadata LV */
+		dm_list_iterate_items(lvl, &vg->lvs)
+			if (lv_is_pool_metadata(lvl->lv) &&
+			    (lvl->lv->le_count > extents))
+				extents = lvl->lv->le_count;
+
+	if (!poolmetadataspare) {
+		/* TODO: Not showing when lvm.conf would define 'n' ? */
+		if (DEFAULT_POOL_METADATA_SPARE && extents)
+			/* Warn if there would be any user */
+			log_warn("WARNING: recovery of pools without pool "
+				 "metadata spare LV is not automated.");
+		return 1;
+	}
+
+	if (!lv) {
+		if (!_alloc_pool_metadata_spare(vg, extents, pvh))
+			return_0;
+
+		return 1;
+	}
+
+	seg = last_seg(lv);
+	seg_mirrors = lv_mirror_count(lv);
+
+	/* Check spare LV is big enough and preserve segtype */
+	if ((lv->le_count < extents) && seg &&
+	    !lv_extend(lv, seg->segtype,
+		       seg->area_count / seg_mirrors,
+		       seg->stripe_size,
+		       seg_mirrors,
+		       seg->region_size,
+		       extents - lv->le_count, NULL,
+		       pvh, lv->alloc, 0))
+		return_0;
+
+	return 1;
+}
+
+int vg_set_pool_metadata_spare(struct logical_volume *lv)
+{
+	char new_name[NAME_LEN];
+	struct volume_group *vg = lv->vg;
+
+	if (vg->pool_metadata_spare_lv) {
+		if (vg->pool_metadata_spare_lv == lv)
+			return 1;
+		if (!vg_remove_pool_metadata_spare(vg))
+			return_0;
+	}
+
+	if (dm_snprintf(new_name, sizeof(new_name), "%s_pmspare", lv->name) < 0) {
+		log_error("Can't create pool metadata spare. Name of pool LV "
+			  "%s is too long.", lv->name);
+		return 0;
+	}
+
+	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
+		return_0;
+
+	lv_set_hidden(lv);
+	lv->status |= POOL_METADATA_SPARE;
+	vg->pool_metadata_spare_lv = lv;
+
+	return 1;
+}
+
+int vg_remove_pool_metadata_spare(struct volume_group *vg)
+{
+	char new_name[NAME_LEN];
+	char *c;
+
+	struct logical_volume *lv = vg->pool_metadata_spare_lv;
+
+	if (!(lv->status & POOL_METADATA_SPARE)) {
+		log_error(INTERNAL_ERROR "LV %s is not pool metadata spare.",
+			  lv->name);
+		return 0;
+	}
+
+	vg->pool_metadata_spare_lv = NULL;
+	lv->status &= ~POOL_METADATA_SPARE;
+	lv_set_visible(lv);
+
+	/* Cut off suffix _pmspare */
+	(void) dm_strncpy(new_name, lv->name, sizeof(new_name));
+	if (!(c = strchr(new_name, '_'))) {
+		log_error(INTERNAL_ERROR "LV %s has no suffix for pool metadata spare.",
+			  new_name);
+		return 0;
+	}
+	*c = 0;
+
+	/* If the name is in use, generate new lvol%d */
+	if (find_lv_in_vg(vg, new_name) &&
+	    !generate_lv_name(vg, "lvol%d", new_name, sizeof(new_name))) {
+		log_error("Failed to generate unique name for "
+			  "pool metadata spare logical volume.");
+		return 0;
+	}
+
+	log_print_unless_silent("Renaming existing pool metadata spare "
+				"logical volume \"%s/%s\" to \"%s/%s\".",
+                                vg->name, lv->name, vg->name, new_name);
+
+	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
+		return_0;
+
+	/* To display default warning */
+	(void) handle_pool_metadata_spare(vg, 0, 0, 0);
+
+	return 1;
+}
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b2ebaa1..33ab31c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -20,24 +20,6 @@
 #include "defaults.h"
 #include "display.h"
 
-int detach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume **metadata_lv)
-{
-	struct logical_volume *lv = pool_seg->metadata_lv;
-
-	if (!lv || !lv_is_thin_pool_metadata(lv) ||
-	    !remove_seg_from_segs_using_this_lv(lv, pool_seg)) {
-		log_error(INTERNAL_ERROR "LV %s is invalid thin pool.", pool_seg->lv->name);
-		return 0;
-	}
-
-	lv_set_visible(lv);
-	lv->status &= ~THIN_POOL_METADATA;
-	*metadata_lv = lv;
-	pool_seg->metadata_lv = NULL;
-
-	return 1;
-}
-
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
 			int no_update)
@@ -540,215 +522,3 @@ const char *get_pool_discards_name(thin_discards_t discards)
 
 	return "unknown";
 }
-
-struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
-					   const char *name, uint32_t read_ahead,
-					   uint32_t stripes, uint32_t stripe_size,
-					   uint64_t size, alloc_policy_t alloc,
-					   struct dm_list *pvh)
-{
-	struct logical_volume *metadata_lv;
-	/* FIXME: Make lvm2api usable */
-	struct lvcreate_params lvc = {
-		.activate = CHANGE_ALY,
-		.alloc = alloc,
-		.major = -1,
-		.minor = -1,
-		.permission = LVM_READ | LVM_WRITE,
-		.pvh = pvh,
-		.read_ahead = read_ahead,
-		.stripe_size = stripe_size,
-		.stripes = stripes,
-		.zero = 1,
-	};
-
-	dm_list_init(&lvc.tags);
-
-	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
-					      pool_lv->vg->extent_size)))
-		return_0;
-
-	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
-		return_0;
-
-	/* FIXME: allocate properly space for metadata_lv */
-
-	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
-		return_0;
-
-	if (!lv_rename_update(pool_lv->vg->cmd, metadata_lv, name, 0))
-		return_0;
-
-	return metadata_lv;
-}
-
-static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg,
-							 uint32_t extents,
-							 struct dm_list *pvh)
-{
-	struct logical_volume *lv;
-
-	/* FIXME: Make lvm2api usable */
-	struct lvcreate_params lp = {
-		.activate = CHANGE_ALY,
-		.alloc = ALLOC_INHERIT,
-		.extents = extents,
-		.major = -1,
-		.minor = -1,
-		.permission = LVM_READ | LVM_WRITE,
-		.pvh = pvh ? : &vg->pvs,
-		.read_ahead = DM_READ_AHEAD_AUTO,
-		.stripes = 1,
-		.zero = 1,
-		.temporary = 1,
-	};
-
-	dm_list_init(&lp.tags);
-
-	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
-		return_0;
-
-	/* FIXME: Maybe using silent mode ? */
-	if (!(lv = lv_create_single(vg, &lp)))
-		return_0;
-
-	/* Spare LV should not be active */
-	if (!deactivate_lv_local(vg->cmd, lv)) {
-		log_error("Unable to deactivate pool metadata spare LV. "
-			  "Manual intervention required.");
-		return 0;
-	}
-
-	if (!vg_set_pool_metadata_spare(lv))
-		return_0;
-
-	return lv;
-}
-
-/*
- * Create/resize pool metadata spare LV
- * Caller does vg_write(), vg_commit() with pool creation
- * extents is 0, max size is determined
- */
-int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
-			       struct dm_list *pvh, int poolmetadataspare)
-{
-	struct logical_volume *lv = vg->pool_metadata_spare_lv;
-	uint32_t seg_mirrors;
-	struct lv_segment *seg;
-	const struct lv_list *lvl;
-
-	if (!extents)
-		/* Find maximal size of metadata LV */
-		dm_list_iterate_items(lvl, &vg->lvs)
-			if (lv_is_thin_pool_metadata(lvl->lv) &&
-			    (lvl->lv->le_count > extents))
-				extents = lvl->lv->le_count;
-
-	if (!poolmetadataspare) {
-		/* TODO: Not showing when lvm.conf would define 'n' ? */
-		if (DEFAULT_POOL_METADATA_SPARE && extents)
-			/* Warn if there would be any user */
-			log_warn("WARNING: recovery of pools without pool "
-				 "metadata spare LV is not automated.");
-		return 1;
-	}
-
-	if (!lv) {
-		if (!_alloc_pool_metadata_spare(vg, extents, pvh))
-			return_0;
-
-		return 1;
-	}
-
-	seg = last_seg(lv);
-	seg_mirrors = lv_mirror_count(lv);
-
-	/* Check spare LV is big enough and preserve segtype */
-	if ((lv->le_count < extents) && seg &&
-	    !lv_extend(lv, seg->segtype,
-		       seg->area_count / seg_mirrors,
-		       seg->stripe_size,
-		       seg_mirrors,
-		       seg->region_size,
-		       extents - lv->le_count, NULL,
-		       pvh, lv->alloc, 0))
-		return_0;
-
-	return 1;
-}
-
-int vg_set_pool_metadata_spare(struct logical_volume *lv)
-{
-	char new_name[NAME_LEN];
-	struct volume_group *vg = lv->vg;
-
-	if (vg->pool_metadata_spare_lv) {
-		if (vg->pool_metadata_spare_lv == lv)
-			return 1;
-		if (!vg_remove_pool_metadata_spare(vg))
-			return_0;
-	}
-
-	if (dm_snprintf(new_name, sizeof(new_name), "%s_pmspare", lv->name) < 0) {
-		log_error("Can't create pool metadata spare. Name of pool LV "
-			  "%s is too long.", lv->name);
-		return 0;
-	}
-
-	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
-		return_0;
-
-	lv_set_hidden(lv);
-	lv->status |= POOL_METADATA_SPARE;
-	vg->pool_metadata_spare_lv = lv;
-
-	return 1;
-}
-
-int vg_remove_pool_metadata_spare(struct volume_group *vg)
-{
-	char new_name[NAME_LEN];
-	char *c;
-
-	struct logical_volume *lv = vg->pool_metadata_spare_lv;
-
-	if (!(lv->status & POOL_METADATA_SPARE)) {
-		log_error(INTERNAL_ERROR "LV %s is not pool metadata spare.",
-			  lv->name);
-		return 0;
-	}
-
-	vg->pool_metadata_spare_lv = NULL;
-	lv->status &= ~POOL_METADATA_SPARE;
-	lv_set_visible(lv);
-
-	/* Cut off suffix _pmspare */
-	(void) dm_strncpy(new_name, lv->name, sizeof(new_name));
-	if (!(c = strchr(new_name, '_'))) {
-		log_error(INTERNAL_ERROR "LV %s has no suffix for pool metadata spare.",
-			  new_name);
-		return 0;
-	}
-	*c = 0;
-
-	/* If the name is in use, generate new lvol%d */
-	if (find_lv_in_vg(vg, new_name) &&
-	    !generate_lv_name(vg, "lvol%d", new_name, sizeof(new_name))) {
-		log_error("Failed to generate unique name for "
-			  "pool metadata spare logical volume.");
-		return 0;
-	}
-
-	log_print_unless_silent("Renaming existing pool metadata spare "
-				"logical volume \"%s/%s\" to \"%s/%s\".",
-                                vg->name, lv->name, vg->name, new_name);
-
-	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
-		return_0;
-
-	/* To display default warning */
-	(void) handle_pool_metadata_spare(vg, 0, 0, 0);
-
-	return 1;
-}


