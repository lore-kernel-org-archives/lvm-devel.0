From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:20 -0400
Subject: master - vdo: keep minimum_io_size in sectors
Message-ID: <201910041533.x94FXKco031027@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d8a028e8cd9aaa34030af26046b04d87149be32
Commit:        9d8a028e8cd9aaa34030af26046b04d87149be32
Parent:        aad91330fecd7718fe5eb66a258feabc42f73c26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 14:58:18 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: keep minimum_io_size in sectors

---
 device_mapper/libdm-deptree.c  |    2 +-
 device_mapper/vdo/target.h     |    2 +-
 device_mapper/vdo/vdo_target.c |    5 +++--
 lib/metadata/vdo_manip.c       |    2 +-
 lib/vdo/vdo.c                  |    3 ++-
 5 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 4c030fc..7fac6ab 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2755,7 +2755,7 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		    "maxDiscard %u ack %u bio %u bioRotationInterval %u cpu %u hash %u logical %u physical %u",
 		    data_dev,
 		    seg->vdo_data_size / 8, // this parameter is in 4K units
-		    seg->vdo_params.minimum_io_size,
+		    seg->vdo_params.minimum_io_size * UINT32_C(512), //  sector to byte units
 		    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
 		    seg->vdo_params.block_map_era_length,
 		    seg->vdo_params.use_metadata_hints ? "on" : "off" ,
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index f83cffd..7767983 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -74,7 +74,7 @@ enum dm_vdo_write_policy {
 
 // FIXME: review whether we should use the createParams from the userlib
 struct dm_vdo_target_params {
-	uint32_t minimum_io_size;
+	uint32_t minimum_io_size;       // in sectors
 	uint32_t block_map_cache_size_mb;
 	uint32_t block_map_era_length;	// format period
 
diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index 976d71a..946be5a 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -23,8 +23,9 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 {
 	bool valid = true;
 
-	if ((vtp->minimum_io_size != 512) &&
-	    (vtp->minimum_io_size != 4096)) {
+	/* 512 or 4096 bytes only ATM */
+	if ((vtp->minimum_io_size != 1) &&
+	    (vtp->minimum_io_size != 8)) {
 		log_error("VDO minimum io size %u is unsupported.",
 			  vtp->minimum_io_size);
 		valid = false;
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 548b4ad..4877e77 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -436,7 +436,7 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 	vtp->use_metadata_hints =
 		find_config_tree_int(cmd, allocation_vdo_use_metadata_hints_CFG, profile);
 	vtp->minimum_io_size =
-		find_config_tree_int(cmd, allocation_vdo_minimum_io_size_CFG, profile);
+		find_config_tree_int(cmd, allocation_vdo_minimum_io_size_CFG, profile) >> SECTOR_SHIFT;
 	vtp->block_map_cache_size_mb =
 		find_config_tree_int64(cmd, allocation_vdo_block_map_cache_size_mb_CFG, profile);
 	vtp->block_map_era_length =
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index ed051fc..b4cb578 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -239,6 +239,7 @@ static int _vdo_pool_text_import(struct lv_segment *seg,
 
 	if (!dm_config_get_uint32(n, "minimum_io_size", &vtp->minimum_io_size))
 		return _bad_field("minimum_io_size");
+	vtp->minimum_io_size >>= SECTOR_SHIFT; // keep in sectors, while metadata uses bytes
 
 	if (!dm_config_get_uint32(n, "block_map_cache_size_mb", &vtp->block_map_cache_size_mb))
 		return _bad_field("block_map_cache_size_mb");
@@ -308,7 +309,7 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 	if (vtp->use_metadata_hints)
 		outf(f, "use_metadata_hints = 1");
 
-	outf(f, "minimum_io_size = %u", vtp->minimum_io_size);
+	outf(f, "minimum_io_size = %u", (vtp->minimum_io_size << SECTOR_SHIFT));
 
 	outsize(f, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024),
 		"block_map_cache_size_mb = %u", vtp->block_map_cache_size_mb);


