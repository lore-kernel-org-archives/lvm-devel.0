From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 18 Jun 2014 04:02:52 +0000 (UTC)
Subject: master - pvmove: Enable all-or-nothing (atomic) pvmoves
Message-ID: <20140618040252.E729860A3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ebff6cc9f631b7409d99b72fa0b39ccec30bf1f
Commit:        5ebff6cc9f631b7409d99b72fa0b39ccec30bf1f
Parent:        b16f5633ab199dedfd25f08562f686a6fb4aba9d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jun 17 22:59:36 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jun 17 22:59:36 2014 -0500

pvmove: Enable all-or-nothing (atomic) pvmoves

pvmove can be used to move single LVs by name or multiple LVs that
lie within the specified PV range (e.g. /dev/sdb1:0-1000).  When
moving more than one LV, the portions of those LVs that are in the
range to be moved are added to a new temporary pvmove LV.  The LVs
then point to the range in the pvmove LV, rather than the PV
range.

Example 1:
	We have two LVs in this example.  After they were
	created, the first LV was grown, yeilding two segments
	in LV1.  So, there are two LVs with a total of three
	segments.

	Before pvmove:
	      ---------  ---------   ---------
	      | LV1s0 |  | LV2s0 |   | LV1s1 |
	      ---------  ---------   ---------
	         |           |           |
	   -------------------------------------
	PV | 000 - 255 | 256 - 511 | 512 - 767 |
	   -------------------------------------

	After pvmove inserts the temporary pvmove LV:
	          ---------   ---------   ---------
	          | LV1s0 |   | LV2s0 |   | LV1s1 |
	          ---------   ---------   ---------
	              |           |           |
	        -------------------------------------
	pvmove0 |   seg 0   |   seg 1   |   seg 2   |
	        -------------------------------------
	              |           |           |
	        -------------------------------------
	PV      | 000 - 255 | 256 - 511 | 512 - 767 |
	        -------------------------------------

	Each of the affected LV segments now point to a
	range of blocks in the pvmove LV, which purposefully
	corresponds to the segments moved from the original
	LVs into the temporary pvmove LV.

The current implementation goes on from here to mirror the temporary
pvmove LV by segment.  Further, as the pvmove LV is activated, only
one of its segments is actually mirrored (i.e. "moving") at a time.
The rest are either complete or not addressed yet.  If the pvmove
is aborted, those segments that are completed will remain on the
destination and those that are not yet addressed or in the process
of moving will stay on the source PV.  Thus, it is possible to have
a partially completed move - some LVs (or certain segments of LVs)
on the source PV and some on the destination.

Example 2:
	What 'example 1' might look if it was half-way
	through the move.
	             ---------   ---------   ---------
	             | LV1s0 |   | LV2s0 |   | LV1s1 |
	             ---------   ---------   ---------
	                 |           |           |
	           -------------------------------------
	pvmove0    |   seg 0   |   seg 1   |   seg 2   |
	           -------------------------------------
	                 |           |           |
	                 |     -------------------------
	source PV        |     | 256 - 511 | 512 - 767 |
	                 |     -------------------------
	                 |           ||
	           -------------------------
	dest PV    | 000 - 255 | 256 - 511 |
	           -------------------------

This update allows the user to specify that they would like the
pvmove mirror created "by LV" rather than "by segment".  That is,
the pvmove LV becomes an image in an encapsulating mirror along
with the allocated copy image.

Example 3:
	A pvmove that is performed "by LV" rather than "by segment".

	                   ---------   ---------
	                   | LV1s0 |   | LV2s0 |
	                   ---------   ---------
	                       |           |
	                 -------------------------
	        pvmove0  |  * LV-level mirror *  |
	                 -------------------------
                             /                \
	   pvmove_mimage0   /          pvmove_mimage1
	   -------------------------   -------------------------
	   |   seg 0   |   seg 1   |   |   seg 0   |   seg 1   |
	   -------------------------   -------------------------
	        |            |               |           |
	   -------------------------   -------------------------
	   | 000 - 255 | 256 - 511 |   | 000 - 255 | 256 - 511 |
	   -------------------------   -------------------------
	           source PV                    dest PV

The thing that differentiates a pvmove done in this way and a simple
"up-convert" from linear to mirror is the preservation of the
distinct segments.  A normal up-convert would simply allocate the
necessary space with no regard for segment boundaries.  The pvmove
operation must preserve the segments because they are the critical
boundary between the segments of the LVs being moved.  So, when the
pvmove copy image is allocated, all corresponding segments must be
allocated.  The code that merges ajoining segments that are part of
the same LV when the metadata is written must also be avoided in
this case.  This method of mirroring is unique enough to warrant its
own definitional macro, MIRROR_BY_SEGMENTED_LV.  This joins the two
existing macros: MIRROR_BY_SEG (for original pvmove) and MIRROR_BY_LV
(for user created mirrors).

