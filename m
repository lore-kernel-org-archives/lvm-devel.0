From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:12 -0600
Subject: [LVM PATCH 6/6] cache: Code that allows removal of cache LVs
In-Reply-To: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
References: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1391212992-3439-7-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch makes the changes necessary to be able to remove cache LVs.

If the user wants to remove just the cache for an LV.  They specify
the LV's associated cache pool when removing:
# Removes the cache pool - leaving the origin un-cached
~> lvremove vg/cachepool

If the user wishes to remove the origin, but leave the cachepool to be
used for another LV, they specify the cache LV.
# Removes the origin - leaving the cache pool
~> lvremove vg/origin

In order to remove it all, specify both LVs.
---
 lib/metadata/lv_manip.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3013bf8..125bf64 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -542,6 +542,8 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s,
 						uint32_t area_reduction, int with_discard)
 {
+	struct lv_segment *cache_seg;
+
 	if (seg_type(seg, s) == AREA_UNASSIGNED)
 		return 1;
 
@@ -558,7 +560,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
+	if (seg_is_cache(seg) ||
+	    (seg_lv(seg, s)->status & MIRROR_IMAGE) ||
 	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
 	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
@@ -566,6 +569,15 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
+	if (seg_is_cache_pool(seg) &&
+	    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
+		if (!(cache_seg = get_only_segment_using_this_lv(seg->lv)))
+			return_0;
+
+		if (!lv_cache_remove(cache_seg->lv))
+			return_0;
+	}
+
 	if (seg_lv(seg, s)->status & RAID_IMAGE) {
 		/*
 		 * FIXME: Use lv_reduce not lv_remove
@@ -4598,6 +4610,21 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
+	/*
+	 * If we are removing a cache_pool, we must first unlink
+	 * it from any origins (i.e. remove the cache layer).
+	 *
+	 * If the cache_pool is not linked, we can simply proceed
+	 * to remove it.
+	 */
+	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+
+		if (!lv_cache_remove(cache_seg->lv))
+			return_0;
+	}
+
 	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
 		log_error("Can't remove logical volume %s used by a cache_pool.",
 			  lv->name);
@@ -5122,6 +5149,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
+	//FIXME: why do we empty the parent?  It removes everything below.
+	//This makes the function unusable for 'lv_cache_remove'
 	if (!lv_empty(parent))
 		return_0;
 
-- 
1.7.7.6


