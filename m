From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 18:52:01 -0400
Subject: master - raid: add validation checks for segment data_offset member
Message-ID: <201707142252.v6EMq1AX015559@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb641c342343ac48cc623c8079900b1f4f395a69
Commit:        fb641c342343ac48cc623c8079900b1f4f395a69
Parent:        c64e2a85cb1c76413cf2eee49873bfb9ee24393f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Jul 15 00:50:19 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Jul 15 00:51:43 2017 +0200

raid: add validation checks for segment data_offset member

Commit 34504855a70772e1de3f117a9a610860ead80981 introduced
flag LV_RESHAPE_DATA_OFFSET and used it to avoid incompatible
activation on older runtime.

Enhance vg_validate() raid checking functions with checks for it.
---
 lib/metadata/merge.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index e642459..dbe0d58 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -119,6 +119,8 @@ static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error_val("non-zero min recovery rate", seg->min_recovery_rate);
 	if (seg->max_recovery_rate)
 		raid_seg_error_val("non-zero max recovery rate", seg->max_recovery_rate);
+	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET)
+		raid_seg_error_val("data_offset", seg->data_offset);
 }
 
 /* Check RAID @seg for non-zero, power of 2 region size and min recovery rate <= max */
@@ -141,6 +143,8 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error("no meta areas");
 	if (seg->stripe_size)
 		raid_seg_error_val("non-zero stripe size", seg->stripe_size);
+	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET)
+		raid_seg_error_val("data_offset", seg->data_offset);
 	_check_raid_region_recovery(seg, error_count);
 }
 
@@ -165,6 +169,10 @@ static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 	_check_raid_region_recovery(seg, error_count);
 	/* END: checks applying to any raid4/5/6/10 */
 
+	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) &&
+	    (seg->data_offset & (seg->lv->vg->extent_size - 1)))
+		raid_seg_error_val("data_offset", seg->data_offset);
+
 	/* Specific checks per raid level */
 	if (seg_is_raid4(seg) ||
 	    seg_is_any_raid5(seg)) {


