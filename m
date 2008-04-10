From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 17:19:03 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/rep ...
Message-ID: <20080410171903.5361.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 17:19:02

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/report     : columns.h report.c 

Log message:
	Fix vgdisplay 'Cur LV' field to match lvdisplay output.
	Fix lv_count report field to exclude hidden LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.842&r2=1.843
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2008/04/10 17:09:29	1.842
+++ LVM2/WHATS_NEW	2008/04/10 17:19:02	1.843
@@ -1,5 +1,7 @@
 Version 2.02.34 -
 ===================================
+  Fix vgdisplay 'Cur LV' field to match lvdisplay output.
+  Fix lv_count report field to exclude hidden LVs.
   Add vg_is_clustered() helper function.
   Fix vgsplit to only move hidden 'snapshotN' LVs when necessary.
   Update vgsplit tests for lvnames on the cmdline.
--- LVM2/lib/display/display.c	2008/04/10 17:09:31	1.88
+++ LVM2/lib/display/display.c	2008/04/10 17:19:02	1.89
@@ -574,6 +574,8 @@
 {
 	uint32_t access;
 	uint32_t active_pvs;
+	uint32_t lv_count = 0;
+	struct lv_list *lvl;
 	char uuid[64] __attribute((aligned(8)));
 
 	if (vg->status & PARTIAL_VG)
@@ -607,8 +609,13 @@
 		log_print("Shared                %s",
 			  vg->status & SHARED ? "yes" : "no");
 	}
+
+	list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
+			lv_count++;
+
 	log_print("MAX LV                %u", vg->max_lv);
-	log_print("Cur LV                %u", vg->lv_count + vg->snapshot_count);
+	log_print("Cur LV                %u", lv_count);
 	log_print("Open LV               %u", lvs_in_vg_opened(vg));
 /****** FIXME Max LV Size
       log_print ( "MAX LV Size           %s",
@@ -652,6 +659,8 @@
 void vgdisplay_colons(const struct volume_group *vg)
 {
 	uint32_t active_pvs;
+	uint32_t lv_count;
+	struct lv_list *lvl;
 	const char *access;
 	char uuid[64] __attribute((aligned(8)));
 
@@ -660,6 +669,10 @@
 	else
 		active_pvs = vg->pv_count;
 
+	list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_visible(lvl->lv) || (lvl->lv->status & SNAPSHOT))
+			lv_count++;
+
 	switch (vg->status & (LVM_READ | LVM_WRITE)) {
 		case LVM_READ | LVM_WRITE:
 			access = "r/w";
--- LVM2/lib/report/columns.h	2008/01/10 18:35:51	1.27
+++ LVM2/lib/report/columns.h	2008/04/10 17:19:02	1.28
@@ -66,7 +66,7 @@
 FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv", "Maximum number of LVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.")
-FIELD(VGS, vg, NUM, "#LV", lv_count, 3, uint32, "lv_count", "Number of LVs.")
+FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, "lv_count", "Number of LVs.")
 FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
--- LVM2/lib/report/report.c	2008/04/10 17:09:32	1.78
+++ LVM2/lib/report/report.c	2008/04/10 17:19:02	1.79
@@ -899,6 +899,21 @@
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+        struct lv_list *lvl;
+	uint32_t count = 0;
+
+        list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
+			count++;
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)


