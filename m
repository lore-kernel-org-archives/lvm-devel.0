From: Mike Snitzer <snitzer@redhat.com>
Date: Sun, 26 Jul 2009 00:20:36 -0400
Subject: Re: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to shift start of aligned data area
In-Reply-To: <1248560096-28641-2-git-send-email-snitzer@redhat.com>
References: <1248560096-28641-1-git-send-email-snitzer@redhat.com>
	<1248560096-28641-2-git-send-email-snitzer@redhat.com>
Message-ID: <20090726042036.GA29629@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

[patch updated in response to the recent liblvm pvcreate changes]

Implement pvcreate --dataalignmentoffset to shift the start of
the aligned data area.

Adds pe_align_offset to 'struct physical_volume'; is initialized with
set_pe_align_offset().  After pe_start is established pe_align_offset is
added to it.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                        |    1 +
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   17 ++++++++++++++++-
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/metadata.c          |   30 +++++++++++++++++++++++++++---
 lib/metadata/metadata.h          |    3 +++
 man/pvcreate.8.in                |   20 +++++++++++++++++---
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++++---
 tools/pvcreate.c                 |   18 ++++++++++++++++++
 tools/vgconvert.c                |    2 +-
 13 files changed, 94 insertions(+), 12 deletions(-)

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW
+++ LVM2/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
   Add global/wait_for_locks to lvm.conf so blocking for locks can be disabled.
   All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
   Fix race condition with vgcreate and vgextend on same device (2.02.49).
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
@@ -1382,8 +1382,16 @@ static int _text_pv_write(const struct f
 			adjustment = pv->pe_start % pv->pe_align;
 			if (adjustment)
 				pv->pe_start += pv->pe_align - adjustment;
+			if (pv->pe_align_offset)
+				pv->pe_start += pv->pe_align_offset;
 		}
 	}
+	if (pv->pe_start >= pv->size) {
+		log_error("Data area is beyond end of device %s!",
+			  pv_dev_name(pv));
+		return 0;
+	}
+
 	if (!add_da
 	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
 		return_0;
@@ -1598,6 +1606,7 @@ static struct metadata_area_ops _metadat
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1702,8 +1711,14 @@ static int _text_pv_setup(const struct f
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
-		if (pv->pe_start < pv->pe_align)
+		if (!pe_start)
+			set_pe_align_offset(pv, data_alignment_offset);
+
+		if (pv->pe_start < pv->pe_align) {
 			pv->pe_start = pv->pe_align;
+			if (pv->pe_align_offset)
+				pv->pe_start += pv->pe_align_offset;
+		}
 
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -184,6 +184,7 @@ struct physical_volume {
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
 	unsigned long pe_align;
+	unsigned long pe_align_offset;
 
 	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
 	struct dm_list tags;
@@ -341,6 +342,7 @@ struct pvcreate_params {
 	int zero;
 	uint64_t size;
 	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -418,6 +420,7 @@ pv_t *pv_create(const struct cmd_context
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
@@ -96,6 +96,25 @@ out:
 	return pv->pe_align;
 }
 
+unsigned long set_pe_align_offset(struct physical_volume *pv,
+				  unsigned long data_alignment_offset)
+{
+	if (pv->pe_align_offset)
+		goto out;
+
+	if (data_alignment_offset)
+		pv->pe_align_offset = data_alignment_offset;
+
+	if (!pv->dev)
+		goto out;
+
+	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
+			 dev_name(pv->dev), pv->pe_align_offset);
+
+out:
+	return pv->pe_align_offset;
+}
+
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
  * @vg - volume group to add to
@@ -157,7 +176,7 @@ int add_pv_to_vg(struct volume_group *vg
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -1117,6 +1136,7 @@ static void fill_default_pvcreate_params
 	pp->zero = 0;
 	pp->size = 0;
 	pp->data_alignment = UINT64_C(0);
+	pp->data_alignment_offset = UINT64_C(0);
 	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
 	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
 	pp->labelsector = DEFAULT_LABELSECTOR;
@@ -1175,8 +1195,8 @@ pv_t * pvcreate_single(struct cmd_contex
 
 	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
-			     pp->data_alignment, pp->pe_start,
-			     pp->extent_count, pp->extent_size,
+			     pp->data_alignment, pp->data_alignment_offset,
+			     pp->pe_start, pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
@@ -1245,6 +1265,7 @@ static struct physical_volume *_alloc_pv
 	pv->pe_count = 0;
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
+	pv->pe_align_offset = 0;
 	pv->fmt = NULL;
 	pv->dev = dev;
 
@@ -1263,6 +1284,7 @@ static struct physical_volume *_alloc_pv
  * @dev: PV device to initialize
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -1281,6 +1303,7 @@ struct physical_volume *pv_create(const 
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -1333,6 +1356,7 @@ struct physical_volume *pv_create(const 
 
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
@@ -267,6 +268,8 @@ struct format_handler {
  * Utility functions
  */
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
+unsigned long set_pe_align_offset(struct physical_volume *pv,
+				  unsigned long data_alignment_offset);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
Index: LVM2/man/pvcreate.8.in
===================================================================
--- LVM2.orig/man/pvcreate.8.in
+++ LVM2/man/pvcreate.8.in
@@ -14,6 +14,7 @@ pvcreate \- initialize a disk or partiti
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
+.RB [ \-\-dataalignmentoffset alignment_offset ]
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
+\fBalignment\fP.  In addition it may be shifted by \fBalignment_offset\fP from
+\fBdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
+\fB--dataalignmentoffset\fP.
+.TP
+.BR \-\-dataalignmentoffset " alignment_offset"
+Shift the start of the data area by this additional \fBalignment_offset\fP.
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
@@ -140,6 +140,24 @@ static int pvcreate_validate_params(stru
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


