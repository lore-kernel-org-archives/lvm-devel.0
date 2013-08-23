From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 23 Aug 2013 16:05:07 +0000 (UTC)
Subject: master - misc: make lv_is_on_pv use for_each_sub_lv to walk LV tree
Message-ID: <20130823160507.592D960D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72d6bdd6b960d946039818684c125c3c31b7ae5e
Commit:        72d6bdd6b960d946039818684c125c3c31b7ae5e
Parent:        448ff0119fc0f4983917e10b663d9db896f8c5db
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 23 11:03:28 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 23 11:03:28 2013 -0500

misc: make lv_is_on_pv use for_each_sub_lv to walk LV tree

Make lv_is_on_pv use for_each_sub_lv to walk the LV tree.  This
reduces code duplication.
---
 lib/metadata/lv_manip.c |  126 ++++++++++++++++++++--------------------------
 1 files changed, 55 insertions(+), 71 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d2830b2..9728310 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -76,88 +76,76 @@ struct lv_names {
 	const char *new;
 };
 
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
- * Currently handles:
- *  - linear
- *  - stripe
- *  - RAID
- *  - mirror
- *  - thin-pool
- *  - thin
- *
- * FIXME:  This should be made more generic, possibly use 'for_each_sub_lv'.
- * 'for_each_sub_lv' does not yet allow us to short-circuit execution or
- * pass back the values we need yet though (i.e. it only allows success or
- * error - not true or false).
- *
- * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
- */
-int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
+struct pv_and_int {
+	struct physical_volume *pv;
+	int *i;
+};
+static int _lv_is_on_pv(struct cmd_context *cmd,
+			struct logical_volume *lv, void *data)
 {
+	int *is_on_pv = ((struct pv_and_int *)data)->i;
+	struct physical_volume *pv = ((struct pv_and_int *)data)->pv;
 	uint32_t s;
 	struct physical_volume *pv2;
 	struct lv_segment *seg;
 
-	if (!lv)
-		return 0;
-
-	seg = first_seg(lv);
-	if (!seg)
-		return 0;
-
-	/* Check mirror log */
-	if (lv_is_on_pv(seg->log_lv, pv))
-		return 1;
-
-	/* Check thin-pool metadata area */
-	if (lv_is_on_pv(seg->metadata_lv, pv))
-		return 1;
-
-	/* Check thin volume's pool LV */
-	if (lv_is_on_pv(seg->pool_lv, pv))
-		return 1;
+	if (!lv || !(seg = first_seg(lv)))
+		return_0;
 
 	/*
-	 * Do _not_ check 'external_lv.  We wouldn't count an origin's
-	 * PVs as part of a snapshot, so we don't count external_origin's
-	 * PVs as part of a thin-snap/LV
+	 * If the LV has already been found to be on the PV, then
+	 * we don't need to continue checking - just return.
 	 */
+	if (*is_on_pv)
+		return 1;
 
-	/* Check stack of LVs */
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) == AREA_PV) {
-				pv2 = seg_pv(seg, s);
-				if (id_equal(&pv->id, &pv2->id))
-					return 1;
-				if (pv->dev && pv2->dev &&
-				    (pv->dev->dev == pv2->dev->dev))
-					return 1;
-			}
-
-			if ((seg_type(seg, s) == AREA_LV) &&
-			    lv_is_on_pv(seg_lv(seg, s), pv))
-				return 1;
-
-			if (!seg_is_raid(seg))
+			if (seg_type(seg, s) != AREA_PV)
 				continue;
 
-			/* This is RAID, so we know the meta_area is AREA_LV */
-			if (lv_is_on_pv(seg_metalv(seg, s), pv))
+			pv2 = seg_pv(seg, s);
+			if (id_equal(&pv->id, &pv2->id)) {
+				*is_on_pv = 1;
+				return 1;
+			}
+			if (pv->dev && pv2->dev &&
+			    (pv->dev->dev == pv2->dev->dev)) {
+				*is_on_pv = 1;
 				return 1;
+			}
 		}
 	}
 
-	return 0;
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
+	if (!_lv_is_on_pv(lv->vg->cmd, lv, &context) ||
+	    !for_each_sub_lv(lv->vg->cmd, lv, _lv_is_on_pv, &context))
+		/* Failure only happens if bad arguments are passed */
+		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
+
+	log_debug_metadata("%s is %son %s", lv->name,
+			   is_on_pv ? "" : "not ", pv_dev_name(pv));
+	return is_on_pv;
 }
 
 /*
@@ -173,13 +161,9 @@ int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, pvs)
-		if (lv_is_on_pv(lv, pvl->pv)) {
-			log_debug_metadata("%s is on %s", lv->name,
-					   pv_dev_name(pvl->pv));
+		if (lv_is_on_pv(lv, pvl->pv))
 			return 1;
-		} else
-			log_debug_metadata("%s is not on %s", lv->name,
-					   pv_dev_name(pvl->pv));
+
 	return 0;
 }
 


