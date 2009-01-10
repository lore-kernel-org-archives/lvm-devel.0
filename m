From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2009 17:09:41 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20090110170941.1780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-10 17:09:40

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	More fields can cause segfaults with orphans.
	Fix these by populating the dummy VG struct more completely.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1019&r2=1.1020
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2009/01/10 15:04:28	1.1019
+++ LVM2/WHATS_NEW	2009/01/10 17:09:40	1.1020
@@ -1,6 +1,6 @@
 Version 2.02.44 - 
 ====================================
-  Fix pvs segfault when run with orphan PV and vg_mda_size or vg_mda_free.
+  Fix pvs segfault when run with orphan PV and some VG fields.
   Display a 'dev_size' of zero for missing devices in reports.
   Add pv_mda_size to pvs and vg_mda_size to vgs.
   Fix lvmdump /sys listing to include virtual devices directory.
--- LVM2/lib/report/report.c	2009/01/10 15:04:29	1.93
+++ LVM2/lib/report/report.c	2009/01/10 17:09:40	1.94
@@ -926,13 +926,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	/*
-	 * An orphan PV will have vg->fid == NULL
-	 */
-	if (vg->fid == NULL)
-		min_mda_size = UINT64_C(0);
-	else
-		min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
+	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -945,12 +939,6 @@
 	uint64_t freespace = UINT64_MAX, mda_free;
 	struct metadata_area *mda;
 
-	/*
-	 * An orphan PV will have vg->fid == NULL
-	 */
-	if (vg->fid == NULL)
-		goto calc_done;
-
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (!mda->ops->mda_free_sectors)
 			continue;
@@ -958,7 +946,7 @@
 		if (mda_free < freespace)
 			freespace = mda_free;
 	}
-calc_done:
+
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
 
@@ -1081,8 +1069,17 @@
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */
+static struct format_instance _dummy_fid = {
+	.metadata_areas = { &(_dummy_fid.metadata_areas), &(_dummy_fid.metadata_areas) },
+};
+
 static struct volume_group _dummy_vg = {
+	.fid = &_dummy_fid,
 	.name = (char *) "",
+	.system_id = (char *) "",
+	.pvs = { &(_dummy_vg.pvs), &(_dummy_vg.pvs) },
+	.lvs = { &(_dummy_vg.lvs), &(_dummy_vg.lvs) },
+	.tags = { &(_dummy_vg.tags), &(_dummy_vg.tags) },
 };
 
 static void *_obj_get_vg(void *obj)
@@ -1182,6 +1179,10 @@
 {
 	struct lvm_report_object obj;
 
+	/* The two format fields might as well match. */
+	if (!vg && pv)
+		_dummy_fid.fmt = pv->fmt;
+
 	obj.vg = vg;
 	obj.lv = lv;
 	obj.pv = pv;


