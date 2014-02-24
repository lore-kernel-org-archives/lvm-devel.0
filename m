From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 24 Feb 2014 22:51:12 +0000 (UTC)
Subject: master - allocation: improve approx alloc with resize
Message-ID: <20140224225112.90AF660CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b359b86f88642888116d54d4204d367664fbdcf5
Commit:        b359b86f88642888116d54d4204d367664fbdcf5
Parent:        80831438220f0ee8b88d2c8c25fab131bf619f5b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 24 22:48:23 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 24 22:48:23 2014 +0000

allocation: improve approx alloc with resize

Start to convert percentage size handling in lvresize to the new
standard.  Note in the man pages that this code is incomplete.
Fix a regression in non-percentage allocation in my last check in.

This is what I am aiming for:

-l<extents>
-l<percent> LV/ORIGIN
	sets or changes the LV size based on the specified quantity
	of logical logical extents (that might be backed by
	a higher number of physical extents)

-l<percent> PVS/VG/FREE
	sets or changes the LV size so as to allocate or free the
	desired quantity of physical extents (that might amount to a
	lower number of logical extents for the LV concerned)

-l+50%FREE - Use up half the remaining free space in the VG when
	carrying out this operation.

-l50%VG - After this operation, this LV should be using up half the
	space in the VG.

-l200%LV - Double the logical size of this LV.

-l+100%LV - Double the logical size of this LV.

-l-50%LV - Reduce the logical size of this LV by half.
---
 lib/metadata/lv_manip.c          |   33 ++++++++++++++++++++++-----------
 lib/metadata/metadata-exported.h |    1 +
 man/lvcreate.8.in                |    7 +++++--
 man/lvextend.8.in                |    7 +++++++
 man/lvreduce.8.in                |    6 ++++++
 man/lvresize.8.in                |    7 +++++++
 tools/lvcreate.c                 |    1 +
 7 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 92e65ae..c4b644c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1197,9 +1197,11 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		ah->log_len = !metadata_area_count ? 0 :
 			mirror_log_extents(ah->region_size, extent_size,
 					   new_extents / ah->area_multiple);
-		ah->new_extents = ah->new_extents * ah->area_multiple / ah->area_count;
-		ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
-		log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
+		if (approx_alloc) {
+			ah->new_extents = ah->new_extents * ah->area_multiple / ah->area_count;
+			ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
+			log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
+		}
 	}
 
 	for (s = 0; s < alloc_count; s++)
