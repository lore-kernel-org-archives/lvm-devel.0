From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:17 -0400
Subject: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
Message-ID: <1247515882-13736-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement pvcreate --dataalignmentoffset to pad the start of
the aligned data area.

When setting up the first mda, format-text.c:_mda_setup now sets the
pe_start to immediately follow the first mda (which ends at a pe_align
boundry).  data_alignment_offset will be added to pe_start if
--dataalignmentoffset was used.

Testing included verifying 'pvcreate --metadatacopies 2' works
(2nd mda's location on disk isn't affected by data_alignment_offset).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                        |    1 +
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   16 ++++++++++++++--
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   10 ++++++++--
 lib/metadata/metadata.h          |    1 +
 man/pvcreate.8.in                |   20 +++++++++++++++++---
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++++---
 tools/pvcreate.c                 |   23 +++++++++++++++++++++--
 tools/vgconvert.c                |    2 +-
 13 files changed, 72 insertions(+), 14 deletions(-)

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW
+++ LVM2/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Add --dataalignmentoffset to pvcreate to pad aligned data area.
   Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.
   Make all tools consistent with lock ordering - obtain VG_ORPHAN lock second.
Index: LVM2/lib/format1/format1.c
===================================================================
--- LVM2.orig/lib/format1/format1.c
+++ LVM2/lib/format1/format1.c
@@ -296,6 +296,7 @@ static int _format1_pv_setup(const struc
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     unsigned long data_alignment __attribute((unused)),
+		     unsigned long data_alignment_offset __attribute((unused)),
 		     int pvmetadatacopies __attribute((unused)),
 		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
Index: LVM2/lib/format_pool/format_pool.c
===================================================================
--- LVM2.orig/lib/format_pool/format_pool.c
+++ LVM2/lib/format_pool/format_pool.c
@@ -192,6 +192,7 @@ static int _pool_pv_setup(const struct f
 			  uint32_t extent_count __attribute((unused)),
 			  uint32_t extent_size __attribute((unused)),
 			  unsigned long data_alignment __attribute((unused)),
+			  unsigned long data_alignment_offset __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
Index: LVM2/lib/format_text/archiver.c
===================================================================
--- LVM2.orig/lib/format_text/archiver.c
+++ LVM2/lib/format_text/archiver.c
@@ -320,7 +320,7 @@ int backup_restore_vg(struct cmd_context
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
Index: LVM2/lib/format_text/format-text.c
===================================================================
--- LVM2.orig/lib/format_text/format-text.c
+++ LVM2/lib/format_text/format-text.c
@@ -1175,6 +1175,7 @@ static int _text_scan(const struct forma
    Always have an mda between end-of-label and pe_align() boundary */
 static int _mda_setup(const struct format_type *fmt,
 		      uint64_t pe_start, uint64_t pe_end,
+		      unsigned long data_alignment_offset,
 		      int pvmetadatacopies,
 		      uint64_t pvmetadatasize, struct dm_list *mdas,
 		      struct physical_volume *pv,
@@ -1251,6 +1252,16 @@ static int _mda_setup(const struct forma
 			return 0;
 		}
 
+		if (!pe_start && !pe_end) {
+			/*
+			 * Set PV's pe_start to immediately follow the
+			 * first mda (which ends at a pe_align boundary)
+			 */
+			pv->pe_start = (start1 + mda_size1) >> SECTOR_SHIFT;
+			if (data_alignment_offset)
+				pv->pe_start += data_alignment_offset;
+		}
+
 		if (pvmetadatacopies == 1)
 			return 1;
 	} else
@@ -1598,6 +1609,7 @@ static struct metadata_area_ops _metadat
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1707,8 +1719,8 @@ static int _text_pv_setup(const struct f
 
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
-		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, mdas, pv, vg))
+		if (!_mda_setup(fmt, pe_start, pe_end, data_alignment_offset,
+				pvmetadatacopies, pvmetadatasize, mdas, pv, vg))
 			return_0;
 	}
 
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -402,6 +402,7 @@ pv_t *pv_create(const struct cmd_context
 		      struct id *id,
 		      uint64_t size,
 		      unsigned long data_alignment,
+		      unsigned long data_alignment_offset,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c
+++ LVM2/lib/metadata/metadata.c
@@ -48,6 +48,7 @@ static struct physical_volume *_pv_creat
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -161,7 +162,7 @@ int add_pv_to_vg(struct volume_group *vg
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -904,6 +905,7 @@ int vg_split_mdas(struct cmd_context *cm
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -922,13 +924,15 @@ pv_t *pv_create(const struct cmd_context
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
@@ -973,6 +977,7 @@ static struct physical_volume *_pv_creat
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -1024,6 +1029,7 @@ static struct physical_volume *_pv_creat
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
+				data_alignment_offset,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
Index: LVM2/lib/metadata/metadata.h
===================================================================
--- LVM2.orig/lib/metadata/metadata.h
+++ LVM2/lib/metadata/metadata.h
@@ -213,6 +213,7 @@ struct format_handler {
 	int (*pv_setup) (const struct format_type * fmt,
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size, unsigned long data_alignment,
+			 unsigned long data_alignment_offset,
 			 int pvmetadatacopies,
 			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
Index: LVM2/man/pvcreate.8.in
===================================================================
--- LVM2.orig/man/pvcreate.8.in
+++ LVM2/man/pvcreate.8.in
@@ -14,6 +14,7 @@ pvcreate \- initialize a disk or partiti
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
+.RB [ \-\-dataalignmentoffset offset ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -91,13 +92,18 @@ The approximate amount of space to be se
 (The size you specify may get rounded.)
 .TP
 .BR \-\-dataalignment " alignment"
-Align the offset of the start of the data to a multiple of this number.
+Align the start of the data to a multiple of this number.
 You should also specify an appropriate \fBPhysicalExtentSize\fP when creating
 the Volume Group with \fBvgcreate\fP.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
-\fBdata_alignment\fP.
+\fBalignment\fP.  In addition it may be padded by \fBalignment_offset\fP from
+\fBdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
+\fB--dataalignmentoffset\fP.
+.TP
+.BR \-\-dataalignmentoffset " alignment_offset"
+Pad the start of the data with this additional \fBalignment_offset\fP.
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
+.B pvcreate --dataalignmentoffset 7s /dev/sdb
+.sp
 .SH SEE ALSO
+.BR lvm.conf (5),
 .BR lvm (8),
 .BR vgcreate (8), 
 .BR vgextend (8), 
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -59,6 +59,7 @@ arg(nameprefixes_ARG, '\0', "nameprefixe
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -470,6 +470,7 @@ xx(pvcreate,
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
@@ -479,9 +480,9 @@ xx(pvcreate,
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
Index: LVM2/tools/pvcreate.c
===================================================================
--- LVM2.orig/tools/pvcreate.c
+++ LVM2/tools/pvcreate.c
@@ -20,6 +20,7 @@ struct pvcreate_params {
 	int zero;
 	uint64_t size;
 	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -203,8 +204,8 @@ static int pvcreate_single(struct cmd_co
 
 	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
-			     pp->data_alignment, pp->pe_start,
-			     pp->extent_count, pp->extent_size,
+			     pp->data_alignment, pp->data_alignment_offset,
+			     pp->pe_start, pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
@@ -377,6 +378,24 @@ static int pvcreate_validate_params(stru
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
Index: LVM2/tools/vgconvert.c
===================================================================
--- LVM2.orig/tools/vgconvert.c
+++ LVM2/tools/vgconvert.c
@@ -123,7 +123,7 @@ static int vgconvert_single(struct cmd_c
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0,
+				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {


