From: Mike Snitzer <snitzer@redhat.com>
Date: Sun, 7 Jun 2009 23:40:12 -0400
Subject: [RFC PATCH] pvcreate --dataalignmentoffset
Message-ID: <20090608034011.GA28846@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

The following patch has been tested to work but I just wanted to verify
that I've headed in the right direction before building on it (getting
alignment_offset from sysfs, lvm.conf option, pvcreate man page, etc).

The key to this working is to adjust pv->pe_start after the first mda's
start and size is known (in _mda_setup).

tested with:
pvcreate --dataalignmentoffset 3.75K /dev/loop0

thanks,
Mike

Index: lib/format1/format1.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/format1/format1.c,v
retrieving revision 1.112
diff -u -p -r1.112 format1.c
--- lib/format1/format1.c	10 Apr 2009 09:59:18 -0000	1.112
+++ lib/format1/format1.c	8 Jun 2009 03:19:03 -0000
@@ -296,6 +296,7 @@ static int _format1_pv_setup(const struc
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
 		     unsigned long data_alignment __attribute((unused)),
+		     unsigned long data_alignment_offset __attribute((unused)),
 		     int pvmetadatacopies __attribute((unused)),
 		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
Index: lib/format_pool/format_pool.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/format_pool/format_pool.c,v
retrieving revision 1.23
diff -u -p -r1.23 format_pool.c
--- lib/format_pool/format_pool.c	13 May 2009 21:22:57 -0000	1.23
+++ lib/format_pool/format_pool.c	8 Jun 2009 03:19:04 -0000
@@ -192,6 +192,7 @@ static int _pool_pv_setup(const struct f
 			  uint32_t extent_count __attribute((unused)),
 			  uint32_t extent_size __attribute((unused)),
 			  unsigned long data_alignment __attribute((unused)),
+			  unsigned long data_alignment_offset __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
Index: lib/format_text/archiver.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/format_text/archiver.c,v
retrieving revision 1.25
diff -u -p -r1.25 archiver.c
--- lib/format_text/archiver.c	19 May 2009 09:45:33 -0000	1.25
+++ lib/format_text/archiver.c	8 Jun 2009 03:19:04 -0000
@@ -316,7 +316,7 @@ int backup_restore_vg(struct cmd_context
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
Index: lib/format_text/format-text.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/format_text/format-text.c,v
retrieving revision 1.105
diff -u -p -r1.105 format-text.c
--- lib/format_text/format-text.c	7 May 2009 12:11:51 -0000	1.105
+++ lib/format_text/format-text.c	8 Jun 2009 03:19:04 -0000
@@ -1175,12 +1175,13 @@ static int _text_scan(const struct forma
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
@@ -1251,6 +1252,22 @@ static int _mda_setup(const struct forma
 			return 0;
 		}
 
+		if (!pe_start && !pe_end) {
+			/*
+			 * proactively adjust pv->pe_start to allow for
+			 * proper padding with data_alignment_offset
+			 * - _text_pv_write is too late given the lack of info
+			 */
+			pv->pe_start = (start1 + mda_size1) >> SECTOR_SHIFT;
+			/* round up to pe_align boundry */
+			adjustment = pv->pe_start % pv->pe_align;
+			if (adjustment)
+				pv->pe_start += (pv->pe_align - adjustment);
+
+			if (data_alignment_offset)
+				pv->pe_start += data_alignment_offset;
+		}
+
 		if (pvmetadatacopies == 1)
 			return 1;
 	} else
@@ -1598,6 +1615,7 @@ static struct metadata_area_ops _metadat
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
+		     unsigned long data_alignment_offset,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1707,8 +1725,8 @@ static int _text_pv_setup(const struct f
 
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
-		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, mdas, pv, vg))
+		if (!_mda_setup(fmt, pe_start, pe_end, data_alignment_offset,
+				pvmetadatacopies, pvmetadatasize, mdas, pv, vg))
 			return_0;
 	}
 
Index: lib/metadata/metadata-exported.h
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/metadata-exported.h,v
retrieving revision 1.76
diff -u -p -r1.76 metadata-exported.h
--- lib/metadata/metadata-exported.h	5 Jun 2009 20:00:52 -0000	1.76
+++ lib/metadata/metadata-exported.h	8 Jun 2009 03:19:05 -0000
@@ -423,6 +423,7 @@ pv_t *pv_create(const struct cmd_context
 		      struct id *id,
 		      uint64_t size,
 		      unsigned long data_alignment,
+		      unsigned long data_alignment_offset,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
Index: lib/metadata/metadata.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/metadata.c,v
retrieving revision 1.224
diff -u -p -r1.224 metadata.c
--- lib/metadata/metadata.c	1 Jun 2009 12:43:32 -0000	1.224
+++ lib/metadata/metadata.c	8 Jun 2009 03:19:05 -0000
@@ -48,6 +48,7 @@ static struct physical_volume *_pv_creat
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -157,7 +158,7 @@ int add_pv_to_vg(struct volume_group *vg
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0UL, UINT64_C(0),
+				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -787,6 +788,7 @@ int vg_split_mdas(struct cmd_context *cm
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
  * @data_alignment: requested alignment of data
+ * @data_alignment_offset: requested offset to aligned data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -805,13 +807,15 @@ pv_t *pv_create(const struct cmd_context
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
@@ -856,6 +860,7 @@ static struct physical_volume *_pv_creat
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
+				  unsigned long data_alignment_offset,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -907,6 +912,7 @@ static struct physical_volume *_pv_creat
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
+				data_alignment_offset,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
Index: lib/metadata/metadata.h
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/metadata.h,v
retrieving revision 1.196
diff -u -p -r1.196 metadata.h
--- lib/metadata/metadata.h	1 Jun 2009 12:43:32 -0000	1.196
+++ lib/metadata/metadata.h	8 Jun 2009 03:19:06 -0000
@@ -213,6 +213,7 @@ struct format_handler {
 	int (*pv_setup) (const struct format_type * fmt,
 			 uint64_t pe_start, uint32_t extent_count,
 			 uint32_t extent_size, unsigned long data_alignment,
+			 unsigned long data_alignment_offset,
 			 int pvmetadatacopies,
 			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
Index: tools/args.h
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/args.h,v
retrieving revision 1.65
diff -u -p -r1.65 args.h
--- tools/args.h	4 Jun 2009 12:01:16 -0000	1.65
+++ tools/args.h	8 Jun 2009 03:19:06 -0000
@@ -59,6 +59,7 @@ arg(nameprefixes_ARG, '\0', "nameprefixe
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 
Index: tools/commands.h
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/commands.h,v
retrieving revision 1.127
diff -u -p -r1.127 commands.h
--- tools/commands.h	4 Jun 2009 12:01:16 -0000	1.127
+++ tools/commands.h	8 Jun 2009 03:19:06 -0000
@@ -468,6 +468,7 @@ xx(pvcreate,
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[kKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignmentoffset AlignmentOffset[kKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
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
Index: tools/pvcreate.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/pvcreate.c,v
retrieving revision 1.81
diff -u -p -r1.81 pvcreate.c
--- tools/pvcreate.c	10 Apr 2009 10:01:38 -0000	1.81
+++ tools/pvcreate.c	8 Jun 2009 03:19:06 -0000
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
Index: tools/vgconvert.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/vgconvert.c,v
retrieving revision 1.35
diff -u -p -r1.35 vgconvert.c
--- tools/vgconvert.c	5 Jun 2009 20:00:52 -0000	1.35
+++ tools/vgconvert.c	8 Jun 2009 03:19:06 -0000
@@ -120,7 +120,7 @@ static int vgconvert_single(struct cmd_c
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0,
+				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {


