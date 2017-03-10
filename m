From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:25 -0500
Subject: master - cache: use UNSELECTED enum
Message-ID: <201703101835.v2AIZOaM018318@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41843319654c671ce4419443a73f3cf87bb15199
Commit:        41843319654c671ce4419443a73f3cf87bb15199
Parent:        b8cd0f4808fcb88ea803a7ffff5f27801fb14e02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 3 14:52:32 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: use UNSELECTED enum

Switch from _UNDEFINED to _UNSELECTED which is more describing
its value 0, while value -1 is better match for UNDEFINED.
---
 lib/cache_segtype/cache.c        |    4 ++--
 lib/metadata/cache_manip.c       |    8 ++++----
 lib/metadata/metadata-exported.h |    2 +-
 tools/lvchange.c                 |    2 +-
 tools/toollib.c                  |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 4fb06e7..ffa5d37 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -52,7 +52,7 @@ static void _fix_missing_defaults(struct lv_segment *cpool_seg)
 			    cpool_seg->policy_name);
 	}
 
-	if (cpool_seg->cache_mode == CACHE_MODE_UNDEFINED) {
+	if (cpool_seg->cache_mode == CACHE_MODE_UNSELECTED) {
 		cpool_seg->cache_mode = CACHE_MODE_WHEN_MISSING;
 		log_verbose("Cache pool %s is missing cache mode, using %s.",
 			    display_lvname(cpool_seg->lv),
@@ -169,7 +169,7 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	 * but not worth to break backward compatibility, by shifting
 	 * content to cache segment
 	 */
-	if (seg->cache_mode != CACHE_MODE_UNDEFINED) {
+	if (seg->cache_mode != CACHE_MODE_UNSELECTED) {
 		if (!(cache_mode = get_cache_mode_name(seg)))
 			return_0;
 		outf(f, "cache_mode = \"%s\"", cache_mode);
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5779f2d..1e93127 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -35,7 +35,7 @@ const char *display_cache_mode(const struct lv_segment *seg)
 		seg = first_seg(seg->pool_lv);
 
 	if (!seg_is_cache_pool(seg) ||
-	    (seg->cache_mode == CACHE_MODE_UNDEFINED))
+	    (seg->cache_mode == CACHE_MODE_UNSELECTED))
 		return "";
 
 	return get_cache_mode_name(seg);
@@ -83,7 +83,7 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 	else if (seg_is_cache_pool(seg)) {
-		if (mode == CACHE_MODE_UNDEFINED)
+		if (mode == CACHE_MODE_UNSELECTED)
 			return 1;	/* Defaults only for cache */
 	} else {
 		log_error(INTERNAL_ERROR "Cannot set cache mode for non cache volume %s.",
@@ -91,12 +91,12 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 		return 0;
 	}
 
-	if (mode != CACHE_MODE_UNDEFINED) {
+	if (mode != CACHE_MODE_UNSELECTED) {
 		seg->cache_mode = mode;
 		return 1;
 	}
 
-	if (seg->cache_mode != CACHE_MODE_UNDEFINED)
+	if (seg->cache_mode != CACHE_MODE_UNSELECTED)
 		return 1;               /* Default already set in cache pool */
 
 	/* Figure default settings from config/profiles */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 42ca820..7f9bbfe 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -288,7 +288,7 @@ typedef enum {
 } thin_discards_t;
 
 typedef enum {
-	CACHE_MODE_UNDEFINED = 0,
+	CACHE_MODE_UNSELECTED = 0,
 	CACHE_MODE_WRITETHROUGH,
 	CACHE_MODE_WRITEBACK,
 	CACHE_MODE_PASSTHROUGH,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8fae806..d0d67b3 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -634,7 +634,7 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!get_cache_params(cmd, &mode, &name, &settings))
 		goto_out;
 
-	if ((mode != CACHE_MODE_UNDEFINED) &&
+	if ((mode != CACHE_MODE_UNSELECTED) &&
 	    (mode != pool_seg->cache_mode) &&
 	    lv_is_cache(lv)) {
 		if (!lv_cache_wait_for_clean(lv, &is_clean))
diff --git a/tools/toollib.c b/tools/toollib.c
index c9461e5..4d746ea 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1358,7 +1358,7 @@ int get_cache_params(struct cmd_context *cmd,
 	int ok = 0;
 
 	if (cache_mode)
-		*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNDEFINED);
+		*cache_mode = (cache_mode_t) arg_uint_value(cmd, cachemode_ARG, CACHE_MODE_UNSELECTED);
 
 	if (name)
 		*name = arg_str_value(cmd, cachepolicy_ARG, NULL);


