From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:39 +0000 (UTC)
Subject: master - thin: snapshot merge support
Message-ID: <20131204133139.A5E4B60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e286904da6a253394c050abde780269571289268
Commit:        e286904da6a253394c050abde780269571289268
Parent:        572983d7931eac9347dad79b7d9b13f640bfaeaf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 15:51:28 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

thin: snapshot merge support

---
 lib/metadata/lv_manip.c          |    4 ++--
 lib/metadata/merge.c             |   13 +++++++++++++
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.h          |    3 ++-
 lib/metadata/snapshot_manip.c    |   15 ++++++++++++++-
 lib/metadata/thin_manip.c        |   21 +++++++++++++++++++--
 lib/thin/thin.c                  |   30 +++++++++++++++++++++++++++---
 7 files changed, 79 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6846f4a..2458447 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -491,14 +491,14 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 		/* If this is thin volume, thin snapshot is being created */
 		if (lv_is_thin_volume(thin_pool_lv)) {
 			seg->transaction_id = first_seg(first_seg(thin_pool_lv)->pool_lv)->transaction_id;
-			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv))
+			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv, NULL))
 				return_NULL;
 			/* Use the same external origin */
 			if (!attach_thin_external_origin(seg, first_seg(thin_pool_lv)->external_lv))
 				return_NULL;
 		} else if (lv_is_thin_pool(thin_pool_lv)) {
 			seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
-			if (!attach_pool_lv(seg, thin_pool_lv, NULL))
+			if (!attach_pool_lv(seg, thin_pool_lv, NULL, NULL))
 				return_NULL;
 		} else {
 			log_error(INTERNAL_ERROR "Volume %s is not thin volume or thin pool",
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index c22e922..93e4bfa 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -258,6 +258,19 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 						  lv->name, seg->external_lv->name);
 					inc_error_count;
 				}
