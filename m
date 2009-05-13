From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:23:35 +0200
Subject: [PATCH 2/9] Remove vg->lv_count and use counter function.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <aadeadc24d966a9c735b430e0b3e20d14c5d9aa6.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This should not cause problems but simplifies code a lot.

(the volumes_count is merged with lvs_visible function by following patch.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/import-export.c      |    3 +--
 lib/format_pool/format_pool.c    |    1 -
 lib/format_pool/import_export.c  |    2 --
 lib/format_text/import_vsn1.c    |    1 -
 lib/metadata/lv_manip.c          |    8 +-------
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |   27 +++++++++++++++++++++------
 lib/metadata/snapshot_manip.c    |    6 ------
 tools/vgchange.c                 |    4 ++--
 tools/vgmerge.c                  |    1 -
 tools/vgsplit.c                  |    6 +-----
 11 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 5d2e86a..56800a2 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -282,7 +282,7 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg->lv_count + snapshot_count(vg);
+	vgd->lv_cur = volumes_count(vg) + snapshot_count(vg);
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
@@ -469,7 +469,6 @@ static struct logical_volume *_add_lv(struct dm_pool *mem,
 		return_NULL;
 
 	dm_list_add(&vg->lvs, &ll->list);
-	vg->lv_count++;
 
 	return lv;
 }
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 114cec1..3f31bba 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -119,7 +119,6 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	vg->status = 0;
 	vg->extent_count = 0;
 	vg->pv_count = 0;
-	vg->lv_count = 0;
 	vg->seqno = 1;
 	vg->system_id = NULL;
 	dm_list_init(&vg->pvs);
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 4d2163d..25d53e7 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -49,7 +49,6 @@ int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 		vg->max_lv = 1;
 		vg->max_pv = POOL_MAX_DEVICES;
 		vg->alloc = ALLOC_NORMAL;
-		vg->lv_count = 0;
 	}
 
 	return 1;
@@ -117,7 +116,6 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 	lv->le_count = lv->size / POOL_PE_SIZE;
 	lvl->lv = lv;
 	dm_list_add(&vg->lvs, &lvl->list);
-	vg->lv_count++;
 
 	return 1;
 }
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index a9748aa..8f0d07c 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -562,7 +562,6 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 	}
 
 	lv->vg = vg;
-	vg->lv_count++;
 	dm_list_add(&vg->lvs, &lvl->list);
 
 	return 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7214b27..64419d1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -438,9 +438,6 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 			return_0;
 
 		dm_list_del(&lvl->list);
-
-		if (!(lv->status & SNAPSHOT))
-			lv->vg->lv_count--;
 	} else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
@@ -1827,7 +1824,7 @@ struct logical_volume *lv_create_empty(const char *name,
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == vg->lv_count)) {
+	if (vg->max_lv && (vg->max_lv == volumes_count(vg))) {
 		log_error("Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
 		return NULL;
@@ -1883,9 +1880,6 @@ struct logical_volume *lv_create_empty(const char *name,
 		return_NULL;
 	}
 
-	if (!import)
-		vg->lv_count++;
-
 	dm_list_add(&vg->lvs, &ll->list);
 
 	return lv;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6c32ab4..2970b9c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -251,7 +251,6 @@ struct volume_group {
 	 * - one for the user-visible mirror LV
 	 * all of the instances are reflected in lv_count.
 	 */
-	uint32_t lv_count;
 	struct dm_list lvs;
 
 	struct dm_list tags;
@@ -556,6 +555,8 @@ int vg_remove_snapshot(struct logical_volume *cow);
 
 int vg_check_status(const struct volume_group *vg, uint32_t status);
 
+unsigned volumes_count(const struct volume_group *vg);
+
 /*
 * Mirroring functions
 */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7cd4166..97b9ebb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -571,7 +571,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
 
-	vg->lv_count = 0;
 	dm_list_init(&vg->lvs);
 
 	dm_list_init(&vg->tags);
@@ -1165,6 +1164,22 @@ unsigned snapshot_count(const struct volume_group *vg)
 	return num_snapshots;
 }
 
+unsigned volumes_count(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_cow(lvl->lv))
+			continue;
+		if (lvl->lv->status & SNAPSHOT)
+			continue;
+		lv_count++;
+	}
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1199,7 +1214,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 	}
 
 	if (vg_to->max_lv &&
-	    (vg_to->max_lv < vg_to->lv_count + vg_from->lv_count)) {
+	    (vg_to->max_lv < volumes_count(vg_to) + volumes_count(vg_from))) {
 		log_error("Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
@@ -1455,10 +1470,10 @@ int vg_validate(struct volume_group *vg)
 	}
 
 	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg->lv_count + 2 * snapshot_count(vg)) {
+	    volumes_count(vg) + 2 * snapshot_count(vg)) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
-			  dm_list_size(&vg->lvs), vg->lv_count,
+			  dm_list_size(&vg->lvs), volumes_count(vg),
 			  snapshot_count(vg), vg->name);
 		r = 0;
 	}
@@ -1502,10 +1517,10 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < vg->lv_count)) {
+	if (vg->max_lv && (vg->max_lv < volumes_count(vg))) {
 		log_error("Internal error: Volume group %s contains %u volumes"
 			  " but the limit is set to %u.",
-			  vg->name, vg->lv_count, vg->max_lv);
+			  vg->name, volumes_count(vg), vg->max_lv);
 		r = 0;
 	}
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 9364b4f..e186dff 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -69,13 +69,10 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 	seg->origin = origin;
 	seg->cow = cow;
 
-	// FIXME: direct count manipulation to be removed later
 	cow->status &= ~VISIBLE_LV;
-	cow->vg->lv_count--;
 	cow->snapshot = seg;
 
 	origin->origin_count++;
-	origin->vg->lv_count--;
 
 	/* FIXME Assumes an invisible origin belongs to a sparse device */
 	if (!lv_is_visible(origin))
@@ -116,7 +113,6 @@ int vg_add_snapshot(struct logical_volume *origin,
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	origin->vg->lv_count++;
 	init_snapshot_seg(seg, origin, cow, chunk_size);
 
 	return 1;
@@ -134,8 +130,6 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	}
 
 	cow->snapshot = NULL;
-
-	cow->vg->lv_count++;
 	cow->status |= VISIBLE_LV;
 
 	return 1;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index eb2b816..d01bc01 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -308,9 +308,9 @@ static int _vgchange_logicalvolume(struct cmd_context *cmd,
 		}
 	}
 
-	if (max_lv && max_lv < vg->lv_count) {
+	if (max_lv && max_lv < volumes_count(vg)) {
 		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for \"%s\"", vg->lv_count,
+			  "%d of LVs for %s", volumes_count(vg),
 			  vg->name);
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 8b85c7a..57a700e 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -101,7 +101,6 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		dm_list_move(&vg_to->fid->metadata_areas, mdah);
 	}
 
-	vg_to->lv_count += vg_from->lv_count;
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index e4c7620..317aac1 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -106,12 +106,8 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (!(lv->status & SNAPSHOT) && !lv_is_cow(lv)) {
-		vg_from->lv_count--;
-		vg_to->lv_count++;
-	}
 	return 1;
-}	
+}
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 {
-- 
1.6.2.4


