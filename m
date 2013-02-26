From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:08 +0000 (UTC)
Subject: master - cleanup: use struct pvcreate_restorable_params throughout
Message-ID: <20130226141808.31427A0DFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d8de3638c3e715a1c0273e3fed9daf71a871685
Commit:        6d8de3638c3e715a1c0273e3fed9daf71a871685
Parent:        6692b177777501532ba0d422dcb2a22016405519
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 18 12:47:31 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 11:25:11 2013 +0100

cleanup: use struct pvcreate_restorable_params throughout

---
 lib/format1/format1.c            |   21 +++++++++++++--------
 lib/format_pool/format_pool.c    |    4 +---
 lib/format_text/format-text.c    |   18 ++++++++----------
 lib/metadata/metadata-exported.h |    9 ++++-----
 lib/metadata/metadata.c          |   31 +++++++++++++------------------
 lib/metadata/metadata.h          |    5 +----
 tools/toollib.c                  |    4 ++--
 tools/vgconvert.c                |   15 +++++++++------
 8 files changed, 51 insertions(+), 56 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index bf5333e..335a7e2 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -339,11 +339,9 @@ static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
 
 static int _format1_pv_initialise(const struct format_type * fmt,
 				  int64_t label_sector __attribute__((unused)),
-				  uint64_t pe_start,
-				  uint32_t extent_count,
-				  uint32_t extent_size,
 				  unsigned long data_alignment __attribute__((unused)),
 				  unsigned long data_alignment_offset __attribute__((unused)),
+				  struct pvcreate_restorable_params *rp,
 				  struct physical_volume * pv)
 {
 	if (pv->size > MAX_PV_SIZE)
@@ -355,18 +353,18 @@ static int _format1_pv_initialise(const struct format_type * fmt,
 	}
 
 	/* Nothing more to do if extent size isn't provided */
-	if (!extent_size)
+	if (!rp->extent_size)
 		return 1;
 
 	/*
 	 * This works out pe_start and pe_count.
 	 */
-	if (!calculate_extent_count(pv, extent_size, extent_count, pe_start))
+	if (!calculate_extent_count(pv, rp->extent_size, rp->extent_count, rp->pe_start))
 		return_0;
 
 	/* Retain existing extent locations exactly */
-	if (((pe_start || extent_count) && (pe_start != pv->pe_start)) ||
-	    (extent_count && (extent_count != pv->pe_count))) {
+	if (((rp->pe_start || rp->extent_count) && (rp->pe_start != pv->pe_start)) ||
+	    (rp->extent_count && (rp->extent_count != pv->pe_count))) {
 		log_error("Metadata would overwrite physical extents");
 		return 0;
 	}
@@ -378,7 +376,14 @@ static int _format1_pv_setup(const struct format_type *fmt,
 			     struct physical_volume *pv,
 			     struct volume_group *vg)
 {
-	return _format1_pv_initialise(fmt, -1, 0, 0, vg->extent_size, 0, 0, pv);
+	struct pvcreate_restorable_params rp = {.restorefile = NULL,
+						.id = {{0}},
+						.idp = NULL,
+						.pe_start = 0,
+						.extent_count = 0,
+						.extent_size = vg->extent_size};
+
+	return _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv);
 }
 
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 04bc4cf..c051968 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -165,11 +165,9 @@ bad:
 
 static int _pool_pv_initialise(const struct format_type *fmt __attribute__((unused)),
 			       int64_t label_sector __attribute__((unused)),
-			       uint64_t pe_start __attribute__((unused)),
-			       uint32_t extent_count __attribute__((unused)),
-			       uint32_t extent_size __attribute__((unused)),
 			       unsigned long data_alignment __attribute__((unused)),
 			       unsigned long data_alignment_offset __attribute__((unused)),
+			       struct pvcreate_restorable_params *rp __attribute__((unused)),
 			       struct physical_volume *pv __attribute__((unused)))
 {
 	return 1;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index cf15313..a769daf 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1466,19 +1466,17 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 
 static int _text_pv_initialise(const struct format_type *fmt,
 			       const int64_t label_sector,
-			       uint64_t pe_start,
-			       uint32_t extent_count,
-			       uint32_t extent_size,
 			       unsigned long data_alignment,
 			       unsigned long data_alignment_offset,
+			       struct pvcreate_restorable_params *rp,
 			       struct physical_volume *pv)
 {
 	/*
 	 * Try to keep the value of PE start set to a firm value if requested.
 	 * This is usefull when restoring existing PE start value (backups etc.).
 	 */
-	if (pe_start != PV_PE_START_CALC)
-		pv->pe_start = pe_start;
+	if (rp->pe_start != PV_PE_START_CALC)
+		pv->pe_start = rp->pe_start;
 
 	if (!data_alignment)
 		data_alignment = find_config_tree_int(pv->fmt->cmd,
@@ -1514,14 +1512,14 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (pe_start == PV_PE_START_CALC)
+	if (rp->pe_start == PV_PE_START_CALC)
 		pv->pe_start = pv->pe_align + pv->pe_align_offset;
 
-	if (extent_size)
-		pv->pe_size = extent_size;
+	if (rp->extent_size)
+		pv->pe_size = rp->extent_size;
 
-	if (extent_count)
-		pv->pe_count = extent_count;
+	if (rp->extent_count)
+		pv->pe_count = rp->extent_count;
 
 	if ((pv->pe_start + pv->pe_count * pv->pe_size - 1) > (pv->size << SECTOR_SHIFT)) {
 		log_error("Physical extents end beyond end of device %s.",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1f77ce9..5c8a6df 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -391,6 +391,8 @@ struct lv_list {
 	struct logical_volume *lv;
 };
 
+#define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
+
 struct pvcreate_restorable_params {
 	const char *restorefile; /* 0 if no --restorefile option */
 	struct id id; /* FIXME: redundant */
@@ -477,17 +479,14 @@ uint32_t vg_read_error(struct volume_group *vg_handle);
 * areas can avoid overlap */
 struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev,
-				  struct id *id,
 				  uint64_t size,
 				  unsigned long data_alignment,
 				  unsigned long data_alignment_offset,
-				  uint64_t pe_start,
-				  uint32_t existing_extent_count,
-				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
 				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
-				  unsigned metadataignore);
+				  unsigned metadataignore,
+				  struct pvcreate_restorable_params *rp);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
 	      uint64_t size);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 025329f..2c071b0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1430,7 +1430,7 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->rp.restorefile = 0;
 	pp->rp.idp = 0;
-	pp->rp.pe_start = 0;
+	pp->rp.pe_start = PV_PE_START_CALC;
 	pp->rp.extent_count = 0;
 	pp->rp.extent_size = 0;
 }
@@ -1530,12 +1530,10 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 
 	dm_list_init(&mdas);
 
-	if (!(pv = pv_create(cmd, dev, pp->rp.idp, pp->size,
-			     pp->data_alignment, pp->data_alignment_offset,
-			     pp->rp.pe_start ? pp->rp.pe_start : PV_PE_START_CALC,
-			     pp->rp.extent_count, pp->rp.extent_size,
-			     pp->labelsector, pp->pvmetadatacopies,
-			     pp->pvmetadatasize, pp->metadataignore))) {
+	if (!(pv = pv_create(cmd, dev, pp->size, pp->data_alignment,
+			     pp->data_alignment_offset, pp->labelsector,
+			     pp->pvmetadatacopies, pp->pvmetadatasize,
+			     pp->metadataignore, &pp->rp))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto bad;
 	}
@@ -1602,16 +1600,14 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
  */
 struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev,
-				  struct id *id, uint64_t size,
+				  uint64_t size,
 				  unsigned long data_alignment,
 				  unsigned long data_alignment_offset,
-				  uint64_t pe_start,
-				  uint32_t existing_extent_count,
-				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
 				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
-				  unsigned metadataignore)
+				  unsigned metadataignore,
+				  struct pvcreate_restorable_params *rp)
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct dm_pool *mem = fmt->orphan_vg->vgmem;
@@ -1622,8 +1618,8 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	if (!pv)
 		return_NULL;
 
-	if (id)
-		memcpy(&pv->id, id, sizeof(*id));
+	if (rp->idp)
+		memcpy(&pv->id, rp->idp, sizeof(*rp->idp));
 	else if (!id_create(&pv->id)) {
 		log_error("Failed to create random uuid for %s.",
 			  dev_name(dev));
@@ -1669,9 +1665,8 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
-	if (!fmt->ops->pv_initialise(fmt, label_sector, pe_start,
-				     existing_extent_count, existing_extent_size,
-				     data_alignment, data_alignment_offset, pv)) {
+	if (!fmt->ops->pv_initialise(fmt, label_sector, data_alignment,
+				     data_alignment_offset, rp, pv)) {
 		log_error("Format-specific initialisation of physical "
 			  "volume %s failed.", pv_dev_name(pv));
 		goto bad;
@@ -1680,7 +1675,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	for (mda_index = 0; mda_index < pvmetadatacopies; mda_index++) {
 		if (pv->fmt->ops->pv_add_metadata_area &&
 		    !pv->fmt->ops->pv_add_metadata_area(pv->fmt, pv,
-					pe_start != PV_PE_START_CALC,
+					rp->pe_start != PV_PE_START_CALC,
 					mda_index, pvmetadatasize,
 					metadataignore)) {
 			log_error("Failed to add metadata area for "
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 830c0e1..f7b3409 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -35,7 +35,6 @@
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
 #define VG_MEMPOOL_CHUNK	10240	/* in bytes, hint only */
-#define PV_PE_START_CALC	((uint64_t) -1) /* Calculate pe_start value */
 
 /*
  * Ceiling(n / sz)
@@ -251,11 +250,9 @@ struct format_handler {
 	 */
 	int (*pv_initialise) (const struct format_type * fmt,
 			      int64_t label_sector,
-			      uint64_t pe_start,
-			      uint32_t extent_count,
-			      uint32_t extent_size,
 			      unsigned long data_alignment,
 			      unsigned long data_alignment_offset,
+			      struct pvcreate_restorable_params *rp,
 			      struct physical_volume * pv);
 
 	/*
diff --git a/tools/toollib.c b/tools/toollib.c
index c3c4dbe..3717bde 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1451,7 +1451,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment && pp->rp.pe_start) {
+	if (pp->data_alignment && pp->rp.pe_start != PV_PE_START_CALC) {
 		if (pp->rp.pe_start % pp->data_alignment)
 			log_warn("WARNING: Ignoring data alignment %" PRIu64
 				 " incompatible with --restorefile value (%"
@@ -1470,7 +1470,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment_offset && pp->rp.pe_start) {
+	if (pp->data_alignment_offset && pp->rp.pe_start != PV_PE_START_CALC) {
 		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
 			 " incompatible with --restorefile value (%"
 			 PRIu64").", pp->data_alignment_offset, pp->rp.pe_start);
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 2ba4095..85f68f2 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -20,11 +20,11 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    void *handle __attribute__((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
+	struct pvcreate_restorable_params rp;
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
-	uint64_t pe_start = 0;
 	struct pv_list *pvl;
 	int change_made = 0;
 	struct lvinfo info;
@@ -116,16 +116,19 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
 
-		pe_start = pv_pe_start(existing_pv);
+		rp.id = existing_pv->id;
+		rp.idp = &rp.id;
+		rp.pe_start = pv_pe_start(existing_pv);
+		rp.extent_count = pv_pe_count(existing_pv);
+		rp.extent_size = pv_pe_size(existing_pv);
+
 		/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1; */
 
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, 0, 0, 0,
-				     pe_start, pv_pe_count(existing_pv),
-				     pv_pe_size(existing_pv),
+				     0, 0, 0,
 				     arg_int64_value(cmd, labelsector_ARG,
 						     DEFAULT_LABELSECTOR),
-				     pvmetadatacopies, pvmetadatasize, 0))) {
+				     pvmetadatacopies, pvmetadatasize, 0, &rp))) {
 			log_error("Failed to setup physical volume \"%s\"",
 				  pv_dev_name(existing_pv));
 			if (change_made)


