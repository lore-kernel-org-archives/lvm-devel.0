From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 17:45:40 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20090730174540.30489.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 17:45:31

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	man            : pvcreate.8.in 
	tools          : args.h commands.h pvcreate.c vgconvert.c 

Log message:
	Add --dataalignmentoffset to pvcreate to shift start of aligned data area
	
	Adds pe_align_offset to 'struct physical_volume'; is initialized with
	set_pe_align_offset().  After pe_start is established pe_align_offset is
	added to it.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1215&r2=1.1216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.274&r2=1.275
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2009/07/30 17:42:33	1.1215
+++ LVM2/WHATS_NEW	2009/07/30 17:45:28	1.1216
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
   Preserve pe_start in .pv_setup and .pv_write if pe_start was supplied.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Formalize pe_start policy as split between .pv_setup and .pv_write.
--- LVM2/lib/format1/format1.c	2009/07/27 17:43:39	1.113
+++ LVM2/lib/format1/format1.c	2009/07/30 17:45:28	1.114
@@ -297,6 +297,7 @@
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     unsigned long data_alignment __attribute((unused)),
+		     unsigned long data_alignment_offset __attribute((unused)),
 		     int pvmetadatacopies __attribute((unused)),
 		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
--- LVM2/lib/format_pool/format_pool.c	2009/07/27 17:43:40	1.24
+++ LVM2/lib/format_pool/format_pool.c	2009/07/30 17:45:29	1.25
@@ -193,6 +193,7 @@
 			  uint32_t extent_count __attribute((unused)),
 			  uint32_t extent_size __attribute((unused)),
 			  unsigned long data_alignment __attribute((unused)),
+			  unsigned long data_alignment_offset __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
--- LVM2/lib/format_text/archiver.c	2009/07/15 20:02:47	1.27
+++ LVM2/lib/format_text/archiver.c	2009/07/30 17:45:29	1.28
@@ -320,7 +320,7 @@
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
--- LVM2/lib/format_text/format-text.c	2009/07/30 17:42:33	1.110
+++ LVM2/lib/format_text/format-text.c	2009/07/30 17:45:29	1.111
@@ -1180,7 +1180,7 @@
 		      struct physical_volume *pv,
 		      struct volume_group *vg __attribute((unused)))
 {
-	uint64_t mda_adjustment, disk_size, alignment;
+	uint64_t mda_adjustment, disk_size, alignment, alignment_offset;
 	uint64_t start1, mda_size1;	/* First area - start of disk */
 	uint64_t start2, mda_size2;	/* Second area - end of disk */
 	uint64_t wipe_size = 8 << SECTOR_SHIFT;
@@ -1190,6 +1190,7 @@
 		return 1;
 
 	alignment = pv->pe_align << SECTOR_SHIFT;
+	alignment_offset = pv->pe_align_offset << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
 	pe_start <<= SECTOR_SHIFT;
 	pe_end <<= SECTOR_SHIFT;
@@ -1223,6 +1224,15 @@
 			mda_size1 -= (alignment - mda_adjustment);
 	}
 
+	/* Add pe_align_offset if on pe_align boundary */
+	if (alignment_offset &&
+	    (((start1 + mda_size1) % alignment) == 0)) {
+		mda_size1 += alignment_offset;
+		/* Revert if it's now too large */
+		if (start1 + mda_size1 > disk_size)
+			mda_size1 -= alignment_offset;
+	}
+
 	/* Ensure it's not going to be bigger than the disk! */
 	if (start1 + mda_size1 > disk_size) {
 		log_warn("WARNING: metadata area fills disk leaving no "
@@ -1379,6 +1389,8 @@
 	 * sector after any metadata areas that begin before pe_start.
 	 */
 	pv->pe_start = pv->pe_align;
+	if (pv->pe_align_offset)
+		pv->pe_start += pv->pe_align_offset;
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1389,11 +1401,26 @@
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
 			    >> SECTOR_SHIFT;
-			adjustment = pv->pe_start % pv->pe_align;
+			/* Adjust pe_start to: (N * pe_align) + pe_align_offset */
+			adjustment =
+				(pv->pe_start - pv->pe_align_offset) % pv->pe_align;
 			if (adjustment)
 				pv->pe_start += pv->pe_align - adjustment;
+			log_very_verbose("%s: setting pe_start=%lu (orig_pe_start=%lu, "
+					 "pe_align=%lu, pe_align_offset=%lu, "
+					 "adjustment=%" PRIu64 ")",
+					 pv_dev_name(pv), pv->pe_start,
+					 (adjustment ?
+					  pv->pe_start -= pv->pe_align - adjustment :
+					  pv->pe_start),
+					 pv->pe_align, pv->pe_align_offset, adjustment);
 		}
 	}
