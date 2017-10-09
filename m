From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 9 Oct 2017 08:02:39 -0400
Subject: master - raid: fix validation checks for segment data_offset member
Message-ID: <201710091202.v99C2dUG005480@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f754b73ffdaa95af4a6d703e31b76d4efbf7a36
Commit:        2f754b73ffdaa95af4a6d703e31b76d4efbf7a36
Parent:        554a761db2acf2216eadf0279a390ac924038286
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 9 14:00:46 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 9 14:01:23 2017 +0200

raid: fix validation checks for segment data_offset member

Commit 222e1e3acee399b0acf31565f784716d67c465a8 was not
valuing special case of data_ofset member equal to 1.
---
 lib/metadata/merge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index b0adc5a..5017cf1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -143,7 +143,7 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error("no meta areas");
 	if (seg->stripe_size)
 		raid_seg_error_val("non-zero stripe size", seg->stripe_size);
-	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset)
+	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset > 1)
 		raid_seg_error_val("data_offset", seg->data_offset);
 	_check_raid_region_recovery(seg, error_count);
 }
@@ -170,7 +170,7 @@ static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 	/* END: checks applying to any raid4/5/6/10 */
 
 	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET) {
-		if (seg->data_offset & (seg->lv->vg->extent_size - 1))
+		if (seg->data_offset > 1 && (seg->data_offset & (seg->lv->vg->extent_size - 1)))
 			raid_seg_error_val("data_offset", seg->data_offset);
 	} else if (seg->data_offset)
 		raid_seg_error_val("data_offset", seg->data_offset);


