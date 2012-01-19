From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:34:34 -0000
Subject: LVM2/lib config/defaults.h metadata/lv.c metad ...
Message-ID: <20120119153434.7826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:34:33

Modified files:
	lib/config     : defaults.h 
	lib/metadata   : lv.c lv.h 
	lib/report     : columns.h properties.c report.c 

Log message:
	Thin add new display field for  lvs
	
	New field Data% is able to display info about
	thin_pool, thin, snapshot and has generic meaning here.
	
	Simple Time/Host field are here to display host and time creation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/lib/config/defaults.h	2011/12/21 13:10:52	1.92
+++ LVM2/lib/config/defaults.h	2012/01/19 15:34:32	1.93
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -148,13 +148,13 @@
 #define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
 
-#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,thin_pool,origin,snap_percent,move_pv,mirror_log,copy_percent,convert_lv"
+#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
-#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,thin_pool,origin,snap_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
+#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
--- LVM2/lib/metadata/lv.c	2012/01/19 15:31:45	1.31
+++ LVM2/lib/metadata/lv.c	2012/01/19 15:34:33	1.32
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -129,8 +129,11 @@
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_cow(seg->lv)->chunk_size;
+	else if (lv_is_thin_pool(seg->lv))
+		size = (uint64_t) seg->data_block_size;
 	else
 		size = UINT64_C(0);
+
 	return size;
 }
 
@@ -203,6 +206,18 @@
 	return NULL;
 }
 
+char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return lv_is_thin_pool(lv) ?
+		dm_pool_strdup(mem, seg_lv(first_seg(lv), 0)->name) : NULL;
+}
+
+char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return lv_is_thin_pool(lv) ?
+		dm_pool_strdup(mem, first_seg(lv)->metadata_lv->name) : NULL;
+}
+
 int lv_kernel_minor(const struct logical_volume *lv)
 {
 	struct lvinfo info;
@@ -255,6 +270,11 @@
 	return 0;
 }
 
+uint64_t lv_metadata_size(const struct logical_volume *lv)
+{
+	return lv_is_thin_pool(lv) ? first_seg(lv)->metadata_lv->size : 0;
+}
+
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	char *repstr;
--- LVM2/lib/metadata/lv.h	2012/01/19 15:31:45	1.22
+++ LVM2/lib/metadata/lv.h	2012/01/19 15:34:33	1.23
@@ -52,6 +52,7 @@
 };
 
 uint64_t lv_size(const struct logical_volume *lv);
+uint64_t lv_metadata_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
@@ -62,6 +63,8 @@
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
--- LVM2/lib/report/columns.h	2011/09/27 12:33:36	1.48
+++ LVM2/lib/report/columns.h	2012/01/19 15:34:33	1.49
@@ -71,16 +71,23 @@
 FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
 FIELD(LVS, lv, NUM, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
+FIELD(LVS, lv, NUM, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
+FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
+FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, copy_percent, "For mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
-FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
-FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, thin_pool, "For thinly-provisioned devices, the pool LV holding the data.", 0)
+FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin pools, the LV holding the associated data.", 0)
+FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin pools, the LV holding the associated metadata.", 0)
+FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
+FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
+FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
@@ -132,6 +139,9 @@
 FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
+FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
+FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
+FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
 FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
--- LVM2/lib/report/properties.c	2011/09/09 00:54:49	1.32
+++ LVM2/lib/report/properties.c	2012/01/19 15:34:33	1.33
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -100,6 +100,20 @@
 	return perc;
 }
 
+static percent_t _data_percent(const struct logical_volume *lv)
+{
+	percent_t perc;
+
+	return lv_thin_pool_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+}
+
+static percent_t _metadata_percent(const struct logical_volume *lv)
+{
+	percent_t perc;
+
+	return lv_thin_pool_percent(lv, 1, &perc) ? perc : PERCENT_INVALID;
+}
+
 /* PV */
 GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
 #define _pv_fmt_set _not_implemented_set
@@ -175,10 +189,24 @@
 #define _lv_tags_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set _not_implemented_set
-GET_LV_STR_PROPERTY_FN(thin_pool, lv_pool_lv_dup(lv->vg->vgmem, lv))
-#define _thin_pool_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _modules_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
+#define _data_lv_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
+#define _metadata_lv_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(pool_lv, lv_pool_lv_dup(lv->vg->vgmem, lv))
+#define _pool_lv_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(data_percent, _data_percent(lv))
+#define _data_percent_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(metadata_percent, _metadata_percent(lv))
+#define _metadata_percent_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(lv_metadata_size, lv_metadata_size(lv) * SECTOR_SIZE)
+#define _lv_metadata_size_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv))
+#define _lv_time_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
+#define _lv_host_set _not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
@@ -243,6 +271,12 @@
 #define _chunksize_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(chunk_size, lvseg_chunksize(lvseg))
 #define _chunk_size_set _not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(thin_count, dm_list_size(&lvseg->lv->segs_using_this_lv))
