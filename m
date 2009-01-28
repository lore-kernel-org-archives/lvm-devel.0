From: Milan Broz <mbroz@redhat.com>
Date: Wed, 28 Jan 2009 13:07:20 +0100
Subject: [PATCH] Add --align parameter to pvcreate
Message-ID: <49804A78.3020302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add --align parameter to pvcreate.

Some RAID controllers suggest align volumes
to stripe or chunk size.

Currently lvm2 align LVs to underlying MD device chunk automatically,
but there is no proper way to set this parameter directly
for other RAID drivers.

Note that it is not as the same as metadata area size.

I think we should provide possibility for system administrator
to force PV data payload alignment during PV creation.
(Also it is administrator or distro installator responsibility
to set proper physical extent size later during vgcreate.)

Patch adds --align to pvcreate (default is size in MB).

pe_align() function now takes force_pe_align parameter, which
can overwrite data alignment if set to non-zero.

Patch also fixes that after vgremove the orphan PV data align
value is not rewritten by default.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                        |    1 +
 lib/format_text/format-text.c    |   13 +++++++++----
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   34 ++++++++++++++++++++++++++--------
 lib/metadata/metadata.h          |    2 +-
 man/pvcreate.8.in                |    7 +++++++
 tools/args.h                     |    1 +
 tools/commands.h                 |    5 +++--
 tools/pvcreate.c                 |   14 +++++++++++++-
 tools/vgconvert.c                |    2 +-
 10 files changed, 63 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29c3cd2..c9b3d8e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add --align parameter to pvcreate to allow specify payload align directly.
   Replace internal vg_check_status() implementation.
   Rename vg_read() to vg_read_internal().
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 428b5e2..74c8759 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1182,7 +1182,7 @@ static int _mda_setup(const struct format_type *fmt,
 	if (!pvmetadatacopies)
 		return 1;
 
-	alignment = pe_align(pv) << SECTOR_SHIFT;
+	alignment = pe_align(pv, 0) << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
 	pe_start <<= SECTOR_SHIFT;
 	pe_end <<= SECTOR_SHIFT;
@@ -1347,9 +1347,14 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	else
 		dm_list_init(&info->das);
 
+	/*
+	 * Keep PV data alignment if already set
+	 */
+	if (pv->pe_start < pe_align(pv, 0))
+		pv->pe_start = pe_align(pv, 0);
+
 	/* Set pe_start to first aligned sector after any metadata
 	 * areas that begin before pe_start */
-	pv->pe_start = pe_align(pv);
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1358,9 +1363,9 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
 			    >> SECTOR_SHIFT;
-			adjustment = pv->pe_start % pe_align(pv);
+			adjustment = pv->pe_start % pe_align(pv, 0);
 			if (adjustment)
-				pv->pe_start += (pe_align(pv) - adjustment);
+				pv->pe_start += (pe_align(pv, 0) - adjustment);
 		}
 	}
 	if (!add_da
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e785383..b25e30d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -407,6 +407,7 @@ pv_t *pv_create(const struct cmd_context *cmd,
 		      struct device *dev,
 		      struct id *id,
 		      uint64_t size,
+		      unsigned long req_pe_align,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0130bd3..dd3e975 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -46,6 +46,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
+				  unsigned long align,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -65,9 +66,9 @@ static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
-unsigned long pe_align(struct physical_volume *pv)
+unsigned long pe_align(struct physical_volume *pv, unsigned long force_pe_align)
 {
-	if (pv->pe_align)
+	if (pv->pe_align && !force_pe_align)
 		goto out;
 
 	pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
@@ -84,6 +85,9 @@ unsigned long pe_align(struct physical_volume *pv)
 				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
 						     pv->dev));
 
+	if (force_pe_align)
+		pv->pe_align = MAX(pv->pe_align, force_pe_align);
+
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align);
 
@@ -148,8 +152,8 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 
 	/* FIXME Do proper rounding-up alignment? */
 	/* Reserved space for label; this holds 0 for PVs created by LVM1 */
