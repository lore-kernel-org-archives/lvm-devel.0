From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:19 +0000 (GMT)
Subject: main - vdo: check vdo memory constrains
Message-ID: <20220710232219.84E9C385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebad057579aeff0980a1b8af7eaacd56e62ed0c9
Commit:        ebad057579aeff0980a1b8af7eaacd56e62ed0c9
Parent:        9f3eff002cc229d3c22dfd7db6da69dadc0bd460
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 8 23:33:29 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: check vdo memory constrains

Add function to check for avaialble memory for particular VDO
configuration - to avoid unnecessary machine swapping for configs
that will not fit into memory (possibly in locked section).

Formula tries to estimate RAM size machine can use also with
swapping for kernel target - but still leaving some amount of
usable RAM.

Estimation is based on documented RAM usage of VDO target.

If the /proc/meminfo would be theoretically unavailable, try to use
'sysinfo()' function, however this is giving only free RAM without
the knowledge about how much RAM could be eventually swapped.

TODO: move _get_memory_info() into generic lvm2 API function used
by other targets with non-trivial memory requirements.
---
 lib/metadata/metadata-exported.h |   2 +
 lib/metadata/vdo_manip.c         | 144 +++++++++++++++++++++++++++++++++++++++
 lib/vdo/vdo.c                    |   8 ++-
 tools/lvcreate.c                 |   4 ++
 4 files changed, 156 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fd370d4b2..191bf4326 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1377,6 +1377,8 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
 			   uint64_t *vdo_pool_header_size,
 			   struct profile *profile);
+int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
+			 uint64_t virtual_size, struct dm_vdo_target_params *vtp);
 /* --  metadata/vdo_manip.c */
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index fa9c893cb..b83bff391 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -23,6 +23,8 @@
 #include "lib/config/defaults.h"
 #include "lib/misc/lvm-exec.h"
 
