From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 04:27:29 -0000
Subject: LVM2 lib/format1/import-export.c lib/format_po ...
Message-ID: <20080919042729.10728.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 04:27:27

Modified files:
	lib/format1    : import-export.c 
	lib/format_pool: import_export.c 
	lib/format_text: format-text.c import_vsn1.c 
	lib/metadata   : metadata-exported.h metadata.c 
	.              : WHATS_NEW 

Log message:
	Pass struct physical_volume to pe_align.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.956&r2=1.957

--- LVM2/lib/format1/import-export.c	2008/04/22 11:47:22	1.97
+++ LVM2/lib/format1/import-export.c	2008/09/19 04:27:26	1.98
@@ -95,6 +95,7 @@
 	pv->pe_start = pvd->pe_start;
 	pv->pe_count = pvd->pe_total;
 	pv->pe_alloc_count = 0;
+	pv->pe_align = 0;
 
 	/* Fix up pv size if missing or impossibly large */
 	if (!pv->size || pv->size > (1ULL << 62)) {
--- LVM2/lib/format_pool/import_export.c	2008/06/11 13:14:41	1.23
+++ LVM2/lib/format_pool/import_export.c	2008/09/19 04:27:26	1.24
@@ -173,6 +173,7 @@
 	pv->pe_start = POOL_PE_START;
 	pv->pe_count = pv->size / POOL_PE_SIZE;
 	pv->pe_alloc_count = 0;
+	pv->pe_align = 0;
 
 	list_init(&pv->tags);
 	list_init(&pv->segments);
--- LVM2/lib/format_text/format-text.c	2008/08/16 09:46:55	1.94
+++ LVM2/lib/format_text/format-text.c	2008/09/19 04:27:26	1.95
@@ -1166,7 +1166,7 @@
 	if (!pvmetadatacopies)
 		return 1;
 
-	alignment = pe_align() << SECTOR_SHIFT;
+	alignment = pe_align(pv) << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
 	pe_start <<= SECTOR_SHIFT;
 	pe_end <<= SECTOR_SHIFT;
@@ -1333,7 +1333,7 @@
 
 	/* Set pe_start to first aligned sector after any metadata
 	 * areas that begin before pe_start */
-	pv->pe_start = pe_align();
+	pv->pe_start = pe_align(pv);
 	list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1342,9 +1342,9 @@
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
 			    >> SECTOR_SHIFT;
-			adjustment = pv->pe_start % pe_align();
+			adjustment = pv->pe_start % pe_align(pv);
 			if (adjustment)
-				pv->pe_start += (pe_align() - adjustment);
+				pv->pe_start += (pe_align(pv) - adjustment);
 		}
 	}
 	if (!add_da
--- LVM2/lib/format_text/import_vsn1.c	2008/07/11 09:19:54	1.52
+++ LVM2/lib/format_text/import_vsn1.c	2008/09/19 04:27:26	1.53
@@ -243,6 +243,7 @@
 	pv->pe_size = vg->extent_size;
 
 	pv->pe_alloc_count = 0;
+	pv->pe_align = 0;
 	pv->fmt = fid->fmt;
 
 	/* Fix up pv size if missing or impossibly large */
--- LVM2/lib/metadata/metadata-exported.h	2008/09/18 19:56:50	1.51
+++ LVM2/lib/metadata/metadata-exported.h	2008/09/19 04:27:27	1.52
@@ -168,6 +168,7 @@
 	uint64_t pe_start;
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
+	unsigned long pe_align;
 
 	struct list segments;	/* Ordered pv_segments covering complete PV */
 	struct list tags;
--- LVM2/lib/metadata/metadata.c	2008/08/29 13:41:21	1.187
+++ LVM2/lib/metadata/metadata.c	2008/09/19 04:27:27	1.188
@@ -64,9 +64,12 @@
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
-unsigned long pe_align(void)
+unsigned long pe_align(struct physical_volume *pv)
 {
-	return MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+	if (!pv->pe_align)
+		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+
+	return pv->pe_align;
 }
 
 /**
@@ -126,8 +129,8 @@
 
 	/* FIXME Do proper rounding-up alignment? */
 	/* Reserved space for label; this holds 0 for PVs created by LVM1 */
-	if (pv->pe_start < pe_align())
-		pv->pe_start = pe_align();
+	if (pv->pe_start < pe_align(pv))
+		pv->pe_start = pe_align(pv);
 
 	/*
 	 * pe_count must always be calculated by pv_setup
@@ -771,7 +774,7 @@
 	dm_pool_free(mem, pv);
 }
 
-static struct physical_volume *_alloc_pv(struct dm_pool *mem)
+static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev)
 {
 	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
 
@@ -787,7 +790,9 @@
 	pv->pe_start = 0;
 	pv->pe_count = 0;
 	pv->pe_alloc_count = 0;
+	pv->pe_align = 0;
 	pv->fmt = NULL;
+	pv->dev = dev;
 
 	pv->status = ALLOCATABLE_PV;
 
@@ -808,7 +813,7 @@
 				  uint64_t pvmetadatasize, struct list *mdas)
 {
 	struct dm_pool *mem = fmt->cmd->mem;
-	struct physical_volume *pv = _alloc_pv(mem);
+	struct physical_volume *pv = _alloc_pv(mem, dev);
 
 	if (!pv)
 		return NULL;
@@ -821,8 +826,6 @@
 		goto bad;
 	}
 
-	pv->dev = dev;
-
 	if (!dev_get_size(pv->dev, &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));
 		goto bad;
--- LVM2/WHATS_NEW	2008/09/19 03:42:36	1.956
+++ LVM2/WHATS_NEW	2008/09/19 04:27:27	1.957
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Pass struct physical_volume to pe_align.
   Store sysfs location in struct cmd_context.
   Avoid shuffling remaining mirror images when removing one, retaining primary.
   Add missing LV error target activation in _remove_mirror_images.


