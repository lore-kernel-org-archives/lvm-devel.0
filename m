From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 16:18:52 -0500
Subject: master - raid: add missing lv_merge_segments() call
Message-ID: <201703092118.v29LIqgY002406@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66fff1d7748f8251c8781830fa984f34d1492310
Commit:        66fff1d7748f8251c8781830fa984f34d1492310
Parent:        76f6951c3e8f0933df9730a42e9c46f273d1da24
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 22:18:34 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 22:18:34 2017 +0100

raid: add missing lv_merge_segments() call

On conversion from striped to raid0, data LVs are created
and all segments and their respective areas of the striped
LV are moved across to new segments allocated for the raid0
image LVs.  This can cause non-canonical segments to be added
to the image LVs.

Add a call to lv_merge_segments() once all segments have been
added to an image LV to compensate for that.  This avoids
unsafe table loads on activation.

Fix comments.
---
 lib/metadata/raid_manip.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 515e4b8..0906916 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3986,6 +3986,10 @@ static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
 		dlv->le_count = le;
 		dlv->size = (uint64_t) le * lv->vg->extent_size;
 		s++;
+
+		/* Try merging raid0 rimage sub LV segments */
+		if (!lv_merge_segments(dlv))
+			return_0;
 	}
 
 	/* Remove the empty segments from the striped LV */
@@ -5122,7 +5126,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	if (!_lv_free_reshape_space(lv))
 		return_0;
 
-	/* This helper can be used to convert from striped/raid0* -> raid10 too */
+	/* This helper can be used to convert from striped/raid0* -> raid10_near too */
 	if (seg_is_striped_target(seg)) {
 		log_debug_metadata("Converting LV %s from %s to %s.",
 				   display_lvname(lv), SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID0);
@@ -5179,7 +5183,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	} else if (segtype_is_raid10_near(new_segtype)) {
 		uint32_t s;
 
-		log_debug_metadata("Reordering areas for raid0 -> raid10 takeover.");
+		log_debug_metadata("Reordering areas for raid0 -> raid10_near takeover.");
 		if (!_reorder_raid10_near_seg_areas(seg, reorder_to_raid10_near))
 			return 0;
 		/* Set rebuild flags accordingly */


