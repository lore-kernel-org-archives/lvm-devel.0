From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jan 2009 15:04:29 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20090110150429.5175.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-10 15:04:29

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	Fix pvs segfault when run with orphan PV and vg_mda_size or vg_mda_free fields
	
	We display '0' for these fields now in this case.  Ideally these values are
	undefined for an orphan PV but today there is no way to specify undefined
	with display functions such as _size64_disp().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1018&r2=1.1019
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2009/01/10 02:43:52	1.1018
+++ LVM2/WHATS_NEW	2009/01/10 15:04:28	1.1019
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix pvs segfault when run with orphan PV and vg_mda_size or vg_mda_free.
   Display a 'dev_size' of zero for missing devices in reports.
   Add pv_mda_size to pvs and vg_mda_size to vgs.
   Fix lvmdump /sys listing to include virtual devices directory.
--- LVM2/lib/report/report.c	2009/01/09 22:44:34	1.92
+++ LVM2/lib/report/report.c	2009/01/10 15:04:29	1.93
@@ -926,7 +926,13 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
+	/*
+	 * An orphan PV will have vg->fid == NULL
+	 */
+	if (vg->fid == NULL)
+		min_mda_size = UINT64_C(0);
+	else
+		min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -939,6 +945,12 @@
 	uint64_t freespace = UINT64_MAX, mda_free;
 	struct metadata_area *mda;
 
+	/*
+	 * An orphan PV will have vg->fid == NULL
+	 */
+	if (vg->fid == NULL)
+		goto calc_done;
+
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (!mda->ops->mda_free_sectors)
 			continue;
@@ -946,7 +958,7 @@
 		if (mda_free < freespace)
 			freespace = mda_free;
 	}
-
+calc_done:
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
 


