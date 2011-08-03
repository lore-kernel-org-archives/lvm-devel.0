From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 03 Aug 2011 09:44:40 -0500
Subject: [PATCH 5 of 5] LVM RAID: Add '--splitmirrors' support for RAID1
In-Reply-To: <1312381844.1169.8.camel@f14.redhat.com>
References: <1312381844.1169.8.camel@f14.redhat.com>
Message-ID: <1312382680.1169.23.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -37,6 +37,22 @@ uint32_t lv_raid_image_count(const struc
 	return seg->area_count;
 }
 
+static int do_correct_activate(struct logical_volume *orig_lv,
+			       struct logical_volume *new_lv)
+{
+	struct cmd_context *cmd = orig_lv->vg->cmd;
+
+	/* If top RAID was EX, use EX */
+	if (lv_is_active_exclusive_locally(orig_lv)) {
+		if (!activate_lv_excl(cmd, new_lv))
+			return_0;
+	} else {
+		if (!activate_lv(cmd, new_lv))
+			return_0;
+	}
+	return 1;
+}
+
 static int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 {
 	struct pv_list *pvl;
@@ -380,18 +396,9 @@ int lv_raid_change_image_count(struct lo
 	 * Bring extracted LVs into existance, so there are no
 	 * conflicts for the main RAID device's resume
 	 */
-	if (!dm_list_empty(&removal_list)) {
-		dm_list_iterate_items(lvl, &removal_list) {
-			/* If top RAID was EX, use EX */
-			if (lv_is_active_exclusive_locally(lv)) {
-				if (!activate_lv_excl(lv->vg->cmd, lvl->lv))
-					return_0;
-			} else {
-				if (!activate_lv(lv->vg->cmd, lvl->lv))
-					return_0;
-			}
-		}
-	}
+	dm_list_iterate_items(lvl, &removal_list)
+		if (!do_correct_activate(lv, lvl->lv))
+			return_0;
 
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
@@ -416,3 +423,99 @@ int lv_raid_change_image_count(struct lo
 
 	return 1;
 }
+
+int lv_raid_split(struct logical_volume *lv, const char *split_name,
+		  uint32_t new_count, struct dm_list *splittable_pvs)
+{
+	int r;
+	struct lv_list *lvl;
+	struct dm_list meta_list, data_list;
+	uint32_t old_count = lv_raid_image_count(lv);
+
+	dm_list_init(&meta_list);
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
+	r = raid_extract_images(lv, new_count, splittable_pvs, 1,
+				&meta_list, &data_list);
+	if (!r)
+		return 0;
+
+	/* Get first item */
+	dm_list_iterate_items(lvl, &data_list)
+		break;
+
+	lvl->lv->name = split_name;
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(lv->vg->cmd, lv)) {
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
+	 * Bring extracted LVs into existance, so there are no
+	 * conflicts for the main RAID device's resume
+	 */
+	dm_list_iterate_items(lvl, &meta_list)
+		if (!do_correct_activate(lv, lvl->lv))
+			return 0;
+	dm_list_iterate_items(lvl, &data_list)
+		if (!do_correct_activate(lv, lvl->lv))
+			return 0;
+
+	/* Resume original LV */
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/* Remove the meta LVs */
+	dm_list_iterate_items(lvl, &meta_list) {
+		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
+			return_0;
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
@@ -748,6 +748,9 @@ struct logical_volume *first_replicator_
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs);
+int lv_raid_split(struct logical_volume *lv, const char *split_name,
+		  uint32_t new_count, struct dm_list *splittable_pvs);
+
 /* --  metadata/raid_manip.c */
 
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,




