From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:10 -0500
Subject: master - cache: use DM_CACHE_FEATURE_METADATA2 with libdm
Message-ID: <201703101837.v2AIbAwR022131@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=825c16e57e0e05bbffda9a32ea245c0e6acfb081
Commit:        825c16e57e0e05bbffda9a32ea245c0e6acfb081
Parent:        518b814cdb806f70f99aaa168fca45495b18a4cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 25 12:49:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: use DM_CACHE_FEATURE_METADATA2 with libdm

Call libdm  with new feature flag when metadata format 2 is selected
and available in kernel cache target.
---
 lib/cache_segtype/cache.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 985af68..3129783 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -445,6 +445,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 	struct lv_segment *cache_pool_seg;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
 	uint64_t feature_flags = 0;
+	unsigned attr;
 
 	if (!seg->pool_lv || !seg_is_cache(seg)) {
 		log_error(INTERNAL_ERROR "Passed segment is not cache.");
@@ -472,6 +473,26 @@ static int _cache_add_target_line(struct dev_manager *dm,
 			break;
 		}
 
+	switch (cache_pool_seg->cache_metadata_format) {
+	case CACHE_METADATA_FORMAT_1: break;
+	case CACHE_METADATA_FORMAT_2:
+		if (!_target_present(cmd, NULL, &attr))
+			return_0;
+
+		if (!(attr & CACHE_FEATURE_METADATA2)) {
+			log_error("LV %s has metadata format %u unsuported by kernel.",
+				  display_lvname(seg->lv), cache_pool_seg->cache_metadata_format);
+			return 0;
+		}
+		feature_flags |= DM_CACHE_FEATURE_METADATA2;
+		log_debug_activation("Using metadata2 format for %s.", display_lvname(seg->lv));
+		break;
+	default:
+		log_error(INTERNAL_ERROR "LV %s has unknown metadata format %u.",
+			  display_lvname(seg->lv), cache_pool_seg->cache_metadata_format);
+		return 0;
+	}
+
 	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
 


