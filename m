From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:25 -0400
Subject: master - cache: fix lvdisplay output
Message-ID: <201706221818.v5MIIPLo006618@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58e075f5fb12d8bce4ebb1c19c9f20b10d984e57
Commit:        58e075f5fb12d8bce4ebb1c19c9f20b10d984e57
Parent:        732928dda8eaf20ab2375e27ae641d58db08b8f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 20:05:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:17:18 2017 +0200

cache: fix lvdisplay output

Unused cache pool may have lots of fields actually undefined,
so avoid printing them, if they are not specified in metadata.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |   12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 12368dd..f1f354d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Do not lvdisplay --maps unset settings of cache pool.
   Fix lvdisplay --maps for cache pool without policy settings.
   Avoid using origin_only manipulation with cached device.
   Support aborting of flushing cache LV.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 7461b21..26f3e32 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -51,9 +51,15 @@ static void _cache_display(const struct lv_segment *seg)
 
 	log_print("  Chunk size\t\t%s",
 		  display_size(seg->lv->vg->cmd, pool_seg->chunk_size));
-	log_print("  Metadata format\t%u", pool_seg->cache_metadata_format);
-	log_print("  Mode\t\t%s", get_cache_mode_name(pool_seg));
-	log_print("  Policy\t\t%s", pool_seg->policy_name);
+
+	if (pool_seg->cache_metadata_format != CACHE_METADATA_FORMAT_UNSELECTED)
+		log_print("  Metadata format\t%u", pool_seg->cache_metadata_format);
+
+	if (pool_seg->cache_mode != CACHE_MODE_UNSELECTED)
+		log_print("  Mode\t\t%s", get_cache_mode_name(pool_seg));
+
+	if (pool_seg->policy_name)
+		log_print("  Policy\t\t%s", pool_seg->policy_name);
 
 	if (pool_seg->policy_settings &&
 	    (n = pool_seg->policy_settings->child))


