From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:57 +0000 (UTC)
Subject: master - cleanup: code move
Message-ID: <20141024144057.A306760CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16320642813c811c30c9348c57b7f7fec1221ee9
Commit:        16320642813c811c30c9348c57b7f7fec1221ee9
Parent:        b23e125982ea5f1c4b712a31b2133526a8fc12d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 13:53:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

cleanup: code move

Update comment and move code to new place.
Gets updated with next commit.
---
 tools/lvcreate.c |  196 +++++++++++++++++++++++++++---------------------------
 1 files changed, 98 insertions(+), 98 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8c52611..301bda6 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -231,104 +231,6 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 }
 
 /*
- * Normal snapshot or thinly-provisioned snapshot?
- */
-static int _determine_snapshot_type(struct volume_group *vg,
-				    struct lvcreate_params *lp)
-{
-	struct logical_volume *lv, *pool_lv = NULL;
-
-	if (!(lv = find_lv(vg, lp->origin_name))) {
-		log_error("Snapshot origin LV %s not found in Volume group %s.",
-			  lp->origin_name, vg->name);
-		return 0;
-	}
-
-	if (lv_is_cache(lv)) {
-		log_error("Snapshot of cache LV is not yet supported.");
-		return 0;
-	}
-
-	if (lp->pool_name) {
-		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
-			log_error("Thin pool volume %s not found in Volume group %s.",
-				  lp->pool_name, vg->name);
-			return 0;
-		}
-
-		if (!lv_is_thin_pool(pool_lv)) {
-			log_error("Logical volume %s is not a thin pool volume.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
-	}
-
-	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
-		if (lv_is_thin_volume(lv) && !lp->pool_name)
-			lp->pool_name = first_seg(lv)->pool_lv->name;
-
-		if (seg_is_thin(lp) || lp->pool_name) {
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-				return_0;
-			return 1;
-		}
-
-		log_error("Please specify either size or extents with snapshots.");
-		return 0;
-	} else if (lp->pool_name) {
-		log_error("Cannot specify size with thin pool snapshot.");
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * _determine_cache_argument
- * @vg
- * @lp
- *
- * 'lp->pool' is set with an LV that could be either the cache_pool
- * or the origin of the cached LV which is being created.  This
- * function determines which it is and sets 'lp->origin' or
- * 'lp->pool' appropriately.
- */
-static int _determine_cache_argument(struct volume_group *vg,
-				     struct lvcreate_params *lp)
-{
-	struct logical_volume *lv;
-
-	if (!seg_is_cache(lp)) {
-		log_error(INTERNAL_ERROR
-			  "Unable to determine cache argument on %s segtype",
-			  lp->segtype->name);
-		return 0;
-	}
-
-	if (!lp->pool_name) {
-		lp->pool_name = lp->lv_name;
-	} else if (lp->pool_name == lp->origin_name) {
-		if (!(lv = find_lv(vg, lp->pool_name))) {
-			/* Cache pool nor origin volume exists */
-			lp->cache = 0;
-			lp->origin_name = NULL;
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
-				return_0;
-		} else if (!lv_is_cache_pool(lv)) {
-			/* Name arg in this case is for pool name */
-			lp->pool_name = lp->lv_name;
-			/* We were given origin for caching */
-		} else {
-			/* FIXME error on pool args */
-			lp->create_pool = 0;
-			lp->origin_name = NULL;
-		}
-	}
-
-	return 1;
-}
-
-/*
  * Update extents parameters based on other parameters which affect the size
  * calculation.
  * NOTE: We must do this here because of the dm_percent_t typedef and because we
@@ -1064,6 +966,104 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	return 1;
 }
 
+/*
+ * _determine_cache_argument
+ * @vg
+ * @lp
+ *
+ * 'lp->pool_name' is set with an LV that could be either the cache_pool name
+ * or the origin name of the cached LV which is being created.
+ * This function determines which it is and sets 'lp->origin_name' or
+ * 'lp->pool_name' appropriately.
+ */
+static int _determine_cache_argument(struct volume_group *vg,
+				     struct lvcreate_params *lp)
+{
+	struct logical_volume *lv;
+
+	if (!seg_is_cache(lp)) {
+		log_error(INTERNAL_ERROR
+			  "Unable to determine cache argument on %s segtype",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	if (!lp->pool_name) {
+		lp->pool_name = lp->lv_name;
+	} else if (lp->pool_name == lp->origin_name) {
+		if (!(lv = find_lv(vg, lp->pool_name))) {
+			/* Cache pool nor origin volume exists */
+			lp->cache = 0;
+			lp->origin_name = NULL;
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
+				return_0;
+		} else if (!lv_is_cache_pool(lv)) {
+			/* Name arg in this case is for pool name */
+			lp->pool_name = lp->lv_name;
+			/* We were given origin for caching */
+		} else {
+			/* FIXME error on pool args */
+			lp->create_pool = 0;
+			lp->origin_name = NULL;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Normal snapshot or thinly-provisioned snapshot?
+ */
+static int _determine_snapshot_type(struct volume_group *vg,
+				    struct lvcreate_params *lp)
+{
+	struct logical_volume *lv, *pool_lv = NULL;
+
+	if (!(lv = find_lv(vg, lp->origin_name))) {
+		log_error("Snapshot origin LV %s not found in Volume group %s.",
+			  lp->origin_name, vg->name);
+		return 0;
+	}
+
+	if (lv_is_cache(lv)) {
+		log_error("Snapshot of cache LV is not yet supported.");
+		return 0;
+	}
+
+	if (lp->pool_name) {
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
+			log_error("Thin pool volume %s not found in Volume group %s.",
+				  lp->pool_name, vg->name);
+			return 0;
+		}
+
+		if (!lv_is_thin_pool(pool_lv)) {
+			log_error("Logical volume %s is not a thin pool volume.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+	}
+
+	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
+		if (lv_is_thin_volume(lv) && !lp->pool_name)
+			lp->pool_name = first_seg(lv)->pool_lv->name;
+
+		if (seg_is_thin(lp) || lp->pool_name) {
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+				return_0;
+			return 1;
+		}
+
+		log_error("Please specify either size or extents with snapshots.");
+		return 0;
+	} else if (lp->pool_name) {
+		log_error("Cannot specify size with thin pool snapshot.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_params *lp,
 				  struct lvcreate_cmdline_params *lcp)
 {