+
+				if (seg->merge_lv) {
+					if (!lv_is_thin_volume(seg->merge_lv)) {
+						log_error("LV %s: thin volume segment %u merging LV %s is not flagged as a thin LV",
+							  lv->name, seg_count, seg->merge_lv->name);
+						inc_error_count;
+					}
+					if (!lv_is_merging_origin(seg->merge_lv)) {
+						log_error("LV %s: merging LV %s is not flagged as merging.",
+							  lv->name, seg->merge_lv->name);
+						inc_error_count;
+					}
+				}
 			} else {
 				if (seg->pool_lv) {
 					log_error("LV %s: segment %u must not have thin pool LV set",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0186c61..9798197 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -360,6 +360,7 @@ struct lv_segment {
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
 				/* For thin_pool, 128..2097152. */
 	struct logical_volume *origin;	/* snap and thin */
+	struct logical_volume *merge_lv; /* thin, merge descendent lv into this ancestor */
 	struct logical_volume *cow;
 	struct dm_list origin_list;
 	uint32_t region_size;	/* For mirrors, replicators - in sectors */
@@ -881,7 +882,7 @@ int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
-/* Given a cow LV, return return the snapshot lv_segment that uses it */
+/* Given a cow or thin LV, return the snapshot lv_segment that uses it */
 struct lv_segment *find_snapshot(const struct logical_volume *lv);
 
 /* Given a cow LV, return its origin */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 21ac204..0ab63f2 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -462,11 +462,12 @@ int fixup_imported_mirrors(struct volume_group *vg);
  * From thin_manip.c
  */
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
-		   struct logical_volume *origin_lv);
+		   struct logical_volume *origin_lv, struct logical_volume *merge_lv);
 int detach_pool_lv(struct lv_segment *seg);
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
 			int auto_increment);
+int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
 int pool_below_threshold(const struct lv_segment *pool_seg);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e9a6d87..e563a78 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -27,7 +27,8 @@ int lv_is_origin(const struct logical_volume *lv)
 
 int lv_is_cow(const struct logical_volume *lv)
 {
-	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
+	/* Make sure a merging thin origin isn't confused as a cow LV */
+	return (!lv_is_thin_volume(lv) && !lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
 static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
@@ -150,6 +151,13 @@ void init_snapshot_merge(struct lv_segment *snap_seg,
 	origin->snapshot = snap_seg;
 	origin->status |= MERGING;
 
+	if (lv_is_thin_volume(origin)) {
+		snap_seg->merge_lv = origin;
+		/* Making thin LV inivisible with regular log */
+		lv_set_hidden(snap_seg->lv);
+		return;
+	}
+
 	/*
 	 * Even though lv_is_visible(snap_seg->lv) returns 0,
 	 * the snap_seg->lv (name: snapshotX) is _not_ hidden;
@@ -166,6 +174,11 @@ void init_snapshot_merge(struct lv_segment *snap_seg,
 void clear_snapshot_merge(struct logical_volume *origin)
 {
 	/* clear merge attributes */
+	if (origin->snapshot->merge_lv)
+		/* Removed thin volume has to be visible */
+		lv_set_visible(origin->snapshot->lv);
+
+	origin->snapshot->merge_lv = NULL;
 	origin->snapshot->status &= ~MERGING;
 	origin->snapshot = NULL;
 	origin->status &= ~MERGING;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b3fedcf..0223752 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -60,7 +60,7 @@ int attach_pool_data_lv(struct lv_segment *pool_seg, struct logical_volume *pool
 }
 
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
-		   struct logical_volume *origin)
+		   struct logical_volume *origin, struct logical_volume *merge_lv)
 {
 	seg->pool_lv = pool_lv;
 	seg->lv->status |= THIN_VOLUME;
@@ -69,7 +69,19 @@ int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
 	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
 		return_0;
 
-	return add_seg_to_segs_using_this_lv(pool_lv, seg);
+	if (!add_seg_to_segs_using_this_lv(pool_lv, seg))
+		return_0;
+
+	if (merge_lv) {
+		if (origin != merge_lv) {
+			if (!add_seg_to_segs_using_this_lv(merge_lv, seg))
+				return_0;
+		}
+
+		init_snapshot_merge(seg, merge_lv);
+	}
+
+	return 1;
 }
 
 int detach_pool_lv(struct lv_segment *seg)
@@ -247,6 +259,11 @@ int detach_thin_external_origin(struct lv_segment *seg)
 	return 1;
 }
 
+int lv_is_merging_thin_snapshot(const struct logical_volume *lv)
+{
+	return (first_seg(lv)->status & MERGING) ? 1 : 0;
+}
+
 /*
  * Check whether pool has some message queued for LV or for device_id
  * When LV is NULL and device_id is 0 it just checks for any message.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8477aac..5f0c271 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -456,7 +456,7 @@ static int _thin_text_import(struct lv_segment *seg,
 			     struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
-	struct logical_volume *pool_lv, *origin = NULL, *external_lv = NULL;
+	struct logical_volume *pool_lv, *origin = NULL, *external_lv = NULL, *merge_lv = NULL;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
@@ -475,6 +475,13 @@ static int _thin_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Unknown origin %s in", lv_name);
 	}
 
+	if (dm_config_has_node(sn, "merge")) {
+		if (!dm_config_get_str(sn, "merge", &lv_name))
+			return SEG_LOG_ERROR("Merge lv must be a string in");
+		if (!(merge_lv = find_lv(seg->lv->vg, lv_name)))
+			return SEG_LOG_ERROR("Unknown merge lv %s in", lv_name);
+	}
+
 	if (!dm_config_get_uint32(sn, "device_id", &seg->device_id))
 		return SEG_LOG_ERROR("Could not read device_id for");
 
@@ -490,7 +497,7 @@ static int _thin_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Unknown external origin %s in", lv_name);
 	}
 
-	if (!attach_pool_lv(seg, pool_lv, origin))
+	if (!attach_pool_lv(seg, pool_lv, origin, merge_lv))
 		return_0;
 
 	if (!attach_thin_external_origin(seg, external_lv))
@@ -509,6 +516,8 @@ static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 		outf(f, "external_origin = \"%s\"", seg->external_lv->name);
 	if (seg->origin)
 		outf(f, "origin = \"%s\"", seg->origin->name);
+	if (seg->merge_lv)
+		outf(f, "merge = \"%s\"", seg->merge_lv->name);
 
 	return 1;
 }
@@ -519,7 +528,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 				 struct cmd_context *cmd __attribute__((unused)),
 				 void **target_state __attribute__((unused)),
 				 struct lv_segment *seg,
-				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 const struct lv_activate_opts *laopts,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
@@ -537,6 +546,21 @@ static int _thin_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
+	if (!laopts->no_merging) {
+		/*
+		 * merge support for thinp snapshots is implemented by
+		 * simply swapping the thinp device_id of the snapshot
+		 * and origin.
+		 */
+		if (seg->merge_lv) {
+			/* snapshot, use merging lv's device_id */
+			device_id = first_seg(seg->merge_lv)->device_id;
+		} else if (lv_is_merging_origin(seg->lv)) {
+			/* origin, use merging snapshot's device_id */
+			device_id = find_snapshot(seg->lv)->device_id;
+		}
+	}
+
 	if (!dm_tree_node_add_thin_target(node, len, pool_dlid, device_id))
 		return_0;
 


