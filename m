From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:54:48 -0400
Subject: master - snapshot: use single merging sequence
Message-ID: <201910252254.x9PMsm0D011790@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e5f39a5accf777db0cb5934f5adfd983c5e4491
Commit:        0e5f39a5accf777db0cb5934f5adfd983c5e4491
Parent:        855b16ce14f09523132ea624a7b4d1edaccc2450
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 23:29:16 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:49:16 2019 +0200

snapshot: use single merging sequence

The resume of 'released' 'COW' should preceed the resume of origin.
The fact we need to do the sequence differently for merge was
cause by bugs fixed in 2 previous commits - so we no longer need
to recognize 'merging' and we should always go with single
sequence.

The importance of this order is - to properly remove  '-real' device
from origin LV. When COW is activated as 2nd. '-real' device is
kept in table as it cannot be removed during 1st. resume of origin,
and later activation of COW LV no longer builds tree associated
with origin LV.
---
 lib/metadata/snapshot_manip.c |   19 +------------------
 1 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index d105942..e58aea4 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -286,7 +286,6 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
-	int merging_snapshot = 0;
 	struct logical_volume *origin = origin_from_cow(cow);
 	int is_origin_active = lv_is_active(origin);
 
@@ -315,17 +314,6 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		 * preload origin IFF "snapshot-merge" target is active
 		 * - IMPORTANT: avoids preload if inactivate merge is pending
 		 */
-		if (lv_has_target_type(origin->vg->vgmem, origin, NULL,
-				       TARGET_NAME_SNAPSHOT_MERGE)) {
-			/*
-			 * preload origin to:
-			 * - allow proper release of -cow
-			 * - avoid allocations with other devices suspended
-			 *   when transitioning from "snapshot-merge" to
-			 *   "snapshot-origin after a merge completes.
-			 */
-			merging_snapshot = 1;
-		}
 	}
 
 	if (!lv_remove(cow->snapshot->lv)) {
@@ -356,7 +344,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		 * the LV lock on cluster has to be grabbed, so use
 		 * activate_lv() which resumes suspend cow device.
 		 */
-		if (!merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
+		if (!activate_lv(cow->vg->cmd, cow)) {
 			log_error("Failed to activate %s.", cow->name);
 			return 0;
 		}
@@ -365,11 +353,6 @@ int vg_remove_snapshot(struct logical_volume *cow)
 			log_error("Failed to resume %s.", origin->name);
 			return 0;
 		}
-
-		if (merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
-			log_error("Failed to activate %s.", cow->name);
-			return 0;
-		}
 	}
 
 	return 1;


