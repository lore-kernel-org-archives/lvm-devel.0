From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:20:58 -0500
Subject: [PATCH 5 of 5] LVM RAID: Add ability to merge back LV split from RAID1
In-Reply-To: <1313503895.11617.10.camel@f14.redhat.com>
References: <1313503895.11617.10.camel@f14.redhat.com>
Message-ID: <1313504458.11617.21.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add ability to merge back a RAID1 image that has been split w/ --trackchanges

Argument layout is very similar to the merge command for snapshots.

Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -746,6 +746,7 @@ int lv_raid_split(struct logical_volume 
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    struct dm_list *splittable_pvs);
+int lv_raid_merge(struct logical_volume *lv);
 
 /* --  metadata/raid_manip.c */
 
Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -1016,3 +1016,89 @@ int lv_raid_split_and_track(struct logic
 		  lv->vg->name, seg_lv(seg, s)->name, lv->name);
 	return 1;
 }
+
+int lv_raid_merge(struct logical_volume *image_lv)
+{
+	uint32_t s;
+	char *p, *lv_name;
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+	struct logical_volume *meta_lv = NULL;
+	struct lv_segment *seg;
+	struct volume_group *vg = image_lv->vg;
+
+	lv_name = dm_pool_strdup(vg->vgmem, image_lv->name);
+	if (!lv_name)
+		return_0;
+
+	if (!(p = strstr(lv_name, "_rimage_"))) {
+		log_error("Unable to merge non-mirror image %s/%s",
+			  vg->name, image_lv->name);
+		return 0;
+	}
+	*p = '\0'; /* lv_name is now that of top-level RAID */
+
+	if (image_lv->status & LVM_WRITE) {
+		log_error("%s/%s is not read-only - refusing to merge",
+			  vg->name, image_lv->name);
+		return 0;
+	}
+
+	if (!(lvl = find_lv_in_vg(vg, lv_name))) {
+		log_error("Unable to find containing RAID array for %s/%s",
+			  vg->name, image_lv->name);
+		return 0;
+	}
+	lv = lvl->lv;
+	seg = first_seg(lv);
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_lv(seg, s) == image_lv) {
+			meta_lv = seg_metalv(seg, s);
+		}
+	}
+	if (!meta_lv)
+		return_0;
+
+	if (!deactivate_lv(vg->cmd, meta_lv)) {
+		log_error("Failed to deactivate %s", meta_lv->name);
+		return 0;
+	}
+
+	if (!deactivate_lv(vg->cmd, image_lv)) {
+		log_error("Failed to deactivate %s/%s before merging",
+			  vg->name, image_lv->name);
+		return 0;
+	}
+	lv_set_hidden(image_lv);
+	image_lv->status |= (lv->status & LVM_WRITE);
+	image_lv->status |= RAID_IMAGE;
+
+	if (!vg_write(vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(vg->cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, vg->name);
+		return 0;
+	}
+
+	if (!resume_lv(vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  vg->name, lv->name);
+		return 0;
+	}
+
+	log_print("%s/%s successfully merged back into %s/%s",
+		  vg->name, image_lv->name,
+		  vg->name, lv->name);
+	return 1;
+}
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -20,6 +20,7 @@
 struct lvconvert_params {
 	int snapshot;
 	int merge;
+	int merge_mirror;
 	int zero;
 
 	const char *origin;
@@ -107,7 +108,7 @@ static int _lvconvert_name_params(struct
 	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
 
-	if (!apply_lvname_restrictions(lp->lv_name))
+	if (!lp->merge_mirror && !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
 	if (*pargc && lp->snapshot) {
@@ -178,8 +179,12 @@ static int _read_params(struct lvconvert
 		return 0;
 	}
 
-	if (arg_count(cmd, merge_ARG))
-		lp->merge = 1;
+	if (arg_count(cmd, merge_ARG)) {
+		if ((argc == 1) && strstr(argv[0], "_rimage_"))
+			lp->merge_mirror = 1;
+		else
+			lp->merge = 1;
+	}
 
 	if (arg_count(cmd, mirrors_ARG)) {
 		/*
@@ -1339,6 +1344,12 @@ static int _lvconvert_mirrors(struct cmd
 	uint32_t new_mimage_count;
 	uint32_t new_log_count;
 
+	if (lp->merge_mirror) {
+		log_error("Unable to merge mirror images"
+			  "of segment type 'mirror'");
+		return 0;
+	}
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -1423,17 +1434,21 @@ static int lvconvert_raid(struct logical
 				  "split" : "reduce");
 			return 0;
 		}
-
-		if (arg_count(cmd, trackchanges_ARG))
-			return lv_raid_split_and_track(lv, lp->pvh);
-		else if (arg_count(cmd, splitmirrors_ARG))
-			return lv_raid_split(lv, lp->lv_split_name,
-					     image_count, lp->pvh);
-		else
-			return lv_raid_change_image_count(lv, image_count,
-							  lp->pvh);
 	}
 
+	if (lp->merge_mirror)
+		return lv_raid_merge(lv);
+
+	if (arg_count(cmd, trackchanges_ARG))
+		return lv_raid_split_and_track(lv, lp->pvh);
+
+	if (arg_count(cmd, splitmirrors_ARG))
+		return lv_raid_split(lv, lp->lv_split_name,
+				     image_count, lp->pvh);
+
+	if (arg_count(cmd, mirrors_ARG))
+		return lv_raid_change_image_count(lv, image_count, lp->pvh);
+
 	log_error("Conversion operation not yet supported.");
 	return 0;
 }
@@ -1652,7 +1667,8 @@ static int _lvconvert_single(struct cmd_
 			stack;
 			return ECMD_FAILED;
 		}
-	} else if (segtype_is_raid(lp->segtype) || (lv->status & RAID)) {
+	} else if (segtype_is_raid(lp->segtype) ||
+		   (lv->status & RAID) || lp->merge_mirror) {
 		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;
Index: LVM2/libdm/ioctl/libdm-iface.c
===================================================================
--- LVM2.orig/libdm/ioctl/libdm-iface.c
+++ LVM2/libdm/ioctl/libdm-iface.c
@@ -1639,9 +1639,10 @@ static struct dm_ioctl *_do_dm_ioctl(str
 				    	    _cmd_data_v4[dmt->type].name,
 					    strerror(errno));
 			else
-				log_error("device-mapper: %s ioctl "
+				log_error("device-mapper: %s ioctl for %s "
 					  "failed: %s",
-				    	   _cmd_data_v4[dmt->type].name,
+					  _cmd_data_v4[dmt->type].name,
+					  dmi->name ? dmi->name : dmi->uuid,
 					  strerror(errno));
 			_dm_zfree_dmi(dmi);
 			return NULL;



