From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Jan 2015 10:50:28 +0000 (UTC)
Subject: master - cache: use built-in define for cache_mode
Message-ID: <20150129105028.926E661125@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84557040129b284c50f68124b4b3eeb5497baeb6
Commit:        84557040129b284c50f68124b4b3eeb5497baeb6
Parent:        bfeabea631782b3f0b8ec6494c4490663c412774
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 29 11:47:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 29 11:49:27 2015 +0100

cache: use built-in define for cache_mode

When cache_mode is undefined, the read of metadata will miss to
set a bit with mode and fails to process metadata on internal
error:

  Internal error: LV vg/lvol1 has uknown feature flags 0.

Fix it by using compile time DEFAULTS.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 92b62a6..2a58a8b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Set default cache_mode when unset/missing in metadata.
   Preserve chunk size with repair and metadata swap of a thin pool.
   Fix raid --splitmirror 1 functionality (2.02.112).
   Fix tree preload to handle splitting raid images.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 73839f4..0cab85a 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -68,7 +68,8 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("cache_mode must be a string in");
 		if (!set_cache_pool_feature(&seg->feature_flags, str))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
-	}
+	} else if (!set_cache_pool_feature(&seg->feature_flags, DEFAULT_CACHE_POOL_CACHEMODE))
+			return SEG_LOG_ERROR(INTERNAL_ERROR "Unknown built-in cache_mode");
 
 	if (dm_config_has_node(sn, "policy")) {
 		if (!(str = dm_config_find_str(sn, "policy", NULL)))
@@ -77,7 +78,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
 	} else
 		/* Cannot use 'just' default, so pick one */
-		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* FIXME make configurable */
+		seg->policy_name = DEFAULT_CACHE_POOL_CACHEMODE; /* FIXME make configurable */
 
 	/*
 	 * Read in policy args:


