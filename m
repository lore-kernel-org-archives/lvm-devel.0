From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Apr 2019 06:58:18 -0400
Subject: stable-2.02 - cache: support vgsplit
Message-ID: <201904161058.x3GAwIGI016906@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa025cdd9a7453c86e34bf550235a00537d059de
Commit:        fa025cdd9a7453c86e34bf550235a00537d059de
Parent:        f5d1f4f086f75148e25f7fda28bf2166e0c5a162
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 1 21:29:22 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 16 12:57:18 2019 +0200

cache: support vgsplit

Enable vgsplit to work with VG containing cached LVs.
---
 WHATS_NEW       |    1 +
 tools/vgsplit.c |   81 +++++++++++++++++++++++--------------------------------
 2 files changed, 35 insertions(+), 47 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b15ffa3..6457d4c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Add support for vgsplit with cached devices.
   Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 2d39111..e7ad4c0 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009,2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2019 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -384,68 +384,55 @@ static int _move_cache(struct volume_group *vg_from,
 
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
-		data = meta = orig = NULL;
 		seg = first_seg(lv);
 
 		if (!lv_is_cache(lv) && !lv_is_cache_pool(lv))
 			continue;
 
-		/*
-		 * FIXME: The code seems to move cache LVs fine, but it
-		 *        hasn't been well tested and it causes problems
-		 *        when just splitting PVs that don't contain
-		 *        cache LVs.
-		 * Waiting for next release before fixing and enabling.
-		 */
-		log_error("Unable to split VG while it contains cache LVs");
-		return 0;
-
-		/* NOTREACHED */
-
 		if (lv_is_cache(lv)) {
 			orig = seg_lv(seg, 0);
-			data = seg_lv(first_seg(seg->pool_lv), 0);
-			meta = first_seg(seg->pool_lv)->metadata_lv;
-			/* Ensure all components are coming along */
-			is_moving = _lv_is_in_vg(vg_to, orig);
-		} else {
-			if (!dm_list_empty(&seg->lv->segs_using_this_lv) &&
-			    !(cache_seg = get_only_segment_using_this_lv(seg->lv)))
-				return_0;
-			orig = seg_lv(cache_seg, 0);
-			data = seg_lv(seg, 0);
-			meta = seg->metadata_lv;
-
-			if (_lv_is_in_vg(vg_to, data) ||
-			    _lv_is_in_vg(vg_to, meta))
-				is_moving = 1;
+			seg = first_seg(seg->pool_lv);
+		} else { /* lv_is_cache_pool */
+			orig = NULL;
+			if (!dm_list_empty(&seg->lv->segs_using_this_lv)) {
+				if (!(cache_seg = get_only_segment_using_this_lv(seg->lv)))
+					return_0;
+				orig = seg_lv(cache_seg, 0);
+			}
 		}
 
-		if (!lv_is_on_pvs(data, &vg_to->pvs))
-			continue;
+		data = seg_lv(seg, 0);
+		meta = seg->metadata_lv;
 
-		if (!lv_is_on_pvs(meta, &vg_to->pvs))
+		if ((orig && !lv_is_on_pvs(orig, &vg_to->pvs)) &&
+		    !lv_is_on_pvs(data, &vg_to->pvs) &&
+		    !lv_is_on_pvs(meta, &vg_to->pvs))
 			continue;
 
-		if (orig && (_lv_is_in_vg(vg_to, orig) != is_moving)) {
-			log_error("Can't split %s and its origin (%s)"
-				  " into separate VGs", lv->name, orig->name);
-			return 0;
-		}
+		/* Ensure all components are coming along */
+		if (orig) {
+			is_moving = _lv_is_in_vg(vg_to, orig);
 
-		if (data && (_lv_is_in_vg(vg_to, data) != is_moving)) {
-			log_error("Can't split %s and its cache pool"
-				  " data LV (%s) into separate VGs",
-				  lv->name, data->name);
-			return 0;
-		}
+			if (_lv_is_in_vg(vg_to, data) != is_moving) {
+				log_error("Cannot split cache origin %s and its cache pool data %s "
+					  "into separate VGs.",
+					  display_lvname(orig), display_lvname(data));
+				return 0;
+			}
 
-		if (meta && (_lv_is_in_vg(vg_to, meta) != is_moving)) {
-			log_error("Can't split %s and its cache pool"
-				  " metadata LV (%s) into separate VGs",
-				  lv->name, meta->name);
+			if (_lv_is_in_vg(vg_to, meta) != is_moving) {
+				log_error("Cannot split cache origin %s and its cache pool metadata %s "
+					  "into separate VGs.",
+					  display_lvname(orig), display_lvname(meta));
+				return 0;
+			}
+		} else if (_lv_is_in_vg(vg_to, data) != _lv_is_in_vg(vg_to, meta)) {
+			log_error("Cannot split cache pool data %s and its metadata %s "
+				  "into separate VGs.",
+				  display_lvname(data), display_lvname(meta));
 			return 0;
 		}
+
 		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 			return_0;
 	}


