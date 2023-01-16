From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:15 +0000 (GMT)
Subject: main - vdo: fix and enhance vdo constain checking
Message-ID: <20230116113915.396D43858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2451bc568feb9b3d0cb4d7c15e3c723f4d0c8cc9
Commit:        2451bc568feb9b3d0cb4d7c15e3c723f4d0c8cc9
Parent:        1bed2cafe83096cf01cfff5cd2cd64ecb32b7d78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 15 21:27:37 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

vdo: fix and enhance vdo constain checking

Enhance checking vdo constains so it also handles changes of active VDO LVs
where only added difference is considered now.

For this also the reported informational message about used memory
was improved to only list consuming RAM blocks.
---
 WHATS_NEW                        |  1 +
 lib/metadata/metadata-exported.h |  4 +--
 lib/metadata/vdo_manip.c         | 77 ++++++++++++++++++++++++++++++----------
 lib/vdo/vdo.c                    | 24 +++++++++++--
 tools/lvcreate.c                 |  8 +++--
 5 files changed, 89 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 357203a4d..191338868 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.19 - 
 ====================================
+  Fix and improve runtime memory size detection for VDO volumes.
 
 version 2.03.18 - 22nd december 2022
 ====================================
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7c481905a..a27345781 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1382,8 +1382,8 @@ struct vdo_pool_size_config {
 	uint32_t block_map_cache_size_mb;
 	uint32_t index_memory_size_mb;
 };
-int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
-			 uint64_t virtual_size, struct dm_vdo_target_params *vtp);
+
+int check_vdo_constrains(struct cmd_context *cmd, const struct vdo_pool_size_config *cfg);
 /* --  metadata/vdo_manip.c */
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index b73d40d2c..19291c9d6 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -24,6 +24,7 @@
 #include "lib/misc/lvm-exec.h"
 
 #include <sys/sysinfo.h> // sysinfo
+#include <stdarg.h>
 
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state)
 {
@@ -647,39 +648,76 @@ static uint64_t _round_sectors_to_tib(uint64_t s)
 	return  (s + ((UINT64_C(1) << (40 - SECTOR_SHIFT)) - 1)) >> (40 - SECTOR_SHIFT);
 }
 
-int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
-			 uint64_t virtual_size, struct dm_vdo_target_params *vtp)
+__attribute__ ((format(printf, 3, 4)))
+static int _vdo_snprintf(char **buf, size_t *bufsize, const char *format, ...)
 {
+	int n;
+	va_list ap;
+
+	va_start(ap, format);
+	n = vsnprintf(*buf, *bufsize, format, ap);
+	va_end(ap);
+
+	if (n < 0 || ((unsigned) n >= *bufsize))
+		return -1;
+
+	*buf += n;
+	*bufsize -= n;
+
+	return n;
+}
+
+int check_vdo_constrains(struct cmd_context *cmd, const struct vdo_pool_size_config *cfg)
+{
+	static const char *_split[] = { "", " and", ",", "," };
 	uint64_t req_mb, total_mb, available_mb;
-	uint64_t phy_mb = _round_sectors_to_tib(UINT64_C(268) * physical_size); // 268 MiB per 1 TiB of physical size
-	uint64_t virt_mb = _round_1024(UINT64_C(1638) * _round_sectors_to_tib(virtual_size)); // 1.6 MiB per 1 TiB
-	uint64_t cache_mb = _round_1024(UINT64_C(1177) * vtp->block_map_cache_size_mb); // 1.15 MiB per 1 MiB cache size
+	uint64_t phy_mb = _round_sectors_to_tib(UINT64_C(268) * cfg->physical_size); // 268 MiB per 1 TiB of physical size
+	uint64_t virt_mb = _round_1024(UINT64_C(1638) * _round_sectors_to_tib(cfg->virtual_size)); // 1.6 MiB per 1 TiB
+	uint64_t cache_mb = _round_1024(UINT64_C(1177) * cfg->block_map_cache_size_mb); // 1.15 MiB per 1 MiB cache size
 	char msg[512];
+	size_t mlen = sizeof(msg);
+	char *pmsg = msg;
+	int cnt, has_cnt;
 
-	if (cache_mb < 150)
+	if (cfg->block_map_cache_size_mb && (cache_mb < 150))
 		cache_mb = 150; // always@least 150 MiB for block map
 
 	// total required memory for VDO target
-	req_mb = 38 + vtp->index_memory_size_mb + virt_mb + phy_mb + cache_mb;
+	req_mb = 38 + cfg->index_memory_size_mb + virt_mb + phy_mb + cache_mb;
 
 	_get_memory_info(&total_mb, &available_mb);
 
-	(void)snprintf(msg, sizeof(msg), "VDO configuration needs %s RAM for physical volume size %s, "
-		       "%s RAM for virtual volume size %s, %s RAM for block map cache size %s and "
-		       "%s RAM for index memory.",
-		       display_size(cmd, phy_mb << (20 - SECTOR_SHIFT)),
-		       display_size(cmd, physical_size),
-		       display_size(cmd, virt_mb << (20 - SECTOR_SHIFT)),
-		       display_size(cmd, virtual_size),
-		       display_size(cmd, cache_mb << (20 - SECTOR_SHIFT)),
-		       display_size(cmd, ((uint64_t)vtp->block_map_cache_size_mb) << (20 - SECTOR_SHIFT)),
-		       display_size(cmd, ((uint64_t)vtp->index_memory_size_mb) << (20 - SECTOR_SHIFT)));
+	has_cnt = cnt = (phy_mb ? 1 : 0) +
+			 (virt_mb ? 1 : 0) +
+			 (cfg->block_map_cache_size_mb ? 1 : 0) +
+			 (cfg->index_memory_size_mb ? 1 : 0);
+
+	if (phy_mb)
+		(void)_vdo_snprintf(&pmsg, &mlen, " %s RAM for physical volume size %s%s",
+				    display_size(cmd, phy_mb << (20 - SECTOR_SHIFT)),
+				    display_size(cmd, cfg->physical_size), _split[--cnt]);
+
+	if (virt_mb)
+		(void)_vdo_snprintf(&pmsg, &mlen, " %s RAM for virtual volume size %s%s",
+				    display_size(cmd, virt_mb << (20 - SECTOR_SHIFT)),
+				    display_size(cmd, cfg->virtual_size), _split[--cnt]);
+
+	if (cfg->block_map_cache_size_mb)
+		(void)_vdo_snprintf(&pmsg, &mlen, " %s RAM for block map cache size %s%s",
+				    display_size(cmd, cache_mb << (20 - SECTOR_SHIFT)),
+				    display_size(cmd, ((uint64_t)cfg->block_map_cache_size_mb) << (20 - SECTOR_SHIFT)),
+				    _split[--cnt]);
+
+	if (cfg->index_memory_size_mb)
+		(void)_vdo_snprintf(&pmsg, &mlen, " %s RAM for index memory",
+				    display_size(cmd, ((uint64_t)cfg->index_memory_size_mb) << (20 - SECTOR_SHIFT)));
 
 	if (req_mb > available_mb) {
 		log_error("Not enough free memory for VDO target. %s RAM is required, but only %s RAM is available.",
 			  display_size(cmd, req_mb << (20 - SECTOR_SHIFT)),
 			  display_size(cmd, available_mb << (20 - SECTOR_SHIFT)));
-		log_print_unless_silent("%s", msg);
+		if (has_cnt)
+			log_print_unless_silent("VDO configuration needs%s.", msg);
 		return 0;
 	}
 
@@ -687,7 +725,8 @@ int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
 		  display_size(cmd, req_mb << (20 - SECTOR_SHIFT)),
 		  display_size(cmd, available_mb << (20 - SECTOR_SHIFT)));
 
