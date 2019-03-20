From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:02 -0400
Subject: master - vdo: enable caching for vdopool LV and vdo LV
Message-ID: <201903201340.x2KDe2oA012543@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=677aa84be3b41e94514aa5c1560e987e7763b294
Commit:        677aa84be3b41e94514aa5c1560e987e7763b294
Parent:        0db22c5f81986d9573e0a704397a6de779fb832e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:12:26 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:38:31 2019 +0100

vdo: enable caching for vdopool LV and vdo LV

Allow using caching with VDO.
User can either cache a single vdopool or
a vdo LV - difference when the caching is put-in depends on a use-case
and it's upto user to decide which kind of speed is expected.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    9 ++++++---
 lib/metadata/lv_manip.c    |    4 ++--
 tools/command-lines.in     |    8 ++++----
 tools/lvchange.c           |    3 +++
 tools/lvconvert.c          |    6 ++++++
 6 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5ffef3b..18733b1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Add support for caching VDO LVs and VDOPOOL LVs.
   Add support for vgsplit with cached devices.
   Query mpath device only once per command for its state.
   Use device INFO instead of STATUS when checking for mpath device uuid.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 20deda3..7ea2c0e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -369,7 +369,9 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	}
 
 	/* For now we only support conversion of thin pool data volume */
-	if (!lv_is_visible(origin_lv) && !lv_is_thin_pool_data(origin_lv)) {
+	if (!lv_is_visible(origin_lv) &&
+	    !lv_is_thin_pool_data(origin_lv) &&
+	    !lv_is_vdo_pool_data(origin_lv)) {
 		log_error("Can't convert internal LV %s.", display_lvname(origin_lv));
 		return 0;
 	}
@@ -383,7 +385,8 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	    lv_is_thin_volume(origin_lv) || lv_is_thin_pool_metadata(origin_lv) ||
 	    lv_is_merging_origin(origin_lv) ||
 	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
-	    lv_is_virtual(origin_lv)) {
+	    /* TODO: think about enabling caching of a single thin volume */
+	    (lv_is_virtual(origin_lv) && !lv_is_vdo(origin_lv))) {
 		log_error("Cache is not supported with %s segment type of the original logical volume %s.",
 			  lvseg_name(first_seg(origin_lv)), display_lvname(origin_lv));
 		return 0;
@@ -438,7 +441,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	    !validate_lv_cache_create_origin(cache_lv))
 		return_NULL;
 
-	if (lv_is_thin_pool(cache_lv))
+	if (lv_is_thin_pool(cache_lv) || lv_is_vdo_pool(cache_lv))
 		cache_lv = seg_lv(first_seg(cache_lv), 0); /* cache _tdata */
 
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE)))
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a2f7d74..e128336 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6828,7 +6828,7 @@ int move_lv_segments(struct logical_volume *lv_to,
 		     struct logical_volume *lv_from,
 		     uint64_t set_status, uint64_t reset_status)
 {
-	const uint64_t MOVE_BITS = (RAID | MIRROR | THIN_VOLUME);
+	const uint64_t MOVE_BITS = (RAID | MIRROR | THIN_VOLUME | CACHE | LV_VDO);
 	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv_to->segments)
@@ -6869,7 +6869,7 @@ int move_lv_segments(struct logical_volume *lv_to,
 int remove_layer_from_lv(struct logical_volume *lv,
 			 struct logical_volume *layer_lv)
 {
-	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_vdata" };
 	struct logical_volume *parent_lv;
 	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
diff --git a/tools/command-lines.in b/tools/command-lines.in
index bf9d7df..0de3de7 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -451,7 +451,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
 
-lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool
+lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool_vdo_vdopool_vdopooldata
 OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV, converts the LV to type cache.
@@ -459,7 +459,7 @@ RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
-lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
+lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool_vdo_vdopool_vdopooldata
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV (infers --type cache).
@@ -589,14 +589,14 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvconvert --splitcache LV_cachepool_cache_thinpool_writecache
+lvconvert --splitcache LV_cachepool_cache_thinpool_vdopool_writecache
 OO: OO_LVCONVERT
 ID: lvconvert_split_and_keep_cache
 DESC: Detach a cache from an LV.
 
 ---
 
-lvconvert --uncache LV_cache_thinpool_writecache
+lvconvert --uncache LV_cache_thinpool_vdopool_writecache
 OO: OO_LVCONVERT
 ID: lvconvert_split_and_remove_cache
 DESC: Detach and delete a cache from an LV.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index a40bfcf..ad5abdd 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1281,6 +1281,9 @@ static int _lvchange_properties_check(struct cmd_context *cmd,
 		if (lv_is_thin_pool_data(lv))
 			return 1;
 
+		if (lv_is_vdo_pool_data(lv))
+			return 1;
+
 		if (lv_is_named_arg)
 			log_error("Operation not permitted on hidden LV %s.", display_lvname(lv));
 		return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cd640ab..24db8d2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4261,6 +4261,9 @@ static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 	if (lv_is_thin_pool(lv)) {
 		lv = seg_lv(first_seg(lv), 0);
 		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
+	} else if (lv_is_vdo_pool(lv)) {
+		lv = seg_lv(first_seg(lv), 0);
+		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
 	}
 
 	if (_raid_split_image_conversion(lv))
@@ -4570,6 +4573,9 @@ static int _lvconvert_split_cache_vol(struct cmd_context *cmd,
 	} else if (lv_is_thin_pool(lv)) {
 		lv_main = seg_lv(first_seg(lv), 0); /* cached _tdata */
 		lv_fast = first_seg(lv_main)->pool_lv;
+	} else if (lv_is_vdo_pool(lv)) {
+		lv_main = seg_lv(first_seg(lv), 0); /* cached _vdata */
+		lv_fast = first_seg(lv_main)->pool_lv;
 	}
 
 	if (!lv_main) {


