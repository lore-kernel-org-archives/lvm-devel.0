From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 15 Nov 2017 15:25:17 -0500
Subject: master - raid: add validation checks for reshape flags
Message-ID: <201711152025.vAFKPHYn000539@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93c02e2532c71f5afe91605442a8acc059df982c
Commit:        93c02e2532c71f5afe91605442a8acc059df982c
Parent:        b0618f90116bb723e568e3aeec6cdcfde342d6b2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Nov 15 21:24:44 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Nov 15 21:24:44 2017 +0100

raid: add validation checks for reshape flags

Enhance vg_validate() raid checking functions to check for
flags  LV_RESHAPE and LV_RESHAPE_DELTA_DISKS_(MINUS|PLUS).
---
 lib/metadata/merge.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index d5024cf..f0da2fe 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -98,6 +98,14 @@ int lv_merge_segments(struct logical_volume *lv)
 		return; \
 }
 
+/* Check segment LV for reshape flags. */
+static int _check_raid_seg_reshape_flags(struct lv_segment *seg)
+{
+	return ((seg->lv->status & LV_RESHAPE) ||
+		(seg->lv->status & LV_RESHAPE_DELTA_DISKS_MINUS) ||
+		(seg->lv->status & LV_RESHAPE_DELTA_DISKS_PLUS));
+}
+
 /* Check raid0 segment properties in @seg */
 static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 {
@@ -121,6 +129,8 @@ static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error_val("non-zero max recovery rate", seg->max_recovery_rate);
 	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset > 1)
 		raid_seg_error_val("data_offset", seg->data_offset);
+	if (_check_raid_seg_reshape_flags(seg))
+		raid_seg_error("reshape");
 }
 
 /* Check RAID @seg for non-zero, power of 2 region size and min recovery rate <= max */
@@ -145,6 +155,8 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error_val("non-zero stripe size", seg->stripe_size);
 	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset > 1)
 		raid_seg_error_val("data_offset", seg->data_offset);
+	if (_check_raid_seg_reshape_flags(seg))
+		raid_seg_error("reshape");
 	_check_raid_region_recovery(seg, error_count);
 }
 
@@ -388,6 +400,9 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 	if (seg_is_raid(seg))
 		_check_raid_seg(seg, error_count);
+	else if (!lv_is_raid_type(lv) &&
+		 _check_raid_seg_reshape_flags(seg))
+		seg_error("reshape");
 
 	if (seg_is_pool(seg)) {
 		if ((seg->area_count != 1) || (seg_type(seg, 0) != AREA_LV)) {


