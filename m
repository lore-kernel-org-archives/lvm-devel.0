From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:42 +0000 (UTC)
Subject: master - coverity: return non-null string with internal error
Message-ID: <20160421231842.D9EC3616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=412f09ca332c644e08421e289a3e8d54890971ba
Commit:        412f09ca332c644e08421e289a3e8d54890971ba
Parent:        447daa9179d94f86a972598e42eaab8b6913f3f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:53:22 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:12:34 2016 +0200

coverity: return non-null string with internal error

While we return internal error we should not let tool crash on NULL
access, so return valid string for such case.
---
 lib/metadata/cache_manip.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 3962247..1c51f66 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -41,19 +41,19 @@ int cache_mode_is_set(const struct lv_segment *seg)
 
 const char *get_cache_mode_name(const struct lv_segment *seg)
 {
-	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
-		return "writeback";
-
-	if (seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
-		return "writethrough";
-
 	if (seg->feature_flags & DM_CACHE_FEATURE_PASSTHROUGH)
 		return "passthrough";
 
-	log_error(INTERNAL_ERROR "LV %s has uknown feature flags %" PRIu64 ".",
-		  display_lvname(seg->lv), seg->feature_flags);
+	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+		return "writeback";
+
+	if (!seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH) {
+		log_error(INTERNAL_ERROR "LV %s has uknown feature flags %" PRIu64 ", "
+			  "returning writethrough instead.",
+			  display_lvname(seg->lv), seg->feature_flags);
+	}
 
-	return NULL;
+	return "writethrough";
 }
 
 int cache_set_mode(struct lv_segment *seg, const char *str)


