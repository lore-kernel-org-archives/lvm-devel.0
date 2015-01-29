From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Jan 2015 11:07:27 +0000 (UTC)
Subject: master - cache: use writethrough cache_mode for older metadata
Message-ID: <20150129110727.B120161153@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8dc1da2cbed42e9c5a4dee5b342bb4aff8c9d9a3
Commit:        8dc1da2cbed42e9c5a4dee5b342bb4aff8c9d9a3
Parent:        bfeabea631782b3f0b8ec6494c4490663c412774
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 29 12:05:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 29 12:05:58 2015 +0100

cache: use writethrough cache_mode for older metadata

When cache_mode is undefined, the read of metadata will miss to
set a bit with mode and fails to process metadata on internal
error:

  Internal error: LV vg/lvol1 has uknown feature flags 0.

Fix it by setting it to writethrough mode.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 92b62a6..f2546a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Set default cache_mode to writehrough when missing in metadata.
   Preserve chunk size with repair and metadata swap of a thin pool.
   Fix raid --splitmirror 1 functionality (2.02.112).
   Fix tree preload to handle splitting raid images.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 73839f4..afc0ec6 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -68,7 +68,9 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("cache_mode must be a string in");
 		if (!set_cache_pool_feature(&seg->feature_flags, str))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
-	}
+	} else
+		/* When missed in metadata, it's an old stuff - use writethrough */
+		seg->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
 
 	if (dm_config_has_node(sn, "policy")) {
 		if (!(str = dm_config_find_str(sn, "policy", NULL)))


