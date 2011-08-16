From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:15:19 -0500
Subject: [PATCH 2 of 5] LVM RAID: Add --splitmirrors capability for raid1 segtype
In-Reply-To: <1313503895.11617.10.camel@f14.redhat.com>
References: <1313503895.11617.10.camel@f14.redhat.com>
Message-ID: <1313504119.11617.14.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the ability to split off an image from a RAID1 array.

Users already have the ability to split an image from an LV of "mirror"
segtype.  This patch extends that ability to LVs of "raid1" segtype.

This patch only allows a single image to be split off, however.  (The
"mirror" segtype allows an arbitrary number of images to be split off.
e.g.  4-way => 3-way/linear, 2-way/2-way, linear,3-way)

Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -515,3 +515,111 @@ int lv_raid_change_image_count(struct lo
 
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
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -1401,7 +1401,7 @@ static int lvconvert_raid(struct logical
 	}
 
 	/* Change number of RAID1 images */
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (arg_count(cmd, mirrors_ARG) || arg_count(cmd, splitmirrors_ARG)) {
 		image_count = lv_raid_image_count(lv);
 		if (lp->mirrors_sign == SIGN_PLUS)
 			image_count += lp->mirrors;
@@ -1411,11 +1411,18 @@ static int lvconvert_raid(struct logical
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
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -742,6 +742,9 @@ struct logical_volume *first_replicator_
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs);
+int lv_raid_split(struct logical_volume *lv, const char *split_name,
+		  uint32_t new_count, struct dm_list *splittable_pvs);
+
 /* --  metadata/raid_manip.c */
 
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,



