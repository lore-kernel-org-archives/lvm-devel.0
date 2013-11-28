From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:40 +0000 (UTC)
Subject: master - snapshot: drop find_merging_snapshot
Message-ID: <20131128114840.B8A0160F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79991aa7699587b40946d029787b38ae67405336
Commit:        79991aa7699587b40946d029787b38ae67405336
Parent:        01c438a96c82bf31ccda0721707fc90afa01a07e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 11:39:38 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:42:43 2013 +0100

snapshot: drop find_merging_snapshot

Drop find_merging_snapshot() function. Use find_snapshot()
called after check for lv_is_merging_origin() which
is the commonly used code path - so we avoid duplicated
tests and potential risk of derefering NULL point
in unhandled error path.
---
 lib/activate/dev_manager.c       |   12 ++++++------
 lib/metadata/metadata-exported.h |    2 --
 lib/metadata/snapshot_manip.c    |   11 ++---------
 tools/lvconvert.c                |    9 +++++----
 4 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f8027d4..e53273d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2047,9 +2047,9 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 					       struct logical_volume *lv)
 {
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
-	struct lv_segment *merging_snap_seg;
+	struct lv_segment *merging_snap_seg = find_snapshot(lv);
 
-	if (!(merging_snap_seg = find_merging_snapshot(lv))) {
+	if (!lv_is_merging_origin(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not merging snapshot.", lv->name);
 		return 0;
 	}
@@ -2374,7 +2374,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
 
-	if (lv_is_origin(lv) && lv_is_merging_origin(lv) && !layer) {
+	if (!layer && lv_is_merging_origin(lv)) {
+		seg = find_snapshot(lv);
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
 		 * either origin or merging snapshot are open
@@ -2385,8 +2386,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* An activating merging origin won't have a node in the tree yet */
 		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
 		     dinfo->open_count) ||
-		    ((dinfo = _cached_info(dm->mem, dtree,
-					   find_merging_snapshot(lv)->cow, NULL)) &&
+		    ((dinfo = _cached_info(dm->mem, dtree, seg->cow, NULL)) &&
 		     dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
@@ -2445,7 +2445,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (!laopts->no_merging && lv_is_merging_origin(lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_merging_snapshot(lv)->cow, laopts, "cow"))
+			     find_snapshot(lv)->cow, laopts, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 41bd1a7..c274649 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -882,8 +882,6 @@ int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
-struct lv_segment *find_merging_snapshot(const struct logical_volume *origin);
-
 /* Given a cow LV, return return the snapshot lv_segment that uses it */
 struct lv_segment *find_snapshot(const struct logical_volume *lv);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 3e90f3e..e9a6d87 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -100,14 +100,6 @@ int lv_is_merging_origin(const struct logical_volume *origin)
 	return (origin->status & MERGING) ? 1 : 0;
 }
 
-struct lv_segment *find_merging_snapshot(const struct logical_volume *origin)
-{
-	if (!lv_is_merging_origin(origin))
-		return NULL;
-
-	return find_snapshot(origin);
-}
-
 int lv_is_merging_cow(const struct logical_volume *snapshot)
 {
 	/* checks lv_segment's status to see if cow is merging */
@@ -233,7 +225,8 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
 
-	if (find_merging_snapshot(origin) == find_snapshot(cow)) {
+	if (lv_is_merging_origin(origin) &&
+	    (find_snapshot(origin) == find_snapshot(cow))) {
 		clear_snapshot_merge(origin);
 		/*
 		 * preload origin IFF "snapshot-merge" target is active
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 31eb232..051463b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -650,8 +650,9 @@ static int _finish_lvconvert_merge(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct dm_list *lvs_changed __attribute__((unused)))
 {
-	struct lv_segment *snap_seg = find_merging_snapshot(lv);
-	if (!snap_seg) {
+	struct lv_segment *snap_seg = find_snapshot(lv);
+
+	if (!lv_is_merging_origin(lv)) {
 		log_error("Logical volume %s has no merging snapshot.", lv->name);
 		return 0;
 	}
@@ -1899,8 +1900,8 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		return 0;
 	}
 	if (lv_is_merging_origin(origin)) {
-		log_error("Snapshot %s is already merging into the origin",
-			  find_merging_snapshot(origin)->cow->name);
+		log_error("Snapshot %s is already merging into the origin.",
+			  find_snapshot(origin)->cow->name);
 		return 0;
 	}
 	if (lv_is_virtual_origin(origin)) {


