From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:23:22 +0200
Subject: [PATCH 1/9] Fix snapshot segment import to not use duplicate segments & replace.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <c55d89217577eb23320a760ccf6f0ee08b70a628.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The snapshot segment (snapshotX) is created twice
during the text metadata segment processing.

This can cause temporary violation of max_lv count.

Simplify the code, snapshot segment is properly initialized
in init_snapshot_seg function now and do not need to be replaced
by vg_add_snapshot call.

The vg_add_snapshot() is now usefull only for adding new
snapshot and it shares the same initialization function.

The snapshot name is always generated, name paramater can be
removed from function call.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/import-export.c      |    2 +-
 lib/format_text/import_vsn1.c    |   10 -------
 lib/metadata/metadata-exported.h |    6 +++-
 lib/metadata/snapshot_manip.c    |   55 ++++++++++++++++++++------------------
 lib/snapshot/snapshot.c          |    6 +---
 tools/lvconvert.c                |    3 +-
 tools/lvcreate.c                 |    2 +-
 7 files changed, 37 insertions(+), 47 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index a950f9a..5d2e86a 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -616,7 +616,7 @@ int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_gr
 				continue;
 
 			/* insert the snapshot */
-			if (!vg_add_snapshot(NULL, org, cow, NULL,
+			if (!vg_add_snapshot(org, cow, NULL,
 					     org->le_count,
 					     lvd->lv_chunk_size)) {
 				log_err("Couldn't add snapshot.");
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 0bb9843..a9748aa 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -603,16 +603,6 @@ static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
 
-	/*
-	 * FIXME We now have 2 LVs for each snapshot. The real one was
-	 * created by vg_add_snapshot from the segment text_import.
-	 */
-	if (lv->status & SNAPSHOT) {
-		vg->lv_count--;
-		dm_list_del(&lvl->list);
-		return 1;
-	}
-
 	lv->minor = -1;
 	if ((lv->status & FIXED_MINOR) &&
 	    !_read_int32(lvn, "minor", &lv->minor)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9bd3389..6c32ab4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -545,8 +545,10 @@ struct lv_segment *find_cow(const struct logical_volume *lv);
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
-int vg_add_snapshot(const char *name,
-		    struct logical_volume *origin, struct logical_volume *cow,
+void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
+		       struct logical_volume *cow, uint32_t chunk_size);
+
+int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    uint32_t chunk_size);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 6aa29a0..9364b4f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -62,7 +62,31 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 	return lv->snapshot->origin;
 }
 
-int vg_add_snapshot(const char *name, struct logical_volume *origin,
+void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
+		       struct logical_volume *cow, uint32_t chunk_size)
+{
+	seg->chunk_size = chunk_size;
+	seg->origin = origin;
+	seg->cow = cow;
+
+	// FIXME: direct count manipulation to be removed later
+	cow->status &= ~VISIBLE_LV;
+	cow->vg->lv_count--;
+	cow->snapshot = seg;
+
+	origin->origin_count++;
+	origin->vg->lv_count--;
+
+	/* FIXME Assumes an invisible origin belongs to a sparse device */
+	if (!lv_is_visible(origin))
+		origin->status |= VIRTUAL_ORIGIN;
+
+	seg->lv->status |= (SNAPSHOT | VIRTUAL);
+
+	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
+}
+
+int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
 {
@@ -82,39 +106,18 @@ int vg_add_snapshot(const char *name, struct logical_volume *origin,
 		return 0;
 	}
 
-	/*
-	 * Set origin lv count in advance to prevent fail because
-	 * of temporary violation of LV limits.
-	 */
-	origin->vg->lv_count--;
-
-	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
+	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg))) {
-		origin->vg->lv_count++;
+				     ALLOC_INHERIT, 1, origin->vg)))
 		return_0;
-	}
 
 	snap->le_count = extent_count;
 
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	seg->chunk_size = chunk_size;
-	seg->origin = origin;
-	seg->cow = cow;
-	seg->lv->status |= SNAPSHOT;
-
-	origin->origin_count++;
-	cow->snapshot = seg;
-
-	cow->status &= ~VISIBLE_LV;
-
-        /* FIXME Assumes an invisible origin belongs to a sparse device */
-        if (!lv_is_visible(origin))
-                origin->status |= VIRTUAL_ORIGIN;
-
-	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
+	origin->vg->lv_count++;
+	init_snapshot_seg(seg, origin, cow, chunk_size);
 
 	return 1;
 }
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 1fdf0ab..d704ff9 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -39,8 +39,6 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 	struct logical_volume *org, *cow;
 	int old_suppress;
 
-	seg->lv->status |= SNAPSHOT;
-
 	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
 		return 0;
@@ -74,9 +72,7 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 		return 0;
 	}
 
-	if (!vg_add_snapshot(seg->lv->name, org, cow,
-			     &seg->lv->lvid, seg->len, chunk_size))
-		return_0;
+	init_snapshot_seg(seg, org, cow, chunk_size);
 
 	return 1;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c54a2d1..267ff09 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -760,8 +760,7 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!vg_add_snapshot(NULL, org, lv, NULL, org->le_count,
-			     lp->chunk_size)) {
+	if (!vg_add_snapshot(org, lv, NULL, org->le_count, lp->chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
 	}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 42608c3..069cc0e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -918,7 +918,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* cow LV remains active and becomes snapshot LV */
 
-		if (!vg_add_snapshot(NULL, org, lv, NULL,
+		if (!vg_add_snapshot(org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
 			goto deactivate_and_revert_new_lv;
-- 
1.6.2.4