-	log_verbose("%s", msg);
+	if (has_cnt)
+		log_verbose("VDO configuration needs%s.", msg);
 
 	return 1;
 }
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index d2d14d146..133678ae7 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -355,6 +355,27 @@ static int _vdo_pool_target_status_compatible(const char *type)
 	return (strcmp(type, TARGET_NAME_VDO) == 0);
 }
 
+static int _vdo_check(struct cmd_context *cmd, const struct lv_segment *seg)
+{
+
+	struct vdo_pool_size_config cfg = { 0 };
+
+	if (!lv_vdo_pool_size_config(seg->lv, &cfg))
+		return_0;
+
+	/* Check if we are just adding more size to the already running vdo pool */
+	if (seg->lv->size >= cfg.physical_size)
+		cfg.physical_size = seg->lv->size - cfg.physical_size;
+	if (get_vdo_pool_virtual_size(seg) >= cfg.virtual_size)
+		cfg.virtual_size = get_vdo_pool_virtual_size(seg) - cfg.virtual_size;
+	if (seg->vdo_params.block_map_cache_size_mb >= cfg.block_map_cache_size_mb)
+		cfg.block_map_cache_size_mb = seg->vdo_params.block_map_cache_size_mb - cfg.block_map_cache_size_mb;
+	if (seg->vdo_params.index_memory_size_mb >= cfg.index_memory_size_mb)
+		cfg.index_memory_size_mb = seg->vdo_params.index_memory_size_mb - cfg.index_memory_size_mb;
+
+	return check_vdo_constrains(cmd, &cfg);
+}
+
 static int _vdo_pool_add_target_line(struct dev_manager *dm,
 				     struct dm_pool *mem,
 				     struct cmd_context *cmd,
@@ -375,8 +396,7 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!critical_section() &&
-	    !check_vdo_constrains(cmd, seg->lv->size, get_vdo_pool_virtual_size(seg), &seg->vdo_params))
+	if (!critical_section() && !_vdo_check(cmd, seg))
 		return_0;
 
 	if (!(vdo_pool_name = dm_build_dm_name(mem, seg->lv->vg->name, seg->lv->name, lv_layer(seg->lv))))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3c89fd2c1..06d24430f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1762,8 +1762,12 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (!_update_extents_params(vg, lp, lcp))
 		goto_out;
 
-	if (seg_is_vdo(lp) && !check_vdo_constrains(cmd, (uint64_t)lp->extents * vg->extent_size,
-						    lcp->virtual_size, &lp->vdo_params))
+	if (seg_is_vdo(lp) &&
+	    !check_vdo_constrains(cmd, &(struct vdo_pool_size_config) {
+				  .physical_size = (uint64_t)lp->extents * vg->extent_size,
+				  .virtual_size = lcp->virtual_size,
+				  .block_map_cache_size_mb = lp->vdo_params.block_map_cache_size_mb,
+				  .index_memory_size_mb = lp->vdo_params.index_memory_size_mb }))
 		goto_out;
 
 	if (seg_is_thin(lp) && !_validate_internal_thin_processing(lp))

