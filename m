From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:52 +0000 (UTC)
Subject: master - cleanup: relocate function to vg.c
Message-ID: <20160211173952.6D76060365@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=032cf8ade6904df38b25453d94169ae17fac003a
Commit:        032cf8ade6904df38b25453d94169ae17fac003a
Parent:        acf7815acaceb32133bcdf8160260622c2df2f82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 12:53:54 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:06 2016 +0100

cleanup: relocate function to vg.c

---
 lib/metadata/lv.c       |   92 +++++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c |  137 -----------------------------------------------
 lib/metadata/vg.c       |   45 +++++++++++++++
 3 files changed, 137 insertions(+), 137 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9f745ca..c4e3437 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -347,6 +347,98 @@ uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 	return info.read_ahead;
 }
 
+struct pv_and_int {
+	struct physical_volume *pv;
+	int *i;
+};
+
+static int _lv_is_on_pv(struct logical_volume *lv, void *data)
+{
+	int *is_on_pv = ((struct pv_and_int *)data)->i;
+	struct physical_volume *pv = ((struct pv_and_int *)data)->pv;
+	uint32_t s;
+	struct physical_volume *pv2;
+	struct lv_segment *seg;
+
+	if (!lv || !(first_seg(lv)))
+		return_0;
+
+	/*
+	 * If the LV has already been found to be on the PV, then
+	 * we don't need to continue checking - just return.
+	 */
+	if (*is_on_pv)
+		return 1;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV)
+				continue;
+
+			pv2 = seg_pv(seg, s);
+			if (id_equal(&pv->id, &pv2->id)) {
+				*is_on_pv = 1;
+				return 1;
+			}
+			if (pv->dev && pv2->dev &&
+			    (pv->dev->dev == pv2->dev->dev)) {
+				*is_on_pv = 1;
+				return 1;
+			}
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * lv_is_on_pv
+ * @lv:
+ * @pv:
+ *
+ * If any of the component devices of the LV are on the given PV, 1
+ * is returned; otherwise 0.  For example if one of the images of a RAID
+ * (or its metadata device) is on the PV, 1 would be returned for the
+ * top-level LV.
+ * If you wish to check the images themselves, you should pass them.
+ *
+ * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
+ */
+int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
+{
+	int is_on_pv = 0;
+	struct pv_and_int context = { pv, &is_on_pv };
+
+	if (!_lv_is_on_pv(lv, &context) ||
+	    !for_each_sub_lv(lv, _lv_is_on_pv, &context))
+		/* Failure only happens if bad arguments are passed */
+		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
+
+	log_debug_metadata("%s is %son %s", lv->name,
+			   is_on_pv ? "" : "not ", pv_dev_name(pv));
+	return is_on_pv;
+}
+
+/*
+ * lv_is_on_pvs
+ * @lv
+ * @pvs
+ *
+ * Returns 1 if the LV (or part of the LV) is on any of the pvs
+ * in the list, 0 otherwise.
+ */
+int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, pvs)
+		if (lv_is_on_pv(lv, pvl->pv))
+			return 1;
+
+	return 0;
+}
+
+
 struct logical_volume *lv_origin_lv(const struct logical_volume *lv)
 {
 	struct logical_volume *origin = NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6c6a03c..d5105e1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -82,11 +82,6 @@ struct lv_names {
 	const char *new;
 };
 
-struct pv_and_int {
-	struct physical_volume *pv;
-	int *i;
-};
-
 enum {
 	LV_TYPE_UNKNOWN,
 	LV_TYPE_PUBLIC,
@@ -569,93 +564,6 @@ bad:
 
 	return 0;
 }
-
-static int _lv_is_on_pv(struct logical_volume *lv, void *data)
-{
-	int *is_on_pv = ((struct pv_and_int *)data)->i;
-	struct physical_volume *pv = ((struct pv_and_int *)data)->pv;
-	uint32_t s;
-	struct physical_volume *pv2;
-	struct lv_segment *seg;
-
-	if (!lv || !(first_seg(lv)))
-		return_0;
-
-	/*
-	 * If the LV has already been found to be on the PV, then
-	 * we don't need to continue checking - just return.
-	 */
-	if (*is_on_pv)
-		return 1;
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV)
-				continue;
-
-			pv2 = seg_pv(seg, s);
-			if (id_equal(&pv->id, &pv2->id)) {
-				*is_on_pv = 1;
-				return 1;
-			}
-			if (pv->dev && pv2->dev &&
-			    (pv->dev->dev == pv2->dev->dev)) {
-				*is_on_pv = 1;
-				return 1;
-			}
-		}
-	}
-
-	return 1;
-}
-
-/*
- * lv_is_on_pv
- * @lv:
- * @pv:
- *
- * If any of the component devices of the LV are on the given PV, 1
- * is returned; otherwise 0.  For example if one of the images of a RAID
- * (or its metadata device) is on the PV, 1 would be returned for the
- * top-level LV.
- * If you wish to check the images themselves, you should pass them.
- *
- * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
- */
-int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
-{
-	int is_on_pv = 0;
-	struct pv_and_int context = { pv, &is_on_pv };
-
-	if (!_lv_is_on_pv(lv, &context) ||
-	    !for_each_sub_lv(lv, _lv_is_on_pv, &context))
-		/* Failure only happens if bad arguments are passed */
-		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
-
-	log_debug_metadata("%s is %son %s", lv->name,
-			   is_on_pv ? "" : "not ", pv_dev_name(pv));
-	return is_on_pv;
-}
-
-/*
- * lv_is_on_pvs
- * @lv
- * @pvs
- *
- * Returns 1 if the LV (or part of the LV) is on any of the pvs
- * in the list, 0 otherwise.
- */
-int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
-{
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, pvs)
-		if (lv_is_on_pv(lv, pvl->pv))
-			return 1;
-
-	return 0;
-}
-
 struct dm_list_and_mempool {
 	struct dm_list *list;
 	struct dm_pool *mem;
@@ -5395,20 +5303,6 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 	return buffer;
 }
 
