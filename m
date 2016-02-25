From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:54 +0000 (UTC)
Subject: master - redefine pvcreate structs
Message-ID: <20160225151554.8580960DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4de6caf5b5a1b7eef80fc9ed56ac0cf8b7776ac4
Commit:        4de6caf5b5a1b7eef80fc9ed56ac0cf8b7776ac4
Parent:        c201ee09bdfdfccecd5975ee26537cf790b25e25
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 18 15:31:27 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:10 2016 -0600

redefine pvcreate structs

New pv_create_args struct contains all the specific
parameters for creating a PV, independent of the
command.
---
 lib/format1/format1.c            |   32 ++++++-------
 lib/format_pool/format_pool.c    |    5 +--
 lib/format_text/archiver.c       |   27 +++--------
 lib/format_text/archiver.h       |    5 +--
 lib/format_text/format-text.c    |   43 +++++++++---------
 lib/metadata/metadata-exported.h |   55 ++++++++--------------
 lib/metadata/metadata.c          |   86 ++++++++++++++----------------------
 lib/metadata/metadata.h          |    5 +--
 liblvm/lvm_prop.c                |   20 ++++----
 liblvm/lvm_pv.c                  |    8 ++--
 tools/pvcreate.c                 |   16 +++---
 tools/toollib.c                  |   92 ++++++++++++++++----------------------
 tools/vgconvert.c                |   24 ++++------
 13 files changed, 168 insertions(+), 250 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 30bb696..b3569e0 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -345,10 +345,7 @@ static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
 }
 
 static int _format1_pv_initialise(const struct format_type * fmt,
-				  int64_t label_sector __attribute__((unused)),
-				  unsigned long data_alignment __attribute__((unused)),
-				  unsigned long data_alignment_offset __attribute__((unused)),
-				  struct pvcreate_restorable_params *rp,
+				  struct pv_create_args *pva,
 				  struct physical_volume * pv)
 {
 	if (pv->size > MAX_PV_SIZE)
@@ -360,18 +357,18 @@ static int _format1_pv_initialise(const struct format_type * fmt,
 	}
 
 	/* Nothing more to do if extent size isn't provided */
-	if (!rp->extent_size)
+	if (!pva->extent_size)
 		return 1;
 
 	/*
 	 * This works out pe_start and pe_count.
 	 */
-	if (!calculate_extent_count(pv, rp->extent_size, rp->extent_count, rp->pe_start))
+	if (!calculate_extent_count(pv, pva->extent_size, pva->extent_count, pva->pe_start))
 		return_0;
 
 	/* Retain existing extent locations exactly */
-	if (((rp->pe_start || rp->extent_count) && (rp->pe_start != pv->pe_start)) ||
-	    (rp->extent_count && (rp->extent_count != pv->pe_count))) {
+	if (((pva->pe_start || pva->extent_count) && (pva->pe_start != pv->pe_start)) ||
+	    (pva->extent_count && (pva->extent_count != pv->pe_count))) {
 		log_error("Metadata would overwrite physical extents");
 		return 0;
 	}
@@ -383,16 +380,15 @@ static int _format1_pv_setup(const struct format_type *fmt,
 			     struct physical_volume *pv,
 			     struct volume_group *vg)
 {
-	struct pvcreate_restorable_params rp = {.restorefile = NULL,
-						.id = {{0}},
-						.idp = NULL,
-						.ba_start = 0,
-						.ba_size = 0,
-						.pe_start = 0,
-						.extent_count = 0,
-						.extent_size = vg->extent_size};
-
-	return _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv);
+	struct pv_create_args pva = { .id = {{0}},
+				      .idp = NULL,
+				      .ba_start = 0,
+				      .ba_size = 0,
+				      .pe_start = 0,
+				      .extent_count = 0,
+				      .extent_size = vg->extent_size};
+
+	return _format1_pv_initialise(fmt, &pva, pv);
 }
 
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index d7792a2..f6e5e01 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -166,10 +166,7 @@ bad:
 }
 
 static int _pool_pv_initialise(const struct format_type *fmt __attribute__((unused)),
-			       int64_t label_sector __attribute__((unused)),
-			       unsigned long data_alignment __attribute__((unused)),
-			       unsigned long data_alignment_offset __attribute__((unused)),
-			       struct pvcreate_restorable_params *rp __attribute__((unused)),
+			       struct pv_create_args *pva __attribute__((unused)),
 			       struct physical_volume *pv __attribute__((unused)))
 {
 	return 1;
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 07dece3..b92f4a5 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -361,13 +361,8 @@ static int _restore_vg_should_write_pv(struct physical_volume *pv, int do_pvcrea
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 		      int drop_lvmetad,
 		      int do_pvcreate,
-		      uint64_t bootloaderareasize,
-		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize,
-		      uint64_t label_sector)
-
+		      struct pv_create_args *pva)
 {
-	struct pvcreate_restorable_params rp = { 0 };
 	struct dm_list new_pvs;
 	struct pv_list *pvl, *new_pvl;
 	struct physical_volume *existing_pv, *pv;
@@ -389,20 +384,14 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			existing_pv = pvl->pv;
 
-			rp.id = existing_pv->id;
-			rp.idp = &rp.id;
-			rp.pe_start = pv_pe_start(existing_pv);
-			rp.extent_count = pv_pe_count(existing_pv);
-			rp.extent_size = pv_pe_size(existing_pv);
-			rp.ba_size = bootloaderareasize;
+			pva->id = existing_pv->id;
+			pva->idp = &pva->id;
+			pva->pe_start = pv_pe_start(existing_pv);
+			pva->extent_count = pv_pe_count(existing_pv);
+			pva->extent_size = pv_pe_size(existing_pv);
 			/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1 */
 
-			if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-					     0, 0, 0,
-					     label_sector,
-					     pvmetadatacopies,
-					     pvmetadatasize,
-					     0, &rp))) {
+			if (!(pv = pv_create(cmd, pv_dev(existing_pv), pva))) {
 				log_error("Failed to setup physical volume \"%s\".",
 					  pv_dev_name(existing_pv));
 				return 0;
@@ -561,7 +550,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg, 1, 0, 0, 0, 0, 0);
+		r = backup_restore_vg(cmd, vg, 1, 0, NULL);
 	else
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index b8e53e3..82f7620 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -55,10 +55,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
                       int drop_lvmetad,
                       int do_pvcreate,
-                      uint64_t bootloaderareasize,
-                      int pvmetadatacopies,
-                      uint64_t pvmetadatasize,
-                      uint64_t label_sector);
+		      struct pv_create_args *pva);
 
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file, int force);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 72ca198..408e63c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1550,12 +1550,11 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 }
 
 static int _text_pv_initialise(const struct format_type *fmt,
-			       const int64_t label_sector,
-			       unsigned long data_alignment,
-			       unsigned long data_alignment_offset,
-			       struct pvcreate_restorable_params *rp,
+			       struct pv_create_args *pva,
 			       struct physical_volume *pv)
 {
+	unsigned long data_alignment = pva->data_alignment;
+	unsigned long data_alignment_offset = pva->data_alignment_offset;
 	unsigned long adjustment, final_alignment = 0;
 
 	if (!data_alignment)
@@ -1592,13 +1591,13 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (pv->size < final_alignment + rp->ba_size) {
+	if (pv->size < final_alignment + pva->ba_size) {
 		log_error("%s: Bootloader area with data-aligned start must "
 			  "not exceed device size.", pv_dev_name(pv));
 		return 0;
 	}
 
-	if (rp->pe_start == PV_PE_START_CALC) {
+	if (pva->pe_start == PV_PE_START_CALC) {
 		/*
 		 * Calculate new PE start and bootloader area start value.
 		 * Make sure both are properly aligned!
@@ -1608,10 +1607,10 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * This needs to be done as we can't have a PV without any DA.
 		 * But we still want to support a PV with BA only!
 		 */
-		if (rp->ba_size) {
+		if (pva->ba_size) {
 			pv->ba_start = final_alignment;
-			pv->ba_size = rp->ba_size;
-			if ((adjustment = rp->ba_size % pv->pe_align))
+			pv->ba_size = pva->ba_size;
+			if ((adjustment = pva->ba_size % pv->pe_align))
 				pv->ba_size += pv->pe_align - adjustment;
 			if (pv->size < pv->ba_start + pv->ba_size)
 				pv->ba_size = pv->size - pv->ba_start;
@@ -1626,26 +1625,26 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * it in between the final alignment and existing PE start
 		 * if possible.
 		 */
-		pv->pe_start = rp->pe_start;
-		if (rp->ba_size) {
-			if ((rp->ba_start && rp->ba_start + rp->ba_size > rp->pe_start) ||
-			    (rp->pe_start <= final_alignment) ||
-			    (rp->pe_start - final_alignment < rp->ba_size)) {
+		pv->pe_start = pva->pe_start;
+		if (pva->ba_size) {
+			if ((pva->ba_start && pva->ba_start + pva->ba_size > pva->pe_start) ||
+			    (pva->pe_start <= final_alignment) ||
+			    (pva->pe_start - final_alignment < pva->ba_size)) {
 				log_error("%s: Bootloader area would overlap "
 					  "data area.", pv_dev_name(pv));
 				return 0;
 			} else {
-				pv->ba_start = rp->ba_start ? : final_alignment;
-				pv->ba_size = rp->ba_size;
+				pv->ba_start = pva->ba_start ? : final_alignment;
+				pv->ba_size = pva->ba_size;
 			}
 		}
 	}
 
-	if (rp->extent_size)
-		pv->pe_size = rp->extent_size;
+	if (pva->extent_size)
+		pv->pe_size = pva->extent_size;
 
-	if (rp->extent_count)
-		pv->pe_count = rp->extent_count;
+	if (pva->extent_count)
+		pv->pe_count = pva->extent_count;
 
 	if ((pv->pe_start + pv->pe_count * (uint64_t)pv->pe_size - 1) > pv->size) {
 		log_error("Physical extents end beyond end of device %s.",
@@ -1653,8 +1652,8 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (label_sector != -1)
-                pv->label_sector = label_sector;
+	if (pva->label_sector != -1)
+                pv->label_sector = pva->label_sector;
 
 	return 1;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9c6abd7..c5dee05 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -517,10 +517,21 @@ struct vgnameid_list {
 
 #define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
 
-struct pvcreate_restorable_params {
-	const char *restorefile; /* 0 if no --restorefile option */
-	struct id id; /* FIXME: redundant */
-	struct id *idp; /* 0 if no --uuid option */
+/*
+ * Values used by pv_create().
+ */
+struct pv_create_args {
+	uint64_t size;
+	unsigned long data_alignment;
+	unsigned long data_alignment_offset;
+	uint64_t label_sector;
+	int pvmetadatacopies;
+	uint64_t pvmetadatasize;
+	unsigned metadataignore;
+
+	/* used when restoring */
+	struct id id;
+	struct id *idp;
 	uint64_t ba_start;
 	uint64_t ba_size;
 	uint64_t pe_start;
@@ -530,16 +541,10 @@ struct pvcreate_restorable_params {
 
 struct pvcreate_params {
 	int zero;
-	uint64_t size;
-	uint64_t data_alignment;
-	uint64_t data_alignment_offset;
-	int pvmetadatacopies;
-	uint64_t pvmetadatasize;
-	int64_t labelsector;
 	force_t force;
 	unsigned yes;
-	unsigned metadataignore;
-	struct pvcreate_restorable_params rp;
+	const char *restorefile; /* 0 if no --restorefile option */
+	struct pv_create_args pva;
 };
 
 /*
@@ -557,31 +562,19 @@ struct pvcreate_each_params {
 	 * From command line args.
 	 */
 	int zero;
-	uint64_t size;
-	uint64_t data_alignment;
-	uint64_t data_alignment_offset;
-	int pvmetadatacopies;
-	uint64_t pvmetadatasize;
-	int64_t labelsector;
 	force_t force;
 	unsigned yes;
-	unsigned metadataignore;
 
 	/*
 	 * From recovery-specific command line args.
 	 */
 	const char *restorefile; /* NULL if no --restorefile option */
 	const char *uuid_str;    /* id in printable format, NULL if no id */
-	struct id id;
 
 	/*
-	 * From reading VG backup file.
+	 * Values used by pv_create().
 	 */
-	uint64_t ba_start;
-	uint64_t ba_size;
-	uint64_t pe_start;
-	uint32_t extent_count;
-	uint32_t extent_size;
+	struct pv_create_args pva;
 
 	/*
 	 * Used for command processing.
@@ -722,15 +715,7 @@ uint32_t vg_read_error(struct volume_group *vg_handle);
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 struct physical_volume *pv_create(const struct cmd_context *cmd,
-				  struct device *dev,
-				  uint64_t size,
-				  unsigned long data_alignment,
-				  unsigned long data_alignment_offset,
-				  uint64_t label_sector,
-				  unsigned pvmetadatacopies,
-				  uint64_t pvmetadatasize,
-				  unsigned metadataignore,
-				  struct pvcreate_restorable_params *rp);
+				  struct device *dev, struct pv_create_args *pva);
 
 int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		    void *handle __attribute__((unused)), unsigned force_count,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5a51782..aafc4ce 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1682,25 +1682,24 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
 	pp->zero = 1;
-	pp->size = 0;
-	pp->data_alignment = UINT64_C(0);
-	pp->data_alignment_offset = UINT64_C(0);
-	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
-	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
-	pp->labelsector = DEFAULT_LABELSECTOR;
 	pp->force = PROMPT;
 	pp->yes = 0;
-	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
-	pp->rp.restorefile = 0;
-	pp->rp.idp = 0;
-	pp->rp.ba_start = 0;
-	pp->rp.ba_size = 0;
-	pp->rp.pe_start = PV_PE_START_CALC;
-	pp->rp.extent_count = 0;
-	pp->rp.extent_size = 0;
+	pp->restorefile = 0;
+	pp->pva.size = 0;
+	pp->pva.data_alignment = UINT64_C(0);
+	pp->pva.data_alignment_offset = UINT64_C(0);
+	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->pva.label_sector = DEFAULT_LABELSECTOR;
+	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
+	pp->pva.idp = 0;
+	pp->pva.ba_start = 0;
+	pp->pva.ba_size = 0;
+	pp->pva.pe_start = PV_PE_START_CALC;
+	pp->pva.extent_count = 0;
+	pp->pva.extent_size = 0;
 }
 
-
 static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
 	struct physical_volume *pv = pvw->pv;
@@ -1753,17 +1752,17 @@ static int _verify_pv_create_params(struct pvcreate_params *pp)
 	/*
 	 * FIXME: Some of these checks are duplicates in pvcreate_params_validate.
 	 */
-	if (pp->pvmetadatacopies > 2) {
+	if (pp->pva.pvmetadatacopies > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return 0;
 	}
 
-	if (pp->data_alignment > UINT32_MAX) {
+	if (pp->pva.data_alignment > UINT32_MAX) {
 		log_error("Physical volume data alignment is too big.");
 		return 0;
 	}
 
-	if (pp->data_alignment_offset > UINT32_MAX) {
+	if (pp->pva.data_alignment_offset > UINT32_MAX) {
 		log_error("Physical volume data alignment offset is too big.");
 		return 0;
 	}
@@ -1802,10 +1801,10 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 		goto bad;
 	}
 
-	if (pp->rp.idp) {
-		if ((dev = lvmcache_device_from_pvid(cmd, pp->rp.idp, NULL, NULL)) &&
+	if (pp->pva.idp) {
+		if ((dev = lvmcache_device_from_pvid(cmd, pp->pva.idp, NULL, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->full_filter))) {
-			if (!id_write_format((const struct id*)&pp->rp.idp->uuid,
+			if (!id_write_format((const struct id*)&pp->pva.idp->uuid,
 			    buffer, sizeof(buffer)))
 				goto_bad;
 			log_error("uuid %s already in use on \"%s\"", buffer,
@@ -1847,10 +1846,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 
 	dm_list_init(&mdas);
 
-	if (!(pv = pv_create(cmd, dev, pp->size, pp->data_alignment,
-			     pp->data_alignment_offset, pp->labelsector,
-			     pp->pvmetadatacopies, pp->pvmetadatasize,
-			     pp->metadataignore, &pp->rp))) {
+	if (!(pv = pv_create(cmd, dev, &pp->pva))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto bad;
 	}
@@ -1895,47 +1891,32 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
  * pv_create - initialize a physical volume for use with a volume group
  * created PV belongs to Orphan VG.
  *
- * @fmt: format type
- * @dev: PV device to initialize
- * @size: size of the PV in sectors
- * @data_alignment: requested alignment of data
- * @data_alignment_offset: requested offset to aligned data
- * @pe_start: physical extent start
- * @existing_extent_count
- * @existing_extent_size
- * @pvmetadatacopies
- * @pvmetadatasize
- * @mdas
- *
  * Returns:
  *   PV handle - physical volume initialized successfully
  *   NULL - invalid parameter or problem initializing the physical volume
- *
- * Note:
- *   FIXME: shorten argument list and replace with explict 'set' functions
  */
+
 struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev,
-				  uint64_t size,
-				  unsigned long data_alignment,
-				  unsigned long data_alignment_offset,
-				  uint64_t label_sector,
-				  unsigned pvmetadatacopies,
-				  uint64_t pvmetadatasize,
-				  unsigned metadataignore,
-				  struct pvcreate_restorable_params *rp)
+				  struct pv_create_args *pva)
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct dm_pool *mem = fmt->orphan_vg->vgmem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 	unsigned mda_index;
 	struct pv_list *pvl;
+	uint64_t size = pva->size;
+	unsigned long data_alignment = pva->data_alignment;
+	unsigned long data_alignment_offset = pva->data_alignment_offset;
+	unsigned pvmetadatacopies = pva->pvmetadatacopies;
+	uint64_t pvmetadatasize = pva->pvmetadatasize;
+	unsigned metadataignore = pva->metadataignore;
 
 	if (!pv)
 		return_NULL;
 
-	if (rp->idp)
-		memcpy(&pv->id, rp->idp, sizeof(*rp->idp));
+	if (pva->idp)
+		memcpy(&pv->id, pva->idp, sizeof(*pva->idp));
 	else if (!id_create(&pv->id)) {
 		log_error("Failed to create random uuid for %s.",
 			  dev_name(dev));
@@ -1981,8 +1962,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
-	if (!fmt->ops->pv_initialise(fmt, label_sector, data_alignment,
-				     data_alignment_offset, rp, pv)) {
+	if (!fmt->ops->pv_initialise(fmt, pva, pv)) {
 		log_error("Format-specific initialisation of physical "
 			  "volume %s failed.", pv_dev_name(pv));
 		goto bad;
@@ -1991,7 +1971,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	for (mda_index = 0; mda_index < pvmetadatacopies; mda_index++) {
 		if (pv->fmt->ops->pv_add_metadata_area &&
 		    !pv->fmt->ops->pv_add_metadata_area(pv->fmt, pv,
-					rp->pe_start != PV_PE_START_CALC,
+					pva->pe_start != PV_PE_START_CALC,
 					mda_index, pvmetadatasize,
 					metadataignore)) {
 			log_error("Failed to add metadata area for "
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 192f88e..91e5961 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -256,10 +256,7 @@ struct format_handler {
 	 * Initialise a new PV.
 	 */
 	int (*pv_initialise) (const struct format_type * fmt,
-			      int64_t label_sector,
-			      unsigned long data_alignment,
-			      unsigned long data_alignment_offset,
-			      struct pvcreate_restorable_params *rp,
+			      struct pv_create_args *pva,
 			      struct physical_volume * pv);
 
 	/*
diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
index f269a7f..d5b1493 100644
--- a/liblvm/lvm_prop.c
+++ b/liblvm/lvm_prop.c
@@ -21,20 +21,20 @@ GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 SET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 
 /* PV create parameters */
-GET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->size)
-SET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->size)
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->pva.size)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->pva.size)
 
-GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pvmetadatacopies)
-SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pvmetadatacopies)
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pva.pvmetadatacopies)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pva.pvmetadatacopies)
 
-GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pvmetadatasize)
-SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pvmetadatasize)
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pva.pvmetadatasize)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pva.pvmetadatasize)
 
-GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->data_alignment)
-SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->data_alignment)
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->pva.data_alignment)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->pva.data_alignment)
 
-GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->data_alignment_offset)
-SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->data_alignment_offset)
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->pva.data_alignment_offset)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->pva.data_alignment_offset)
 
 GET_PVCREATEPARAMS_NUM_PROPERTY_FN(zero, pvcp->zero)
 SET_PVCREATEPARAMS_NUM_PROPERTY_FN(zero, pvcp->zero)
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 9bc7153..4c40b8b 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -421,12 +421,12 @@ static int _pv_create(pv_create_params_t params)
 	struct cmd_context *cmd = (struct cmd_context *)params->libh;
 	int rc = 0;
 
-	if (params->pv_p.size) {
-		if (params->pv_p.size % SECTOR_SIZE) {
+	if (params->pv_p.pva.size) {
+		if (params->pv_p.pva.size % SECTOR_SIZE) {
 			log_errno(EINVAL, "Size not a multiple of 512");
 			return -1;
 		}
-		params->pv_p.size = params->pv_p.size >> SECTOR_SHIFT;
+		params->pv_p.pva.size = params->pv_p.pva.size >> SECTOR_SHIFT;
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
@@ -448,7 +448,7 @@ int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
 	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
 	if (_lvm_pv_params_create(libh, pv_name, &pp)) {
-		pp.pv_p.size = size;
+		pp.pv_p.pva.size = size;
 		rc = _pv_create(&pp);
 	}
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 47eb85c..92356b3 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -47,7 +47,7 @@ static int pvcreate_each_restore_params_from_args(struct cmd_context *cmd, int a
 
 	if (arg_count(cmd, uuidstr_ARG)) {
 		pp->uuid_str = arg_str_value(cmd, uuidstr_ARG, "");
-		if (!id_read_format(&pp->id, pp->uuid_str))
+		if (!id_read_format(&pp->pva.id, pp->uuid_str))
 			return 0;
 	}
 
@@ -55,7 +55,7 @@ static int pvcreate_each_restore_params_from_args(struct cmd_context *cmd, int a
 		log_error("Physical volume size may not be negative");
 		return 0;
 	}
-	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
+	pp->pva.size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
 	if (arg_count(cmd, restorefile_ARG) || arg_count(cmd, uuidstr_ARG))
 		pp->zero = 0;
@@ -79,18 +79,18 @@ static int pvcreate_each_restore_params_from_backup(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, &pp->id))) {
+	if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, &pp->pva.id))) {
 		release_vg(vg);
 		log_error("Can't find uuid %s in backup file %s",
 			  pp->uuid_str, pp->restorefile);
 		return 0;
 	}
 
-	pp->ba_start = pv_ba_start(existing_pvl->pv);
-	pp->ba_size = pv_ba_size(existing_pvl->pv);
-	pp->pe_start = pv_pe_start(existing_pvl->pv);
-	pp->extent_size = pv_pe_size(existing_pvl->pv);
-	pp->extent_count = pv_pe_count(existing_pvl->pv);
+	pp->pva.ba_start = pv_ba_start(existing_pvl->pv);
+	pp->pva.ba_size = pv_ba_size(existing_pvl->pv);
+	pp->pva.pe_start = pv_pe_start(existing_pvl->pv);
+	pp->pva.extent_size = pv_pe_size(existing_pvl->pv);
+	pp->pva.extent_count = pv_pe_count(existing_pvl->pv);
 
 	release_vg(vg);
 	return 1;
diff --git a/tools/toollib.c b/tools/toollib.c
index dc025e4..b640285 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3430,22 +3430,23 @@ void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp)
 	memset(pp, 0, sizeof(*pp));
 
 	pp->zero = 1;
-	pp->size = 0;
-	pp->data_alignment = UINT64_C(0);
-	pp->data_alignment_offset = UINT64_C(0);
-	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
-	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
-	pp->labelsector = DEFAULT_LABELSECTOR;
 	pp->force = PROMPT;
 	pp->yes = 0;
-	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->restorefile = NULL;
 	pp->uuid_str = NULL;
-	pp->ba_start = 0;
-	pp->ba_size = 0;
-	pp->pe_start = PV_PE_START_CALC;
-	pp->extent_count = 0;
-	pp->extent_size = 0;
+
+	pp->pva.size = 0;
+	pp->pva.data_alignment = UINT64_C(0);
+	pp->pva.data_alignment_offset = UINT64_C(0);
+	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->pva.label_sector = DEFAULT_LABELSECTOR;
+	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
+	pp->pva.ba_start = 0;
+	pp->pva.ba_size = 0;
+	pp->pva.pe_start = PV_PE_START_CALC;
+	pp->pva.extent_count = 0;
+	pp->pva.extent_size = 0;
 
 	dm_list_init(&pp->prompts);
 	dm_list_init(&pp->arg_devices);
@@ -3467,7 +3468,7 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 			  LABEL_SCAN_SECTORS);
 		return 0;
 	} else {
-		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
+		pp->pva.label_sector = arg_int64_value(cmd, labelsector_ARG,
 						  DEFAULT_LABELSECTOR);
 	}
 
@@ -3489,14 +3490,14 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 	}
 
 	if (arg_count(cmd, metadataignore_ARG))
-		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
+		pp->pva.metadataignore = arg_int_value(cmd, metadataignore_ARG,
 						   DEFAULT_PVMETADATAIGNORE);
 	else
-		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
+		pp->pva.metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
 
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
-	    pp->metadataignore) {
+	    pp->pva.metadataignore) {
 		log_error("metadataignore only applies to metadatacopies > 0");
 		return 0;
 	}
@@ -3507,9 +3508,9 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 		log_error("Physical volume data alignment may not be negative.");
 		return 0;
 	}
-	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
+	pp->pva.data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
 
-	if (pp->data_alignment > UINT32_MAX) {
+	if (pp->pva.data_alignment > UINT32_MAX) {
 		log_error("Physical volume data alignment is too big.");
 		return 0;
 	}
@@ -3518,22 +3519,22 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 		log_error("Physical volume data alignment offset may not be negative");
 		return 0;
 	}
-	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
+	pp->pva.data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
 
-	if (pp->data_alignment_offset > UINT32_MAX) {
+	if (pp->pva.data_alignment_offset > UINT32_MAX) {
 		log_error("Physical volume data alignment offset is too big.");
 		return 0;
 	}
 
-	if ((pp->data_alignment + pp->data_alignment_offset) &&
-	    (pp->pe_start != PV_PE_START_CALC)) {
-		if ((pp->data_alignment ? pp->pe_start % pp->data_alignment : pp->pe_start) != pp->data_alignment_offset) {
+	if ((pp->pva.data_alignment + pp->pva.data_alignment_offset) &&
+	    (pp->pva.pe_start != PV_PE_START_CALC)) {
+		if ((pp->pva.data_alignment ? pp->pva.pe_start % pp->pva.data_alignment : pp->pva.pe_start) != pp->pva.data_alignment_offset) {
 			log_warn("WARNING: Ignoring data alignment %s"
 				 " incompatible with restored pe_start value %s)",
-				 display_size(cmd, pp->data_alignment + pp->data_alignment_offset),
-				 display_size(cmd, pp->pe_start));
-			pp->data_alignment = 0;
-			pp->data_alignment_offset = 0;
+				 display_size(cmd, pp->pva.data_alignment + pp->pva.data_alignment_offset),
+				 display_size(cmd, pp->pva.pe_start));
+			pp->pva.data_alignment = 0;
+			pp->pva.data_alignment_offset = 0;
 		}
 	}
 
@@ -3547,20 +3548,20 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 		return 0;
 	}
 
-	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
+	pp->pva.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+	if (!pp->pva.pvmetadatasize)
+		pp->pva.pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
-	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+	pp->pva.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+	if (pp->pva.pvmetadatacopies < 0)
+		pp->pva.pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 
-	if (pp->pvmetadatacopies > 2) {
+	if (pp->pva.pvmetadatacopies > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return 0;
 	}
 
-	pp->ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->ba_size);
+	pp->pva.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->pva.ba_size);
 
 	return 1;
 }
@@ -3763,7 +3764,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	/*
 	 * Check if the uuid specified for the new PV is used by another PV.
 	 */
-	if (!found && pv->dev && pp->uuid_str && id_equal(&pv->id, &pp->id)) {
+	if (!found && pv->dev && pp->uuid_str && id_equal(&pv->id, &pp->pva.id)) {
 		log_error("uuid %s already in use on \"%s\"", pp->uuid_str, pv_dev_name(pv));
 		pp->check_failed = 1;
 		return 0;
@@ -4114,7 +4115,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 			 struct processing_handle *handle,
 			 struct pvcreate_each_params *pp)
 {
-	struct pvcreate_restorable_params rp;
 	struct pvcreate_device *pd, *pd2;
 	struct pvcreate_prompt *prompt, *prompt2;
 	struct physical_volume *pv;
@@ -4445,23 +4445,7 @@ do_command:
 
 		log_debug("Creating a new PV on %s", pv_name);
 
-		/* FIXME: get rid of rp usage in pv_create to avoid this. */
-		memset(&rp, 0, sizeof(rp));
-		rp.restorefile = pp->restorefile;
-		if (pp->uuid_str) {
-			rp.id = pp->id;
-			rp.idp = &pp->id;
-		}
-		rp.ba_start = pp->ba_start;
-		rp.ba_size = pp->ba_size;
-		rp.pe_start = pp->pe_start;
-		rp.extent_count = pp->extent_count;
-		rp.extent_size = pp->extent_size;
-
-		if (!(pv = pv_create(cmd, pd->dev, pp->size, pp->data_alignment,
-				     pp->data_alignment_offset, pp->labelsector,
-				     pp->pvmetadatacopies, pp->pvmetadatasize,
-				     pp->metadataignore, &rp))) {
+		if (!(pv = pv_create(cmd, pd->dev, &pp->pva))) {
 			log_error("Failed to setup physical volume \"%s\"", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 1462d77..666b484 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -19,13 +19,11 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    struct processing_handle *handle __attribute__((unused)))
 {
+	struct pv_create_args pva = { 0 };
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 	struct lvinfo info;
 	int active = 0;
-	int pvmetadatacopies = 0;
-	uint64_t pvmetadatasize = 0;
-	uint64_t bootloaderareasize = 0;
 
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return_ECMD_FAILED;
@@ -42,13 +40,13 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			return EINVALID_CMD_LINE;
 		}
 
-		pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-		if (!pvmetadatasize)
-			pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
+		pva.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+		if (!pva.pvmetadatasize)
+			pva.pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
-		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-		if (pvmetadatacopies < 0)
-			pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+		pva.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+		if (pva.pvmetadatacopies < 0)
+			pva.pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 	}
 
 	if (cmd->fmt->features & FMT_BAS) {
@@ -57,7 +55,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			return EINVALID_CMD_LINE;
 		}
 
-		bootloaderareasize = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
+		pva.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
 	}
 
 	if (!vg_check_new_extent_size(cmd->fmt, vg->extent_size))
@@ -128,11 +126,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
 
-	if (!backup_restore_vg(cmd, vg, 0, 1,
-			       bootloaderareasize,
-			       pvmetadatacopies,
-			       pvmetadatasize,
-			       arg_int64_value(cmd, labelsector_ARG, DEFAULT_LABELSECTOR))) {
+	if (!backup_restore_vg(cmd, vg, 0, 1, &pva)) {
 		log_error("Conversion failed for volume group %s.", vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");


