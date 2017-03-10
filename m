From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:36 -0500
Subject: master - cache: enhance lvdisplay for cache volumes
Message-ID: <201703101837.v2AIbaVt004801@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52935b5834b6592acab1e68df18b9779de54033f
Commit:        52935b5834b6592acab1e68df18b9779de54033f
Parent:        4d2b1a06603d09e815af5bf8687972a000683841
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 2 00:15:11 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: enhance lvdisplay for cache volumes

Better support for lvdisplay.
By default info about running (in kernel) cache status is printed.
To get 'segtype' info, user runs: 'lvdisplay -m',  example:

  --- Logical volume ---
  LV Path                /dev/vg/lvol0
  LV Name                lvol0
  VG Name                vg
  LV UUID                Y4uWuN-TBGk-duer-aPWl-yBWn-iFFR-RU1gg1
  LV Write Access        read/write
  LV Creation host, time linux, 2017-03-01 20:52:39 +0100
  LV Cache pool name     lvol2
  LV Cache origin name   lvol0_corig
  LV Status              available
  # open                 0
  LV Size                12,00 MiB
  Cache used blocks      10,42%
  Cache metadata blocks  0,49%
  Cache dirty blocks     0,00%
  Cache read hits/misses 112 / 34
  Cache wrt hits/misses  133 / 0
  Cache demotions        0
  Cache promotions       20
  Current LE             3
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Segments ---
  Logical extents 0 to 2:
    Type		cache
    Chunk size		64,00 KiB
    Metadata format	1
    Mode		writethrough
    Policy		smq
      Setting		migration_threshold=100000
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |   27 +++++++++++++++++++++++++++
 lib/display/display.c     |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1cc3e13..ba17a10 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Lvdisplay [-m] shows more informations for cached volumes.
   Add option for lvcreate/lvconvert --cachemetadataformat auto|1|2.
   Support cache segment with configurable metadata format.
   Add allocation/cache_metadata_format profilable setttings.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 3129783..55b4c6e 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -36,6 +36,31 @@ static unsigned _feature_mask;
         log_error(t " segment %s of logical volume %s.", ## p,	\
                   dm_config_parent_name(sn), seg->lv->name), 0;
 
+static int _cache_out_line(const char *line, void *_f)
+{
+	log_print("    Setting\t\t%s", line);
+
+	return 1;
+}
+
+static void _cache_display(const struct lv_segment *seg)
+{
+	const struct dm_config_node *n;
+	const struct lv_segment *pool_seg =
+		seg_is_cache_pool(seg) ? seg : first_seg(seg->pool_lv);
+
+	log_print("  Chunk size\t\t%s",
+		  display_size(seg->lv->vg->cmd, pool_seg->chunk_size));
+	log_print("  Metadata format\t%u", pool_seg->cache_metadata_format);
+	log_print("  Mode\t\t%s", get_cache_mode_name(pool_seg));
+	log_print("  Policy\t\t%s", pool_seg->policy_name);
+
+	if ((n = pool_seg->policy_settings->child))
+		dm_config_write_node(n, _cache_out_line, NULL);
+
+	log_print(" ");
+}
+
 /*
  * When older metadata are loaded without newer settings,
  * set then to default settings (the one that could have been
@@ -356,6 +381,7 @@ static int _modules_needed(struct dm_pool *mem,
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_pool_ops = {
+	.display = _cache_display,
 	.text_import = _cache_pool_text_import,
 	.text_import_area_count = _cache_pool_text_import_area_count,
 	.text_export = _cache_pool_text_export,
@@ -519,6 +545,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_ops = {
+	.display = _cache_display,
 	.text_import = _cache_text_import,
 	.text_import_area_count = _cache_text_import_area_count,
 	.text_export = _cache_text_export,
diff --git a/lib/display/display.c b/lib/display/display.c
index f8dd338..a8bb5cc 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -386,6 +386,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	dm_percent_t thin_data_percent, thin_metadata_percent;
 	int thin_active = 0;
 	dm_percent_t thin_percent;
+	struct lv_status_cache *cache_status = NULL;
 
 	if (lv_is_historical(lv))
 		return _lvdisplay_historical_full(cmd, lv);
@@ -491,6 +492,19 @@ int lvdisplay_full(struct cmd_context *cmd,
 		seg = first_seg(lv);
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
+	} else if (lv_is_cache_origin(lv)) {
+		log_print("LV origin of Cache LV  %s",
+			  get_only_segment_using_this_lv(lv)->lv->name);
+	} else if (lv_is_cache(lv)) {
+		seg = first_seg(lv);
+		if (inkernel && !lv_cache_status(lv, &cache_status))
+                        return_0;
+		log_print("LV Cache pool name     %s", seg->pool_lv->name);
+		log_print("LV Cache origin name   %s", seg_lv(seg, 0)->name);
+	} else if (lv_is_cache_pool(lv)) {
+		seg = first_seg(lv);
+		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
+		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
 	}
 
 	if (inkernel && info.suspended)
@@ -510,6 +524,27 @@ int lvdisplay_full(struct cmd_context *cmd,
 		  display_size(cmd,
 			       snap_seg ? snap_seg->origin->size : lv->size));
 
+	if (cache_status) {
+		log_print("Cache used blocks      %.2f%%",
+			  dm_percent_to_float(cache_status->data_usage));
+		log_print("Cache metadata blocks  %.2f%%",
+			  dm_percent_to_float(cache_status->metadata_usage));
+		log_print("Cache dirty blocks     %.2f%%",
+			  dm_percent_to_float(cache_status->dirty_usage));
+		log_print("Cache read hits/misses " FMTu64 " / " FMTu64,
+			  cache_status->cache->read_hits,
+			  cache_status->cache->read_misses);
+		log_print("Cache wrt hits/misses  " FMTu64 " / " FMTu64,
+			  cache_status->cache->write_hits,
+			  cache_status->cache->write_misses);
+		log_print("Cache demotions        " FMTu64,
+			  cache_status->cache->demotions);
+		log_print("Cache promotions       " FMTu64,
+			  cache_status->cache->promotions);
+
+		dm_pool_destroy(cache_status->mem);
+	}
+
 	if (thin_data_active)
 		log_print("Allocated pool data    %.2f%%",
 			  dm_percent_to_float(thin_data_percent));


