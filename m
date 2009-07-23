From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 22 Jul 2009 22:53:02 -0400
Subject: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <1248317587-11187-1-git-send-email-snitzer@redhat.com>
References: <1248317587-11187-1-git-send-email-snitzer@redhat.com>
Message-ID: <1248317587-11187-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement pvcreate --dataalignmentoffset to pad the start of
the aligned data area.

Added pe_align_offset to 'struct physical_volume'; Added
set_pe_align_offset().  After pe_start is initialized pe_align_offset is
added to it.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                        |    1 +
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   11 ++++++++++-
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   30 ++++++++++++++++++++++++++++--
 lib/metadata/metadata.h          |    3 +++
 man/pvcreate.8.in                |   20 +++++++++++++++++---
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 ++++---
 tools/pvcreate.c                 |   23 +++++++++++++++++++++--
 tools/vgconvert.c                |    2 +-
 13 files changed, 91 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49e803a..92fed6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add --dataalignmentoffset to pvcreate to pad aligned data area.
   Add liblvm2app Makefile installation targets.
   Add liblvm pkgconfig file.
   Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.
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
index 6d744ed..a3fd4bd 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -320,7 +320,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d8e03f0..32af70b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1382,6 +1382,8 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 			adjustment = pv->pe_start % pv->pe_align;
 			if (adjustment)
 				pv->pe_start += pv->pe_align - adjustment;
+			if (pv->pe_align_offset)
+				pv->pe_start += pv->pe_align_offset;
 		}
 	}
 	if (!add_da
@@ -1598,6 +1600,7 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1702,8 +1705,14 @@ static int _text_pv_setup(const struct format_type *fmt,
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9d8d542..3594f65 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -184,6 +184,7 @@ struct physical_volume {
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
 	unsigned long pe_align;
+	unsigned long pe_align_offset;
 
 	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
 	struct dm_list tags;
@@ -398,6 +399,7 @@ pv_t *pv_create(const struct cmd_context *cmd,
 		      struct id *id,
 		      uint64_t size,
 		      unsigned long data_alignment,
+		      unsigned long data_alignment_offset,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 03e0810..0dbb7bc 100644
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
@@ -102,6 +103,25 @@ out:
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
@@ -163,7 +183,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -979,6 +999,7 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -997,13 +1018,15 @@ pv_t *pv_create(const struct cmd_context *cmd,
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
@@ -1032,6 +1055,7 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 	pv->pe_count = 0;
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
+	pv->pe_align_offset = 0;
 	pv->fmt = NULL;
 	pv->dev = dev;
 
@@ -1048,6 +1072,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -1099,6 +1124,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
+				data_alignment_offset,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ceb089c..e9129fb 100644
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
@@ -267,6 +268,8 @@ struct format_handler {
  * Utility functions
  */
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
+unsigned long set_pe_align_offset(struct physical_volume *pv,
+				  unsigned long data_alignment_offset);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 4d48805..ce65448 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -14,6 +14,7 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
+.RB [ \-\-dataalignmentoffset alignment_offset ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -91,13 +92,18 @@ The approximate amount of space to be set aside for each metadata area.
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
index 8559799..7f9feee 100644
--- a/tools/commands.h
+++ b/tools/commands.h
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
index 0996d95..a8b064d 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -123,7 +123,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0,
+				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
-- 
1.6.2.5


