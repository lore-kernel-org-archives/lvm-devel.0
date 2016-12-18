From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:19 +0000 (UTC)
Subject: master - lvconvert: support cache to external origin conversion
Message-ID: <20161218185219.208CD60E2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bb6266046b11e6e4b47596689e3f4a75ba692a3
Commit:        5bb6266046b11e6e4b47596689e3f4a75ba692a3
Parent:        69434c2eca5bb7667d73916a28d03b8c687aea32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 22:41:27 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:35:27 2016 +0100

lvconvert: support cache to external origin conversion

Add this functionality to lvconvert:

'lvconvert --thin cachedLV --thinpool vg/poll'

Converts cachedLV to external origin (which will be read-only).
New thin volume is created in thinpool LV and it's using external
origin as source for unprovisioned chunks.
This conversion happens  online (while volume is in use).
Thin LV remains fully writable.
Cached external origin no longer could be written so cache will be used
ONLY for read operations. For this limitation we require cache mode
to be writethrough (as writeback cannot write to read-only volumes).

When  thinLV is later removed  cached external origin is again
fully usable, just note, LV remain in 'read-only' mode.
When read-write is needed,  'lvchange -prw' has to be used.

Single external origin could be user by multiple thinLV in
multiple differen thin pool.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    1 -
 tools/lvconvert.c          |   39 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 74638fd..e7abf59 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Enable usage of cached volume as thin volume's external origin.
   Support cache volume activation with -real layer.
   Improve search of lock-holder for external origin and thin-pool.
   Support status checking of cache volume used in layer.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index ed72fae..12b1054 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -324,7 +324,6 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	    lv_is_thin_volume(origin_lv) || lv_is_thin_pool_metadata(origin_lv) ||
 	    lv_is_origin(origin_lv) || lv_is_merging_origin(origin_lv) ||
 	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
-	    lv_is_external_origin(origin_lv) ||
 	    lv_is_virtual(origin_lv)) {
 		log_error("Cache is not supported with %s segment type of the original logical volume %s.",
 			  first_seg(origin_lv)->segtype->name, display_lvname(origin_lv));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index dc32e37..393d286 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2825,7 +2825,6 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 
 	if (lv_is_locked(lv) ||
 	    !lv_is_visible(lv) ||
-	    lv_is_cache_type(lv) ||
 	    lv_is_cow(lv) ||
 	    lv_is_pool(lv) ||
 	    lv_is_pool_data(lv) ||
@@ -3725,6 +3724,12 @@ static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct lo
  * Convert a cache LV to a thin pool (using the cache LV for thin pool data).
  * lvconvert --type thin-pool LV
  *
+ * Convert a cache LV to a thin volume with cached external origin using given
+ * thinpool tpLV (when not yet Thinpool convert it to thin-pool first).
+ * Conversion is 2-step process in this case.
+ * Only writethrough cacheLV can be converted as external origin is read-only.
+ * lvconvert --thin cacheLV --thinpool tpLV
+ *
  * Alternate syntax:
  * This is equivalent to above, but not preferred because it's ambiguous and inconsistent.
  * lvconvert --thinpool LV
@@ -3732,7 +3737,37 @@ static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct lo
 static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 					   struct lvconvert_params *lp)
 {
-	return _lvconvert_pool(cmd, lv, lp);
+	int is_clean;
+	const struct lv_segment *pool_seg;
+
+	if (!_lvconvert_pool(cmd, lv, lp))
+		return_0;
+
+	if (lv_is_cache(lv) && !lv_is_pool_data(lv)) {
+		pool_seg = first_seg(first_seg(lv)->pool_lv);
+		if (pool_seg->cache_mode != CACHE_MODE_WRITETHROUGH) {
+			log_error("Cannot convert cache volume %s with %s cache mode to external origin.",
+				  display_lvname(lv),
+				  get_cache_mode_name(pool_seg));
+			log_error("To proceed, run 'lvchange --cachemode writethrough %s'.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		if (!lv_cache_wait_for_clean(lv, &is_clean))
+			return_0;
+
+		if (!is_clean) {
+			log_error("Cache %s is not clean, refusing to convert to external origin.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		if (!_lvconvert_thin(cmd, lv, lp))
+			return_0;
+	}
+
+	return 1;
 }
 
 /*


