From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:26:46 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20090513212646.28822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:26:45

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	                 snapshot_manip.c 

Log message:
	Introduce lv_set_visible & lv_set_invisible and use lv_is_visible always.
	
	The vg->lv_count parameter now includes always number of visible
	logical volumes.
	
	Note that virtual snapshot volume (snapshotX) is never visible,
	but it is stored in metadata with visible flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1107&r2=1.1108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2009/05/13 21:25:45	1.1107
+++ LVM2/WHATS_NEW	2009/05/13 21:26:45	1.1108
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Introduce lv_set_visible & lv_set_invisible functions.
   Fix lv_is_visible to handle virtual origin.
   Introduce link_lv_to_vg and unlink_lv_from_vg functions.
   Remove lv_count from VG and use counter function instead.
--- LVM2/lib/activate/activate.c	2009/04/10 10:00:04	1.145
+++ LVM2/lib/activate/activate.c	2009/05/13 21:26:45	1.146
@@ -647,7 +647,7 @@
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->status & VISIBLE_LV)
+		if (lv_is_visible(lvl->lv))
 			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
 	}
 
@@ -996,7 +996,7 @@
 		goto out;
 	}
 
-	if (info.open_count && (lv->status & VISIBLE_LV)) {
+	if (info.open_count && lv_is_visible(lv)) {
 		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
 			  lv->name);
 		goto out;
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:25:02	1.168
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:26:45	1.169
@@ -1503,7 +1503,7 @@
 		if (!set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count],
 					    0, status))
 			return_0;
-		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
+		lv_set_invisible(sub_lvs[m - old_area_count]);
 	}
 
 	lv->status |= MIRRORED;
@@ -1960,6 +1960,26 @@
 	return 1;
 }
 
+void lv_set_visible(struct logical_volume *lv)
+{
+	if (lv_is_visible(lv))
+		return;
+
+	lv->status |= VISIBLE_LV;
+
+	log_debug("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
+}
+
+void lv_set_invisible(struct logical_volume *lv)
+{
+	if (!lv_is_visible(lv))
+		return;
+
+	lv->status &= ~VISIBLE_LV;
+
+	log_debug("LV %s in VG %s is now invisible.",  lv->name, lv->vg->name);
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     const force_t force)
 {
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:25:02	1.69
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:26:45	1.70
@@ -373,6 +373,8 @@
  */
 int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv);
 int unlink_lv_from_vg(struct logical_volume *lv);
+void lv_set_visible(struct logical_volume *lv);
+void lv_set_invisible(struct logical_volume *lv);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
--- LVM2/lib/metadata/mirror.c	2009/04/23 16:43:01	1.85
+++ LVM2/lib/metadata/mirror.c	2009/05/13 21:26:45	1.86
@@ -260,7 +260,7 @@
 	}
 
 	/* Temporary make it visible for set_lv() */
-	log_lv->status |= VISIBLE_LV;
+	lv_set_visible(log_lv);
 
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tags)
@@ -303,7 +303,7 @@
 		return 0;
 	}
 
-	log_lv->status &= ~VISIBLE_LV;
+	lv_set_invisible(log_lv);
 
 	if (was_active && !activate_lv(cmd, log_lv))
 		return_0;
@@ -410,7 +410,7 @@
 
 	log_lv = mirrored_seg->log_lv;
 	mirrored_seg->log_lv = NULL;
-	log_lv->status |= VISIBLE_LV;
+	lv_set_visible(log_lv);
 	log_lv->status &= ~MIRROR_LOG;
 	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
 
@@ -536,7 +536,7 @@
 	dm_list_init(&tmp_orphan_lvs);
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
-		seg_lv(mirrored_seg, m)->status |= VISIBLE_LV;
+		lv_set_visible(seg_lv(mirrored_seg, m));
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");
 			return 0;
@@ -554,7 +554,7 @@
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
 		lv1->status &= ~MIRROR_IMAGE;
-		lv1->status |= VISIBLE_LV;
+		lv_set_visible(lv1);
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
@@ -1340,7 +1340,7 @@
 {
 	seg->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	log_lv->status &= ~VISIBLE_LV;
+	lv_set_invisible(log_lv);
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:25:46	1.39
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:26:45	1.40
@@ -76,7 +76,8 @@
 	seg->origin = origin;
 	seg->cow = cow;
 
-	cow->status &= ~VISIBLE_LV;
+	lv_set_invisible(cow);
+
 	cow->snapshot = seg;
 
 	origin->origin_count++;
@@ -137,7 +138,7 @@
 	}
 
 	cow->snapshot = NULL;
-	cow->status |= VISIBLE_LV;
+	lv_set_visible(cow);
 
 	return 1;
 }


