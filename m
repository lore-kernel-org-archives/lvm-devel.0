From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:41 +0000 (UTC)
Subject: master - thin: merge support for device tree
Message-ID: <20131204133141.CF6E460FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=664a695561c98645dd557428108766b702db530d
Commit:        664a695561c98645dd557428108766b702db530d
Parent:        e286904da6a253394c050abde780269571289268
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 21:18:34 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

thin: merge support for device tree

When thin snapshot merge is requested, tree must detect
if user tries to active such LV while origin or
snapshost is still active.
---
 lib/activate/dev_manager.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 24574ec..7b0b6e2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1830,6 +1830,9 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		dm_list_iterate(snh, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				return_0;
+	if (dm->activation && !origin_only && lv_is_merging_origin(lv) &&
+	    !_add_lv_to_dtree(dm, dtree, find_snapshot(lv)->lv, 1))
+		return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
 	if (dm->track_pvmove_deps && lv->status & PVMOVE) {
@@ -1868,6 +1871,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;
 		}
+
+		/* When activating, detect merging LV presence */
+		if (dm->activation && seg->merge_lv &&
+		    !_add_lv_to_dtree(dm, dtree, seg->merge_lv, 1))
+			return_0;
 	}
 
 	return 1;
@@ -2436,10 +2444,13 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* An activating merging origin won't have a node in the tree yet */
 		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
 		     dinfo->open_count) ||
-		    ((dinfo = _cached_info(dm->mem, dtree, seg->cow, NULL)) &&
+		    ((dinfo = _cached_info(dm->mem, dtree,
+					   seg_is_thin_volume(seg) ?
+					   seg->lv : seg->cow, NULL)) &&
 		     dinfo->open_count)) {
-			/* FIXME Is there anything simpler to check for instead? */
-			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
+			if (seg_is_thin_volume(seg) ||
+			    /* FIXME Is there anything simpler to check for instead? */
+                            !lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
 				laopts->no_merging = 1;
 		}
 	}


