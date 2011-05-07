From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 May 2011 13:32:07 -0000
Subject: LVM2/lib metadata/metadata-exported.h metadata ...
Message-ID: <20110507133207.4999.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-07 13:32:06

Modified files:
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	lib/mirror     : mirrored.c 

Log message:
	Make vg_mark_partial_lvs also clear existing PARTIAL_LV flags, so it can be
	issued repeatedly on the same VG, keeping the PARTIAL_LV flags up to date.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.455&r2=1.456
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/lib/metadata/metadata-exported.h	2011/04/28 20:30:00	1.190
+++ LVM2/lib/metadata/metadata-exported.h	2011/05/07 13:32:05	1.191
@@ -763,6 +763,8 @@
 int lv_has_unknown_segments(const struct logical_volume *lv);
 int vg_has_unknown_segments(const struct volume_group *vg);
 
+int vg_mark_partial_lvs(struct volume_group *vg, int clear);
+
 struct vgcreate_params {
 	const char *vg_name;
 	uint32_t extent_size;
--- LVM2/lib/metadata/metadata.c	2011/04/21 13:13:40	1.455
+++ LVM2/lib/metadata/metadata.c	2011/05/07 13:32:05	1.456
@@ -2138,11 +2138,16 @@
  * propagated transitively, so LVs referencing other LVs are marked
  * partial as well, if any of their referenced LVs are marked partial.
  */
-int vg_mark_partial_lvs(struct volume_group *vg)
+int vg_mark_partial_lvs(struct volume_group *vg, int clear)
 {
+	struct lv_list *lvl;
+
+	if (clear)
+		dm_list_iterate_items(lvl, &vg->lvs)
+			lvl->lv->status &= ~PARTIAL_LV;
+
 	if (!_lv_postorder_vg(vg, _lv_mark_if_partial_single, NULL))
 		return_0;
-
 	return 1;
 }
 
@@ -2825,7 +2830,7 @@
 		if (vg_missing_pv_count(correct_vg)) {
 			log_verbose("There are %d physical volumes missing.",
 				    vg_missing_pv_count(correct_vg));
-			vg_mark_partial_lvs(correct_vg);
+			vg_mark_partial_lvs(correct_vg, 1);
 		}
 		return correct_vg;
 	} else {
@@ -3179,7 +3184,7 @@
 	if (vg_missing_pv_count(correct_vg)) {
 		log_verbose("There are %d physical volumes missing.",
 			    vg_missing_pv_count(correct_vg));
-		vg_mark_partial_lvs(correct_vg);
+		vg_mark_partial_lvs(correct_vg, 1);
 	}
 
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
--- LVM2/lib/metadata/metadata.h	2011/03/11 14:50:15	1.242
+++ LVM2/lib/metadata/metadata.h	2011/05/07 13:32:05	1.243
@@ -471,7 +471,6 @@
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
-int vg_mark_partial_lvs(struct volume_group *vg);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
--- LVM2/lib/mirror/mirrored.c	2011/04/29 00:21:14	1.86
+++ LVM2/lib/mirror/mirrored.c	2011/05/07 13:32:06	1.87
@@ -343,7 +343,7 @@
 
 	/* update PARTIAL_LV flags across the VG */
 	if (failed)
-		vg_mark_partial_lvs(lv->vg);
+		vg_mark_partial_lvs(lv->vg, 0);
 
 	return 1;
 }


