From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:01 -0500
Subject: master - cache: rename variable in _cache_add_target_line
Message-ID: <201811062143.wA6Lh1g1004760@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ee1727f808e76f59637d78f2691aadc25d49b17
Commit:        5ee1727f808e76f59637d78f2691aadc25d49b17
Parent:        7541e002b21260c558059c3c3c9739d05f37d4b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:05:28 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: rename variable in _cache_add_target_line

so it is not specific to lv/seg type
---
 lib/cache_segtype/cache.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index a9be51d..17f94d1 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -543,6 +543,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	struct lv_segment *cache_pool_seg;
+	struct lv_segment *setting_seg;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
 	uint64_t feature_flags = 0;
 	unsigned attr;
@@ -552,15 +553,20 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
+	log_debug("cache_add_target_line lv %s pool %s", seg->lv->name, seg->pool_lv->name);
+
 	cache_pool_seg = first_seg(seg->pool_lv);
+
+	setting_seg = cache_pool_seg;
+
 	if (seg->cleaner_policy)
 		/* With cleaner policy always pass writethrough */
 		feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
 	else
-		switch (cache_pool_seg->cache_mode) {
+		switch (setting_seg->cache_mode) {
 		default:
 			log_error(INTERNAL_ERROR "LV %s has unknown cache mode %d.",
-				  display_lvname(seg->lv), cache_pool_seg->cache_mode);
+				  display_lvname(seg->lv), setting_seg->cache_mode);
 			/* Fall through */
 		case CACHE_MODE_WRITETHROUGH:
 			feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
@@ -573,7 +579,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 			break;
 		}
 
-	switch (cache_pool_seg->cache_metadata_format) {
+	switch (setting_seg->cache_metadata_format) {
 	case CACHE_METADATA_FORMAT_1: break;
 	case CACHE_METADATA_FORMAT_2:
 		if (!_target_present(cmd, NULL, &attr))
@@ -581,7 +587,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 
 		if (!(attr & CACHE_FEATURE_METADATA2)) {
 			log_error("LV %s has metadata format %u unsuported by kernel.",
-				  display_lvname(seg->lv), cache_pool_seg->cache_metadata_format);
+				  display_lvname(seg->lv), setting_seg->cache_metadata_format);
 			return 0;
 		}
 		feature_flags |= DM_CACHE_FEATURE_METADATA2;
@@ -589,7 +595,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		break;
 	default:
 		log_error(INTERNAL_ERROR "LV %s has unknown metadata format %u.",
-			  display_lvname(seg->lv), cache_pool_seg->cache_metadata_format);
+			  display_lvname(seg->lv), setting_seg->cache_metadata_format);
 		return 0;
 	}
 


