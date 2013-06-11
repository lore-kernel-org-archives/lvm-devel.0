From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:10 +0000 (UTC)
Subject: master - thin: lvresize supports pool metadata resize
Message-ID: <20130611120910.809BE60DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87aca628d6b477ec4f0b6dac7d4895b31253a6e1
Commit:        87aca628d6b477ec4f0b6dac7d4895b31253a6e1
Parent:        72c3ae253e52b896795cc0769860c4fcd82ef244
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:45:49 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:05:20 2013 +0200

thin: lvresize supports pool metadata resize

Add support for lvresize of thin pool metadata device.

lvresize --poolmetadatasize +20   vgname/thinpool_lv

or

lvresize -L +20 vgname/thinpool_lv_tmeta

Where the second one allows all the args for resize (striping...)
and the first option resizes accoding to the last metadata lv segment.
---
 WHATS_NEW         |    1 +
 man/lvcreate.8.in |    4 +-
 man/lvresize.8.in |    9 +++
 tools/commands.h  |   10 +++-
 tools/lvresize.c  |  151 ++++++++++++++++++++++++++++++++++++++++++++++------
 5 files changed, 152 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 084738d..aecf227 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lvresize support for online thin pool metadata volume resize.
   Add helper functions find_pool_lv() and pool_can_resize_metadata().
   Add detection for thin pool metadata resize kernel support.
   Report lvs volume type 'e' with higher priority.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 3d675ae..ac5cf65 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -61,7 +61,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
