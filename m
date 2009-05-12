From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 May 2009 19:12:15 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20090512191215.29370.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-12 19:12:10

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_pool: format_pool.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	                 snapshot_manip.c 
	lib/report     : columns.h report.c 
	tools          : vgmerge.c vgsplit.c 

Log message:
	Remove snapshot_count from VG and use function instead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1100&r2=1.1101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/WHATS_NEW	2009/05/12 19:09:21	1.1100
+++ LVM2/WHATS_NEW	2009/05/12 19:12:09	1.1101
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Remove snapshot_count from VG and use function instead.
   Fix first_seg() call for empty segment list.
   Add make install_lvm2 as complement to device-mapper install.
   Reject missing PVs from allocation in toollib.
--- LVM2/lib/format1/import-export.c	2008/11/03 22:14:28	1.100
+++ LVM2/lib/format1/import-export.c	2009/05/12 19:12:09	1.101
@@ -282,7 +282,7 @@
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg->lv_count + vg->snapshot_count;
+	vgd->lv_cur = vg->lv_count + snapshot_count(vg);
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
--- LVM2/lib/format_pool/format_pool.c	2009/04/10 09:59:18	1.21
+++ LVM2/lib/format_pool/format_pool.c	2009/05/12 19:12:09	1.22
@@ -120,7 +120,6 @@
 	vg->extent_count = 0;
 	vg->pv_count = 0;
 	vg->lv_count = 0;
-	vg->snapshot_count = 0;
 	vg->seqno = 1;
 	vg->system_id = NULL;
 	dm_list_init(&vg->pvs);
--- LVM2/lib/metadata/metadata-exported.h	2009/04/25 01:17:59	1.65
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/12 19:12:09	1.66
@@ -243,8 +243,7 @@
 	 * Snapshots consist of 2 instances of "struct logical_volume":
 	 * - cow (lv_name is visible to the user)
 	 * - snapshot (lv_name is 'snapshotN')
-	 * Neither of these instances is reflected in lv_count, but we
-	 * multiply the snapshot_count by 2.
+	 * Neither of these instances is reflected in lv_count.
 	 *
 	 * Mirrors consist of multiple instances of "struct logical_volume":
 	 * - one for the mirror log
@@ -253,7 +252,6 @@
 	 * all of the instances are reflected in lv_count.
 	 */
 	uint32_t lv_count;
-	uint32_t snapshot_count;
 	struct dm_list lvs;
 
 	struct dm_list tags;
--- LVM2/lib/metadata/metadata.c	2009/05/12 19:09:21	1.214
+++ LVM2/lib/metadata/metadata.c	2009/05/12 19:12:09	1.215
@@ -574,8 +574,6 @@
 	vg->lv_count = 0;
 	dm_list_init(&vg->lvs);
 
-	vg->snapshot_count = 0;
-
 	dm_list_init(&vg->tags);
 
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
@@ -1155,6 +1153,18 @@
 	return lv_count;
 }
 
+unsigned snapshot_count(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_cow(lvl->lv))
+			lv_count++;
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1445,11 +1455,11 @@
 	}
 
 	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg->lv_count + 2 * vg->snapshot_count) {
+	    vg->lv_count + 2 * snapshot_count(vg)) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  dm_list_size(&vg->lvs), vg->lv_count,
-			  vg->snapshot_count, vg->name);
+			  snapshot_count(vg), vg->name);
 		r = 0;
 	}
 
--- LVM2/lib/metadata/metadata.h	2009/04/25 01:18:00	1.192
+++ LVM2/lib/metadata/metadata.h	2009/05/12 19:12:10	1.193
@@ -345,6 +345,11 @@
 unsigned displayable_lvs_in_vg(const struct volume_group *vg);
 
 /*
+ * Count snapshot LVs.
+ */
+unsigned snapshot_count(const struct volume_group *vg);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
--- LVM2/lib/metadata/snapshot_manip.c	2009/04/25 01:18:00	1.35
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/12 19:12:10	1.36
@@ -106,7 +106,6 @@
 	seg->lv->status |= SNAPSHOT;
 
 	origin->origin_count++;
-	origin->vg->snapshot_count++;
 	cow->snapshot = seg;
 
 	cow->status &= ~VISIBLE_LV;
@@ -133,7 +132,6 @@
 
 	cow->snapshot = NULL;
 
-	cow->vg->snapshot_count--;
 	cow->vg->lv_count++;
 	cow->status |= VISIBLE_LV;
 
--- LVM2/lib/report/columns.h	2009/05/06 15:25:23	1.35
+++ LVM2/lib/report/columns.h	2009/05/12 19:12:10	1.36
@@ -108,7 +108,7 @@
 FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.")
 FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, "lv_count", "Number of LVs.")
-FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of snapshots.")
+FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
--- LVM2/lib/report/report.c	2009/04/25 01:18:00	1.97
+++ LVM2/lib/report/report.c	2009/05/12 19:12:10	1.98
@@ -991,6 +991,18 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _snapcount_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = snapshot_count(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private __attribute((unused)))
--- LVM2/tools/vgmerge.c	2009/04/10 10:01:39	1.51
+++ LVM2/tools/vgmerge.c	2009/05/12 19:12:10	1.52
@@ -102,8 +102,6 @@
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
-	vg_to->snapshot_count += vg_from->snapshot_count;
-
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
--- LVM2/tools/vgsplit.c	2009/04/10 10:01:39	1.70
+++ LVM2/tools/vgsplit.c	2009/05/12 19:12:10	1.71
@@ -106,10 +106,7 @@
 		return 0;
 	}
 
-	if (lv->status & SNAPSHOT) {
-		vg_from->snapshot_count--;
-		vg_to->snapshot_count++;
-	} else if (!lv_is_cow(lv)) {
+	if (!(lv->status & SNAPSHOT) && !lv_is_cow(lv)) {
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}


