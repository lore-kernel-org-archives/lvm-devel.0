From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:32 -0500
Subject: master - activation: avoid rechecking pvmove node
Message-ID: <201712011120.vB1BKWtv029463@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e794b7748a84d2e8f48012b6c31ba50992c8ac1
Commit:        7e794b7748a84d2e8f48012b6c31ba50992c8ac1
Parent:        e4db42e4769823aceb59698cef9811c11e330b7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 30 13:26:44 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

activation: avoid rechecking pvmove node

Use new 3rd. state of trace_pvmove_deps == 2.
In this state we know, we have already seen the node and can skip futher
testing.   Remainging value 1 signals we want to track, and value 0
is for ignoring tracking, but node is still checking in this case.

Reduces large amount of duplicate ioctl queries.
---
 lib/activate/dev_manager.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 429f4f6..9f19912 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2059,6 +2059,9 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	const char *uuid;
 	const struct logical_volume *plv;
 
+	if (lv_is_pvmove(lv) && (dm->track_pvmove_deps == 2))
+		return 1; /* Avoid rechecking of already seen pvmove LV */
+
 	if (lv_is_cache_pool(lv)) {
 		if (!dm_list_empty(&lv->segs_using_this_lv)) {
 			if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), 0))
@@ -2178,8 +2181,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
-	if (dm->track_pvmove_deps && lv_is_pvmove(lv)) {
-		dm->track_pvmove_deps = 0;
+	if ((dm->track_pvmove_deps == 1) && lv_is_pvmove(lv)) {
+		dm->track_pvmove_deps = 2; /* Mark as already seen */
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 			/* If LV is snapshot COW - whole snapshot needs reload */
 			plv = lv_is_cow(sl->seg->lv) ? origin_from_cow(sl->seg->lv) : sl->seg->lv;


