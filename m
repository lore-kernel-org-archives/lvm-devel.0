From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:42:36 -0500
Subject: master - cache: add cache_mode_num_to_str
Message-ID: <201811062142.wA6LgadS004705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d7075528f0c6e3a0ddeb737c25540683a1946a2
Commit:        8d7075528f0c6e3a0ddeb737c25540683a1946a2
Parent:        a427a935493aa2d92c85f1765aaf714e073d88bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 14:53:52 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: add cache_mode_num_to_str

Requires only string and number, no specific lv/seg type.
---
 lib/metadata/cache_manip.c       |   50 ++++++++++++++++++++++++++-----------
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5ba353c..0cf94ae 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -30,33 +30,53 @@
 #define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
 #define DM_MAX_HINT_WIDTH		(4+16)  /* bytes.  FIXME Configurable? */
 
+const char *cache_mode_num_to_str(cache_mode_t mode)
+{
+	switch (mode) {
+	case CACHE_MODE_WRITETHROUGH:
+		return "writethrough";
+	case CACHE_MODE_WRITEBACK:
+		return "writeback";
+	case CACHE_MODE_PASSTHROUGH:
+		return "passthrough";
+	default:
+		return NULL;
+	}
+}
+
 const char *display_cache_mode(const struct lv_segment *seg)
 {
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
+	const struct lv_segment *setting_seg = NULL;
+	const char *str;
 
-	if (!seg_is_cache_pool(seg) ||
-	    (seg->cache_mode == CACHE_MODE_UNSELECTED))
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+
+	if (!setting_seg || (setting_seg->cache_mode == CACHE_MODE_UNSELECTED))
 		return "";
 
-	return get_cache_mode_name(seg);
-}
+	if (!(str = cache_mode_num_to_str(setting_seg->cache_mode))) {
+		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
+			  display_lvname(seg->lv));
+		str = "writethrough";
+	}
 
+	return str;
+}
 
 const char *get_cache_mode_name(const struct lv_segment *pool_seg)
 {
-	switch (pool_seg->cache_mode) {
-	default:
+	const char *str;
+		
+	if (!(str = cache_mode_num_to_str(pool_seg->cache_mode))) {
 		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
 			  display_lvname(pool_seg->lv));
-		/* Fall through */
-	case CACHE_MODE_WRITETHROUGH:
-		return "writethrough";
-	case CACHE_MODE_WRITEBACK:
-		return "writeback";
-	case CACHE_MODE_PASSTHROUGH:
-		return "passthrough";
+		str = "writethrough";
 	}
+	return str;
 }
 
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 840f623..76c164b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1216,6 +1216,7 @@ struct lv_status_cache {
 	dm_percent_t dirty_usage;
 };
 
+const char *cache_mode_num_to_str(cache_mode_t mode);
 const char *display_cache_mode(const struct lv_segment *seg);
 const char *get_cache_mode_name(const struct lv_segment *pool_seg);
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode);