The advantages of performing pvmove in this way is that all of the
LVs affected can be moved together.  It is an all-or-nothing approach
that leaves all LV segments on the source PV if the move is aborted.
Additionally, a mirror log can be used (in the future) to provide tracking
of progress; allowing the copy to continue where it left off in the event
there is a deactivation.
---
 WHATS_NEW                           |    1 +
 lib/metadata/lv_alloc.h             |    3 +
 lib/metadata/lv_manip.c             |  108 ++++++++++++++++++++++++++++++++++-
 lib/metadata/merge.c                |    7 ++-
 lib/metadata/metadata-exported.h    |    4 +
 lib/metadata/mirror.c               |   66 +++++++++++++++++----
 man/pvmove.8.in                     |   34 ++++++++++-
 test/shell/pvmove-background.sh     |    7 ++-
 test/shell/pvmove-basic.sh          |   78 +++++++++++++++----------
 test/shell/pvmove-cache-segtypes.sh |   24 +++++---
 test/shell/pvmove-raid-segtypes.sh  |   17 ++++--
 test/shell/pvmove-restart.sh        |    8 ++-
 test/shell/pvmove-thin-segtypes.sh  |   13 +++-
 tools/args.h                        |    1 +
 tools/commands.h                    |    3 +-
 tools/pvmove.c                      |   45 ++++++++++++++-
 16 files changed, 344 insertions(+), 75 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 77dfdcf..5a9a498 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Add support for all-or-nothing (atomic) pvmove.
   Automatically add snapshot metadata size for -l %ORIGIN calculation.
   When converting RAID origin to cache LV, properly rename sub-LVs.
   Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 395420d..f99e1a1 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -68,6 +68,9 @@ int lv_add_segment(struct alloc_handle *ah,
 int lv_add_mirror_areas(struct alloc_handle *ah,
 			struct logical_volume *lv, uint32_t le,
 			uint32_t region_size);
+int lv_add_segmented_mirror_image(struct alloc_handle *ah,
+				  struct logical_volume *lv, uint32_t le,
+				  uint32_t region_size);
 int lv_add_mirror_lvs(struct logical_volume *lv,
 		      struct logical_volume **sub_lvs,
 		      uint32_t num_extra_areas,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0aac385..b05f6cc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2712,6 +2712,112 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 /*
  * Add new areas to mirrored segments
  */
+int lv_add_segmented_mirror_image(struct alloc_handle *ah,
+				  struct logical_volume *lv, uint32_t le,
+				  uint32_t region_size)
+{
+	char *image_name;
+	struct alloced_area *aa;
+	struct lv_segment *seg, *new_seg;
+	uint32_t current_le = le;
+	uint32_t s;
+	struct segment_type *segtype;
+	struct logical_volume *orig_lv, *copy_lv;
+
+	if (!(lv->status & PVMOVE)) {
+		log_error(INTERNAL_ERROR
+			  "Non-pvmove LV, %s, passed as argument", lv->name);
+		return 0;
+	}
+
+	if (seg_type(first_seg(lv), 0) != AREA_PV) {
+		log_error(INTERNAL_ERROR
+			  "Bad segment type for first segment area");
+		return 0;
+	}
+
+	/*
+	 * Perform any necessary segment splitting before creating
+	 * the mirror layer.
+	 */
+	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
+		if (!(seg = find_seg_by_le(lv, current_le))) {
+			log_error("Failed to find segment for %s extent %"
+				  PRIu32, lv->name, current_le);
+			return 0;
+		}
+
+		/* Allocator assures aa[0].len <= seg->area_len */
+		if (aa[0].len < seg->area_len) {
+			if (!lv_split_segment(lv, seg->le + aa[0].len)) {
+				log_error("Failed to split segment at %s "
+					  "extent %" PRIu32, lv->name, le);
+				return 0;
+			}
+		}
+		current_le += seg->area_len;
+	}
+	current_le = le;
+
+	if (!insert_layer_for_lv(lv->vg->cmd, lv, PVMOVE, "_mimage_0")) {
+		log_error("Failed to build pvmove LV-type mirror, %s",
+			  lv->name);
+		return 0;
+	}
+	orig_lv = seg_lv(first_seg(lv), 0);
+	if (!(image_name = dm_pool_strdup(lv->vg->vgmem, orig_lv->name)))
+		return_0;
+	image_name[strlen(image_name) - 1] = '1';
+
+	if (!(copy_lv = lv_create_empty(image_name, NULL,
+					orig_lv->status,
+					ALLOC_INHERIT, lv->vg)))
+		return_0;
+
+	if (!lv_add_mirror_lvs(lv, &copy_lv, 1, MIRROR_IMAGE, region_size))
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+		return_0;
+
+	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
+		if (!(seg = find_seg_by_le(orig_lv, current_le))) {
+			log_error("Failed to find segment for %s extent %"
+				  PRIu32, lv->name, current_le);
+			return 0;
+		}
+
+		if (!(new_seg = alloc_lv_segment(segtype, copy_lv,
+						 seg->le, seg->len, PVMOVE, 0,
+						 NULL, NULL, 1, seg->len,
+						 0, 0, 0, NULL)))
+			return_0;
+
+		for (s = 0; s < ah->area_count; s++) {
+			if (!set_lv_segment_area_pv(new_seg, s,
+						    aa[s].pv, aa[s].pe))
+				return_0;
+		}
+
+		dm_list_add(&copy_lv->segments, &new_seg->list);
+
+		current_le += seg->area_len;
+		copy_lv->le_count += seg->area_len;
+	}
+	lv->status |= MIRRORED;
+
+	/* FIXME: add log */
+
+	if (lv->vg->fid->fmt->ops->lv_setup &&
+	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
+		return_0;
+
+	return 1;
+}
+
+/*
+ * Add new areas to mirrored segments
+ */
 int lv_add_mirror_areas(struct alloc_handle *ah,
 			struct logical_volume *lv, uint32_t le,
 			uint32_t region_size)
@@ -5116,7 +5222,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 					  layer_lv->name, lseg->le);
 				return 0;
 			}
