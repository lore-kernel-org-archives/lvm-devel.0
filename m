From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Feb 2010 16:04:21 -0500
Subject: [PATCH 2/3] Introduce find_shared_cow() and lv_is_shared_cow() wrappers.
In-Reply-To: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
References: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
Message-ID: <1267218262-23954-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c       |   11 +++++----
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/snapshot_manip.c    |   39 ++++++++++++++++++++++++++++++-------
 lib/report/report.c              |    8 +++---
 tools/lvresize.c                 |    3 +-
 5 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 47de5d9..0d4a01e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1211,8 +1211,8 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
 		}
 		if (!dm_tree_node_add_snapshot_shared_target(dnode, lv->size,
 				real_dlid, cow_dlid,
-				lv->shared_snapshot->exception_store,
-				lv->shared_snapshot->chunk_size,
+				find_shared_cow(lv)->exception_store,
+				find_shared_cow(lv)->chunk_size,
 				n, snapids))
 			return_0;
 	} else {
@@ -1261,7 +1261,7 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (snap_seg->status & SNAPSHOT_SHARED)
+	if (lv_is_shared_cow(lv))
 		return 1;
 
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
@@ -1346,7 +1346,8 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 			return 0;
 		}
 		if (lv_is_multisnap_origin(seg->lv)) {
-			if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->shared_snapshot->cow, seg->lv, "cow"))
+			if (!_add_new_lv_to_dtree(dm, dtree,
+			    find_shared_cow(seg->lv)->cow, seg->lv, "cow"))
 				return_0;
 		} else if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
@@ -1432,7 +1433,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
-	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_SHARED && !layer)
+	if (lv_is_shared_cow(lv) && !layer)
 		return 1;
 
 	if (!identity_lv)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5e5bcb7..c6ad213 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -633,6 +633,7 @@ int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
 int lv_is_multisnap_origin(const struct logical_volume *lv);
 int lv_is_multisnap_cow(const struct logical_volume *lv);
+int lv_is_shared_cow(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
@@ -641,6 +642,8 @@ int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
 struct lv_segment *find_merging_cow(const struct logical_volume *origin);
 
+struct lv_segment *find_shared_cow(const struct logical_volume *origin);
+
 /* Given a cow LV, return return the snapshot lv_segment that uses it */
 struct lv_segment *find_cow(const struct logical_volume *lv);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 717b11a..66adfeb 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -41,6 +41,11 @@ int lv_is_multisnap_cow(const struct logical_volume *lv)
 	return seg && seg_is_virtual(seg) && seg->origin;
 }
 
+int lv_is_shared_cow(const struct logical_volume *lv)
+{
+	return lv_is_cow(lv) && (find_cow(lv)->status & SNAPSHOT_SHARED);
+}
+
 int lv_is_visible(const struct logical_volume *lv)
 {
 	if (lv->status & SNAPSHOT)
@@ -89,12 +94,31 @@ struct lv_segment *find_cow(const struct logical_volume *lv)
 	return lv->snapshot;
 }
 
+struct lv_segment *find_shared_cow(const struct logical_volume *origin)
+{
+	if (!lv_is_multisnap_origin(origin))
+		return NULL;
+
+	return origin->shared_snapshot;
+}
+
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 {
 	return lv->snapshot->origin;
 }
 
+static void init_shared_snapshot(struct lv_segment *cow_seg,
+				 struct logical_volume *origin)
+{
+	origin->shared_snapshot = cow_seg;
+}
+
+static void clear_shared_snapshot(struct logical_volume *origin)
+{
+	origin->shared_snapshot = NULL;
+}
+
 int init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		      struct logical_volume *cow, const char *exception_store,
 		      uint32_t chunk_size, int merge)
@@ -128,12 +152,11 @@ int init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		init_snapshot_merge(seg, origin);
 
 	if (seg->status & SNAPSHOT_SHARED) {
-		if (!origin->shared_snapshot) {
-			origin->shared_snapshot = seg;
-		} else {
-			log_err("Origin '%s' has already a shared snapshot.", origin->name);
+		if (lv_is_multisnap_origin(origin)) {
+			log_err("Origin '%s' already has a shared snapshot.", origin->name);
 			return_0;
 		}
+		init_shared_snapshot(seg, origin);
 	}
 
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
@@ -189,8 +212,8 @@ int vg_add_snapshot(struct logical_volume *origin,
 		return 0;
 	}
 
-	if (snapshot_flags & SNAPSHOT_SHARED && origin->shared_snapshot) {
-		log_error("Origin has already a shared snapshot.");
+	if (snapshot_flags & SNAPSHOT_SHARED && lv_is_multisnap_origin(origin)) {
+		log_error("Origin already has a shared snapshot.");
 		return 0;
 	}
 
@@ -228,8 +251,8 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		preload_origin = 1;
 	}
 
-	if (cow->snapshot->origin->shared_snapshot == cow->snapshot)
-		cow->snapshot->origin->shared_snapshot = NULL;
+	if (find_shared_cow(origin) == find_cow(cow))
+		clear_shared_snapshot(origin);
 
 	if (!lv_remove(cow->snapshot->lv)) {
 		log_error("Failed to remove internal snapshot LV %s",
diff --git a/lib/report/report.c b/lib/report/report.c
index 51ba7bc..f3f7209 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -383,8 +383,8 @@ static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 		repstr[5] = '-';
 	}
 
-	if (lv_is_cow(lv) && lv->snapshot->status & SNAPSHOT_SHARED)
-		lv = lv->snapshot->origin;
+	if (lv_is_shared_cow(lv))
+		lv = origin_from_cow(lv);
 	else if (lv_is_multisnap_cow(lv))
 		lv = first_seg(lv)->origin;
 	else
@@ -1044,8 +1044,8 @@ report_empty:
 		return 1;
 	}
 
-	if (lv->snapshot->status & SNAPSHOT_SHARED)
-		lv = lv->snapshot->origin;
+	if (lv_is_shared_cow(lv))
+		lv = origin_from_cow(lv);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)
 		goto report_empty;
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 7df48d3..60e30b2 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -575,8 +575,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return ECMD_FAILED;
 		}
 	}
-	if (lp->resize == LV_REDUCE &&
-	    lv_is_cow(lv) && lv->snapshot->status & SNAPSHOT_SHARED) {
+	if (lp->resize == LV_REDUCE && lv_is_shared_cow(lv)) {
 		log_error("Shared snapshot cannot be reduced.");
 		return ECMD_FAILED;
 	}
-- 
1.6.5.2