+#define _thin_count_set _not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
+#define _zero_set _not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
+#define _transaction_id_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
--- LVM2/lib/report/report.c	2011/11/07 11:03:47	1.147
+++ LVM2/lib/report/report.c	2012/01/19 15:34:33	1.148
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -240,19 +240,6 @@
 	return 1;
 }
 
-static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
-{
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *name;
-
-	if ((name = lv_pool_lv_dup(mem, lv)))
-		return dm_report_field_string(rh, field, &name);
-
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
-}
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
@@ -285,6 +272,51 @@
 	return 1;
 }
 
+static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_thin_pool(lv))
+		return _lvname_disp(rh, mem, field,
+				    seg_lv(first_seg(lv), 0), private);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
+static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_thin_pool(lv))
+		return _lvname_disp(rh, mem, field,
+				    first_seg(lv)->metadata_lv, private);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
+static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct lv_segment *seg;
+
+	if (lv_is_thin_volume(lv))
+		dm_list_iterate_items(seg, &lv->segments)
+			if (seg_is_thin_volume(seg))
+				return _lvname_disp(rh, mem, field,
+						    seg->pool_lv, private);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
 static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
@@ -401,6 +433,20 @@
 	return 1;
 }
 
+static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	return dm_report_field_uint32(rh, field, data);
+}
+
+static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+		       struct dm_report_field *field,
+		       const void *data, void *private __attribute__((unused)))
+{
+	return dm_report_field_int32(rh, field, data);
+}
+
 static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
@@ -488,6 +534,37 @@
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
+static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	/* Suppress thin count if not thin pool */
+	if (!seg_is_thin_pool(seg)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
+}
+
+static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	/* Suppress thin count if not thin pool */
+	if (!seg_is_thin_pool(seg)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return  dm_report_field_uint64(rh, field, &seg->transaction_id);
+}
+
+
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)
@@ -577,20 +654,6 @@
 	return 1;
 }
 
-static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
-{
-	return dm_report_field_uint32(rh, field, data);
-}
-
-static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-		       struct dm_report_field *field,
-		       const void *data, void *private __attribute__((unused)))
-{
-	return dm_report_field_int32(rh, field, data);
-}
-
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -844,6 +907,155 @@
 	return 1;
 }
 
+static int _dtpercent_disp(int metadata, struct dm_report *rh,
+			   struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct lvinfo info;
+	percent_t percent;
+	uint64_t *sortval;
+	char *repstr;
+
+	/* Suppress data percent if not thin pool/volume or not using driver */
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) || !info.exists) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	if (!(sortval = dm_pool_zalloc(mem, sizeof(uint64_t)))) {
+		log_error("Failed to allocate sortval.");
+		return 0;
+	}
+
+	if (lv_is_thin_pool(lv)) {
+		if (!lv_thin_pool_percent(lv, metadata, &percent))
+			return_0;
+	} else { /* thin_volume */
+		if (!lv_thin_percent(lv, 0, &percent))
+			return_0;
+	}
+
+	if (!(repstr = dm_pool_alloc(mem, 8))) {
+		log_error("Failed to allocate report buffer.");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, 8, "%.2f", percent_to_float(percent)) < 0) {
+		log_error("Data percentage too large.");
+		return 0;
+	}
+
+	*sortval = (uint64_t)(percent * 1000.f);
+	dm_report_field_set_value(field, repstr, sortval);
+
+	return 1;
+}
+
+static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_cow(lv))
+		return _snpercent_disp(rh, mem, field, data, private);
+
+	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
+		return _dtpercent_disp(0, rh, mem, field, data, private);
+
+	dm_report_field_set_value(field, "", NULL);
+
+	return 1;
+}
+
+static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_thin_pool(lv))
+		return _dtpercent_disp(1, rh, mem, field, data, private);
+
+	dm_report_field_set_value(field, "", NULL);
+
+	return 1;
+}
+
+static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t size;
+
+	if (!lv_is_thin_pool(lv)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	size = lv_metadata_size(lv);
+
+	return _size64_disp(rh, mem, field, &size, private);
+}
+
+static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
+                         struct dm_report_field *field,
+                         const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t count;
+
+	/* Suppress thin count if not thin pool */
+	if (!seg_is_thin_pool(seg)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	count = dm_list_size(&seg->lv->segs_using_this_lv);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
+static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+	uint64_t *sortval;
+
+	if (!(sortval = dm_pool_zalloc(mem, sizeof(uint64_t)))) {
+		log_error("Failed to allocate sortval.");
+		return 0;
+	}
+
+	*sortval = lv->timestamp;
+	if (!(repstr = lv_time_dup(mem, lv)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, sortval);
+
+	return 1;
+}
+
+static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+
+	if (!(repstr = lv_host_dup(mem, lv)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, repstr);
+
+	return 1;
+}
+
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */


