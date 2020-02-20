From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Feb 2020 18:20:08 -0500
Subject: master - writecache: working real dm uuid suffix for wcorig lv
Message-ID: <46734.120022018200300324@us-mta-473.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8153c5f1e61b305661ab92302ebe1077e2d6f483
Commit:        8153c5f1e61b305661ab92302ebe1077e2d6f483
Parent:        4829f27b76742ed663de0a11babb5b9a5985b741
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 19 13:30:02 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 20 17:13:43 2020 -0600

writecache: working real dm uuid suffix for wcorig lv

---
 lib/activate/dev_manager.c      |  4 ++++
 lib/metadata/lv.c               |  2 +-
 lib/metadata/writecache_manip.c | 16 ++++++++--------
 lib/misc/lvm-string.c           |  1 +
 lib/writecache/writecache.c     |  2 +-
 tools/lvconvert.c               |  2 ++
 6 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c8a22fb..3b99131 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3316,6 +3316,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!layer && lv_is_new_thin_pool(lv))
 		layer = lv_layer(lv);
 
+	/* Adds -real to the dm uuid of wcorig LV. */
+	if (!layer && lv_is_writecache_origin(lv))
+		layer = lv_layer(lv); /* "real" */
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ab26b8d..17d4907 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -830,7 +830,7 @@ const char *lv_layer(const struct logical_volume *lv)
 	if (lv_is_vdo_pool(lv))
 		return "vpool";
 
-	if (lv_is_origin(lv) || lv_is_external_origin(lv))
+	if (lv_is_origin(lv) || lv_is_external_origin(lv) || lv_is_writecache_origin(lv))
 		return "real";
 
 	return NULL;
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 0122025..31d069e 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -24,15 +24,15 @@
 
 int lv_is_writecache_origin(const struct logical_volume *lv)
 {
-	struct seg_list *sl;
+	struct lv_segment *seg;
 
-	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
-		if (!sl->seg || !sl->seg->lv || !sl->seg->origin)
-			continue;
-		if (lv_is_writecache(sl->seg->lv) && (sl->seg->origin == lv))
-			return 1;
-	}
-	return 0;
+	/* Make sure there's exactly one segment in segs_using_this_lv! */
+	if (dm_list_empty(&lv->segs_using_this_lv) ||
+	    (dm_list_size(&lv->segs_using_this_lv) > 1))
+		return 0;
+
+	seg = get_only_segment_using_this_lv(lv);
+	return seg && lv_is_writecache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
 int lv_is_writecache_cachevol(const struct logical_volume *lv)
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index d8b27cb..0ee3403 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -251,6 +251,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 */
 		/* Suffixes used here MUST match lib/activate/dev_manager.c */
 		layer = lv_is_cache_origin(lv) ? "real" :
+			lv_is_writecache_origin(lv) ? "real" :
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 08a306e..130922a 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -260,7 +260,7 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 	if ((pmem = lv_on_pmem(seg->writecache)) < 0)
 		return_0;
 
-	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), "real")))
 		return_0;
 
 	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, "cvol")))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 757b323..0ddeb35 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5537,6 +5537,8 @@ static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_WRITECACHE)))
 		return_NULL;
 
+	lv->status |= WRITECACHE;
+
 	/*
 	 * "lv_wcorig" is a new LV with new id, but with the segments from "lv".
 	 * "lv" keeps the existing name and id, but gets a new writecache segment,



