From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jan 2009 22:44:35 -0000
Subject: LVM2 lib/format_text/format-text.c lib/metadat ...
Message-ID: <20090109224435.1246.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-09 22:44:34

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.h 
	lib/report     : columns.h report.c 
	man            : pvs.8.in vgs.8.in 

Log message:
	Add pv_mda_size to 'pvs' and vg_mda_size to 'vgs'.
	
	Reports the size of the smallest metadata area in a PV or a VG.
	Useful to confirm pvcreate --metadatasize or pvmetadatasize setting in
	/etc/lvm/lvm.conf file.
	
	NOTE: Actual value in these fields will most always differ from that
	given in pvcreate options due to rounding and alignment effects.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/format_text/format-text.c	2008/12/07 04:27:57	1.99
+++ LVM2/lib/format_text/format-text.c	2009/01/09 22:44:33	1.100
@@ -87,6 +87,13 @@
 	return mdac->free_sectors;
 }
 
+static uint64_t _mda_total_sectors_raw(struct metadata_area *mda)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	return mdac->area.size >> SECTOR_SHIFT;
+}
+
 /*
  * Check if metadata area belongs to vg
  */
@@ -1559,6 +1566,7 @@
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
+	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
 };
--- LVM2/lib/metadata/metadata.h	2008/12/19 15:24:53	1.186
+++ LVM2/lib/metadata/metadata.h	2009/01/09 22:44:33	1.187
@@ -139,6 +139,11 @@
 	uint64_t (*mda_free_sectors) (struct metadata_area *mda);
 
 	/*
+	 * Returns number of total sectors in given metadata area.
+	 */
+	uint64_t (*mda_total_sectors) (struct metadata_area *mda);
+
+	/*
 	 * Check if metadata area belongs to vg
 	 */
 	int (*mda_in_vg) (struct format_instance * fi,
--- LVM2/lib/report/columns.h	2008/04/10 17:19:02	1.28
+++ LVM2/lib/report/columns.h	2009/01/09 22:44:34	1.29
@@ -51,7 +51,8 @@
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
-FIELD(PVS, pv, NUM, "#PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(PVS, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(PVS, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -71,7 +72,8 @@
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
-FIELD(VGS, vg, NUM, "#VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
+FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
+FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
--- LVM2/lib/report/report.c	2008/12/15 13:30:46	1.91
+++ LVM2/lib/report/report.c	2009/01/09 22:44:34	1.92
@@ -884,6 +884,53 @@
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static uint64_t _find_min_mda_size(struct dm_list *mdas)
+{
+	uint64_t min_mda_size = UINT64_MAX, mda_size;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, mdas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		if (mda_size < min_mda_size)
+			min_mda_size = mda_size;
+	}
+
+	if (min_mda_size == UINT64_MAX)
+		min_mda_size = UINT64_C(0);
+
+	return min_mda_size;
+}
+
+static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	struct lvmcache_info *info;
+	uint64_t min_mda_size;
+	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+
+	info = info_from_pvid(pvid, 0);
+
+	/* PVs could have 2 mdas of different sizes (rounding effect) */
+	min_mda_size = _find_min_mda_size(&info->mdas);
+
+	return _size64_disp(rh, mem, field, &min_mda_size, private);
+}
+
+static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint64_t min_mda_size;
+
+	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
+
+	return _size64_disp(rh, mem, field, &min_mda_size, private);
+}
+
 static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
--- LVM2/man/pvs.8.in	2008/11/12 15:16:58	1.3
+++ LVM2/man/pvs.8.in	2009/01/09 22:44:34	1.4
@@ -31,7 +31,8 @@
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns.  Column names are: pv_fmt, pv_uuid,
 pv_size, dev_size, pv_free, pv_used, pv_name, pv_attr, pv_pe_count, 
-pv_pe_alloc_count, pv_tags, pvseg_start, pvseg_size, pe_start.
+pv_pe_alloc_count, pv_tags, pvseg_start, pvseg_size, pe_start,
+pv_mda_count, pv_mda_free, and pv_mda_size.
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
 be chosen. The pv_attr bits are: (a)llocatable and e(x)ported.
--- LVM2/man/vgs.8.in	2008/11/12 15:16:58	1.3
+++ LVM2/man/vgs.8.in	2009/01/09 22:44:34	1.4
@@ -33,7 +33,7 @@
 to the default selection of columns.  Column names are: vg_fmt, vg_uuid,
 vg_name, vg_attr, vg_size, vg_free, vg_sysid, vg_extent_size, vg_extent_count,
 vg_free_count, max_lv, max_pv, pv_count, lv_count, snap_count, vg_seqno,
-vg_tags.
+vg_tags, vg_mda_count, vg_mda_free, and vg_mda_size.
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
 at the same time.  