@@ -3813,7 +3815,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 {
 	struct volume_group *vg = lv->vg;
 	uint32_t pv_extent_count;
-	uint32_t extents_used;
+	uint32_t extents_used, extents;
 	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
 	uint32_t seg_mirrors = 0;
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
@@ -3825,24 +3827,24 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	/* If percent options were used, convert them into actual numbers of extents */
 	switch (lp->percent) {
 		case PERCENT_VG:
-			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+			extents = percent_of_extents(lp->extents, vg->extent_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_FREE:
-			lp->extents = percent_of_extents(lp->extents, vg->free_count,
+			extents = percent_of_extents(lp->extents, vg->free_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_LV:
-			lp->extents = percent_of_extents(lp->extents, lv->le_count,
+			extents = percent_of_extents(lp->extents, lv->le_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_PVS:
 			if (lp->argc) {
 				pv_extent_count = pv_list_extents_free(pvh);
-				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
+				extents = percent_of_extents(lp->extents, pv_extent_count,
 								 (lp->sign != SIGN_MINUS));
 			} else
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+				extents = percent_of_extents(lp->extents, vg->extent_count,
 								 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_ORIGIN:
@@ -3850,13 +3852,22 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				log_error("Specified LV does not have an origin LV.");
 				return 0;
 			}
-			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
+			extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_NONE:
+			extents = lp->extents;
 			break;
 	}
 
+	if (lp->percent != PERCENT_NONE) {
+		log_verbose("Converted %" PRIu32 "%%%s into %" PRIu32 " extents.", lp->extents, get_percent_string(lp->percent), extents);
+		lp->extents = extents;
+		if (lp->sign == SIGN_NONE && (lp->percent != PERCENT_LV && lp->percent != PERCENT_ORIGIN))
+			lp->approx_alloc = 1;
+		/* FIXME Adjust for parallel areas here before processing relative allocations */
+	}
+
 	if (lp->sign == SIGN_PLUS) {
 		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
 			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
@@ -4213,7 +4224,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc, 0))
+			      pvh, alloc, lp->approx_alloc))
 		return_NULL;
 
 	if (lock_lv) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3e57113..87e6046 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -484,6 +484,7 @@ struct lvresize_params {
 	uint64_t poolmetadatasize;
 	sign_t poolmetadatasign;
 	uint32_t poolmetadataextents;
+	int approx_alloc;
 	percent_type_t percent;
 
 	enum {
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 682ff3a..c449eb1 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -223,14 +223,17 @@ is specified.
 .TP
 .IR \fB\-l ", " \fB\-\-extents " " LogicalExtentsNumber [ % { VG | PVS | FREE | ORIGIN }]
 Gives the number of logical extents to allocate for the new
-logical volume.
+logical volume.  The total number of physical extents allocated will be
+greater than this, for example, if the volume is mirrored.
 The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix \fI%VG\fR, as a percentage of the
 remaining free space in the Volume Group with the suffix \fI%FREE\fR, as a
 percentage of the remaining free space for the specified
 PhysicalVolume(s) with the suffix \fI%PVS\fR, or (for a snapshot) as a
 percentage of the total space in the Origin Logical Volume with the
-suffix \fI%ORIGIN\fR.
+suffix \fI%ORIGIN\fR.  When expressed as a percentage, the number is treated
+as an approximate upper limit for the total number of physical extents
+to be allocated (including extents used by any mirrors, for example).
 .TP
 .IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Gives the size to allocate for the new logical volume.
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index c51a9dc..d9bc0c8 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -45,6 +45,8 @@ Proceed with size extension without prompting.
 Extend or set the logical volume size in units of logical extents.
 With the '\fI+\fP' sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
+The total number of physical extents allocated will be
+greater than this, for example, if the volume is mirrored.
 The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix \fI%VG\fP, relative to the existing
 size of the Logical Volume with the suffix \fI%LV\fP, of the remaining
@@ -53,6 +55,11 @@ as a percentage of the remaining free space in the Volume Group
 with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage of the total
 space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
 The resulting value is rounded upward.
+N.B. In a future release, when expressed as a percentage with PVS, VG or FREE,
+the number will be treated as an approximate upper limit for the total number
+of physical extents to be allocated (including extents used by any mirrors, for
+example).  The code may currently allocate more space than you might otherwise
+expect.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Extend or set the logical volume size in units of megabytes.
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 2c38f5b..2b0f3f8 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -51,6 +51,8 @@ Reduce or set the logical volume size in units of logical extents.
 With the \fI-\fP sign the value will be subtracted from
 the logical volume's actual size and without it the value will be taken
 as an absolute size.
+The total number of physical extents freed will be greater than this logical
+value if, for example, the volume is mirrored.
 The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix \fI%VG\fP, relative to the existing
 size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of the
@@ -59,6 +61,10 @@ a snapshot) as a percentage of the total space in the Origin Logical
 Volume with the suffix \fI%ORIGIN\fP.
 The resulting value for the subtraction is rounded downward, for the absolute
 size it is rounded upward.
+N.B. In a future release, when expressed as a percentage with VG or FREE, the
+number will be treated as an approximate total number of physical extents to be
+freed (including extents used by any mirrors, for example).  The code may
+currently release more space than you might otherwise expect.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Reduce or set the logical volume size in units of megabytes.
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 3606762..14fc7ba 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -49,6 +49,8 @@ Resize underlying filesystem together with the logical volume using
 Change or set the logical volume size in units of logical extents.
 With the \fI+\fP or \fI-\fP sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
+The total number of physical extents affected will be
+greater than this if, for example, the volume is mirrored.
 The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix \fI%VG\fP, relative to the existing
 size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of
@@ -58,6 +60,11 @@ Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
 of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
 The resulting value is rounded downward for the subtraction otherwise
 it is rounded upward.
+N.B. In a future release, when expressed as a percentage with PVS, VG or FREE,
+the number will be treated as an approximate total number of physical extents
+to be allocated or freed (including extents used by any mirrors, for example).
+The code may currently allocate or remove more space than you might otherwise
+expect.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Change or set the logical volume size in units of megabytes.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 19df387..7d9d22e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -400,6 +400,7 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lcp->percent) {
+		/* FIXME Don't do the adjustment for parallel allocation with PERCENT_ORIGIN! */
 		lp->approx_alloc = 1;
 		log_verbose("Converted %" PRIu32 "%%%s into %" PRIu32 " extents.", lp->extents, get_percent_string(lcp->percent), extents);
 		lp->extents = extents;


