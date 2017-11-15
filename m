From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:34 -0500
Subject: master - pvmove: snapshots need to go with origin device
Message-ID: <201711151309.vAFD9Y0r001939@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=919744375e21856ee6511f5f7185c3773d60da0b
Commit:        919744375e21856ee6511f5f7185c3773d60da0b
Parent:        7c5531b4ca2bb261a7a37fd1c895963afb9d80e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 21:18:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 11:51:53 2017 +0100

pvmove: snapshots need to go with origin device

Enable future support for pvmove for COW LVs.
---
 lib/activate/dev_manager.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 29727df..1ca3baa 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1939,6 +1939,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_segment *seg;
 	struct dm_tree_node *node;
 	const char *uuid;
+	const struct logical_volume *plv;
 
 	if (lv_is_cache_pool(lv)) {
 		if (!dm_list_empty(&lv->segs_using_this_lv)) {
@@ -2061,9 +2062,12 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
 	if (dm->track_pvmove_deps && lv_is_pvmove(lv)) {
 		dm->track_pvmove_deps = 0;
-		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+			/* If LV is snapshot COW - whole snapshot needs reload */
+			plv = lv_is_cow(sl->seg->lv) ? origin_from_cow(sl->seg->lv) : sl->seg->lv;
+			if (!_add_lv_to_dtree(dm, dtree, plv, 0))
 				return_0;
+		}
 		dm->track_pvmove_deps = 1;
 	}
 