+	if (pv->pe_start >= pv->size) {
+		log_error("Data area is beyond end of device %s!",
+			  pv_dev_name(pv));
+		return 0;
+	}
 
  preserve_pe_start:
 	if (!add_da
@@ -1617,6 +1644,7 @@
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1723,6 +1751,15 @@
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
+		set_pe_align_offset(pv, data_alignment_offset);
+
+		if (pv->pe_align < pv->pe_align_offset) {
+			log_error("%s: pe_align (%lu sectors) must not be less "
+				  "than pe_align_offset (%lu sectors)",
+				  pv_dev_name(pv), pv->pe_align, pv->pe_align_offset);
+			return 0;
+		}
+
 	preserve_pe_start:
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
--- LVM2/lib/metadata/metadata-exported.h	2009/07/29 13:26:01	1.106
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/30 17:45:29	1.107
@@ -183,6 +183,7 @@
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
 	unsigned long pe_align;
+	unsigned long pe_align_offset;
 
 	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
 	struct dm_list tags;
@@ -346,6 +347,7 @@
 	int zero;
 	uint64_t size;
 	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -424,6 +426,7 @@
 		      struct id *id,
 		      uint64_t size,
 		      unsigned long data_alignment,
+		      unsigned long data_alignment_offset,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
--- LVM2/lib/metadata/metadata.c	2009/07/29 13:26:01	1.274
+++ LVM2/lib/metadata/metadata.c	2009/07/30 17:45:29	1.275
@@ -93,6 +93,25 @@
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
@@ -154,7 +173,7 @@
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -1191,6 +1210,7 @@
 	pp->zero = 0;
 	pp->size = 0;
 	pp->data_alignment = UINT64_C(0);
+	pp->data_alignment_offset = UINT64_C(0);
 	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
 	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
 	pp->labelsector = DEFAULT_LABELSECTOR;
@@ -1249,8 +1269,8 @@
 
 	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
-			     pp->data_alignment, pp->pe_start,
-			     pp->extent_count, pp->extent_size,
+			     pp->data_alignment, pp->data_alignment_offset,
+			     pp->pe_start, pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
@@ -1319,6 +1339,7 @@
 	pv->pe_count = 0;
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
+	pv->pe_align_offset = 0;
 	pv->fmt = NULL;
 	pv->dev = dev;
 
@@ -1337,6 +1358,7 @@
  * @dev: PV device to initialize
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -1355,6 +1377,7 @@
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -1407,6 +1430,7 @@
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
+				data_alignment_offset,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
--- LVM2/lib/metadata/metadata.h	2009/07/29 13:26:01	1.197
+++ LVM2/lib/metadata/metadata.h	2009/07/30 17:45:29	1.198
@@ -213,6 +213,7 @@
 	int (*pv_setup) (const struct format_type * fmt,
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size, unsigned long data_alignment,
+			 unsigned long data_alignment_offset,
 			 int pvmetadatacopies,
 			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
@@ -267,6 +268,8 @@
  * Utility functions
  */
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
+unsigned long set_pe_align_offset(struct physical_volume *pv,
+				  unsigned long data_alignment_offset);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
--- LVM2/man/pvcreate.8.in	2009/02/22 19:00:28	1.3
+++ LVM2/man/pvcreate.8.in	2009/07/30 17:45:29	1.4
@@ -14,6 +14,7 @@
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-dataalignment alignment ]
+.RB [ \-\-dataalignmentoffset alignment_offset ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -91,13 +92,18 @@
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
@@ -128,13 +134,21 @@
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
--- LVM2/tools/args.h	2009/06/04 12:01:16	1.65
+++ LVM2/tools/args.h	2009/07/30 17:45:29	1.66
@@ -59,6 +59,7 @@
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 
--- LVM2/tools/commands.h	2009/07/06 19:13:26	1.129
+++ LVM2/tools/commands.h	2009/07/30 17:45:30	1.130
@@ -470,6 +470,7 @@
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
@@ -479,9 +480,9 @@
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
--- LVM2/tools/pvcreate.c	2009/07/26 01:54:20	1.83
+++ LVM2/tools/pvcreate.c	2009/07/30 17:45:30	1.84
@@ -96,7 +96,8 @@
 	if (!(cmd->fmt->features & FMT_MDAS) &&
 	    (arg_count(cmd, metadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG)   ||
-	     arg_count(cmd, dataalignment_ARG))) {
+	     arg_count(cmd, dataalignment_ARG)  ||
+	     arg_count(cmd, dataalignmentoffset_ARG))) {
 		log_error("Metadata and data alignment parameters only "
 			  "apply to text format.");
 		return 0;
@@ -140,6 +141,24 @@
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
--- LVM2/tools/vgconvert.c	2009/07/01 17:00:52	1.36
+++ LVM2/tools/vgconvert.c	2009/07/30 17:45:30	1.37
@@ -123,7 +123,7 @@
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0,
+				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {


