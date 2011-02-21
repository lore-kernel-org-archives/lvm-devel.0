From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:20:20 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20110221122020.474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:20:19

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.h 

Log message:
	Separate new pv_initialise function out of the original pv_setup code.
	
	pv_initiliase initialises a new PV
	pv_setup sets up an existing PV with a VG

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.235&r2=1.236

--- LVM2/lib/format1/format1.c	2011/02/21 12:15:59	1.129
+++ LVM2/lib/format1/format1.c	2011/02/21 12:20:18	1.130
@@ -361,16 +361,14 @@
 	return r;
 }
 
-static int _format1_pv_setup(const struct format_type *fmt,
-			     uint64_t pe_start, uint32_t extent_count,
-			     uint32_t extent_size,
-			     unsigned long data_alignment __attribute__((unused)),
-			     unsigned long data_alignment_offset __attribute__((unused)),
-			     int pvmetadatacopies __attribute__((unused)),
-			     uint64_t pvmetadatasize __attribute__((unused)),
-			     unsigned metadataignore __attribute__((unused)),
-			     struct dm_list *mdas __attribute__((unused)),
-			     struct physical_volume *pv, struct volume_group *vg __attribute__((unused)))
+static int _format1_pv_initialise(const struct format_type * fmt,
+				  int64_t label_sector __attribute__((unused)),
+				  uint64_t pe_start,
+				  uint32_t extent_count,
+				  uint32_t extent_size,
+				  unsigned long data_alignment __attribute__((unused)),
+				  unsigned long data_alignment_offset __attribute__((unused)),
+				  struct physical_volume * pv)
 {
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
@@ -400,6 +398,21 @@
 	return 1;
 }
 
