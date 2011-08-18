From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Aug 2011 19:43:10 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110818194310.6744.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-18 19:43:09

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h raid_manip.c 
	libdm/ioctl    : libdm-iface.c 
	man            : lvconvert.8.in 
	tools          : lvconvert.c 

Log message:
	Add ability to merge back a RAID1 image that has been split w/ --trackchanges
	
	Argument layout is very similar to the merge command for snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2078&r2=1.2079
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171

--- LVM2/WHATS_NEW	2011/08/18 19:41:21	1.2078
+++ LVM2/WHATS_NEW	2011/08/18 19:43:08	1.2079
@@ -1,5 +1,6 @@
 Version 2.02.88 - 
 ==================================
+  Add --merge support for RAID1 images that were split with --trackchanges
   Add support for m-way to n-way up-convert in RAID1 (no linear to n-way yet)
   Add --trackchanges support to --splitmirrors option for RAID1
   Add --splitmirrors support for RAID1 (1 image only)
--- LVM2/lib/metadata/metadata-exported.h	2011/08/18 19:38:27	1.200
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/18 19:43:08	1.201
@@ -746,6 +746,7 @@
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    struct dm_list *splittable_pvs);
+int lv_raid_merge(struct logical_volume *lv);
 
 /* --  metadata/raid_manip.c */
 
--- LVM2/lib/metadata/raid_manip.c	2011/08/18 19:41:21	1.8
+++ LVM2/lib/metadata/raid_manip.c	2011/08/18 19:43:08	1.9
@@ -1016,3 +1016,89 @@
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
--- LVM2/libdm/ioctl/libdm-iface.c	2011/08/11 20:49:33	1.116
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/08/18 19:43:09	1.117
@@ -1639,9 +1639,10 @@
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
--- LVM2/man/lvconvert.8.in	2011/08/18 19:38:27	1.20
+++ LVM2/man/lvconvert.8.in	2011/08/18 19:43:09	1.21
@@ -40,7 +40,7 @@
 [\-h|\-?|\-\-help]
 [\-v|\-\-verbose]
 [\-\-version]
-SnapshotLogicalVolume[Path]...
+LogicalVolume[Path]...
 .br
 
 .br
@@ -146,8 +146,11 @@
 If the volume is read-only the snapshot will not be zeroed.
 .TP
 .I \-\-merge
-Merges a snapshot into its origin volume.  To check if your kernel
-supports this feature, look for 'snapshot-merge' in the output
+Merges a snapshot into its origin volume or merges a RAID1 image that has
+been split from its mirror with \-\-trackchanges back into its mirror.
+
+To check if your kernel supports the snapshot merge feature, look
+for 'snapshot-merge' in the output
 of 'dmsetup targets'.  If both the origin and snapshot volume are not
 open the merge will start immediately.  Otherwise, the merge will start
 the first time either the origin or snapshot are activated and both are closed.
@@ -206,7 +209,7 @@
 extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
 
 .br
-"lvconvert -m0 vg00/lvmirror1 /dev/sda
+"lvconvert -m0 vg00/lvmirror1 /dev/sda"
 .br
 converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
 extents from /dev/sda.
@@ -224,6 +227,32 @@
 then vg00/lvol2, then vg00/lvol3.  If --background were used it would start
 all snapshot logical volume merges in parallel.
 
+.br
+"lvconvert --splitmirrors 1 --name lv_split vg00/lvmirror1"
+.br
+Extract one image from the mirror, making it a new logical volume named
+"lv_split".  The mirror the image is extracted from is reduced accordingly.
+If it was a 2-way mirror (created with '-m 1'), then the resulting original
+volume will be linear.
+
+.br
+"lvconvert --splitmirrors 1 --trackchanges vg00/lv_raid1"
+.br
+A mirrored logical volume that uses the "raid1" segment type (i.e. created
+with '--type raid1') can use the '\-\-trackchanges' argument when splitting
+off an image.  The split-off image cannot be given a new name, as it is still
+part of the original RAID1 logical volume in the sense that changes between
+the two are being tracked for future integration upon merging.  The device that
+results from the split will be read-only and will be named similarly to the
+original - in this case "lv_raid1_rimage_N", where 'N' is the index of the
+image that has been split.
+
+.br
+"lvconvert --merge vg00/lv_raid1_rimage_1"
+.br
+Merge an image back into the mirror it was split from when the '\-\-trackchanges'
+argument was used.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/tools/lvconvert.c	2011/08/18 19:38:27	1.170
+++ LVM2/tools/lvconvert.c	2011/08/18 19:43:09	1.171
@@ -20,6 +20,7 @@
 struct lvconvert_params {
 	int snapshot;
 	int merge;
+	int merge_mirror;
 	int zero;
 
 	const char *origin;
@@ -107,7 +108,7 @@
 	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
 
-	if (!apply_lvname_restrictions(lp->lv_name))
+	if (!lp->merge_mirror && !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
 	if (*pargc && lp->snapshot) {
@@ -178,8 +179,12 @@
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
@@ -1339,6 +1344,12 @@
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
@@ -1423,17 +1434,21 @@
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
@@ -1652,7 +1667,8 @@
 			stack;
 			return ECMD_FAILED;
 		}
-	} else if (segtype_is_raid(lp->segtype) || (lv->status & RAID)) {
+	} else if (segtype_is_raid(lp->segtype) ||
+		   (lv->status & RAID) || lp->merge_mirror) {
 		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;


