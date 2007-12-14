From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Dec 2007 21:53:02 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h lib/rep ...
Message-ID: <20071214215302.515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-14 21:53:02

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	lib/report     : columns.h report.c 
	tools          : reporter.c 

Log message:
	Append fields to report/pvsegs_cols_verbose.
	Permit LV segment fields with PV segment reports.
	Add seg_start_pe and seg_pe_ranges to reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.744&r2=1.745
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW	2007/12/05 22:48:06	1.744
+++ LVM2/WHATS_NEW	2007/12/14 21:53:01	1.745
@@ -1,5 +1,8 @@
 Version 2.02.30 -
 ===================================
+  Append fields to report/pvsegs_cols_verbose.
+  Permit LV segment fields with PV segment reports.
+  Add seg_start_pe and seg_pe_ranges to reports.
 
 Version 2.02.29 - 5th December 2007
 ===================================
--- LVM2/lib/config/defaults.h	2007/11/09 16:51:53	1.34
+++ LVM2/lib/config/defaults.h	2007/12/14 21:53:01	1.35
@@ -113,7 +113,7 @@
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
-#define DEFAULT_PVSEGS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
+#define DEFAULT_PVSEGS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
 
 #define DEFAULT_LVS_SORT "vg_name,lv_name"
 #define DEFAULT_VGS_SORT "vg_name"
--- LVM2/lib/report/columns.h	2007/11/09 16:51:54	1.25
+++ LVM2/lib/report/columns.h	2007/12/14 21:53:02	1.26
@@ -81,8 +81,10 @@
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunksize", "For snapshots, the unit of data used when tracking changes.")
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunk_size", "For snapshots, the unit of data used when tracking changes.")
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, "seg_start", "Offset within the LV to the start of the segment in current units.")
+FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, "seg_start_pe", "Offset within the LV to the start of the segment in physical extents.")
 FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, "seg_size", "Size of segment in current units.")
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, "seg_tags", "Tags, if any.")
+FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, "seg_pe_ranges", "Ranges of Physical Extents of underlying devices in command line format.")
 FIELD(SEGS, seg, STR, "Devices", list, 5, devices, "devices", "Underlying devices used with starting extent numbers.")
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.")
--- LVM2/lib/report/report.c	2007/11/14 00:08:25	1.67
+++ LVM2/lib/report/report.c	2007/12/14 21:53:02	1.68
@@ -80,9 +80,8 @@
 	return dm_report_field_string(rh, field, &name);
 }
 
-static int _devices_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
-			 struct dm_report_field *field,
-			 const void *data, void *private __attribute((unused)))
+static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
+			  const void *data, int range_format)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	unsigned int s;
@@ -115,19 +114,32 @@
 			return 0;
 		}
 
-		if (dm_snprintf(extent_str, sizeof(extent_str), "(%" PRIu32
-				 ")", extent) < 0) {
+		if (dm_snprintf(extent_str, sizeof(extent_str),
+			        "%s%" PRIu32 "%s",
+				range_format ? ":" : "(", extent,
+				range_format ? "-"  : ")") < 0) {
 			log_error("Extent number dm_snprintf failed");
 			return 0;
 		}
-
 		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
 
+		if (range_format) {
+			if (dm_snprintf(extent_str, sizeof(extent_str),
+				        "%" PRIu32, extent + seg->area_len - 1) < 0) {
+				log_error("Extent number dm_snprintf failed");
+				return 0;
+			}
+			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
+				log_error("dm_pool_grow_object failed");
+				return 0;
+			}
+		}
+
 		if ((s != seg->area_count - 1) &&
-		    !dm_pool_grow_object(mem, ",", 1)) {
+		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
@@ -143,6 +155,20 @@
 	return 1;
 }
 
+static int _devices_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private __attribute((unused)))
+{
+	return _format_pvsegs(mem, field, data, 0);
+}
+
+static int _peranges_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private __attribute((unused)))
+{
+	return _format_pvsegs(mem, field, data, 1);
+}
+
 static int _tags_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute((unused)))
@@ -613,6 +639,15 @@
 	return _size64_disp(rh, mem, field, &start, private);
 }
 
+static int _segstartpe_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	return dm_report_field_uint32(rh, field, &seg->le);
+}
+
 static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
--- LVM2/tools/reporter.c	2007/11/15 02:20:03	1.30
+++ LVM2/tools/reporter.c	2007/12/14 21:53:02	1.31
@@ -59,8 +59,10 @@
 			      struct pv_segment *pvseg, void *handle)
 {
 	int ret = ECMD_PROCESSED;
+	struct lv_segment *seg = pvseg->lvseg;
 
-	if (!report_object(handle, vg, NULL, pvseg->pv, NULL, pvseg))
+	if (!report_object(handle, vg, seg ? seg->lv : NULL, pvseg->pv, seg,
+			   pvseg))
 		ret = ECMD_FAILED;
 
 	return ret;
@@ -279,21 +281,22 @@
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
-	if ((report_type & LVS) && (report_type & PVS)) {
+	if ((report_type & LVS) && (report_type & PVS) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return 0;
 	}
 
 	/* Change report type if fields specified makes this necessary */
-	if (report_type & SEGS)
-		report_type = SEGS;
-	else if (report_type & LVS)
-		report_type = LVS;
-	else if (report_type & PVSEGS)
+	if ((report_type & PVSEGS) ||
+	    (report_type & PVS) && (report_type & LVS))
 		report_type = PVSEGS;
 	else if (report_type & PVS)
 		report_type = PVS;
+	else if (report_type & SEGS)
+		report_type = SEGS;
+	else if (report_type & LVS)
+		report_type = LVS;
 
 	switch (report_type) {
 	case LVS:


