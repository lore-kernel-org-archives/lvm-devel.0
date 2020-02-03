From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Feb 2020 16:35:20 -0500
Subject: master - vgsplit: handle cachevol
Message-ID: <68330.120020316351401783@us-mta-36.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=379a7e1288a5e7a15cd2872c074b219992575b4d
Commit:        379a7e1288a5e7a15cd2872c074b219992575b4d
Parent:        adbb0a8d5bd0f735a756e32effcf0bddac0f6de7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 3 15:33:58 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 3 15:33:58 2020 -0600

vgsplit: handle cachevol

attached to a cache or writecache LV.
Ensure PVs in cachevol are moved with the main LV.
---
 test/shell/vgsplit-cache.sh | 26 ++++++++++++++++++++++++-
 tools/vgsplit.c             | 46 ++++++++++++++++++++++++++++++---------------
 2 files changed, 56 insertions(+), 16 deletions(-)

diff --git a/test/shell/vgsplit-cache.sh b/test/shell/vgsplit-cache.sh
index 3bbcc2d..200f0a9 100644
--- a/test/shell/vgsplit-cache.sh
+++ b/test/shell/vgsplit-cache.sh
@@ -68,4 +68,28 @@ vgs $vg $vg1
 test 4 -eq "$(get vg_field $vg pv_count)"
 test 3 -eq "$(get vg_field $vg1 pv_count)"
 
-vgremove -ff $vg $vg1
+lvremove -y $vg
+
+# dm-cache or dm-writecache with cachevol must not
+# separated main LV and cachevol
+
+vgremove -ff $vg
+vgremove -ff $vg1
+
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate -L6 -n $lv1 -an $vg "$dev2"
+lvcreate -L6 -n $lv2 -an $vg "$dev3"
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
+fail vgsplit $vg $vg1 "$dev2"
+fail vgsplit $vg $vg1 "$dev3"
+lvremove $vg/$lv1
+
+lvcreate -L6 -n $lv1 -an $vg "$dev2"
+lvcreate -L6 -n $lv2 -an $vg "$dev3"
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+fail vgsplit $vg $vg1 "$dev2"
+fail vgsplit $vg $vg1 "$dev3"
+lvremove $vg/$lv1
+
+vgremove -ff $vg
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1bcc308..3dc19ec 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -379,25 +379,25 @@ static int _move_cache(struct volume_group *vg_from,
 {
 	int is_moving;
 	struct dm_list *lvh, *lvht;
-	struct logical_volume *lv, *data, *meta, *orig;
+	struct logical_volume *lv, *data = NULL, *meta = NULL, *orig = NULL, *fast = NULL;
 	struct lv_segment *seg, *cache_seg;
 
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
 		seg = first_seg(lv);
 
-		if (!lv_is_cache(lv) && !lv_is_cache_pool(lv))
+		if (!lv_is_cache(lv) && !lv_is_writecache(lv) && !lv_is_cache_pool(lv) && !lv_is_cache_vol(lv))
 			continue;
 
-		if (lv_is_cache(lv) && lv_is_cache_vol(seg->pool_lv)) {
-			log_error("Cannot split while LV %s has cache attached.", display_lvname(lv));
-			return 0;
-		}
-
 		if (lv_is_cache(lv)) {
 			orig = seg_lv(seg, 0);
 			seg = first_seg(seg->pool_lv);
-		} else { /* lv_is_cache_pool */
+
+		} else if (lv_is_writecache(lv)) {
+			orig = seg_lv(seg, 0);
+			seg = first_seg(seg->writecache);
+
+		} else if (lv_is_cache_pool(lv) || lv_is_cache_vol(lv)) {
 			orig = NULL;
 			if (!dm_list_empty(&seg->lv->segs_using_this_lv)) {
 				if (!(cache_seg = get_only_segment_using_this_lv(seg->lv)))
@@ -406,16 +406,26 @@ static int _move_cache(struct volume_group *vg_from,
 			}
 		}
 
-		data = seg_lv(seg, 0);
-		meta = seg->metadata_lv;
+		if (lv_is_cache_vol(lv)) {
+			fast = lv;
+		} else {
+			data = seg_lv(seg, 0);
+			meta = seg->metadata_lv;
+		}
 
-		if ((orig && !lv_is_on_pvs(orig, &vg_to->pvs)) &&
-		    !lv_is_on_pvs(data, &vg_to->pvs) &&
-		    !lv_is_on_pvs(meta, &vg_to->pvs))
+		if (data && meta) {
+			if ((orig && !lv_is_on_pvs(orig, &vg_to->pvs)) &&
+			    !lv_is_on_pvs(data, &vg_to->pvs) &&
+			    !lv_is_on_pvs(meta, &vg_to->pvs))
+				continue;
+		}
+		
+		if (fast && orig &&
+		    !lv_is_on_pvs(orig, &vg_to->pvs) && !lv_is_on_pvs(fast, &vg_to->pvs))
 			continue;
 
 		/* Ensure all components are coming along */
-		if (orig) {
+		if (orig && data && meta) {
 			is_moving = _lv_is_in_vg(vg_to, orig);
 
 			if (_lv_is_in_vg(vg_to, data) != is_moving) {
@@ -431,11 +441,17 @@ static int _move_cache(struct volume_group *vg_from,
 					  display_lvname(orig), display_lvname(meta));
 				return 0;
 			}
-		} else if (_lv_is_in_vg(vg_to, data) != _lv_is_in_vg(vg_to, meta)) {
+
+		} else if (data && meta && (_lv_is_in_vg(vg_to, data) != _lv_is_in_vg(vg_to, meta))) {
 			log_error("Cannot split cache pool data %s and its metadata %s "
 				  "into separate VGs.",
 				  display_lvname(data), display_lvname(meta));
 			return 0;
+
+		} else if (orig && fast && (_lv_is_in_vg(vg_to, orig) != _lv_is_in_vg(vg_to, fast))) {
+			log_error("Cannot split cache origin %s and its cachevol %s into separate VGs.",
+				  display_lvname(orig), display_lvname(fast));
+			return 0;
 		}
 
 		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))