-			if ((lseg->status & status_mask) != status_mask) {
+			if (((lseg->status & status_mask) != status_mask)) {
 				log_error("Layer status does not match: "
 					  "%s:%" PRIu32 " status: 0x%" PRIx64 "/0x%" PRIx64,
 					  layer_lv->name, lseg->le,
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 9d6df34..142d4d8 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -38,11 +38,16 @@ static int _merge(struct lv_segment *first, struct lv_segment *second)
 int lv_merge_segments(struct logical_volume *lv)
 {
 	struct dm_list *segh, *t;
-	struct lv_segment *current, *prev = NULL;
+	struct lv_segment *seg, *current, *prev = NULL;
 
 	if (lv->status & LOCKED || lv->status & PVMOVE)
 		return 1;
 
+	if ((lv->status & MIRROR_IMAGE) &&
+	    (seg = get_only_segment_using_this_lv(lv)) &&
+	    (seg->lv->status & LOCKED || seg->lv->status & PVMOVE))
+		return 1;
+
 	dm_list_iterate_safe(segh, t, &lv->segments) {
 		current = dm_list_item(segh, struct lv_segment);
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 237ed18..90fd6d8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -133,6 +133,10 @@
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
+#define MIRROR_BY_SEGMENTED_LV	0x00000004U	/* mirror using whole mimage
+						 * LVs, but preserve the
+						 * segment layout templated by
+						 * the primary mimage */
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* vg_read and vg_read_for_update flags */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 81a5f19..ca0c2a1 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -842,7 +842,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *temp_layer_lv = NULL;
-	struct lv_segment *mirrored_seg = first_seg(lv);
+	struct lv_segment *pvmove_seg, *mirrored_seg = first_seg(lv);
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;
@@ -949,6 +949,10 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		mirrored_seg = first_seg(lv);
 		if (remove_log && !detached_log_lv)
 			detached_log_lv = detach_mirror_log(mirrored_seg);
+
+		if (lv->status & PVMOVE)
+			dm_list_iterate_items(pvmove_seg, &lv->segments)
+				pvmove_seg->status |= PVMOVE;
 	} else if (new_area_count == 0) {
 		log_very_verbose("All mimages of %s are gone", lv->name);
 
@@ -1557,7 +1561,9 @@ struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 
 		/* Check segment origins point to pvname */
 		dm_list_iterate_items(seg, &lv->segments) {
-			if (seg_type(seg, 0) != AREA_PV)
+			if (seg_type(seg, 0) == AREA_LV) /* Atomic pvmove */
+				seg = first_seg(seg_lv(seg, 0));
+			if (seg_type(seg, 0) != AREA_PV) /* Segment pvmove */
 				continue;
 			if (seg_dev(seg, 0) != dev)
 				continue;
@@ -1652,13 +1658,14 @@ int fixup_imported_mirrors(struct volume_group *vg)
 	return 1;
 }
 
-/*
- * Add mirrors to "linear" or "mirror" segments
- */
-int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
-			    uint32_t mirrors, uint32_t region_size,
-			    struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
+					       uint32_t flags,
+					       uint32_t mirrors,
+					       uint32_t region_size,
+					       struct dm_list *allocatable_pvs,
+					       alloc_policy_t alloc)
 {
+	struct cmd_context *cmd = lv->vg->cmd;
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
@@ -1682,16 +1689,38 @@ int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
-		log_error("Failed to add mirror areas to %s", lv->name);
+	if (flags & MIRROR_BY_SEG) {
+		if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
+			log_error("Failed to add mirror areas to %s", lv->name);
+			r = 0;
+		}
+	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
+		if (!lv_add_segmented_mirror_image(ah, lv, 0,
+						   adjusted_region_size)) {
+			log_error("Failed to add mirror areas to %s", lv->name);
+			r = 0;
+		}
+	} else {
+		log_error(INTERNAL_ERROR "Unknown mirror flag");
 		r = 0;
 	}
-
 	alloc_destroy(ah);
 	return r;
 }
 
 /*
+ * Add mirrors to "linear" or "mirror" segments
+ */
+int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
+			    uint32_t mirrors, uint32_t region_size,
+			    struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+{
+	return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEG,
+						   mirrors, region_size,
+						   allocatable_pvs, alloc);
+}
+
+/*
  * Convert mirror log
  *
  * FIXME: Can't handle segment-by-segment mirror (like pvmove)
@@ -2112,8 +2141,19 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 
-		return add_mirrors_to_segments(cmd, lv, mirrors,
-					       region_size, pvs, alloc);
+		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEG,
+							   mirrors, region_size,
+							   pvs, alloc);
+	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
+		if (stripes > 1) {
+			log_error("Striped-mirroring is not supported on "
+				  "segment-by-segment mirroring");
+			return 0;
+		}
+
+		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEGMENTED_LV,
+							   mirrors, region_size,
+							   pvs, alloc);
 	} else if (flags & MIRROR_BY_LV) {
 		if (!mirrors)
 			return add_mirror_log(cmd, lv, log_count,
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index 0f58b05..43a4e00 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -6,6 +6,7 @@ pvmove \(em move physical extents
 .RB [ \-\-abort ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
+.RB [ \-\-atomic ]
 .RB [ \-b | \-\-background ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
@@ -35,8 +36,11 @@ is specified, the normal allocation rules for the Volume Group are used.
 If pvmove gets interrupted for any reason (e.g. the machine crashes)
 then run pvmove again without any PhysicalVolume arguments to
 restart any moves that were in progress from the last checkpoint.
-Alternatively use \fBpvmove \-\-abort\fP at any time to abort them
-at the last checkpoint.
+Alternatively use \fBpvmove \-\-abort\fP at any time to abort.  The
+resulting location of logical volumes after an abort is issued depends
+on whether the
+.B \-\-atomic
+option was used when starting the pvmove process.
 
 You can run more than one pvmove at once provided they are moving data
 off different SourcePhysicalVolumes, but additional pvmoves will ignore
@@ -77,11 +81,35 @@ is updated so that the Logical Volumes reflect the new data locations.
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
 
+If the
+.B \-\-atomic
+option is used, a slightly different approach is used for the move.  Again,
+a temporary 'pvmove' logical volume is created to store the details of all
+the data movements required.  This temporary LV contains all the segments of
+the various LVs that need to be moved.  However this time, an identical
+logical volume is allocated that contains the same number of segments and
+a mirror is created to copy the contents from the first temporary LV to the
+second.  When a complete copy is accomplished, the temporary logical volumes
+are removed, leaving behind the segments on the destination physical volume.
+If an abort is issued during the move, all logical volumes being moved will
+remain on the source physical volume.
+
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
 .B \-\-abort
-Abort any moves in progress.
+Abort any moves in progress.  If the
+.B \-\-atomic
+option was used to start the pvmove, all logical volumes will remain on
+the source physical volume.  Otherwise, those segments that have completed
+the move will stay on the destination physical volume, while those that
+have not will remain on the source physical volume.
+.TP
+.B \-\-atomic
+Make the entire operation atomic.  That is, ensure that all affected logical
+volumes are moved to the destination physical volume together; unless the move
+has been aborted.  If the move has been aborted, all logical volumes will
+remain on the source physical volume.
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 0cd5dd3..8f59301 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -15,10 +15,15 @@
 
 aux prepare_vg 3
 
+for mode in "--atomic" ""
+do
 lvcreate -aey -l1 -n $lv1 $vg "$dev1"
 
 lvs -o +devices | grep $dev1
-pvmove -i 1 -b "$dev1" "$dev2"
+pvmove $mode -i 1 -b "$dev1" "$dev2"
 sleep 5 # arbitrary...
 lvs -o +devices | not grep "pvmove"
 lvs -o +devices | grep "$dev2"
+
+lvremove -ff $vg
+done
\ No newline at end of file
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e58f5bf..bdfb79a 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -80,6 +80,9 @@ check_and_cleanup_lvs_() {
 aux prepare_pvs 5 5
 create_vg_
 
+for mode in "--atomic" ""
+do
+
 #COMM "check environment setup/cleanup"
 prepare_lvs_
 check_and_cleanup_lvs_
@@ -92,7 +95,7 @@ check_and_cleanup_lvs_
 
 #COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
 restore_lvs_
-pvmove -i1 -n $vg/$lv1 "$dev2" "$dev5"
+pvmove $mode -i1 -n $vg/$lv1 "$dev2" "$dev5"
 check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
 lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
@@ -102,21 +105,21 @@ check_and_cleanup_lvs_
 
 #COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
 restore_lvs_
-pvmove -i0 -n $vg/$lv1 "$dev1" "$dev4"
+pvmove $mode -i0 -n $vg/$lv1 "$dev1" "$dev4"
 check lv_on $vg $lv1 "$dev4" "$dev2" "$dev3"
 lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
 restore_lvs_
-pvmove -i0 -n $vg/$lv1 "$dev2" "$dev4"
+pvmove $mode -i0 -n $vg/$lv1 "$dev2" "$dev4"
 check lv_on $vg $lv1 "$dev1" "$dev4" "$dev3"
 lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
 restore_lvs_
-pvmove -i0 -n $vg/$lv1 "$dev3" "$dev4"
+pvmove $mode -i0 -n $vg/$lv1 "$dev3" "$dev4"
 check lv_on $vg $lv1 "$dev1" "$dev2" "$dev4"
 lvs_not_changed_ $lv2 $lv3
 check_and_cleanup_lvs_
@@ -126,14 +129,14 @@ check_and_cleanup_lvs_
 
 #COMM "1 out of 3 LVs is moved: from pv4 to pv5"
 restore_lvs_
-pvmove -i0 "$dev4" "$dev5"
+pvmove $mode -i0 "$dev4" "$dev5"
 check lv_on $vg $lv2 "$dev2" "$dev3" "$dev5"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "2 out of 3 LVs are moved: from pv3 to pv5"
 restore_lvs_
-pvmove -i0 "$dev3" "$dev5"
+pvmove $mode -i0 "$dev3" "$dev5"
 check lv_on $vg $lv1 "$dev1" "$dev2" "$dev5"
 check lv_on $vg $lv2 "$dev2" "$dev5" "$dev4"
 lvs_not_changed_ $lv3
@@ -141,7 +144,7 @@ check_and_cleanup_lvs_
 
 #COMM "3 out of 3 LVs are moved: from pv2 to pv5"
 restore_lvs_
-pvmove -i0 "$dev2" "$dev5"
+pvmove $mode -i0 "$dev2" "$dev5"
 check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
 check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
 check lv_on $vg $lv3 "$dev5"
@@ -152,21 +155,21 @@ check_and_cleanup_lvs_
 
 #COMM "move the 1st stripe: from pv2 of lv2 to pv1"
 restore_lvs_
-pvmove -i0 -n $vg/$lv2 "$dev2" "$dev1"
+pvmove $mode -i0 -n $vg/$lv2 "$dev2" "$dev1"
 check lv_on $vg $lv2 "$dev1" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
 restore_lvs_
-pvmove -i0 -n $vg/$lv2 "$dev3" "$dev1"
+pvmove $mode -i0 -n $vg/$lv2 "$dev3" "$dev1"
 check lv_on $vg $lv2 "$dev2" "$dev1" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
 restore_lvs_
-pvmove -i0 -n $vg/$lv2 "$dev4" "$dev1"
+pvmove $mode -i0 -n $vg/$lv2 "$dev4" "$dev1"
 check lv_on $vg $lv2 "$dev2" "$dev3" "$dev1"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
@@ -176,21 +179,21 @@ check_and_cleanup_lvs_
 
 #COMM "match to the start of segment:from pv2:0-0 to pv5"
 restore_lvs_
-pvmove -i0 "$dev2":0-0 "$dev5"
+pvmove $mode -i0 "$dev2":0-0 "$dev5"
 check lv_on $vg $lv2 "$dev5" "$dev2" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 #exit 0
 #COMM "match to the middle of segment: from pv2:1-1 to pv5"
 restore_lvs_
-pvmove -i0 "$dev2":1-1 "$dev5"
+pvmove $mode -i0 "$dev2":1-1 "$dev5"
 check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4" "$dev5"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "match to the end of segment: from pv2:2-2 to pv5"
 restore_lvs_
-pvmove -i0 "$dev2":2-2 "$dev5"
+pvmove $mode -i0 "$dev2":2-2 "$dev5"
 check lv_on $vg $lv2 "$dev2" "$dev5" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
@@ -200,21 +203,21 @@ check_and_cleanup_lvs_
 
 #COMM "no destination split: from pv2:0-2 to pv5"
 restore_lvs_
-pvmove -i0 "$dev2":0-2 "$dev5"
+pvmove $mode -i0 "$dev2":0-2 "$dev5"
 check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
 restore_lvs_
-pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
+pvmove $mode -i0 --alloc anywhere "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
 check lv_on $vg $lv2 "$dev5" "$dev4" "$dev3"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
 restore_lvs_
-pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev3":5-5 "$dev4":5-5 "$dev5":5-5
+pvmove $mode -i0 --alloc anywhere "$dev2":0-2 "$dev3":5-5 "$dev4":5-5 "$dev5":5-5
 check lv_on $vg $lv2 "$dev3" "$dev4" "$dev5"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
@@ -224,14 +227,14 @@ check_and_cleanup_lvs_
 
 #COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7"
 restore_lvs_
-not pvmove -i0 "$dev3":0-2 "$dev3":5-7
+not pvmove $mode -i0 "$dev3":0-2 "$dev3":5-7
 # "(cleanup previous test)"
 lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
 restore_lvs_
-pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7
+pvmove $mode -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7
 check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
@@ -241,7 +244,7 @@ restore_lvs_
 #lvs -a -o name,size,seg_pe_ranges $vg
 #LV2    1.12m @TESTDIR@/dev/mapper/@PREFIX at pv2:0-2 @TESTDIR@/dev/mapper/@PREFIX at pv3:0-2 @TESTDIR@/dev/mapper/@PREFIX at pv4:0-2
 
-pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7 "$dev5":5-6 "$dev4":5-5
+pvmove $mode -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7 "$dev5":5-6 "$dev4":5-5
 
 #lvs -a -o name,size,seg_pe_ranges $vg
 # Hmm is this correct ? - why pv2 is split
@@ -253,14 +256,14 @@ check_and_cleanup_lvs_
 
 #COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
 restore_lvs_
-not pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
+not pvmove $mode -i0 --alloc contiguous "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
 # "(cleanup previous test)"
 lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
 restore_lvs_
-pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":0-0 "$dev5":3-5 "$dev4":5-6
+pvmove $mode -i0 --alloc contiguous "$dev2":0-2 "$dev5":0-0 "$dev5":3-5 "$dev4":5-6
 check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
 lvs_not_changed_ $lv1 $lv3
 check_and_cleanup_lvs_
@@ -270,7 +273,7 @@ check_and_cleanup_lvs_
 
 #COMM "multiple source LVs: from pv3 to pv5"
 restore_lvs_
-pvmove -i0 "$dev3" "$dev5"
+pvmove $mode -i0 "$dev3" "$dev5"
 check lv_on $vg $lv1 "$dev1" "$dev2" "$dev5"
 check lv_on $vg $lv2 "$dev2" "$dev5" "$dev4"
 lvs_not_changed_ $lv3
@@ -283,7 +286,7 @@ check_and_cleanup_lvs_
 restore_lvs_
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv3
-pvmove -i0 "$dev2" "$dev5"
+pvmove $mode -i0 "$dev2" "$dev5"
 check lv_on $vg $lv1 "$dev1" "$dev5" "$dev3"
 check lv_on $vg $lv2 "$dev5" "$dev3" "$dev4"
 check lv_on $vg $lv3 "$dev5"
@@ -294,8 +297,8 @@ check_and_cleanup_lvs_
 
 #COMM "no PEs to move: from pv3 to pv1"
 restore_lvs_
-pvmove -i0 "$dev3" "$dev1"
-not pvmove -i0 "$dev3" "$dev1"
+pvmove $mode -i0 "$dev3" "$dev1"
+not pvmove $mode -i0 "$dev3" "$dev1"
 # "(cleanup previous test)"
 check lv_on $vg $lv1 "$dev1" "$dev2" "$dev1"
 check lv_on $vg $lv2 "$dev2" "$dev1" "$dev4"
@@ -304,21 +307,21 @@ check_and_cleanup_lvs_
 
 #COMM "no space available: from pv2:0-0 to pv1:0-0"
 restore_lvs_
-not pvmove -i0 "$dev2":0-0 "$dev1":0-0
+not pvmove $mode -i0 "$dev2":0-0 "$dev1":0-0
 # "(cleanup previous test)"
 lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM 'same source and destination: from pv1 to pv1'
 restore_lvs_
-not pvmove -i0 "$dev1" "$dev1"
+not pvmove $mode -i0 "$dev1" "$dev1"
 #"(cleanup previous test)"
 lvs_not_changed_ $lv1 $lv2 $lv3
 check_and_cleanup_lvs_
 
 #COMM "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough"
 restore_lvs_
-not pvmove --alloc anywhere "$dev1":0-2 "$dev1":0-2 "$dev5":0-0 2> err
+not pvmove $mode --alloc anywhere "$dev1":0-2 "$dev1":0-2 "$dev5":0-0 2> err
 #"(cleanup previous test)"
 grep "Insufficient free space" err
 lvs_not_changed_ $lv1 $lv2 $lv3
@@ -328,7 +331,7 @@ check_and_cleanup_lvs_
 
 #COMM "pvmove abort"
 restore_lvs_
-pvmove -i100 -b "$dev1" "$dev3"
+pvmove $mode -i100 -b "$dev1" "$dev3"
 pvmove --abort
 check_and_cleanup_lvs_
 
@@ -338,10 +341,21 @@ pvcreate $(cat DEVICES)
 pvcreate --metadatacopies 0 "$dev1" "$dev2"
 create_vg_
 lvcreate -l4 -n $lv1 $vg "$dev1"
-pvmove "$dev1"
+pvmove $mode "$dev1"
 
 #COMM "pvmove fails activating mirror, properly restores state before pvmove"
 dmsetup create $vg-pvmove0 --notable
-not pvmove -i 1 "$dev2"
+not pvmove $mode -i 1 "$dev2"
+echo BARF
+dmsetup ls
+dmsetup info --noheadings -c -o suspended $vg-$lv1
 test $(dmsetup info --noheadings -c -o suspended $vg-$lv1) = "Active"
-dmsetup remove $vg-pvmove0
+if [ -e /dev/mapper/$vg-pvmove0_mimage_0 ]; then
+        dmsetup remove $vg-pvmove0 /dev/mapper/$vg-pvmove0_mimage*
+else
+        dmsetup remove $vg-pvmove0
+fi
+dmsetup ls
+
+lvremove -ff $vg
+done
\ No newline at end of file
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 0c1020e..94a3848 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -29,6 +29,8 @@ aux have_raid 1 4 2 || skip
 
 aux prepare_vg 5 80
 
+for mode in "--atomic" ""
+do
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
 #    The two LVs will share a PV.
@@ -42,14 +44,14 @@ lvcreate --type cache-pool -n ${lv1}_pool -l 4 $vg "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg ${lv1}_pool "$dev1"
 
-pvmove "$dev1" "$dev5" 2>&1 | tee out
+pvmove $mode "$dev1" "$dev5" 2>&1 | tee out
 grep "Skipping cache-pool LV, ${lv1}_pool" out
 grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
 grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 not check lv_tree_on $vg ${lv1}_pool "$dev5"
 
-#pvmove -n ${lv1}_pool "$dev5" "$dev4"
+#pvmove $mode -n ${lv1}_pool "$dev5" "$dev4"
 #check lv_tree_on $vg ${lv1}_pool "$dev4"
 #check lv_tree_on $vg ${lv1}_foo "$dev5"
 
@@ -66,7 +68,7 @@ check lv_tree_on $vg ${lv1}_pool "$dev5"
 check lv_tree_on $vg ${lv1} "$dev1"
 
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev3" 2>&1 | tee out
+pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
 grep "Skipping cache LV, ${lv1}" out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
@@ -74,7 +76,7 @@ lvs -a -o name,attr,devices $vg
 not check lv_tree_on $vg ${lv1} "$dev3"
 #check dev_md5sum $vg $lv1
 
-#pvmove -n $lv1 "$dev3" "$dev1"
+#pvmove $mode -n $lv1 "$dev3" "$dev1"
 #check lv_tree_on $vg ${lv1}_foo "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
 #check lv_tree_on $vg ${lv1} "$dev1"
@@ -91,14 +93,14 @@ check lv_tree_on $vg ${lv1} "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_pool "$dev5"
 
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev3" 2>&1 | tee out
+pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
 grep "Skipping cache LV, ${lv1}" out
 check lv_tree_on $vg ${lv1}_foo "$dev3"
 not check lv_tree_on $vg ${lv1} "$dev2" "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
 #check dev_md5sum $vg $lv1 -- THIS IS WHERE THINGS FAIL IF PVMOVE NOT DISALLOWED
 
-#pvmove -n $lv1 "$dev3" "$dev1"
+#pvmove $mode -n $lv1 "$dev3" "$dev1"
 #check lv_tree_on $vg ${lv1}_foo "$dev3"
 #check lv_tree_on $vg ${lv1} "$dev1" "$dev2"
 #check lv_tree_on $vg ${lv1}_pool "$dev5"
@@ -120,7 +122,7 @@ check lv_tree_on $vg ${lv1} "$dev5"
 aux mkdev_md5sum $vg $lv1
 # This will move ${lv1}_foo and the cache-pool data & meta
 #  LVs, both of which contain a RAID1 _rimage & _rmeta LV - 5 total LVs
-pvmove "$dev1" "$dev3" 2>&1 | tee out
+pvmove $mode "$dev1" "$dev3" 2>&1 | tee out
 grep "Skipping cache-pool LV, ${lv1}_pool" out
 grep "Skipping cache-related LV, ${lv1}_pool_cmeta" out
 grep "Skipping cache-related LV, ${lv1}_pool_cdata" out
@@ -129,7 +131,7 @@ not check lv_tree_on $vg ${lv1}_pool "$dev2" "$dev3"
 #check lv_tree_on $vg ${lv1} "$dev5"
 #check dev_md5sum $vg $lv1
 
-#pvmove -n ${lv1}_pool "$dev3" "$dev1"
+#pvmove $mode -n ${lv1}_pool "$dev3" "$dev1"
 #check lv_tree_on $vg ${lv1}_foo "$dev3"
 #check lv_tree_on $vg ${lv1}_pool "$dev1" "$dev2"
 #check lv_tree_on $vg ${lv1} "$dev5"
@@ -161,17 +163,19 @@ check lv_tree_on $vg thinpool "$dev1" "$dev3" "$dev4"
 aux mkdev_md5sum $vg thin_lv
 lvs -a -o name,attr,devices $vg
 # Should move ${lv1}_foo and thinpool_tmeta from dev1 to dev5
-pvmove "$dev1" "$dev5" 2>&1 | tee out
+pvmove $mode "$dev1" "$dev5" 2>&1 | tee out
 lvs -a -o name,attr,devices $vg
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 not check lv_tree_on $vg cachepool "$dev5" "$dev2"
 check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
 #check dev_md5sum $vg/thin_lv
 
-#pvmove -n $vg/cachepool "$dev5" "$dev1"
+#pvmove $mode -n $vg/cachepool "$dev5" "$dev1"
 #check lv_tree_on $vg ${lv1}_foo "$dev5"
 #check lv_tree_on $vg $vg/cachepool "$dev1" "$dev2"
 #check lv_tree_on $vg $vg/thinpool "$dev3" "$dev4"
 #check dev_md5sum $vg/thin_lv
 
 lvremove -ff $vg
+
+done
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index dd12c1b..0accf4a 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -21,6 +21,8 @@ aux have_raid 1 3 5 || skip
 aux prepare_pvs 5 20
 vgcreate -c n -s 128k $vg $(cat DEVICES)
 
+for mode in "--atomic" ""
+do
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
 #    The two LVs will share a PV.
@@ -33,11 +35,11 @@ lvcreate -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
+pvmove $mode "$dev1" "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev2" "$dev5"
 check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev4"
+pvmove $mode -n $lv1 "$dev5" "$dev4"
 check lv_tree_on $vg $lv1 "$dev2" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
@@ -50,11 +52,11 @@ lvcreate -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
+pvmove $mode "$dev1" "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4" "$dev5"
 check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev1"
+pvmove $mode -n $lv1 "$dev5" "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
@@ -67,13 +69,16 @@ lvcreate -l 4 --type raid5 -i 2 -n $lv1 $vg \
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3"
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
+pvmove $mode "$dev1" "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev5"
 check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev4"
+pvmove $mode -n $lv1 "$dev5" "$dev4"
 check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
 
+lvremove -ff $vg
+done
+
 vgremove -ff $vg
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 9f30cf7..af079ea 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -17,6 +17,9 @@ aux prepare_pvs 3 60
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 
+for mode in "--atomic" ""
+do
+
 # Create multisegment LV
 lvcreate -an -Zn -l5 -n $lv1 $vg "$dev1"
 lvextend -l+10 $vg/$lv1 "$dev2"
@@ -37,7 +40,7 @@ wait
 
 # Simulate reboot - forcibly remove related devices
 dmsetup remove $vg-$lv1
-dmsetup remove $vg-pvmove0
+dmsetup remove /dev/mapper/$vg-pvmove0*
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"
@@ -81,4 +84,7 @@ aux delay_dev "$dev3"
 
 lvs -a -o+devices $vg
 
+lvremove -ff $vg
+done
+
 vgremove -ff $vg
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 7819e6c..33128d5 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -22,6 +22,9 @@ aux have_raid 1 3 5 || skip
 aux prepare_pvs 5 20
 vgcreate -c n -s 128k $vg $(cat DEVICES)
 
+for mode in "--atomic" ""
+do
+
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
 #    The two LVs will share a PV.
@@ -35,11 +38,11 @@ lvcreate -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1"
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
+pvmove "$dev1" "$dev5" $mode
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev5"
 check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev4"
+pvmove -n $lv1 "$dev5" "$dev4" $mode
 check lv_tree_on $vg $lv1 "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
@@ -55,14 +58,16 @@ lvcreate -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
+pvmove "$dev1" "$dev5" $mode
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev2" "$dev5"
 check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev4"
+pvmove -n $lv1 "$dev5" "$dev4" $mode
 check lv_tree_on $vg $lv1 "$dev2" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
+done
+
 vgremove -ff $vg
diff --git a/tools/args.h b/tools/args.h
index 0ee380a..8dc8b5f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -17,6 +17,7 @@
  * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
+arg(atomic_ARG, '\0', "atomic", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 019d4ef..0644c54 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -764,6 +764,7 @@ xx(pvmove,
    0,
    "pvmove " "\n"
    "\t[--abort]\n"
+   "\t[--atomic]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -780,7 +781,7 @@ xx(pvmove,
    "\tSourcePhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]}\n"
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
-   abort_ARG, alloc_ARG, autobackup_ARG, background_ARG,
+   abort_ARG, atomic_ARG, alloc_ARG, autobackup_ARG, background_ARG,
    interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
 
 xx(pvremove,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a7788ba..24410d1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -486,7 +486,9 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	}
 
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
-			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
+			    allocatable_pvs, alloc,
+			    (arg_count(cmd, atomic_ARG)) ?
+			    MIRROR_BY_SEGMENTED_LV : MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored");
 		return_NULL;
 	}
@@ -515,15 +517,54 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 	return r;
 }
 
+static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
+				      void *baton)
+{
+	uint32_t s = *((uint32_t *)baton);
+	struct lv_segment *mirror_seg;
+
+	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {
+		log_error(INTERNAL_ERROR
+			  "%s is not a proper mirror image",
+			  mimage_lv->name);
+		return 0;
+	}
+
+	if (seg_type(mirror_seg, 0) != AREA_LV) {
+		log_error(INTERNAL_ERROR
+			  "%s is not a pvmove mirror of LV-type",
+			  mirror_seg->lv->name);
+		return 0;
+	}
+
+	if (s > mirror_seg->area_count) {
+		log_error(INTERNAL_ERROR
+			  "Invalid segment number");
+		return 0;
+	}
+
+	if (seg_lv(mirror_seg, s) == mimage_lv)
+		return 1;
+
+	return 0;
+}
+
 static int _detach_pvmove_mirror(struct cmd_context *cmd,
 				 struct logical_volume *lv_mirr)
 {
+	uint32_t s = 0;
 	struct dm_list lvs_completed;
 	struct lv_list *lvl;
 
 	/* Update metadata to remove mirror segments and break dependencies */
 	dm_list_init(&lvs_completed);
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, NULL, PVMOVE) ||
+
+	if (arg_is_set(cmd, abort_ARG) &&
+	    (seg_type(first_seg(lv_mirr), 0) == AREA_LV))
+		s = 1; /* remove the second mirror leg */
+
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0,
+			       _is_pvmove_image_removable, &s, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
 		return 0;


