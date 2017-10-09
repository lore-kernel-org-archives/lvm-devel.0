From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 9 Oct 2017 10:15:34 -0400
Subject: master - raid: cleanup raid4/5/6/10 validation check
Message-ID: <201710091415.v99EFYsZ027715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a639d81445a00974c5ccfd877a197adf5607b22
Commit:        3a639d81445a00974c5ccfd877a197adf5607b22
Parent:        44275c763c9c628152095aee9c99a8e078fc44d6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 9 16:13:45 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 9 16:13:45 2017 +0200

raid: cleanup raid4/5/6/10 validation check

---
 lib/metadata/merge.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 711e7e7..9462a36 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -169,11 +169,13 @@ static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 	_check_raid_region_recovery(seg, error_count);
 	/* END: checks applying to any raid4/5/6/10 */
 
-	if (seg->lv->status & LV_RESHAPE_DATA_OFFSET) {
-		if (seg->data_offset > 1 && (seg->data_offset & (seg->lv->vg->extent_size - 1)))
+	if (seg->data_offset > 1) {
+		if (seg->lv->status & LV_RESHAPE_DATA_OFFSET) {
+			if (seg->data_offset & (seg->lv->vg->extent_size - 1))
+				raid_seg_error_val("data_offset", seg->data_offset);
+		} else
 			raid_seg_error_val("data_offset", seg->data_offset);
-	} else if (seg->data_offset)
-		raid_seg_error_val("data_offset", seg->data_offset);
+	}
 
 	/* Specific checks per raid level */
 	if (seg_is_raid4(seg) ||


