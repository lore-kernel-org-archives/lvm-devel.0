From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Jun 2009 18:55:06 -0400
Subject: [PATCH 2/4] pvcreate: --dataalignmentoffset
In-Reply-To: <1245452108-25318-1-git-send-email-snitzer@redhat.com>
References: <1245452108-25318-1-git-send-email-snitzer@redhat.com>
Message-ID: <1245452108-25318-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement pvcreate --dataalignmentoffset to pad offset of the start of
the aligned data area (pe_start).

Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                        |    1 +
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   24 +++++++++++++++++++++---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   10 ++++++++--
 lib/metadata/metadata.h          |    1 +
 man/pvcreate.8.in                |   18 ++++++++++++++++--
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++++---
 tools/pvcreate.c                 |   23 +++++++++++++++++++++--
 tools/vgconvert.c                |    2 +-
 13 files changed, 78 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eaeb925..7990d13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Implement pvcreate --dataalignmentoffset to pad offset of pe_start.
   Update the man pages to uniformly document size units.
   Allow specifying commandline sizes in terms of bytes and sectors.
   Explicitly request fallback to default major number in device mapper.
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index c8f9519..538b882 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -296,6 +296,7 @@ static int _format1_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     unsigned long data_alignment __attribute((unused)),
+		     unsigned long data_alignment_offset __attribute((unused)),
 		     int pvmetadatacopies __attribute((unused)),
 		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 3f31bba..2cc1fd9 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -192,6 +192,7 @@ static int _pool_pv_setup(const struct format_type *fmt __attribute((unused)),
 			  uint32_t extent_count __attribute((unused)),
 			  uint32_t extent_size __attribute((unused)),
 			  unsigned long data_alignment __attribute((unused)),
+			  unsigned long data_alignment_offset __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index d80c0ba..f9966f4 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -316,7 +316,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4181335..0022a9e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1175,12 +1175,13 @@ static int _text_scan(const struct format_type *fmt)
    Always have an mda between end-of-label and pe_align() boundary */
 static int _mda_setup(const struct format_type *fmt,
 		      uint64_t pe_start, uint64_t pe_end,
+		      unsigned long data_alignment_offset,
 		      int pvmetadatacopies,
 		      uint64_t pvmetadatasize, struct dm_list *mdas,
 		      struct physical_volume *pv,
 		      struct volume_group *vg __attribute((unused)))
 {
-	uint64_t mda_adjustment, disk_size, alignment;
+	uint64_t mda_adjustment, adjustment, disk_size, alignment;
 	uint64_t start1, mda_size1;	/* First area - start of disk */
 	uint64_t start2, mda_size2;	/* Second area - end of disk */
 	uint64_t wipe_size = 8 << SECTOR_SHIFT;
@@ -1251,6 +1252,22 @@ static int _mda_setup(const struct format_type *fmt,
 			return 0;
 		}
 
+		if (data_alignment_offset && !pe_start && !pe_end) {
+			/*
+			 * proactively adjust pv->pe_start to allow for
+			 * proper padding with data_alignment_offset
+			 * - doing so in _text_pv_write is too late given
+			 *   its lack of data_alignment_offset info
+			 */
+			pv->pe_start = (start1 + mda_size1) >> SECTOR_SHIFT;
+			/* round up to pe_align boundry */
+			adjustment = pv->pe_start % pv->pe_align;
+			if (adjustment)
+				pv->pe_start += (pv->pe_align - adjustment);
+
+			pv->pe_start += data_alignment_offset;
+		}
+
 		if (pvmetadatacopies == 1)
 			return 1;
 	} else
@@ -1598,6 +1615,7 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1707,8 +1725,8 @@ static int _text_pv_setup(const struct format_type *fmt,
 
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
-		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, mdas, pv, vg))
+		if (!_mda_setup(fmt, pe_start, pe_end, data_alignment_offset,
+				pvmetadatacopies, pvmetadatasize, mdas, pv, vg))
 			return_0;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 278d21c..f86fb2c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -426,6 +426,7 @@ pv_t *pv_create(const struct cmd_context *cmd,
 		      struct id *id,
 		      uint64_t size,
 		      unsigned long data_alignment,
+		      unsigned long data_alignment_offset,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 36e27fc..c5ab9ed 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -48,6 +48,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -157,7 +158,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -787,6 +788,7 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -805,13 +807,15 @@ pv_t *pv_create(const struct cmd_context *cmd,
 		struct device *dev,
 		struct id *id, uint64_t size,
 		unsigned long data_alignment,
+		unsigned long data_alignment_offset,
 		uint64_t pe_start,
 		uint32_t existing_extent_count,
 		uint32_t existing_extent_size,
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct dm_list *mdas)
 {
-	return _pv_create(cmd->fmt, dev, id, size, data_alignment, pe_start,
+	return _pv_create(cmd->fmt, dev, id, size,
+			  data_alignment, data_alignment_offset, pe_start,
 			  existing_extent_count,
 			  existing_extent_size,
 			  pvmetadatacopies,
@@ -856,6 +860,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -907,6 +912,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
+				data_alignment_offset,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ceb089c..ab66e39 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -213,6 +213,7 @@ struct format_handler {
 	int (*pv_setup) (const struct format_type * fmt,
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size, unsigned long data_alignment,
+			 unsigned long data_alignment_offset,
 			 int pvmetadatacopies,
 			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 4d48805..cbcaa9f 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -14,6 +14,7 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
+.RB [ \-\-dataalignmentoffset offset ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -97,7 +98,12 @@ the Volume Group with \fBvgcreate\fP.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
-\fBdata_alignment\fP.
+\fBalignment\fP plus the \fBalignment_offset\fP from
+\fBdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
+\fB--dataalignmentoffset\fP.
+.TP
+.BR \-\-dataalignmentoffset " alignment_offset"
+The offset of the start of the aligned data area will include \fBalignment_offset\fP.
 .TP
 .BR \-\-metadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
@@ -128,13 +134,21 @@ in the source).  Use with care.
 .TP
 .BR \-\-setphysicalvolumesize " size"
 Overrides the automatically-detected size of the PV.  Use with care.
-.SH Example
+.SH EXAMPLES
 Initialize partition #4 on the third SCSI disk and the entire fifth
 SCSI disk for later use by LVM:
 .sp
 .B pvcreate /dev/sdc4 /dev/sde
 .sp
+If the 2nd SCSI disk is a 4KB sector drive that compensates for windows
+partitioning (sector 7 is the lowest aligned logical block, the 4KB
+sectors start at LBA -1, and consequently sector 63 is aligned on a 4KB
+boundary) manually account for this when initializing for use by LVM:
+.sp
+.B pvcreate --dataalignmentoffset 7S /dev/sdb
+.sp
 .SH SEE ALSO
+.BR lvm.conf (5),
 .BR lvm (8),
 .BR vgcreate (8), 
 .BR vgextend (8), 
diff --git a/tools/args.h b/tools/args.h
index 846b6c2..f5db50e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -59,6 +59,7 @@ arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 
diff --git a/tools/commands.h b/tools/commands.h
index 1bfbf46..eed131f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -468,6 +468,7 @@ xx(pvcreate,
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[sSbBkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[sSbBkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignmentoffset AlignmentOffset[sSbBkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[sSbBkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
@@ -477,9 +478,9 @@ xx(pvcreate,
    "\t[--version] " "\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   dataalignment_ARG, force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
-   metadatacopies_ARG, metadatasize_ARG, physicalvolumesize_ARG,
-   restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
+   dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
+   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, metadatasize_ARG,
+   physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 0f71df5..da0d407 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -20,6 +20,7 @@ struct pvcreate_params {
 	int zero;
 	uint64_t size;
 	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -203,8 +204,8 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 
 	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
-			     pp->data_alignment, pp->pe_start,
-			     pp->extent_count, pp->extent_size,
+			     pp->data_alignment, pp->data_alignment_offset,
+			     pp->pe_start, pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
@@ -377,6 +378,24 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 		pp->data_alignment = 0;
 	}
 
+	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment offset may not be negative");
+		return 0;
+	}
+	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
+
+	if (pp->data_alignment_offset > ULONG_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment_offset && pp->pe_start) {
+		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
+			 " incompatible with --restorefile value (%"
+			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
+		pp->data_alignment_offset = 0;
+	}
+
 	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
 		log_error("Metadata size may not be negative");
 		return 0;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index ec5032e..3c43a61 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -120,7 +120,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0,
+				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
-- 
1.6.2.2


