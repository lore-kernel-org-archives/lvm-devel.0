From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 15:12:20 -0400
Subject: master - writecache: use dm suffixes and lv attributes
Message-ID: <201909201912.x8KJCKHN001000@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f7d7089b4527cd1e198bac9da0341d8f65d4717
Commit:        6f7d7089b4527cd1e198bac9da0341d8f65d4717
Parent:        6f355c673631b0d7959191c8a56a577b3a0e97c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 20 14:04:18 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 14:08:51 2019 -0500

writecache: use dm suffixes and lv attributes

- use internal CACHE_VOL flag on cachevol LV
- add suffixes to dm uuids for internal LVs
- display appropriate letters in the LV attr field
- display writecache's cachevol in lvs output
---
 lib/metadata/lv.c                |   12 ++++++++++--
 lib/metadata/metadata-exported.h |   24 ++++++++++++++----------
 lib/metadata/metadata.c          |   14 ++++++++++++++
 lib/misc/lvm-string.c            |    2 ++
 lib/writecache/writecache.c      |    4 ++--
 tools/lvconvert.c                |    4 ++++
 6 files changed, 46 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b4ed712..4c2ab2b 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -716,6 +716,9 @@ struct logical_volume *lv_pool_lv(const struct logical_volume *lv)
 	if (lv_is_vdo(lv))
 		return seg_lv(first_seg(lv), 0);
 
+	if (lv_is_writecache(lv))
+		return first_seg(lv)->writecache;
+
 	return NULL;
 }
 
@@ -1235,7 +1238,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv))
 		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
-	else if (lv_is_cache_origin(lv))
+	else if (lv_is_cache_origin(lv) || lv_is_writecache_origin(lv))
 		repstr[0] = 'o';
 	else
 		repstr[0] = '-';
@@ -1314,7 +1317,12 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
-	else if (lv_is_cache_pool(lv) || lv_is_cache_vol(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
+	else if (lv_is_cache_pool(lv) ||
+		 lv_is_cache_vol(lv) ||
+		 lv_is_cache(lv) ||
+		 lv_is_cache_origin(lv) ||
+		 lv_is_writecache(lv) ||
+		 lv_is_writecache_origin(lv))
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1c10390..63d3fad 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -269,16 +269,19 @@
 #define lv_is_removed(lv)	(((lv)->status & LV_REMOVED) ? 1 : 0)
 
 /* Recognize component LV (matching lib/misc/lvm-string.c _lvname_has_reserved_component_string()) */
-#define lv_is_component(lv) (lv_is_cache_origin(lv) || ((lv)->status & (\
-	CACHE_POOL_DATA |\
-	CACHE_POOL_METADATA |\
-	LV_VDO_POOL_DATA |\
-	MIRROR_IMAGE |\
-	MIRROR_LOG |\
-	RAID_IMAGE |\
-	RAID_META |\
-	THIN_POOL_DATA |\
-	THIN_POOL_METADATA)) ? 1 : 0)
+#define lv_is_component(lv) (lv_is_cache_origin(lv) || \
+			     lv_is_writecache_origin(lv) || \
+			     ((lv)->status & (\
+					      CACHE_POOL_DATA |\
+					      CACHE_POOL_METADATA |\
+					      LV_CACHE_VOL |\
+					      LV_VDO_POOL_DATA |\
+					      MIRROR_IMAGE |\
+					      MIRROR_LOG |\
+					      RAID_IMAGE |\
+					      RAID_META |\
+					      THIN_POOL_DATA |\
+					      THIN_POOL_METADATA)) ? 1 : 0)
 
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role);
@@ -1077,6 +1080,7 @@ int lv_is_cow(const struct logical_volume *lv);
 #define lv_is_thick_snapshot lv_is_cow
 
 int lv_is_cache_origin(const struct logical_volume *lv);
+int lv_is_writecache_origin(const struct logical_volume *lv);
 
 int lv_is_merging_cow(const struct logical_volume *cow);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b434967..dc88d87 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5166,3 +5166,17 @@ struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_
 
 	return vg;
 }
+
+int lv_is_writecache_origin(const struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (!sl->seg || !sl->seg->lv || !sl->seg->origin)
+			continue;
+		if (lv_is_writecache(sl->seg->lv) && (sl->seg->origin == lv))
+			return 1;
+	}
+	return 0;
+}
+
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index b7c1c12..4034b40 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -158,6 +158,7 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_cmeta",
 		"_corig",
 		"_cvol",
+		"_wcorig",
 		"_mimage",
 		"_mlog",
 		"_rimage",
@@ -249,6 +250,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 */
 		/* Suffixes used here MUST match lib/activate/dev_manager.c */
 		layer = lv_is_cache_origin(lv) ? "real" :
+			lv_is_writecache_origin(lv) ? "real" :
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 53619c3..0a5b485 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -260,10 +260,10 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 	if ((pmem = lv_on_pmem(seg->writecache)) < 0)
 		return_0;
 
-	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), "real")))
 		return_0;
 
-	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, NULL)))
+	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, "cvol")))
 		return_0;
 
 	if (!dm_tree_node_add_writecache_target(node, len,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 77aad9d..5d1267a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5230,6 +5230,8 @@ static int _lv_writecache_detach(struct cmd_context *cmd, struct logical_volume
 	lv->status &= ~WRITECACHE;
 	seg->writecache = NULL;
 
+	lv_fast->status &= ~LV_CACHE_VOL;
+
 	if (!remove_layer_from_lv(lv, origin))
 		return_0;
 
@@ -5646,6 +5648,8 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	if (!archive(vg))
 		goto_bad;
 
+	lv_fast->status |= LV_CACHE_VOL;
+
 	/*
 	 * TODO: use libblkid to get the sector size of lv.  If it doesn't
 	 * match the block_size we are using for the writecache, then warn that