+#include <sys/sysinfo.h> // sysinfo
+
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state)
 {
 	switch (state) {
@@ -514,3 +516,145 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 
 	return 1;
 }
+
+static int _get_sysinfo_memory(uint64_t *total_mb, uint64_t *available_mb)
+{
+	struct sysinfo si = { 0 };
+
+	*total_mb = *available_mb = UINT64_MAX;
+
+	if (sysinfo(&si) != 0)
+		return 0;
+
+	log_debug("Sysinfo free:%lu  bufferram:%lu  sharedram:%lu  freehigh:%lu  unit:%u.",
+		  si.freeram >> 20, si.bufferram >> 20, si.sharedram >> 20,
+		  si.freehigh >> 20, si.mem_unit);
+
+	*available_mb = ((uint64_t)(si.freeram + si.bufferram) * si.mem_unit) >> 30;
+	*total_mb = si.totalram >> 30;
+
+	return 1;
+}
+
+typedef struct mem_table_s {
+	const char *name;
+	uint64_t *value;
+} mem_table_t;
+
+static int _compare_mem_table_s(const void *a, const void *b){
+	return strcmp(((const mem_table_t*)a)->name, ((const mem_table_t*)b)->name);
+}
+
+static int _get_memory_info(uint64_t *total_mb, uint64_t *available_mb)
+{
+	uint64_t anon_pages, mem_available, mem_free, mem_total, shmem, swap_free;
+	uint64_t can_swap;
+	mem_table_t mt[] = {
+		{ "AnonPages",    &anon_pages },
+		{ "MemAvailable", &mem_available },
+		{ "MemFree",	  &mem_free },
+		{ "MemTotal",	  &mem_total },
+		{ "Shmem",	  &shmem },
+		{ "SwapFree",	  &swap_free },
+	};
+
+	char line[128], namebuf[32], *e, *tail;
+	FILE *fp;
+	mem_table_t findme = { namebuf, NULL };
+	mem_table_t *found;
+
+	if (!(fp = fopen("/proc/meminfo", "r")))
+		return _get_sysinfo_memory(total_mb, available_mb);
+
+	while (fgets(line, sizeof(line), fp)) {
+		if (!(e = strchr(line, ':')))
+			break;
+
+		if ((++e - line) > sizeof(namebuf))
+			continue; // something too long
+
+		(void)dm_strncpy((char*)findme.name, line, e - line);
+
+		found = bsearch(&findme, mt, DM_ARRAY_SIZE(mt), sizeof(mem_table_t),
+				_compare_mem_table_s);
+		if (!found)
+			continue; // not interesting
+
+		*(found->value) = (uint64_t) strtoull(e, &tail, 10);
+
+		if ((e == tail) || errno)
+			log_debug("Failing to parse value from %s.", line);
+		else
+			log_debug("Parsed %s = " FMTu64 " KiB.", found->name, *(found->value));
+	}
+	(void)fclose(fp);
+
+	// use at most 2/3 of swap space to keep machine usable
+	can_swap = (anon_pages + shmem) * 2 / 3;
+	swap_free = swap_free * 2 / 3;
+
+	if (can_swap > swap_free)
+		can_swap = swap_free;
+
+	// TODO: add more constrains, i.e. 3/4 of physical RAM...
+
+	*total_mb = mem_total >> 10;
+	*available_mb = (mem_available + can_swap) >> 10;
+
+	return 1;
+}
+
+static uint64_t _round_1024(uint64_t s)
+{
+	return (s + ((1 << 10) - 1)) >> 10;
+}
+
+static uint64_t _round_sectors_to_tib(uint64_t s)
+{
+	return  (s + ((UINT64_C(1) << (40 - SECTOR_SHIFT)) - 1)) >> (40 - SECTOR_SHIFT);
+}
+
+int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
+			 uint64_t virtual_size, struct dm_vdo_target_params *vtp)
+{
+	uint64_t req_mb, total_mb, available_mb;
+	uint64_t phy_mb = _round_sectors_to_tib(UINT64_C(268) * physical_size); // 268 MiB per 1 TiB of physical size
+	uint64_t virt_mb = _round_1024(UINT64_C(1638) * _round_sectors_to_tib(virtual_size)); // 1.6 MiB per 1 TiB
+	uint64_t cache_mb = _round_1024(UINT64_C(1177) * vtp->block_map_cache_size_mb); // 1.15 MiB per 1 MiB cache size
+	char msg[512];
+
+	if (cache_mb < 150)
+		cache_mb = 150; // always@least 150 MiB for block map
+
+	// total required memory for VDO target
+	req_mb = 38 + vtp->index_memory_size_mb + virt_mb + phy_mb + cache_mb;
+
+	_get_memory_info(&total_mb, &available_mb);
+
+	(void)snprintf(msg, sizeof(msg), "VDO configuration needs %s RAM for physical volume size %s, "
+		       "%s RAM for virtual volume size %s, %s RAM for block map cache size %s and "
+		       "%s RAM for index memory.",
+		       display_size(cmd, phy_mb << (20 - SECTOR_SHIFT)),
+		       display_size(cmd, physical_size),
+		       display_size(cmd, virt_mb << (20 - SECTOR_SHIFT)),
+		       display_size(cmd, virtual_size),
+		       display_size(cmd, cache_mb << (20 - SECTOR_SHIFT)),
+		       display_size(cmd, ((uint64_t)vtp->block_map_cache_size_mb) << (20 - SECTOR_SHIFT)),
+		       display_size(cmd, ((uint64_t)vtp->index_memory_size_mb) << (20 - SECTOR_SHIFT)));
+
+	if (req_mb > available_mb) {
+		log_error("Not enough free memory for VDO target. %s RAM is required, but only %s RAM is available.",
+			  display_size(cmd, req_mb << (20 - SECTOR_SHIFT)),
+			  display_size(cmd, available_mb << (20 - SECTOR_SHIFT)));
+		log_print_unless_silent("%s", msg);
+		return 0;
+	}
+
+	log_debug("VDO requires %s RAM, currently available %s RAM.",
+		  display_size(cmd, req_mb << (20 - SECTOR_SHIFT)),
+		  display_size(cmd, available_mb << (20 - SECTOR_SHIFT)));
+
+	log_verbose("%s", msg);
+
+	return 1;
+}
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 52e9443ea..b9bcc044f 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -355,8 +355,8 @@ static int _vdo_pool_target_status_compatible(const char *type)
 }
 
 static int _vdo_pool_add_target_line(struct dev_manager *dm,
-				     struct dm_pool *mem __attribute__((unused)),
-				     struct cmd_context *cmd __attribute__((unused)),
+				     struct dm_pool *mem,
+				     struct cmd_context *cmd,
 				     void **target_state __attribute__((unused)),
 				     struct lv_segment *seg,
 				     const struct lv_activate_opts *laopts __attribute__((unused)),
@@ -369,6 +369,10 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 		log_error(INTERNAL_ERROR "Passed segment is not VDO pool.");
 		return 0;
 	}
+
+	if (!check_vdo_constrains(cmd, seg->lv->size, seg_lv(seg, 0)->size, &seg->vdo_params))
+		return_0;
+
 	if (!(vdo_pool_name = dm_build_dm_name(mem, seg->lv->vg->name, seg->lv->name, lv_layer(seg->lv))))
 		return_0;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 20d7e4690..6bdbe943e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1730,6 +1730,10 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (!_update_extents_params(vg, lp, lcp))
 		goto_out;
 
+	if (seg_is_vdo(lp) && !check_vdo_constrains(cmd, (uint64_t)lp->extents * vg->extent_size,
+						    lcp->virtual_size, &lp->vdo_params))
+		return_0;
+
 	if (seg_is_thin(lp) && !_validate_internal_thin_processing(lp))
 		goto_out;
 

