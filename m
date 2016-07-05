From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  5 Jul 2016 22:10:27 +0000 (UTC)
Subject: master - vgsplit: Don't skip moving internal snapshot LV.
Message-ID: <20160705221027.2037C61326@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfcdfa057bad1ea231f89b11ebcc761ffc49d922
Commit:        dfcdfa057bad1ea231f89b11ebcc761ffc49d922
Parent:        4d4f48af9f18b9407c065cdc035cf8e397e08ac0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 5 23:08:14 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 5 23:08:14 2016 +0100

vgsplit: Don't skip moving internal snapshot LV.

Also place snapshot LV handling back at the end, after all possible
origin and cow LVs got dealt with.
---
 tools/vgsplit.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index afe87af..221600e 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -190,10 +190,6 @@ static int _move_snapshots(struct volume_group *vg_from,
 		if (!(lv->status & SNAPSHOT))
 			continue;
 
-		/* Ignore, if no allocations on PVs of @vg_to */
-		if (!lv_is_on_pvs(lv, &vg_to->pvs))
-			continue;
-
 		dm_list_iterate_items(seg, &lv->segments) {
 			cow_from = _lv_is_in_vg(vg_from, seg->cow);
 			origin_from = _lv_is_in_vg(vg_from, seg->origin);
@@ -680,17 +676,18 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!(_move_mirrors(vg_from, vg_to)))
 		goto_bad;
 
-	/* Move required snapshots across */
-	if (!(_move_snapshots(vg_from, vg_to)))
-		goto_bad;
-
 	/* Move required pools across */
 	if (!(_move_thins(vg_from, vg_to)))
 		goto_bad;
 
+	/* Move required cache LVs across */
 	if (!(_move_cache(vg_from, vg_to)))
 		goto_bad;
 
+	/* Move required snapshots across */
+	if (!(_move_snapshots(vg_from, vg_to)))
+		goto_bad;
+
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");


