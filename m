From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 14 Aug 2017 09:07:57 -0400
Subject: master - raid: more validation checks for segment data_offset member
Message-ID: <201708141307.v7ED7vsD028193@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=222e1e3acee399b0acf31565f784716d67c465a8
Commit:        222e1e3acee399b0acf31565f784716d67c465a8
Parent:        42fa20d0d0136c1aeb3ccdf0654c64beeee05821
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 14 15:00:15 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 14 15:00:15 2017 +0200

raid: more validation checks for segment data_offset member

Upgrade commit fb641c342343ac48cc623c8079900b1f4f395a69 with additional checks.
---
 lib/metadata/merge.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index dbe0d58..b0adc5a 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -119,7 +119,7 @@ static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error_val("non-zero min recovery rate", seg->min_recovery_rate);
 	if (seg->max_recovery_rate)
 		raid_seg_error_val("non-zero max recovery rate", seg->max_recovery_rate);
-	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET)
+	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset)
 		raid_seg_error_val("data_offset", seg->data_offset);
 }
 
@@ -143,7 +143,7 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error("no meta areas");
 	if (seg->stripe_size)
 		raid_seg_error_val("non-zero stripe size", seg->stripe_size);
-	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET)
+	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset)
 		raid_seg_error_val("data_offset", seg->data_offset);
 	_check_raid_region_recovery(seg, error_count);
 }
@@ -169,8 +169,10 @@ static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 	_check_raid_region_recovery(seg, error_count);
 	/* END: checks applying to any raid4/5/6/10 */
 
-	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) &&
-	    (seg->data_offset & (seg->lv->vg->extent_size - 1)))
+	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET) {
+		if (seg->data_offset & (seg->lv->vg->extent_size - 1))
+			raid_seg_error_val("data_offset", seg->data_offset);
+	} else if (seg->data_offset)
 		raid_seg_error_val("data_offset", seg->data_offset);
 
 	/* Specific checks per raid level */


