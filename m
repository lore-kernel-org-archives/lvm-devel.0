From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:43:00 +0200
Subject: [PATCH 3/7] Remove snapshot_count from VG and use function instead.
In-Reply-To: <cover.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
Message-ID: <a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/import-export.c      |    2 +-
 lib/format_pool/format_pool.c    |    1 -
 lib/metadata/metadata-exported.h |    8 ++------
 lib/metadata/metadata.c          |   18 ++++++++++++++----
 lib/metadata/metadata.h          |    5 +++++
 lib/metadata/snapshot_manip.c    |    2 --
 lib/report/columns.h             |    2 +-
 lib/report/report.c              |   12 ++++++++++++
 lib/snapshot/snapshot.c          |    1 -
 tools/vgmerge.c                  |    2 --
 tools/vgsplit.c                  |    5 +----
 11 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 4321965..627ee05 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -282,7 +282,7 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg->lv_count + vg->snapshot_count;
+	vgd->lv_cur = vg->lv_count + snapshot_lvs_in_vg(vg);
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 9a34f94..114cec1 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -120,7 +120,6 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	vg->extent_count = 0;
 	vg->pv_count = 0;
 	vg->lv_count = 0;
-	vg->snapshot_count = 0;
 	vg->seqno = 1;
 	vg->system_id = NULL;
 	dm_list_init(&vg->pvs);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d7099b7..92728ff 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -236,15 +236,12 @@ struct volume_group {
 	struct dm_list pvs;
 
 	/*
-	 * logical volumes
-	 * The following relationship should always hold:
-	 * dm_list_size(lvs) = lv_count + 2 * snapshot_count
+	 * logical volumes count
 	 *
 	 * Snapshots consist of 2 instances of "struct logical_volume":
 	 * - cow (lv_name is visible to the user)
 	 * - snapshot (lv_name is 'snapshotN')
-	 * Neither of these instances is reflected in lv_count, but we
-	 * multiply the snapshot_count by 2.
+	 * Neither of these instances is reflected in lv_count.
 	 *
 	 * Mirrors consist of multiple instances of "struct logical_volume":
 	 * - one for the mirror log
@@ -253,7 +250,6 @@ struct volume_group {
 	 * all of the instances are reflected in lv_count.
 	 */
 	uint32_t lv_count;
-	uint32_t snapshot_count;
 	struct dm_list lvs;
 
 	struct dm_list tags;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 13ab8f3..50762f6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -574,8 +574,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 	vg->lv_count = 0;
 	dm_list_init(&vg->lvs);
 
-	vg->snapshot_count = 0;
-
 	dm_list_init(&vg->tags);
 
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
@@ -1155,6 +1153,18 @@ unsigned displayable_lvs_in_vg(const struct volume_group *vg)
 	return lv_count;
 }
 
+unsigned snapshot_lvs_in_vg(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_cow(lvl->lv))
+			lv_count++;
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1445,11 +1455,11 @@ int vg_validate(struct volume_group *vg)
 	}
 
 	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg->lv_count + 2 * vg->snapshot_count) {
+	    vg->lv_count + 2 * snapshot_lvs_in_vg(vg)) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  dm_list_size(&vg->lvs), vg->lv_count,
-			  vg->snapshot_count, vg->name);
+			  snapshot_lvs_in_vg(vg), vg->name);
 		r = 0;
 	}
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index eff2380..410a9f9 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -345,6 +345,11 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 unsigned displayable_lvs_in_vg(const struct volume_group *vg);
 
 /*
+ * Count snapshot LVs.
+ */
+unsigned snapshot_lvs_in_vg(const struct volume_group *vg);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 2297c54..cc57aeb 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -106,7 +106,6 @@ int vg_add_snapshot(struct logical_volume *origin,
 	seg->lv->status |= SNAPSHOT;
 
 	origin->origin_count++;
-	origin->vg->snapshot_count++;
 	cow->snapshot = seg;
 
 	cow->status &= ~VISIBLE_LV;
@@ -133,7 +132,6 @@ int vg_remove_snapshot(struct logical_volume *cow)
 
 	cow->snapshot = NULL;
 
-	cow->vg->snapshot_count--;
 	cow->vg->lv_count++;
 	cow->status |= VISIBLE_LV;
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 707347b..6ca24e5 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -105,7 +105,7 @@ FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv", "Maximum number of LVs
 FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.")
 FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, "lv_count", "Number of LVs.")
-FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of snapshots.")
+FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
diff --git a/lib/report/report.c b/lib/report/report.c
index 91e2b98..b02fdd8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -991,6 +991,18 @@ static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _snapcount_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = snapshot_lvs_in_vg(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private __attribute((unused)))
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index a9eea45..ad5d158 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -85,7 +85,6 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 
 	org->origin_count++;
 	org->vg->lv_count--;
-	org->vg->snapshot_count++;
 
         /* FIXME Assumes an invisible origin belongs to a sparse device */
         if (!lv_is_visible(org))
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index c847c7e..82c3456 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -102,8 +102,6 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
-	vg_to->snapshot_count += vg_from->snapshot_count;
-
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 87e74a4..c4b583a 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -106,10 +106,7 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (lv->status & SNAPSHOT) {
-		vg_from->snapshot_count--;
-		vg_to->snapshot_count++;
-	} else if (!lv_is_cow(lv)) {
+	if (!(lv->status & SNAPSHOT) && !lv_is_cow(lv)) {
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}
-- 
1.6.2.4


