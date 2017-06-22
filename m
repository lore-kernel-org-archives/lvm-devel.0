From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:22 -0400
Subject: master - cache: fix lvdisplay --maps
Message-ID: <201706221818.v5MIIMxV006608@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=732928dda8eaf20ab2375e27ae641d58db08b8f4
Commit:        732928dda8eaf20ab2375e27ae641d58db08b8f4
Parent:        58a9f88b8c021a5e056b883053f257f1a898adf7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 19:53:27 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:15:12 2017 +0200

cache: fix lvdisplay --maps

'lvdisplay -m' tried to go through NULL policy settings,
when such policy was not defined for CachedLV.

Patch is fixing display of cache-pool without defined settings,
as this is now a valid pool and we mostly want users to define
these settings when actually really caching a LV.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2f1ec8a..12368dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Fix lvdisplay --maps for cache pool without policy settings.
   Avoid using origin_only manipulation with cached device.
   Support aborting of flushing cache LV.
   Reenable conversion of data and metadata thin-pool volumes to raid.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index da23dae..7461b21 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -55,7 +55,8 @@ static void _cache_display(const struct lv_segment *seg)
 	log_print("  Mode\t\t%s", get_cache_mode_name(pool_seg));
 	log_print("  Policy\t\t%s", pool_seg->policy_name);
 
-	if ((n = pool_seg->policy_settings->child))
+	if (pool_seg->policy_settings &&
+	    (n = pool_seg->policy_settings->child))
 		dm_config_write_node(n, _cache_out_line, NULL);
 
 	log_print(" ");


