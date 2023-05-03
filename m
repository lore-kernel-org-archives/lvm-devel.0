From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 May 2023 19:28:35 +0000 (GMT)
Subject: main - lvreduce: make _lvseg_get_stripes handle integrity layer
Message-ID: <20230503192835.9DB4D3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=368381fd4022dc99ffe551b30ed75c3ddbc5c5c8
Commit:        368381fd4022dc99ffe551b30ed75c3ddbc5c5c8
Parent:        c4440b5b495a2d11ff541dd7e7791e2a83c83609
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 2 16:12:23 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 11:34:59 2023 -0500

lvreduce: make _lvseg_get_stripes handle integrity layer

lvreduce uses _lvseg_get_stripes() which was unable to get raid stripe
info with an integrity layer present.  This caused lvreduce on a
raid+integrity LV to fail prematurely when checking stripe parameters.
An unhelpful error message about stripe size would be printed.
---
 lib/metadata/lv_manip.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 762a65785..2dfa3c77b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5144,22 +5144,39 @@ int lv_extend_policy_calculate_percent(struct logical_volume *lv,
 
 static uint32_t _lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 {
-	uint32_t s;
-	struct lv_segment *seg_mirr;
+	uint32_t s, a;
+	struct lv_segment *seg_get, *seg_image, *seg_iorig;
+	struct logical_volume *lv_image, *lv_iorig;
 
 	/* If segment mirrored, check if images are striped */
-	if (seg_is_mirrored(seg))
+	if (seg_is_mirrored(seg)) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			seg_mirr = first_seg(seg_lv(seg, s));
 
-			if (seg_is_striped(seg_mirr)) {
-				seg = seg_mirr;
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+			seg_get = NULL;
+
+			if (seg_is_integrity(seg_image)) {
+				/* Get stripe values from the iorig layer. */
+				for (a = 0; a < seg_image->area_count; a++) {
+					lv_iorig = seg_lv(seg_image, a);
+					seg_iorig = first_seg(lv_iorig);
+					seg_get = seg_iorig;
+					break;
+				}
+			} else {
+				/* Get stripe values from the image layer. */
+				seg_get = seg_image;
+			}
+
+			if (seg_get && seg_is_striped(seg_get)) {
+				seg = seg_get;
 				break;
 			}
 		}
-
+	}
 
 	if (seg_is_striped(seg)) {
 		*stripesize = seg->stripe_size;
@@ -5168,7 +5185,7 @@ static uint32_t _lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 
 	if (seg_is_raid(seg)) {
 		*stripesize = seg->stripe_size;
-		return _raid_stripes_count(seg);
+		return _raid_stripes_count(seg); 
 	}
 
 	*stripesize = 0;
@@ -5593,7 +5610,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 						seg_size /= seg_mirrors;
 					lp->extents = logical_extents_used + seg_size;
 					break;
-			}
+				}
 			} else if (new_extents <= logical_extents_used + seg_logical_extents) {
 				seg_size = new_extents - logical_extents_used;
 				lp->extents = new_extents;

