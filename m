From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:32 +0000 (UTC)
Subject: dev-mornfall-activate - raid: read segment only for known LV
Message-ID: <20130604192432.3DD7160E7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e24d563c6e281a582bf1a98673305ce88d6cd05
Commit:        9e24d563c6e281a582bf1a98673305ce88d6cd05
Parent:        4ca6a4105db63344abe3e62eaa0cbcfcb23c47f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 08:47:59 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:07:00 2013 +0200

raid: read segment only for known LV

Avoid reading first_seg() on unknown LV and find it only when needed.
---
 tools/pvmove.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 575f296..a733049 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -207,7 +207,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	/* Find segments to be moved and set up mirrors */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
-		seg = first_seg(lv);
 		if (lv == lv_mirr)
 			continue;
 		if (lv_name) {
@@ -220,14 +219,15 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
-		if (seg_is_raid(seg)) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping %s LV %s",
-						seg->segtype->ops->name(seg),
-						lv->name);
-			continue;
-		}
 		if (lv_is_raid_type(lv)) {
+			seg = first_seg(lv);
+			if (seg_is_raid(seg)) {
+				lv_skipped = 1;
+				log_print_unless_silent("Skipping %s LV %s",
+							seg->segtype->ops->name(seg),
+							lv->name);
+				continue;
+			}
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping RAID sub-LV %s",
 						lv->name);


