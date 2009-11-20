From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:42 -0500
Subject: [PATCH 02/15] lvm-merge-metadata
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Add 'SNAPSHOT_MERGE' lv_segment 'status' flag.

Make 'merging_snapshot' pointer that points from the origin to the
segment that represents the merging snapshot.

Import/export 'merging_store' metadata.

Do not allow creating snapshots while another snapshot is merging.
Snapshot created in this state would certainly contain invalid data.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_manip.c          |    6 ++++++
 lib/metadata/metadata-exported.h |    6 +++++-
 lib/metadata/snapshot_manip.c    |   13 +++++++++++--
 lib/snapshot/snapshot.c          |   15 +++++++++++----
 5 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 829d44a..342dc5a 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -61,6 +61,7 @@ static struct flag _lv_flags[] = {
 	{MIRRORED, NULL, 0},
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
+	{SNAPSHOT_MERGE, NULL, 0},
 	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 260a9ee..ecaab29 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1873,6 +1873,7 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 	}
 
 	lv->snapshot = NULL;
+	lv->merging_snapshot = NULL;
 	dm_list_init(&lv->snapshot_segs);
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
@@ -2937,6 +2938,11 @@ int lv_create_single(struct volume_group *vg,
 					  "supported yet");
 				return 0;
 			}
+			if (org->merging_snapshot) {
+				log_error("Snapshots while another snapshot "
+					  "is merging is not supported");
+				return 0;
+			}
 			if ((org->status & MIRROR_IMAGE) ||
 			    (org->status & MIRROR_LOG)) {
 				log_error("Snapshots of mirror %ss "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e9a3d5d..30073d3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -60,6 +60,7 @@
 //#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
+#define SNAPSHOT_MERGE		0x00800000U	/* SEG */
 
 #define MISSING_PV              0x00800000U	/* PV */
 #define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
@@ -328,6 +329,9 @@ struct logical_volume {
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
+	/* A snapshot that is merging into this origin */
+	struct lv_segment *merging_snapshot;
+
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
@@ -622,7 +626,7 @@ struct lv_segment *find_cow(const struct logical_volume *lv);
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
-		       struct logical_volume *cow, uint32_t chunk_size);
+		       struct logical_volume *cow, uint32_t chunk_size, int merge);
 
 int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 8f902af..86cab6f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -37,6 +37,9 @@ int lv_is_visible(const struct logical_volume *lv)
 		if (lv_is_virtual_origin(origin_from_cow(lv)))
 			return 1;
 
+		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+			return 0;
+
 		return lv_is_visible(origin_from_cow(lv));
 	}
 
@@ -62,7 +65,7 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 }
 
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
-		       struct logical_volume *cow, uint32_t chunk_size)
+		       struct logical_volume *cow, uint32_t chunk_size, int merge)
 {
 	seg->chunk_size = chunk_size;
 	seg->origin = origin;
@@ -79,6 +82,10 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		origin->status |= VIRTUAL_ORIGIN;
 
 	seg->lv->status |= (SNAPSHOT | VIRTUAL);
+	if (merge) {
+		seg->status |= SNAPSHOT_MERGE;
+		origin->merging_snapshot = seg;
+	}
 
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 }
@@ -113,7 +120,7 @@ int vg_add_snapshot(struct logical_volume *origin,
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	init_snapshot_seg(seg, origin, cow, chunk_size);
+	init_snapshot_seg(seg, origin, cow, chunk_size, 0);
 
 	return 1;
 }
@@ -122,6 +129,8 @@ int vg_remove_snapshot(struct logical_volume *cow)
 {
 	dm_list_del(&cow->snapshot->origin_list);
 	cow->snapshot->origin->origin_count--;
+	if (cow->snapshot->origin->merging_snapshot == cow->snapshot)
+		cow->snapshot->origin->merging_snapshot = NULL;
 
 	if (!lv_remove(cow->snapshot->lv)) {
 		log_error("Failed to remove internal snapshot LV %s",
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 6b1a0e2..8a3378c 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -37,7 +37,7 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 	uint32_t chunk_size;
 	const char *org_name, *cow_name;
 	struct logical_volume *org, *cow;
-	int old_suppress;
+	int old_suppress, merge = 0;
 
 	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
@@ -46,7 +46,10 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 
 	old_suppress = log_suppress(1);
 
-	if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
+	cow_name = find_config_str(sn, "merging_store", NULL);
+	if (cow_name) {
+		merge = 1;
+	} else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;
@@ -72,7 +75,7 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 		return 0;
 	}
 
-	init_snapshot_seg(seg, org, cow, chunk_size);
+	init_snapshot_seg(seg, org, cow, chunk_size, merge);
 
 	return 1;
 }
@@ -81,7 +84,11 @@ static int _snap_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "chunk_size = %u", seg->chunk_size);
 	outf(f, "origin = \"%s\"", seg->origin->name);
-	outf(f, "cow_store = \"%s\"", seg->cow->name);
+	if (!(seg->status & SNAPSHOT_MERGE)) {
+		outf(f, "cow_store = \"%s\"", seg->cow->name);
+	} else {
+		outf(f, "merging_store = \"%s\"", seg->cow->name);
+	}
 
 	return 1;
 }
-- 
1.6.5.2


