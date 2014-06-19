From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 19 Jun 2014 12:42:32 +0000 (UTC)
Subject: master - pvmove: tidy
Message-ID: <20140619124232.5149961076@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b33091cb115ccc11741344716756e522ebad8e48
Commit:        b33091cb115ccc11741344716756e522ebad8e48
Parent:        bc0a1ca83d6d89dd86d0d8e43239b97505e82e84
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 19 13:40:47 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 19 13:40:47 2014 +0100

pvmove: tidy

---
 WHATS_NEW                        |    2 +-
 lib/metadata/metadata-exported.h |    6 ++----
 tools/args.h                     |    2 +-
 tools/commands.h                 |    4 ++--
 tools/pvmove.c                   |   23 ++++++++++-------------
 5 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f7d2b96..44cef74 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -6,7 +6,7 @@ Version 2.02.107 -
   Add -S/--select to pvs,vgs,lvs and {pv,vg,lv}display -C for report selection.
   Use dm_report_init_with_selection now, implicit "selected" field appears.
   Make use of libdm's DM_REPORT_FIELD_TYPE{SIZE,PERCENT,STRING_LIST} for fields.
-  Add support for all-or-nothing (atomic) pvmove.
+  Support all-or-nothing pvmove --atomic.
   Automatically add snapshot metadata size for -l %ORIGIN calculation.
   When converting RAID origin to cache LV, properly rename sub-LVs.
   Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 90fd6d8..a7d30b3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -133,10 +133,8 @@
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
-#define MIRROR_BY_SEGMENTED_LV	0x00000004U	/* mirror using whole mimage
-						 * LVs, but preserve the
-						 * segment layout templated by
-						 * the primary mimage */
+#define MIRROR_BY_SEGMENTED_LV	0x00000004U	/* mirror using whole mimage LVs that
+						 * preserve the segment structure */
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* vg_read and vg_read_for_update flags */
diff --git a/tools/args.h b/tools/args.h
index 8dc8b5f..54e225f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -17,7 +17,6 @@
  * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
-arg(atomic_ARG, '\0', "atomic", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
@@ -108,6 +107,7 @@ arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
 arg(readonly_ARG, '\0', "readonly", NULL, 0)
+arg(atomic_ARG, '\0', "atomic", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 0644c54..1484aef 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -764,9 +764,9 @@ xx(pvmove,
    0,
    "pvmove " "\n"
    "\t[--abort]\n"
+   "\t[--alloc AllocationPolicy]\n"
    "\t[--atomic]\n"
    "\t[-A|--autobackup {y|n}]\n"
-   "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n "
@@ -781,7 +781,7 @@ xx(pvmove,
    "\tSourcePhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]}\n"
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
-   abort_ARG, atomic_ARG, alloc_ARG, autobackup_ARG, background_ARG,
+   abort_ARG, alloc_ARG, atomic_ARG, autobackup_ARG, background_ARG,
    interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
 
 xx(pvremove,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 24410d1..c4c590b 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -520,30 +520,28 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 				      void *baton)
 {
-	uint32_t s = *((uint32_t *)baton);
+	uint32_t mimage_to_remove = *((uint32_t *)baton);
 	struct lv_segment *mirror_seg;
 
 	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {
-		log_error(INTERNAL_ERROR
-			  "%s is not a proper mirror image",
+		log_error(INTERNAL_ERROR "%s is not a proper mirror image",
 			  mimage_lv->name);
 		return 0;
 	}
 
 	if (seg_type(mirror_seg, 0) != AREA_LV) {
-		log_error(INTERNAL_ERROR
-			  "%s is not a pvmove mirror of LV-type",
+		log_error(INTERNAL_ERROR "%s is not a pvmove mirror of LV-type",
 			  mirror_seg->lv->name);
 		return 0;
 	}
 
-	if (s > mirror_seg->area_count) {
-		log_error(INTERNAL_ERROR
-			  "Invalid segment number");
+	if (mimage_to_remove > mirror_seg->area_count) {
+		log_error(INTERNAL_ERROR "Mirror image %" PRIu32 " not found in segment",
+			  mimage_to_remove);
 		return 0;
 	}
 
-	if (seg_lv(mirror_seg, s) == mimage_lv)
+	if (seg_lv(mirror_seg, mimage_to_remove) == mimage_lv)
 		return 1;
 
 	return 0;
@@ -552,7 +550,7 @@ static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 static int _detach_pvmove_mirror(struct cmd_context *cmd,
 				 struct logical_volume *lv_mirr)
 {
-	uint32_t s = 0;
+	uint32_t mimage_to_remove = 0;
 	struct dm_list lvs_completed;
 	struct lv_list *lvl;
 
@@ -561,10 +559,9 @@ static int _detach_pvmove_mirror(struct cmd_context *cmd,
 
 	if (arg_is_set(cmd, abort_ARG) &&
 	    (seg_type(first_seg(lv_mirr), 0) == AREA_LV))
-		s = 1; /* remove the second mirror leg */
+		mimage_to_remove = 1; /* remove the second mirror leg */
 
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0,
-			       _is_pvmove_image_removable, &s, PVMOVE) ||
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, _is_pvmove_image_removable, &mimage_to_remove, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
 		return 0;


