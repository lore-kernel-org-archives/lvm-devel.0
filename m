From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 12 Jul 2016 14:16:45 +0000 (UTC)
Subject: master - vgsplit: temporary list pointer may be invalid
Message-ID: <20160712141645.8CC4A60574@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ca55192e0347c0c5124f7f2d8c1c30aa4d57a43
Commit:        4ca55192e0347c0c5124f7f2d8c1c30aa4d57a43
Parent:        d5be748341ec88e35c826b70152bf1e757653a3a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 12 16:15:32 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 12 16:15:32 2016 +0200

vgsplit: temporary list pointer may be invalid

4420d41fea8 introduced recursive split of lvs which
splits a top-level LV together with it's sub LVs.

This lead to invalid temporary list pointers
causing hangs/OOM situations.

Patch updates the temporary list pointer
referencing a moved sub LV.

- resolves rhbz1354686
---
 tools/vgsplit.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 221600e..806dafe 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -35,6 +35,7 @@ static struct dm_list *_lvh_in_vg(struct logical_volume *lv, struct volume_group
 }
 
 static int _lv_tree_move(struct dm_list *lvh,
+			 struct dm_list **lvht,
 			 struct volume_group *vg_from,
 			 struct volume_group *vg_to)
 {
@@ -43,6 +44,10 @@ static int _lv_tree_move(struct dm_list *lvh,
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list *lvh1;
 
+	/* Update the list pointer refering to the item moving to @vg_to. */
+	if (lvh == *lvht)
+		*lvht = lvh->n;
+
 	dm_list_move(&vg_to->lvs, lvh);
 	lv->vg = vg_to;
 	lv->lvid.id[0] = lv->vg->id;
@@ -51,7 +56,7 @@ static int _lv_tree_move(struct dm_list *lvh,
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
 				if ((lvh1 = _lvh_in_vg(seg_lv(seg, s), vg_from))) {
-					if (!_lv_tree_move(lvh1, vg_from, vg_to))
+					if (!_lv_tree_move(lvh1, lvht, vg_from, vg_to))
 						return 0;
 				} else if (!_lvh_in_vg(seg_lv(seg, s), vg_to))
 					return 0;
@@ -62,7 +67,8 @@ static int _lv_tree_move(struct dm_list *lvh,
 
 static int _move_one_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
-			struct dm_list *lvh)
+			struct dm_list *lvh,
+			struct dm_list **lvht)
 {
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 	struct logical_volume *parent_lv;
@@ -82,7 +88,7 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (!_lv_tree_move(lvh, vg_from, vg_to))
+	if (!_lv_tree_move(lvh, lvht, vg_from, vg_to))
 		return 0;
 
 	/* Moved pool metadata spare LV */
@@ -163,7 +169,7 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 			continue;
 
 		/* Move this LV */
-		if (!_move_one_lv(vg_from, vg_to, lvh))
+		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 			return_0;
 	}
 
@@ -209,7 +215,7 @@ static int _move_snapshots(struct volume_group *vg_from,
 			 */
 			if (_lv_is_in_vg(vg_to, seg->cow) &&
 			    _lv_is_in_vg(vg_to, seg->origin)) {
-				if (!_move_one_lv(vg_from, vg_to, lvh))
+				if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 					return_0;
 			}
 		}
@@ -271,7 +277,7 @@ static int _move_mirrors(struct volume_group *vg_from,
 		}
 
 		if (seg_in == seg->area_count && log_in) {
-			if (!_move_one_lv(vg_from, vg_to, lvh))
+			if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 				return_0;
 		}
 	}
@@ -303,7 +309,7 @@ static int _move_raids(struct volume_group *vg_from,
 			continue;
  
 		/* If allocations are on PVs of @vg_to -> move RAID LV stack across */
-		if (!_move_one_lv(vg_from, vg_to, lvh))
+		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 			return_0;
 	}
 
@@ -338,7 +344,7 @@ static int _move_thins(struct volume_group *vg_from,
 						  seg->pool_lv->name);
 					return 0;
 				}
-				if (!_move_one_lv(vg_from, vg_to, lvh))
+				if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 					return_0;
 			}
 		} else if (lv_is_thin_pool(lv)) {
@@ -358,7 +364,7 @@ static int _move_thins(struct volume_group *vg_from,
 						  lv->name);
 					return 0;
 				}
-				if (!_move_one_lv(vg_from, vg_to, lvh))
+				if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 					return_0;
 			}
 		}
@@ -439,7 +445,7 @@ static int _move_cache(struct volume_group *vg_from,
 				  lv->name, meta->name);
 			return 0;
 		}
-		if (!_move_one_lv(vg_from, vg_to, lvh))
+		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 			return_0;
 	}
 


