From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 11 Apr 2017 18:28:13 -0400
Subject: master - raid: handle insufficent PVs on takeover from striped/raid0
Message-ID: <201704112228.v3BMSDDu018941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bc85177b08c7a6f4f0c3384c8d05b9089267c14
Commit:        7bc85177b08c7a6f4f0c3384c8d05b9089267c14
Parent:        c7ecf379abfffee385c8e862029285d1b436845d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 00:25:23 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 00:27:59 2017 +0200

raid: handle insufficent PVs on takeover from striped/raid0

Remove any newly allocated sub LV (pair) remnants in case
allocation fails due to lag of (parallel) free PV space
and keep initial raid type.

Resolves: rhbz1438013
---
 lib/metadata/raid_manip.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 06a92b3..4662736 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5006,6 +5006,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 {
 	uint32_t extents_copied, region_size, seg_len, stripe_size;
 	struct lv_segment *seg = first_seg(lv);
+	const struct segment_type *initial_segtype = seg->segtype;
 	struct dm_list removal_lvs;
 
 	dm_list_init(&removal_lvs);
@@ -5083,7 +5084,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	/* Add metadata LVs */
 	if (seg_is_raid0(seg)) {
 		log_debug_metadata("Adding metadata LVs to %s.", display_lvname(lv));
-		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
+		if (!_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, NULL))
 			return 0;
 	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role change issues in the kernel */
 	}
@@ -5111,8 +5112,28 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
 				   new_image_count - lv_raid_image_count(lv),
 				   display_lvname(lv));
-		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, NULL, 0, 1))
+		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, NULL, 0, 1)) {
+			/*
+			 * Rollback to initial type raid0/striped after failure to upconvert
+			 * to raid4/5/6/10 elminating any newly allocated metadata devices
+			 * (raid4/5 -> raid6 doesn't need any explicit changes after
+			 *  the allocation of the additional sub LV pair failed)
+			 *
+			 * - initial type is raid0 -> just remove remove metadata devices
+			 *
+			 * - initial type is striped -> convert back to it (removes metadata devices)
+			 */
+			if (segtype_is_raid0(initial_segtype) &&
+			    !_raid0_add_or_remove_metadata_lvs(lv, 0, NULL, &removal_lvs))
+				return_0;
+			if (segtype_is_striped_target(initial_segtype) &&
+			    !_convert_raid0_to_striped(lv, 0, &removal_lvs))
+				return_0;
+			if (!_eliminate_extracted_lvs(lv->vg, &removal_lvs)) /* Updates vg */
+				return_0;
+
 			return 0;
+		}
 
 		seg = first_seg(lv);
 	}