-.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]]
+.IR MetadataVolumeSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
 .RB [ \-s | \-\-snapshot
@@ -271,7 +271,7 @@ Sets access permissions to read only (\fIr\fP) or read and write (\fIrw\fP).
 .br
 Default is read and write.
 .TP
-.IR \fB\-\-poolmetadatasize " " ThinPoolMetadataSize [ bBsSkKmMgG ]
+.IR \fB\-\-poolmetadatasize " " MetadataVolumeSize [ bBsSkKmMgG ]
 Sets the size of thin pool's metadata logical volume.
 Supported values are in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 7e85993..e04869d 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -11,6 +11,8 @@ lvresize \- resize a logical volume
 .RI [ + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN "}] |"
 .RB [ \-L | \-\-size
 .RI [ + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-\-poolmetadatasize
+.RI [ + ] MetadataVolumeSize [ bBsSkKmMgG ]
 .RB [ \-f | \-\-force ]
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-r | \-\-resizefs ]
@@ -73,6 +75,13 @@ Defaults to whatever the last segment of the Logical Volume uses.
 Not applicable to LVs using the original metadata LVM format, which must
 use a single value throughout.
 .TP
+.IR \fB\-\-poolmetadatasize " [" + ] MetadataVolumeSize [ bBsSkKmMgG ]
+Change or set the thin pool metadata logical volume size.
+With the \fI+\fP sign the value is added to the actual size
+of the metadata volume and rounded to the full extent size
+and without it, the value is taken as an absolute one.
+Maximal size is 16GiB. Default unit is megabytes.
+.TP
 .BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
 Defaults to whatever the last segment of the Logical Volume uses.
diff --git a/tools/commands.h b/tools/commands.h
index 64d6d0d..2d99d5a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -233,7 +233,7 @@ xx(lvcreate,
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[--poolmetadatasize Size[bBsSkKmMgG]]\n"
+   "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
@@ -308,6 +308,7 @@ xx(lvextend,
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
+   "\t --poolmetadatasize [+]MetadataVolumeSize[bBsSkKmMgG]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[--nosync]\n"
    "\t[--use-policies]\n"
@@ -321,7 +322,8 @@ xx(lvextend,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, nosync_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
+   nofsck_ARG, nosync_ARG, noudevsync_ARG, poolmetadatasize_ARG,
+   resizefs_ARG, size_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, type_ARG, use_policies_ARG)
 
 xx(lvmchange,
@@ -437,6 +439,7 @@ xx(lvresize,
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
+   "\t --poolmetadatasize [+]MetadataVolumeSize[bBsSkKmMgG]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
@@ -447,7 +450,8 @@ xx(lvresize,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
-   noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   noudevsync_ARG, resizefs_ARG, poolmetadatasize_ARG,
+   size_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, type_ARG)
 
 xx(lvs,
diff --git a/tools/lvresize.c b/tools/lvresize.c
index f552992..6de3b3b 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -30,7 +30,10 @@ struct lvresize_params {
 	/* size */
 	uint32_t extents;
 	uint64_t size;
+	int sizeargs;
 	sign_t sign;
+	uint64_t poolmetadatasize;
+	sign_t poolmetadatasign;
 	percent_type_t percent;
 
 	enum {
@@ -192,6 +195,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	int use_policy = arg_count(cmd, use_policies_ARG);
 
 	lp->sign = SIGN_NONE;
+	lp->poolmetadatasign = SIGN_NONE;
 	lp->resize = LV_ANY;
 
 	cmd_name = command_name(cmd);
@@ -211,13 +215,14 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * one or more PVs.  Most likely, the intent was "resize this
 		 * LV the best you can with these PVs"
 		 */
-		if ((arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) == 0) &&
-		    (argc >= 2)) {
+		lp->sizeargs = arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG);
+		if ((lp->sizeargs == 0) && (argc >= 2)) {
 			lp->extents = 100;
 			lp->percent = PERCENT_PVS;
 			lp->sign = SIGN_PLUS;
-		} else if ((arg_count(cmd, extents_ARG) +
-			    arg_count(cmd, size_ARG) != 1)) {
+		} else if ((lp->sizeargs != 1) &&
+			   ((lp->sizeargs == 2) ||
+			    !arg_count(cmd, poolmetadatasize_ARG))) {
 			log_error("Please specify either size or extents but not "
 				  "both.");
 			return 0;
@@ -235,6 +240,15 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
 			lp->percent = PERCENT_NONE;
 		}
+
+		if (arg_count(cmd, poolmetadatasize_ARG)) {
+			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
+			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
+			if (lp->poolmetadatasign == SIGN_MINUS) {
+				log_error("Can't reduce pool metadata size.");
+				return 0;
+			}
+		}
 	}
 
 	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {
@@ -242,7 +256,8 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	if (lp->resize == LV_REDUCE && lp->sign == SIGN_PLUS) {
+	if (lp->resize == LV_REDUCE &&
+	    ((lp->sign == SIGN_PLUS) || (lp->poolmetadatasign == SIGN_PLUS))) {
 		log_error("Positive sign not permitted - use lvextend");
 		return 0;
 	}
@@ -306,18 +321,23 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
-		if (percent > policy_threshold) {
-			/* FIXME: metadata resize support missing */
-			log_error("Resize for %s/%s is not yet supported.",
-				  lp->vg_name, lp->lv_name);
-			return ECMD_FAILED;
+		if ((PERCENT_0 < percent && percent <= PERCENT_100) &&
+		    (percent > policy_threshold)) {
+			if (!pool_can_resize_metadata(lv)) {
+				log_error_once("Online metadata resize for %s/%s is not supported.",
+					       lp->vg_name, lp->lv_name);
+				return 0;
+			}
+			lp->poolmetadatasize = (first_seg(lv)->metadata_lv->size *
+						policy_amount + 99) / 100;
+			lp->poolmetadatasign = SIGN_PLUS;
 		}
 
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
 		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
 		    percent <= policy_threshold)
-			return 1; /* nothing to do */
+			return 1;
 	} else {
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
@@ -326,6 +346,7 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	}
 
 	lp->extents = policy_amount;
+	lp->sizeargs = (lp->extents) ? 1 : 0;
 
 	return 1;
 }
@@ -358,6 +379,74 @@ static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 	return 0;
 }
 
+static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *vg,
+				  struct lvresize_params *lp,
+				  const struct logical_volume *pool_lv,
+				  struct dm_list *pvh,
+				  alloc_policy_t alloc)
+{
+	struct logical_volume *lv;
+	struct lv_segment *mseg;
+	uint32_t extents;
+	uint32_t seg_mirrors;
+
+	if (!pool_can_resize_metadata(pool_lv)) {
+		log_error("Support for online metadata resize not detected.");
+		return 0;
+	}
+
+	if (lp->poolmetadatasize % vg->extent_size) {
+		lp->poolmetadatasize += vg->extent_size -
+			(lp->poolmetadatasize % vg->extent_size);
+		log_print_unless_silent("Rounding pool metadata size to boundary between physical extents: %s",
+					display_size(cmd, lp->poolmetadatasize));
+	}
+
+	if (!(extents = extents_from_size(vg->cmd, lp->poolmetadatasize,
+					  vg->extent_size)))
+		return_0;
+
+	lv = first_seg(pool_lv)->metadata_lv;
+	if (lp->poolmetadatasign == SIGN_PLUS) {
+		if (extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
+			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
+				  lv->name, lv->le_count, MAX_EXTENT_COUNT);
+			return 0;
+		}
+		extents += lv->le_count;
+	}
+
+	if (extents * vg->extent_size > DM_THIN_MAX_METADATA_SIZE) {
+		log_print_unless_silent("Rounding size to maximum supported size 16GiB "
+					"for metadata volume %s.", lv->name);
+		extents = (DM_THIN_MAX_METADATA_SIZE + vg->extent_size - 1) /
+			vg->extent_size;
+	}
+
+	if (extents == lv->le_count) {
+		log_print_unless_silent("Metadata volume %s has already %s.",
+					lv->name, display_size(cmd, lv->size));
+		return 2;
+	}
+
+	log_print_unless_silent("Extending logical volume %s to %s.",
+                                lv->name,
+				display_size(cmd, (uint64_t) extents * vg->extent_size));
+	mseg = last_seg(lv);
+	seg_mirrors = lv_mirror_count(lv);
+	if (!lv_extend(lv,
+		       mseg->segtype,
+		       mseg->area_count / seg_mirrors,
+		       mseg->stripe_size,
+		       seg_mirrors,
+		       mseg->region_size,
+		       extents - lv->le_count, NULL,
+		       pvh, alloc))
+		return_0;
+
+	return 1;
+}
+
 static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp)
 {
@@ -485,6 +574,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	if (lp->sizeargs) { /* TODO: reindent or move to function */
+
 	switch(lp->percent) {
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
@@ -552,6 +643,11 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (lp->extents == lv->le_count) {
+		/* A bit of hack - but still may resize metadata */
+		if (lp->poolmetadatasize) {
+			lp->sizeargs = 0;
+			goto metadata_resize;
+		}
 		if (use_policy)
 			return ECMD_PROCESSED; /* Nothing to do. */
 		if (!lp->resizefs) {
@@ -778,6 +874,9 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			log_warn("Thin pool volumes do not have filesystem.");
 			lp->resizefs = 0;
 		}
+	} else if (lp->poolmetadatasize) {
+		log_error("--poolmetadatasize can be used only with thin pools.");
+		return ECMD_FAILED;
 	}
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
@@ -832,18 +931,34 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	/* If thin metadata, must suspend thin pool */
+	if (lv_is_thin_pool_metadata(lv)) {
+		if (!(lock_lv = find_pool_lv(lv)))
+			return_0;
+	/* If snapshot, must suspend all associated devices */
+	} else if (lv_is_cow(lv))
+		lock_lv = origin_from_cow(lv);
+	else
+		lock_lv = lv;
+
+	} /* lp->sizeargs */
+
+	if (lp->poolmetadatasize) {
+metadata_resize:
+		if (!(status = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc))) {
+			stack;
+			return ECMD_FAILED;
+		} else if ((status == 2) && !lp->sizeargs)
+			return ECMD_PROCESSED;
+		lock_lv = lv;
+	}
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
 
-	/* If snapshot, must suspend all associated devices */
-	if (lv_is_cow(lv))
-		lock_lv = origin_from_cow(lv);
-	else
-		lock_lv = lv;
-
 	if (!suspend_lv(cmd, lock_lv)) {
 		log_error("Failed to suspend %s", lock_lv->name);
 		vg_revert(vg);


