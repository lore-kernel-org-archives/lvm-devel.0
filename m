From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 28 Aug 2013 21:58:16 +0000 (UTC)
Subject: master - activation: Fix segfault with inactive pvmove LV.
Message-ID: <20130828215816.34F9260790@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0f987949b8a0bbbbe7f06694f59f710a73814da
Commit:        c0f987949b8a0bbbbe7f06694f59f710a73814da
Parent:        0acd7173d14195aeb724c1048a8cbf64a2fd2aa7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 28 22:56:23 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 28 22:56:23 2013 +0100

activation: Fix segfault with inactive pvmove LV.

Set flag to avoid recursion back through an inactive pvmove LV when
populating deptree.
---
 WHATS_NEW                  |    3 ++-
 lib/activate/dev_manager.c |    8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d974b0a..71e9fa8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.101 - 
 ===================================
-  Require exactly 3 arguments for lvm2-activation-generator, remove defaults.
+  Avoid unlimited recursion when creating dtree containing inactive pvmove LV.
+  Require exactly 3 arguments for lvm2-activation-generator. Remove defaults.
   Disable pvmove of merging or converting logical volumes.
   Enable pvmove of snapshots and snapshot origins.
   Fix inability to specify LV name when pvmove'ing a RAID, mirror, or thin-LV.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 294606c..11be421 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1763,11 +1763,13 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
-	if (dm->track_pvmove_deps && lv->status & PVMOVE)
+	if (dm->track_pvmove_deps && lv->status & PVMOVE) {
+		dm->track_pvmove_deps = 0;
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-			if (!_cached_info(dm->mem, dtree, sl->seg->lv, 0) &&
-			    !_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
 				return_0;
+		dm->track_pvmove_deps = 1;
+	}
 
 	/* Adding LV head of replicator adds all other related devs */
 	if (lv_is_replicator_dev(lv) &&