-int vg_max_lv_reached(struct volume_group *vg)
-{
-	if (!vg->max_lv)
-		return 0;
-
-	if (vg->max_lv > vg_visible_lvs(vg))
-		return 0;
-
-	log_verbose("Maximum number of logical volumes (%u) reached "
-		    "in volume group %s", vg->max_lv, vg->name);
-
-	return 1;
-}
-
 struct logical_volume *alloc_lv(struct dm_pool *mem)
 {
 	struct logical_volume *lv;
@@ -5598,37 +5492,6 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 	return parallel_areas;
 }
 
-int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv)
-{
-	struct lv_list *lvl;
-
-	if (vg_max_lv_reached(vg))
-		stack;
-
-	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
-		return_0;
-
-	lvl->lv = lv;
-	lv->vg = vg;
-	dm_list_add(&vg->lvs, &lvl->list);
-	lv->status &= ~LV_REMOVED;
-
-	return 1;
-}
-
-int unlink_lv_from_vg(struct logical_volume *lv)
-{
-	struct lv_list *lvl;
-
-	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
-		return_0;
-
-	dm_list_move(&lv->vg->removed_lvs, &lvl->list);
-	lv->status |= LV_REMOVED;
-
-	return 1;
-}
-
 void lv_set_visible(struct logical_volume *lv)
 {
 	if (lv_is_visible(lv))
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index f1005e7..59af13e 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -117,6 +117,51 @@ void free_orphan_vg(struct volume_group *vg)
 	_free_vg(vg);
 }
 
+int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (vg_max_lv_reached(vg))
+		stack;
+
+	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
+		return_0;
+
+	lvl->lv = lv;
+	lv->vg = vg;
+	dm_list_add(&vg->lvs, &lvl->list);
+	lv->status &= ~LV_REMOVED;
+
+	return 1;
+}
+
+int unlink_lv_from_vg(struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
+		return_0;
+
+	dm_list_move(&lv->vg->removed_lvs, &lvl->list);
+	lv->status |= LV_REMOVED;
+
+	return 1;
+}
+
+int vg_max_lv_reached(struct volume_group *vg)
+{
+	if (!vg->max_lv)
+		return 0;
+
+	if (vg->max_lv > vg_visible_lvs(vg))
+		return 0;
+
+	log_verbose("Maximum number of logical volumes (%u) reached "
+		    "in volume group %s", vg->max_lv, vg->name);
+
+	return 1;
+}
+
 char *vg_fmt_dup(const struct volume_group *vg)
 {
 	if (!vg->fid || !vg->fid->fmt)


