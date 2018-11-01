From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Nov 2018 14:26:05 -0400
Subject: master - lvmlockd: fix size/resizing of internal lvmlock LV for sanlock
Message-ID: <201811011826.wA1IQ5Ri020316@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a170873aa13cc09dcc2b4d0a918e45278c4c4dd
Commit:        7a170873aa13cc09dcc2b4d0a918e45278c4c4dd
Parent:        0b01e3f5d7ce1c954aa9f3707aa645508664f7f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 24 11:23:40 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 1 13:25:21 2018 -0500

lvmlockd: fix size/resizing of internal lvmlock LV for sanlock

The lvmlock LV size was not adjusted correctly for 512 vs 4K
sector sizes which influence the lease size used by sanlock.

When lvmlock was automatically extended, the zeroing through
bcache wasn't working.
---
 lib/locking/lvmlockd.c |  111 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 90 insertions(+), 21 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d27c027..d65e06f 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -316,14 +316,18 @@ static int _lockd_request(struct cmd_context *cmd,
  * Eventually add an option to specify which pv the lvmlock lv should be placed on.
  */
 
+#define ONE_MB_IN_BYTES 1048576
+
 static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
-			      const char *lock_lv_name, int extend_mb)
+			      const char *lock_lv_name, int num_mb)
 {
+	uint32_t lv_size_bytes;
+	uint32_t extent_bytes;
+	uint32_t total_extents;
 	struct logical_volume *lv;
 	struct lvcreate_params lp = {
 		.activate = CHANGE_ALY,
 		.alloc = ALLOC_INHERIT,
-		.extents = (extend_mb * 1024 * 1024) / (vg->extent_size * SECTOR_SIZE),
 		.major = -1,
 		.minor = -1,
 		.permission = LVM_READ | LVM_WRITE,
@@ -335,6 +339,13 @@ static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.zero = 1,
 	};
 
+	lv_size_bytes = num_mb * ONE_MB_IN_BYTES;  /* size of sanlock LV in bytes */
+	extent_bytes = vg->extent_size * SECTOR_SIZE; /* size of one extent in bytes */
+	total_extents = lv_size_bytes / extent_bytes; /* number of extents in sanlock LV */
+	lp.extents = total_extents;
+
+	log_debug("Creating lvmlock LV for sanlock with size %um %ub %u extents", num_mb, lv_size_bytes, lp.extents);
+
 	dm_list_init(&lp.tags);
 
 	if (!(lp.segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
@@ -365,24 +376,45 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct device *dev;
 	char path[PATH_MAX];
-	uint64_t old_size_bytes, new_size_bytes;
+	uint64_t old_size_bytes;
+	uint64_t new_size_bytes;
+	uint32_t extend_bytes;
+	uint32_t extend_sectors;
+	uint32_t new_size_sectors;
 	struct logical_volume *lv = vg->sanlock_lv;
 	struct lvresize_params lp = {
 		.sign = SIGN_NONE,
-		.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE),
+		.size = 0,
 		.percent = PERCENT_NONE,
 		.resize = LV_EXTEND,
 		.force = 1,
 	};
+	int i;
 
+	extend_bytes = extend_mb * ONE_MB_IN_BYTES;
+	extend_sectors = extend_bytes / SECTOR_SIZE;
+	new_size_sectors = lv->size + extend_sectors;
 	old_size_bytes = lv->size * SECTOR_SIZE;
 
+	log_debug("Extend sanlock LV from %llus (%llu bytes) to %us (%u bytes)",
+		  (unsigned long long)lv->size,
+		  (unsigned long long)old_size_bytes,
+		  (uint32_t)new_size_sectors,
+		  (uint32_t)(new_size_sectors * SECTOR_SIZE));
+
+	lp.size = new_size_sectors;
+
 	if (!lv_resize(lv, &lp, &vg->pvs)) {
 		log_error("Extend sanlock LV %s to size %s failed.",
 			  display_lvname(lv), display_size(cmd, lp.size));
 		return 0;
 	}
 
+	if (!lv_refresh_suspend_resume(lv)) {
+		log_error("Failed to refresh sanlock LV %s after extend.", display_lvname(lv));
+		return 0;
+	}
+
 	new_size_bytes = lv->size * SECTOR_SIZE;
 
 	if (dm_snprintf(path, sizeof(path), "%s/mapper/%s-%s", lv->vg->cmd->dev_dir,
@@ -392,8 +424,10 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	log_debug("Extend sanlock LV zeroing blocks from offset " FMTu64 " bytes len %u bytes",
-		  old_size_bytes, (uint32_t)(new_size_bytes - old_size_bytes));
+	log_debug("Extend sanlock LV zeroing %u bytes from offset %llu to %llu",
+		  (uint32_t)(new_size_bytes - old_size_bytes),
+		  (unsigned long long)old_size_bytes,
+		  (unsigned long long)new_size_bytes);
 
 	log_print("Zeroing %u MiB on extended internal lvmlock LV...", extend_mb);
 
@@ -407,9 +441,13 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	if (!dev_write_zeros(dev, old_size_bytes, new_size_bytes - old_size_bytes)) {
-		log_error("Extend sanlock LV %s cannot zero device.", display_lvname(lv));
-		return 0;
+	for (i = 0; i < extend_mb; i++) {
+		if (!dev_write_zeros(dev, old_size_bytes + (i * ONE_MB_IN_BYTES), ONE_MB_IN_BYTES)) {
+			log_error("Extend sanlock LV %s cannot zero device@%llu.", display_lvname(lv),
+				  (unsigned long long)(old_size_bytes + i * ONE_MB_IN_BYTES));
+			label_scan_invalidate(dev);
+			return 0;
+		}
 	}
 
 	label_scan_invalidate(dev);
@@ -590,7 +628,11 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	const char *reply_str;
 	const char *vg_lock_args = NULL;
 	const char *opts = NULL;
-	int extend_mb;
+	struct pv_list *pvl;
+	struct device *sector_dev;
+	uint32_t sector_size = 0;
+	unsigned int phys_block_size, block_size;
+	int num_mb;
 	int result;
 	int ret;
 
@@ -600,13 +642,38 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 		return 0;
 
 	/*
-	 * Automatic extension of the sanlock lv is disabled by
-	 * setting sanlock_lv_extend to 0.  Zero won't work as
-	 * an initial size, so in this case, use the default as
-	 * the initial size.
+	 * We need the sector size to know what size to create the LV,
+	 * but we're not sure what PV the LV will be allocated from, so
+	 * just get the sector size of the first PV.
 	 */
-	if (!(extend_mb = find_config_tree_int(cmd, global_sanlock_lv_extend_CFG, NULL)))
-		extend_mb = DEFAULT_SANLOCK_LV_EXTEND_MB;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!dev_get_block_size(pvl->pv->dev, &phys_block_size, &block_size))
+			continue;
+
+		if (!sector_size) {
+			sector_size = phys_block_size;
+			sector_dev = pvl->pv->dev;
+		} else if (sector_size != phys_block_size) {
+			log_warn("Inconsistent sector sizes for %s and %s.",
+				 dev_name(pvl->pv->dev), dev_name(sector_dev));
+			return 1;
+		}
+	}
+
+	if ((sector_size != 512) && (sector_size != 4096)) {
+		log_error("Unknown sector size.");
+		return 1;
+	}
+
+	log_debug("Using sector size %u for sanlock LV", sector_size);
+
+	/* Base starting size of sanlock LV is 256MB/1GB for 512/4K sectors */
+	if (sector_size == 512)
+		num_mb = 256;
+	else if (sector_size == 4096)
+		num_mb = 1024;
+
 
 	/*
 	 * Creating the sanlock LV writes the VG containing the new lvmlock
@@ -618,14 +685,16 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	 * be large enough to hold leases for all existing lvs needing locks.
 	 * One sanlock lease uses 1MB/8MB for 512/4K sector size devices, so
 	 * increase the initial size by 1MB/8MB for each existing lv.
-	 * FIXME: we don't know what sector size the pv will have, so we
-	 * multiply by 8 (MB) unnecessarily when the sector size is 512.
 	 */
 
-	if (lv_lock_count)
-		extend_mb += (lv_lock_count * 8);
+	if (lv_lock_count) {
+		if (sector_size == 512)
+			num_mb += lv_lock_count;
+		else if (sector_size == 4096)
+			num_mb += 8 * lv_lock_count;
+	}
 
-	if (!_create_sanlock_lv(cmd, vg, LOCKD_SANLOCK_LV_NAME, extend_mb)) {
+	if (!_create_sanlock_lv(cmd, vg, LOCKD_SANLOCK_LV_NAME, num_mb)) {
 		log_error("Failed to create internal lv.");
 		return 0;
 	}


