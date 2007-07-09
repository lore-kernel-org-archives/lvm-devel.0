From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jul 2007 15:40:43 -0000
Subject: LVM2 ./WHATS_NEW lib/report/columns.h lib/repo ...
Message-ID: <20070709154043.24139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-09 15:40:43

Modified files:
	.              : WHATS_NEW 
	lib/report     : columns.h report.c 

Log message:
	Add vg_mda_count and pv_mda_count columns to reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.648&r2=1.649
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2007/07/08 22:51:20	1.648
+++ LVM2/WHATS_NEW	2007/07/09 15:40:42	1.649
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Add vg_mda_count and pv_mda_count columns to reports.
   Fix dumpconfig to use log_print instead of stdout directly.
   Remove unused parameter 'fid' from _add_pv_to_vg.
   Add kernel and device-mapper targets versions to lvmdump.
--- LVM2/lib/report/columns.h	2007/01/24 16:51:24	1.19
+++ LVM2/lib/report/columns.h	2007/07/09 15:40:43	1.20
@@ -47,6 +47,7 @@
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of Physical Extents.")
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
+FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -65,6 +66,7 @@
 FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
+FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
--- LVM2/lib/report/report.c	2007/03/27 13:35:33	1.56
+++ LVM2/lib/report/report.c	2007/07/09 15:40:43	1.57
@@ -718,6 +718,31 @@
 	return dm_report_field_int32(rh, field, data);
 }
 
+static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	struct lvmcache_info *info; 
+	uint32_t count;
+
+	info = info_from_pvid((const char *)(&((struct id *) data)->uuid));
+	count = list_size(&info->mdas);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
+static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = list_size(&vg->fid->metadata_areas);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)


