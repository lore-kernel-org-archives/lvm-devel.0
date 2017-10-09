From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 9 Oct 2017 10:03:58 -0400
Subject: master - raid: fix validation check for raid0 segment data_offset member
Message-ID: <201710091403.v99E3whc025569@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44275c763c9c628152095aee9c99a8e078fc44d6
Commit:        44275c763c9c628152095aee9c99a8e078fc44d6
Parent:        5f13e33d541f7af77f586ac55edfed336ad8dcc1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 9 15:21:51 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 9 16:03:35 2017 +0200

raid: fix validation check for raid0 segment data_offset member

Commit 2f754b73ffdaa95af4a6d703e31b76d4efbf7a36 missed one.
---
 lib/metadata/merge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 5017cf1..711e7e7 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -119,7 +119,7 @@ static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 		raid_seg_error_val("non-zero min recovery rate", seg->min_recovery_rate);
 	if (seg->max_recovery_rate)
 		raid_seg_error_val("non-zero max recovery rate", seg->max_recovery_rate);
-	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset)
+	if ((seg->lv->status & LV_RESHAPE_DATA_OFFSET) || seg->data_offset > 1)
 		raid_seg_error_val("data_offset", seg->data_offset);
 }
 


