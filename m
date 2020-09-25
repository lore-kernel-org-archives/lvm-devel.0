From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:01 +0000 (GMT)
Subject: master - vgsplit: support for VDO volumes
Message-ID: <20200925210701.831303947C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc9e7328113fb3c1563909cce3abde329684c637
Commit:        fc9e7328113fb3c1563909cce3abde329684c637
Parent:        502b895bb4a132fa0a45d30a2db0f8f06591b272
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 20:49:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:51:50 2020 +0200

vgsplit: support for VDO volumes

Enable support and ensure VDO always moves with VDOPOOL.
---
 WHATS_NEW       |  1 +
 tools/vgsplit.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad3cbde6a..267914382 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Enable vgsplit for VDO volumes.
   Lvextend of vdo pool volumes ensure at least 1 new VDO slab is added.
   Use revert_lv() on reload error path after vg_revert().
   Configure --with-integrity enabled.
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1a422e683..778e63d47 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -125,6 +125,10 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 		    lv_is_thin_volume(lv))
 			continue;
 
+		if (lv_is_vdo_pool(lv) ||
+		    lv_is_vdo(lv))
+			continue;
+
 		if (lv_is_cache(lv) || lv_is_cache_pool(lv))
 			/* further checks by _move_cache() */
 			continue;
@@ -374,6 +378,42 @@ static int _move_thins(struct volume_group *vg_from,
 	return 1;
 }
 
+static int _move_vdos(struct volume_group *vg_from,
+		      struct volume_group *vg_to)
+{
+	struct dm_list *lvh, *lvht;
+	struct logical_volume *lv, *vdo_data_lv;
+	struct lv_segment *seg;
+
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
+
+		if (lv_is_vdo(lv)) {
+			seg = first_seg(lv);
+			vdo_data_lv = seg_lv(first_seg(seg_lv(seg, 0)), 0);
+
+			/* Ignore, if no allocations on PVs of @vg_to */
+			if (!lv_is_on_pvs(vdo_data_lv, &vg_to->pvs))
+				continue;
+
+			if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
+				return_0;
+		} else if (lv_is_vdo_pool(lv)) {
+			seg = first_seg(lv);
+			vdo_data_lv = seg_lv(seg, 0);
+
+			/* Ignore, if no allocations on PVs of @vg_to */
+			if (!lv_is_on_pvs(vdo_data_lv, &vg_to->pvs))
+				continue;
+
+			if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
 static int _move_cache(struct volume_group *vg_from,
 		       struct volume_group *vg_to)
 {
@@ -621,6 +661,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!(_move_thins(vg_from, vg_to)))
 		goto_bad;
 
+	/* Move required vdo pools across */
+	if (!(_move_vdos(vg_from, vg_to)))
+		goto_bad;
+
 	/* Move required cache LVs across */
 	if (!(_move_cache(vg_from, vg_to)))
 		goto_bad;


