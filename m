From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Sep 2011 00:54:51 -0000
Subject: LVM2 lib/config/defaults.h lib/metadata/lv.c l ...
Message-ID: <20110909005451.9436.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-09 00:54:50

Modified files:
	lib/config     : defaults.h 
	lib/metadata   : lv.c lv.h 
	lib/report     : columns.h properties.c report.c 
	man            : lvs.8.in 

Log message:
	Add a new 'thin_pool' output field to 'lvs.
	
	A gentle reminder that anyone relying on the output of reporting commands
	like lvs in scripts must use -o to guarantee they get the fields they expect.
	
	The default sequence of fields can change from release to release.
	Equally, the 'attr' fields can have new values introduced and/or characters
	appended to them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/lib/config/defaults.h	2011/08/11 17:46:14	1.82
+++ LVM2/lib/config/defaults.h	2011/09/09 00:54:49	1.83
@@ -139,13 +139,13 @@
 #define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
 
-#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent,convert_lv"
+#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,thin_pool,origin,snap_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
-#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,origin,snap_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
+#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,thin_pool,origin,snap_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
--- LVM2/lib/metadata/lv.c	2011/09/08 20:55:39	1.25
+++ LVM2/lib/metadata/lv.c	2011/09/09 00:54:49	1.26
@@ -185,6 +185,18 @@
 	return NULL;
 }
 
+char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (!seg_is_thin_volume(seg) || !seg->pool_lv)
+			continue;
+		return dm_pool_strdup(mem, seg->pool_lv->name);
+	}
+	return NULL;
+}
+
 int lv_kernel_minor(const struct logical_volume *lv)
 {
 	struct lvinfo info;
--- LVM2/lib/metadata/lv.h	2011/04/12 12:24:29	1.20
+++ LVM2/lib/metadata/lv.h	2011/09/09 00:54:49	1.21
@@ -59,6 +59,7 @@
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
--- LVM2/lib/report/columns.h	2010/11/17 19:15:10	1.46
+++ LVM2/lib/report/columns.h	2011/09/09 00:54:49	1.47
@@ -80,6 +80,7 @@
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
+FIELD(LVS, lv, STR, "Pool", lvid, 3, poollv, thin_pool, "For thinly-provisioned devices, the pool LV holding the data.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
--- LVM2/lib/report/properties.c	2011/04/12 12:24:29	1.31
+++ LVM2/lib/report/properties.c	2011/09/09 00:54:49	1.32
@@ -175,6 +175,8 @@
 #define _lv_tags_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(thin_pool, lv_pool_lv_dup(lv->vg->vgmem, lv))
+#define _thin_pool_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _modules_set _not_implemented_set
 
--- LVM2/lib/report/report.c	2011/08/04 14:30:52	1.145
+++ LVM2/lib/report/report.c	2011/09/09 00:54:49	1.146
@@ -240,6 +240,19 @@
 	return 1;
 }
 
+static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *name;
+
+	if ((name = lv_pool_lv_dup(mem, lv)))
+		return dm_report_field_string(rh, field, &name);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
--- LVM2/man/lvs.8.in	2011/09/08 20:55:39	1.14
+++ LVM2/man/lvs.8.in	2011/09/09 00:54:49	1.15
@@ -57,7 +57,7 @@
 Column names include:
 lv_uuid, lv_name, lv_path, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
 lv_kernel_minor, lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size,
-snap_percent, copy_percent, move_pv, convert_lv, lv_tags, mirror_log, modules,
+snap_percent, copy_percent, move_pv, convert_lv, lv_tags, mirror_log, thin_pool, modules,
 segtype, stripes, stripesize, regionsize, chunksize, seg_start, seg_start_pe,
 seg_size, seg_tags, seg_pe_ranges, devices.
 .IP


