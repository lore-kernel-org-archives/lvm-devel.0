From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:31 +0000 (UTC)
Subject: master - cache: wrong feature in seg is internal error
Message-ID: <20141113165331.9E7E7601FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6308a8b06d4dd52e9a8e95bb0ec1933eee547ee4
Commit:        6308a8b06d4dd52e9a8e95bb0ec1933eee547ee4
Parent:        48874703d2deee676d326ed4447c7944ab728767
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 17:41:45 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:44:31 2014 +0100

cache: wrong feature in seg is internal error

---
 lib/metadata/cache_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 27f381d..fb5346d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -40,7 +40,7 @@ const char *get_cache_pool_cachemode_name(const struct lv_segment *seg)
 	if (seg->feature_flags & DM_CACHE_FEATURE_PASSTHROUGH)
 		return "passthrough";
 
-	log_error("LV %s has uknown feature flags %" PRIu64,
+	log_error(INTERNAL_ERROR "LV %s has uknown feature flags %" PRIu64 ".",
 		  display_lvname(seg->lv), seg->feature_flags);
 
 	return NULL;


