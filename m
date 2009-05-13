From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:24:01 +0200
Subject: [PATCH 4/9] Introduce vg_link_lv and vg_unlink_lv functions.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <0ee12ecd53875ca8ce4d90282b0f9cd0d8eebd87.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vg_link_lv and vg_unlink_lv are the only functions for
adding/removing logical volume into volume group.

Only these function should manipulate with vg->lvs list
and (together with following patches) will update
VG logical volume counter (vg->lv_count).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/import-export.c      |   18 ++++-----
 lib/format_pool/import_export.c  |   14 +------
 lib/format_text/import_vsn1.c    |   11 +-----
 lib/metadata/lv_manip.c          |   70 +++++++++++++++++++++----------------
 lib/metadata/metadata-exported.h |    3 ++
 5 files changed, 55 insertions(+), 61 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index b32a345..773ecad 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -455,25 +455,23 @@ static struct logical_volume *_add_lv(struct dm_pool *mem,
 				      struct volume_group *vg,
 				      struct lv_disk *lvd)
 {
-	struct lv_list *ll;
 	struct logical_volume *lv;
 
-	if (!(ll = dm_pool_zalloc(mem, sizeof(*ll))) ||
-	    !(ll->lv = dm_pool_zalloc(mem, sizeof(*ll->lv))))
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
 		return_NULL;
-	lv = ll->lv;
-	lv->vg = vg;
 
 	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
 
-	if (!import_lv(vg->cmd, mem, lv, lvd)) {
-		dm_pool_free(mem, ll);
-		return_NULL;
-	}
+	if (!import_lv(vg->cmd, mem, lv, lvd)) 
+		goto_bad;
 
-	dm_list_add(&vg->lvs, &ll->list);
+	if (!vg_link_lv(vg, lv))
+		goto_bad;
 
 	return lv;
+bad:
+	dm_pool_free(mem, lv);
+	return NULL;
 }
 
 int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds)
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 25d53e7..3277582 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -57,22 +57,14 @@ int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pool_list *pl;
-	struct lv_list *lvl = dm_pool_zalloc(mem, sizeof(*lvl));
 	struct logical_volume *lv;
 
-	if (!lvl) {
-		log_error("Unable to allocate lv list structure");
-		return 0;
-	}
-
-	if (!(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv)))) {
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
 		log_error("Unable to allocate logical volume structure");
 		return 0;
 	}
 
-	lv = lvl->lv;
 	lv->status = 0;
-	lv->vg = vg;
 	lv->alloc = ALLOC_NORMAL;
 	lv->size = 0;
 	lv->name = NULL;
@@ -114,10 +106,8 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 	}
 
 	lv->le_count = lv->size / POOL_PE_SIZE;
-	lvl->lv = lv;
-	dm_list_add(&vg->lvs, &lvl->list);
 
-	return 1;
+	return vg_link_lv(vg, lv);
 }
 
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 8f0d07c..c2b1020 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -495,15 +495,11 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 			 struct dm_hash_table *pv_hash __attribute((unused)))
 {
 	struct logical_volume *lv;
-	struct lv_list *lvl;
 	struct config_node *cn;
 
-	if (!(lvl = dm_pool_zalloc(mem, sizeof(*lvl))) ||
-	    !(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv))))
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
 		return_0;
 
-	lv = lvl->lv;
-
 	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
 		return_0;
 
@@ -561,10 +557,7 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 		return 0;
 	}
 
-	lv->vg = vg;
-	dm_list_add(&vg->lvs, &lvl->list);
-
-	return 1;
+	return vg_link_lv(vg, lv);
 }
 
 static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 64419d1..da2f250 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -402,7 +402,6 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
  */
 static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 {
-	struct lv_list *lvl;
 	struct lv_segment *seg;
 	uint32_t count = extents;
 	uint32_t reduction;
@@ -434,10 +433,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 
 	/* Remove the LV if it is now empty */
 	if (!lv->le_count) {
-		if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
+		if(!vg_unlink_lv(lv))
 			return_0;
-
-		dm_list_del(&lvl->list);
 	} else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
@@ -1819,8 +1816,6 @@ struct logical_volume *lv_create_empty(const char *name,
 				       struct volume_group *vg)
 {
 	struct format_instance *fi = vg->fid;
-	struct cmd_context *cmd = vg->cmd;
-	struct lv_list *ll = NULL;
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
@@ -1840,23 +1835,11 @@ struct logical_volume *lv_create_empty(const char *name,
 	if (!import)
 		log_verbose("Creating logical volume %s", name);
 
-	if (!(ll = dm_pool_zalloc(cmd->mem, sizeof(*ll))) ||
-	    !(ll->lv = dm_pool_zalloc(cmd->mem, sizeof(*ll->lv)))) {
-		log_error("lv_list allocation failed");
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return NULL;
-	}
-
-	lv = ll->lv;
-	lv->vg = vg;
+	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
+		return_NULL;
 
-	if (!(lv->name = dm_pool_strdup(cmd->mem, name))) {
-		log_error("lv name strdup failed");
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return NULL;
-	}
+	if (!(lv->name = dm_pool_strdup(vg->vgmem, name)))
+		goto_bad;
 
 	lv->status = status;
 	lv->alloc = alloc;
@@ -1874,15 +1857,16 @@ struct logical_volume *lv_create_empty(const char *name,
 	if (lvid)
 		lv->lvid = *lvid;
 
-	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv)) {
-		if (ll)
-			dm_pool_free(cmd->mem, ll);
-		return_NULL;
-	}
-
-	dm_list_add(&vg->lvs, &ll->list);
-
+	if (!vg_link_lv(vg, lv))
+		goto_bad;
+ 
+	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
+		goto_bad;
+ 
 	return lv;
+bad:
+	dm_pool_free(vg->vgmem, lv);
+	return NULL;
 }
 
 static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
@@ -1951,6 +1935,32 @@ struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
 	return parallel_areas;
 }
 
+int vg_link_lv(struct volume_group *vg, struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
+		return_0;
+
+	lvl->lv = lv;
+	lv->vg = vg;
+	dm_list_add(&vg->lvs, &lvl->list);
+
+	return 1;
+}
+
+int vg_unlink_lv(struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
+		return_0;
+
+	dm_list_del(&lvl->list);
+
+	return 1;
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     const force_t force)
 {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2970b9c..d534386 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -368,6 +368,9 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				int warnings, int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
+int vg_link_lv(struct volume_group *vg, struct logical_volume *lv);
+int vg_unlink_lv(struct logical_volume *lv);
+
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
 struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);
-- 
1.6.2.4


