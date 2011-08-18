From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Aug 2011 19:34:19 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110818193419.17693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-18 19:34:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h raid_manip.c 
	tools          : lvconvert.c 

Log message:
	Add --splitmirrors support for RAID1 (1 image only)
	
	Users already have the ability to split an image from an LV of "mirror"
	segtype.  This patch extends that ability to LVs of "raid1" segtype.
	
	This patch only allows a single image to be split off, however.  (The
	"mirror" segtype allows an arbitrary number of images to be split off.
	e.g.  4-way => 3-way/linear, 2-way/2-way, linear,3-way)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2075&r2=1.2076
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/WHATS_NEW	2011/08/18 19:31:33	1.2075
+++ LVM2/WHATS_NEW	2011/08/18 19:34:18	1.2076
@@ -1,5 +1,6 @@
 Version 2.02.88 - 
 ==================================
+  Add --splitmirrors support for RAID1 (1 image only)
   When down-converting RAID1, don't activate sub-lvs between suspend/resume
   Add -V as short form of --virtualsize in lvcreate.
   Fix make clean not to remove Makefile.  (2.02.87)
--- LVM2/lib/metadata/metadata-exported.h	2011/08/11 18:24:41	1.198
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/18 19:34:18	1.199
@@ -742,6 +742,9 @@
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs);
+int lv_raid_split(struct logical_volume *lv, const char *split_name,
+		  uint32_t new_count, struct dm_list *splittable_pvs);
+
 /* --  metadata/raid_manip.c */
 
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
--- LVM2/lib/metadata/raid_manip.c	2011/08/18 19:31:33	1.5
+++ LVM2/lib/metadata/raid_manip.c	2011/08/18 19:34:18	1.6
@@ -515,3 +515,111 @@
 
 	return 1;
 }
+
+int lv_raid_split(struct logical_volume *lv, const char *split_name,
+		  uint32_t new_count, struct dm_list *splittable_pvs)
+{
+	const char *old_name;
+	struct lv_list *lvl;
+	struct dm_list removal_list, data_list;
+	struct cmd_context *cmd = lv->vg->cmd;
+	uint32_t old_count = lv_raid_image_count(lv);
+
+	dm_list_init(&removal_list);
+	dm_list_init(&data_list);
+
+	if ((old_count - new_count) != 1) {
+		log_error("Unable to split more than one image from %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!seg_is_mirrored(first_seg(lv))) {
+		log_error("Unable to split logical volume of segment type, %s",
+			  first_seg(lv)->segtype->name);
+		return 0;
+	}
+
+	if (find_lv_in_vg(lv->vg, split_name)) {
+		log_error("Logical Volume \"%s\" already exists in %s",
+			  split_name, lv->vg->name);
+		return 0;
+	}
+
+	if (!raid_in_sync(lv)) {
+		log_error("Unable to split %s/%s while it is not in-sync.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!raid_extract_images(lv, new_count, splittable_pvs, 1,
+				 &removal_list, &data_list)) {
+		log_error("Failed to extract images from %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/* Convert to linear? */
+	if ((new_count == 1) && !raid_remove_top_layer(lv, &removal_list)) {
+		log_error("Failed to remove RAID layer after linear conversion");
+		return 0;
+	}
+
+	/* Get first item */
+	dm_list_iterate_items(lvl, &data_list)
+		break;
+
+	old_name = lvl->lv->name;
+	lvl->lv->name = split_name;
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	/*
+	 * Resume original LV
+	 * This also resumes all other sub-lvs (including the extracted)
+	 */
+	if (!resume_lv(cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/* Recycle newly split LV so it is properly renamed */
+	if (!suspend_lv(cmd, lvl->lv) || !resume_lv(cmd, lvl->lv)) {
+		log_error("Failed to rename %s to %s after committing changes",
+			  old_name, split_name);
+		return 0;
+	}
+
+	/*
+	 * Eliminate the residual LVs
+	 */
+	dm_list_iterate_items(lvl, &removal_list) {
+		if (!deactivate_lv(cmd, lvl->lv))
+			return_0;
+
+		if (!lv_remove(lvl->lv))
+			return_0;
+	}
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	return 1;
+}
--- LVM2/tools/lvconvert.c	2011/08/11 18:24:42	1.168
+++ LVM2/tools/lvconvert.c	2011/08/18 19:34:18	1.169
@@ -1401,7 +1401,7 @@
 	}
 
 	/* Change number of RAID1 images */
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (arg_count(cmd, mirrors_ARG) || arg_count(cmd, splitmirrors_ARG)) {
 		image_count = lv_raid_image_count(lv);
 		if (lp->mirrors_sign == SIGN_PLUS)
 			image_count += lp->mirrors;
@@ -1411,11 +1411,18 @@
 			image_count = lp->mirrors + 1;
 
 		if (image_count < 1) {
-			log_error("Unable to reduce images by specified amount");
+			log_error("Unable to %s images by specified amount",
+				  arg_count(cmd, splitmirrors_ARG) ?
+				  "split" : "reduce");
 			return 0;
 		}
 
-		return lv_raid_change_image_count(lv, image_count, lp->pvh);
+		if (arg_count(cmd, splitmirrors_ARG))
+			return lv_raid_split(lv, lp->lv_split_name,
+					     image_count, lp->pvh);
+		else
+			return lv_raid_change_image_count(lv, image_count,
+							  lp->pvh);
 	}
 
 	log_error("Conversion operation not yet supported.");