+static int _format1_pv_setup(const struct format_type *fmt,
+			     uint64_t pe_start, uint32_t extent_count,
+			     uint32_t extent_size,
+			     unsigned long data_alignment __attribute__((unused)),
+			     unsigned long data_alignment_offset __attribute__((unused)),
+			     int pvmetadatacopies __attribute__((unused)),
+			     uint64_t pvmetadatasize __attribute__((unused)),
+			     unsigned metadataignore __attribute__((unused)),
+			     struct dm_list *mdas __attribute__((unused)),
+			     struct physical_volume *pv,
+			     struct volume_group *vg __attribute__((unused)))
+{
+	return _format1_pv_initialise(fmt, -1, 0, 0, vg->extent_size, 0, 0, pv);
+}
+
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
 {
 	uint64_t max_size = UINT_MAX;
@@ -560,6 +573,7 @@
 
 static struct format_handler _format1_ops = {
 	.pv_read = _format1_pv_read,
+	.pv_initialise = _format1_pv_initialise,
 	.pv_setup = _format1_pv_setup,
 	.pv_write = _format1_pv_write,
 	.lv_setup = _format1_lv_setup,
--- LVM2/lib/format_pool/format_pool.c	2011/02/21 12:15:59	1.37
+++ LVM2/lib/format_pool/format_pool.c	2011/02/21 12:20:18	1.38
@@ -188,6 +188,18 @@
 	return NULL;
 }
 
+static int _pool_pv_initialise(const struct format_type *fmt __attribute__((unused)),
+			       int64_t label_sector __attribute__((unused)),
+			       uint64_t pe_start __attribute__((unused)),
+			       uint32_t extent_count __attribute__((unused)),
+			       uint32_t extent_size __attribute__((unused)),
+			       unsigned long data_alignment __attribute__((unused)),
+			       unsigned long data_alignment_offset __attribute__((unused)),
+			       struct physical_volume *pv __attribute__((unused)))
+{
+	return 1;
+}
+
 static int _pool_pv_setup(const struct format_type *fmt __attribute__((unused)),
 			  uint64_t pe_start __attribute__((unused)),
 			  uint32_t extent_count __attribute__((unused)),
@@ -293,6 +305,7 @@
 /* *INDENT-OFF* */
 static struct format_handler _format_pool_ops = {
 	.pv_read = _pool_pv_read,
+	.pv_initialise = _pool_pv_initialise,
 	.pv_setup = _pool_pv_setup,
 	.create_instance = _pool_create_instance,
 	.destroy_instance = _pool_destroy_instance,
--- LVM2/lib/format_text/format-text.c	2011/02/21 12:17:54	1.160
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:20:18	1.161
@@ -1687,6 +1687,75 @@
 	return 1;
 }
 
+static int _text_pv_initialise(const struct format_type *fmt,
+			       const int64_t label_sector,
+			       uint64_t pe_start,
+			       uint32_t extent_count,
+			       uint32_t extent_size,
+			       unsigned long data_alignment,
+			       unsigned long data_alignment_offset,
+			       struct physical_volume *pv)
+{
+	struct text_fid_pv_context *fid_pv_tc;
+
+	/*
+	 * Try to keep the value of PE start set to a firm value if requested.
+	 * This is usefull when restoring existing PE start value (backups etc.).
+	 */
+	if (pe_start != PV_PE_START_CALC)
+		pv->pe_start = pe_start;
+
+	if (!data_alignment)
+		data_alignment = find_config_tree_int(pv->fmt->cmd,
+					      "devices/data_alignment",
+					      0) * 2;
+
+	if (set_pe_align(pv, data_alignment) != data_alignment &&
+	    data_alignment) {
+		log_error("%s: invalid data alignment of "
+			  "%lu sectors (requested %lu sectors)",
+			  pv_dev_name(pv), pv->pe_align, data_alignment);
+		return 0;
+	}
+
+	if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
+	    data_alignment_offset) {
+		log_error("%s: invalid data alignment offset of "
+			  "%lu sectors (requested %lu sectors)",
+			  pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
+		return 0;
+	}
+
+	if (pv->pe_align < pv->pe_align_offset) {
+		log_error("%s: pe_align (%lu sectors) must not be less "
+			  "than pe_align_offset (%lu sectors)",
+			  pv_dev_name(pv), pv->pe_align, pv->pe_align_offset);
+		return 0;
+	}
+
+	if (pe_start == PV_PE_START_CALC && pv->pe_start < pv->pe_align)
+		pv->pe_start = pv->pe_align;
+
+	if (extent_size)
+		pv->pe_size = extent_size;
+
+	if (extent_count)
+		pv->pe_count = extent_count;
+
+	if ((pv->pe_start + pv->pe_count * pv->pe_size - 1) > (pv->size << SECTOR_SHIFT)) {
+		log_error("Physical extents end beyond end of device %s.",
+			   pv_dev_name(pv));
+		return 0;
+	}
+
+	if (label_sector != -1) {
+		fid_pv_tc = (struct text_fid_pv_context *) pv->fid->private;
+		fid_pv_tc->label_sector = label_sector;
+	}
+
+	return 1;
+}
+
 static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
 {
 }
@@ -2368,6 +2437,7 @@
 static struct format_handler _text_handler = {
 	.scan = _text_scan,
 	.pv_read = _text_pv_read,
+	.pv_initialise = _text_pv_initialise,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
 	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:17:54	1.235
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:20:19	1.236
@@ -256,6 +256,18 @@
 			struct physical_volume * pv, int scan_label_only);
 
 	/*
+	 * Initialise a new PV.
+	 */
+	int (*pv_initialise) (const struct format_type * fmt,
+			      int64_t label_sector,
+			      uint64_t pe_start,
+			      uint32_t extent_count,
+			      uint32_t extent_size,
+			      unsigned long data_alignment,
+			      unsigned long data_alignment_offset,
+			      struct physical_volume * pv);
+
+	/*
 	 * Tweak an already filled out a pv ready for importing into a
 	 * vg.  eg. pe_count is format specific.
 	 */


