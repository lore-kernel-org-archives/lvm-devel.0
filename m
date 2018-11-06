From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:42:55 -0500
Subject: master - cache: rename variable in _cache_display
Message-ID: <201811062142.wA6Lgt8g004749@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7541e002b21260c558059c3c3c9739d05f37d4b3
Commit:        7541e002b21260c558059c3c3c9739d05f37d4b3
Parent:        85b4b2f92490a7e12d3aaf67df1db7a0bcc6937e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 15:56:28 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: rename variable in _cache_display

so it is not specific to lv/seg type
---
 lib/cache_segtype/cache.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index cb86212..a9be51d 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -47,23 +47,30 @@ static int _cache_out_line(const char *line, void *_f)
 static void _cache_display(const struct lv_segment *seg)
 {
 	const struct dm_config_node *n;
-	const struct lv_segment *pool_seg =
-		seg_is_cache_pool(seg) ? seg : first_seg(seg->pool_lv);
+	const struct lv_segment *setting_seg = NULL;
+
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+	else
+		return;
 
 	log_print("  Chunk size\t\t%s",
-		  display_size(seg->lv->vg->cmd, pool_seg->chunk_size));
+		  display_size(seg->lv->vg->cmd, setting_seg->chunk_size));
 
-	if (pool_seg->cache_metadata_format != CACHE_METADATA_FORMAT_UNSELECTED)
-		log_print("  Metadata format\t%u", pool_seg->cache_metadata_format);
+	if (setting_seg->cache_metadata_format != CACHE_METADATA_FORMAT_UNSELECTED)
+		log_print("  Metadata format\t%u", setting_seg->cache_metadata_format);
 
-	if (pool_seg->cache_mode != CACHE_MODE_UNSELECTED)
-		log_print("  Mode\t\t%s", get_cache_mode_name(pool_seg));
+	if (setting_seg->cache_mode != CACHE_MODE_UNSELECTED)
+		log_print("  Mode\t\t%s", get_cache_mode_name(setting_seg));
 
-	if (pool_seg->policy_name)
-		log_print("  Policy\t\t%s", pool_seg->policy_name);
+	if (setting_seg->policy_name)
+		log_print("  Policy\t\t%s", setting_seg->policy_name);
 
-	if (pool_seg->policy_settings &&
-	    (n = pool_seg->policy_settings->child))
+	if (setting_seg->policy_settings &&
+	    (n = setting_seg->policy_settings->child))
 		dm_config_write_node(n, _cache_out_line, NULL);
 
 	log_print(" ");