-	if (pv->pe_start < pe_align(pv))
-		pv->pe_start = pe_align(pv);
+	if (pv->pe_start < pe_align(pv, 0))
+		pv->pe_start = pe_align(pv, 0);
 
 	/*
 	 * pe_count must always be calculated by pv_setup
@@ -759,6 +763,7 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
  * @dev: PV device to initialize
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
+ * @req_pe_align: requested alignment of payload
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -776,13 +781,14 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
 pv_t *pv_create(const struct cmd_context *cmd,
 		struct device *dev,
 		struct id *id, uint64_t size,
+		unsigned long req_pe_align,
 		uint64_t pe_start,
 		uint32_t existing_extent_count,
 		uint32_t existing_extent_size,
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct dm_list *mdas)
 {
-	return _pv_create(cmd->fmt, dev, id, size, pe_start,
+	return _pv_create(cmd->fmt, dev, id, size, req_pe_align, pe_start,
 			  existing_extent_count,
 			  existing_extent_size,
 			  pvmetadatacopies,
@@ -826,6 +832,7 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
+				  unsigned long req_pe_align,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -860,9 +867,11 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 		pv->size = size;
 	}
 
-	if (pv->size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
-			  pv_dev_name(pv), PV_MIN_SIZE);
+	if (pv->size < (req_pe_align + PV_MIN_SIZE)) {
+		log_error("%s: Size %smust exceed minimum of %ld sectors.",
+			  pv_dev_name(pv),
+			  req_pe_align ? "after data alignment " : "",
+			  PV_MIN_SIZE);
 		goto bad;
 	}
 
@@ -877,6 +886,15 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 			  "failed.", pv_dev_name(pv));
 		goto bad;
 	}
+
+	/*
+	 * Force data alignment if specified
+	 */
+	if (req_pe_align && pe_align(pv, req_pe_align) != req_pe_align)
+		log_warn("%s: Overriding data aligmnent to %lu sectors"
+			 " (requested %lu sectors)", pv_dev_name(pv),
+			 pe_align(pv, 0), req_pe_align);
+
 	return pv;
 
       bad:
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c425fbf..c982b78 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -263,7 +263,7 @@ struct format_handler {
 /*
  * Utility functions
  */
-unsigned long pe_align(struct physical_volume *pv);
+unsigned long pe_align(struct physical_volume *pv, unsigned long force_pe_align);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 7ecda56..bfecc5b 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -13,6 +13,7 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-M | \-\-metadatatype type ]
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
+.RB [ \-\-align size ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -89,6 +90,12 @@ to see where the metadata areas are placed.
 The approximate amount of space to be set aside for each metadata area.
 (The size you specify may get rounded.)
 .TP
+.BR \-\-align " size"
+Force align start of the payload to specified boundary (to align
+with underlying RAID device stripe or chunk).
+Note that you should use properly sized physical extent later
+in vgcreate to correctly align all Logical Volumes start too.
+.TP
 .BR \-\-metadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
 this can be 0, 1 or 2.  
diff --git a/tools/args.h b/tools/args.h
index 8f026fc..80a23bb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -56,6 +56,7 @@ arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
+arg(physicalvolumealign_ARG, '\0', "align", size_mb_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 58c6156..4007639 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -462,6 +462,7 @@ xx(pvcreate,
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--align Size[kKmM]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
@@ -472,8 +473,8 @@ xx(pvcreate,
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   metadatasize_ARG, physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG,
-   yes_ARG, zero_ARG)
+   metadatasize_ARG, physicalvolumealign_ARG, physicalvolumesize_ARG,
+   restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index db1a0e2..4507009 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -19,6 +19,7 @@
 struct pvcreate_params {
 	int zero;
 	uint64_t size;
+	uint64_t align;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -177,7 +178,7 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 	}
 
 	dm_list_init(&mdas);
-	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
+	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->align, pp->pe_start,
 			     pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
@@ -329,6 +330,17 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	}
 	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
+	if (arg_sign_value(cmd, physicalvolumealign_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume alignment may not be negative");
+		return 0;
+	}
+	pp->align = arg_uint64_value(cmd, physicalvolumealign_ARG, UINT64_C(0));
+
+	if (pp->align > ULONG_MAX) {
+		log_error("Physical volume alignment is too big.");
+		return 0;
+	}
+
 	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
 		log_error("Metadata size may not be negative");
 		return 0;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index dc9d023..209d597 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -133,7 +133,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size,
+				     &existing_pv->id, size, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {



