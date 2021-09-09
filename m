From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  9 Sep 2021 14:14:21 +0000 (GMT)
Subject: main - vdo: read new sysfs path
Message-ID: <20210909141421.0393B3858C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6f735d411e5911de186a610932c9bb9638275eb
Commit:        e6f735d411e5911de186a610932c9bb9638275eb
Parent:        89595a366554191c3df1a18e1f82b79c450a21ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 14:59:38 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 9 15:24:15 2021 +0200

vdo: read new sysfs path

New versions of kvdo module exposes statistics at new location:
/sys/block/dm-XXX/vdo/statistics/...

Enhance lvm2 to access this location first.
Also if the statistic info is missing - make it 'debug' level info,
so it is not failing 'lvs' command.
---
 WHATS_NEW                        |  1 +
 lib/activate/dev_manager.c       |  7 +++---
 lib/metadata/metadata-exported.h |  3 ++-
 lib/metadata/vdo_manip.c         | 46 ++++++++++++++++++++++------------------
 4 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index feed7f53d..7d4cea1d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Support newer location for VDO statistics.
   Add support for VDO async-unsage write policy.
   Improve lvm_import_vdo script.
   Support VDO LV with lvcreate -ky.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2ada9b525..a8516d661 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -157,6 +157,7 @@ out:
 
 static int _get_segment_status_from_target_params(const char *target_name,
 						  const char *params,
+						  const struct dm_info *dminfo,
 						  struct lv_seg_status *seg_status)
 {
 	const struct lv_segment *seg = seg_status->seg;
@@ -216,7 +217,7 @@ static int _get_segment_status_from_target_params(const char *target_name,
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
 	} else if (segtype_is_vdo_pool(segtype)) {
-		if (!parse_vdo_pool_status(seg_status->mem, seg->lv, params, &seg_status->vdo_pool))
+		if (!parse_vdo_pool_status(seg_status->mem, seg->lv, params, dminfo, &seg_status->vdo_pool))
 			return_0;
 		seg_status->type = SEG_STATUS_VDO_POOL;
 	} else if (segtype_is_writecache(segtype)) {
@@ -320,7 +321,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		} while (target);
 
 		if (!target_name ||
-		    !_get_segment_status_from_target_params(target_name, target_params, seg_status))
+		    !_get_segment_status_from_target_params(target_name, target_params, dminfo, seg_status))
 			stack;
 	}
 
@@ -1886,7 +1887,7 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (!parse_vdo_pool_status(dm->mem, lv, params, *status))
+	if (!parse_vdo_pool_status(dm->mem, lv, params, &info, *status))
 		goto_out;
 
 	(*status)->mem = dm->mem;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 96a9533d2..7bac5b900 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1365,7 +1365,8 @@ const char *get_vdo_write_policy_name(enum dm_vdo_write_policy policy);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
 int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg);
 int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
-			  const char *params, struct lv_status_vdo *status);
+			  const char *params, const struct dm_info *dminfo,
+			  struct lv_status_vdo *status);
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 673db98e2..fa9c893cb 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -125,48 +125,56 @@ int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg)
 	return 1;
 }
 
-static int _sysfs_get_kvdo_value(const char *dm_name, const char *vdo_param, uint64_t *value)
+static int _sysfs_get_kvdo_value(const char *dm_name, const struct dm_info *dminfo,
+				 const char *vdo_param, uint64_t *value)
 {
 	char path[PATH_MAX];
 	char temp[64];
 	int fd, size, r = 0;
 
-	if (dm_snprintf(path, sizeof(path), "%skvdo/%s/%s",
-			dm_sysfs_dir(), dm_name, vdo_param) < 0) {
-		log_error("Failed to build kmod path.");
+	if (dm_snprintf(path, sizeof(path), "%s/block/dm-%d/vdo/%s",
+			dm_sysfs_dir(), dminfo->minor, vdo_param) < 0) {
+		log_debug("Failed to build kvdo path.");
 		return 0;
 	}
 
 	if ((fd = open(path, O_RDONLY)) < 0) {
-		if (errno != ENOENT)
-			log_sys_error("open", path);
-		else
+		/* try with older location */
+		if (dm_snprintf(path, sizeof(path), "%skvdo/%s/%s",
+				dm_sysfs_dir(), dm_name, vdo_param) < 0) {
+			log_debug("Failed to build kvdo path.");
+			return 0;
+		}
+
+		if ((fd = open(path, O_RDONLY)) < 0) {
 			log_sys_debug("open", path);
-		goto bad;
+			goto bad;
+		}
 	}
 
 	if ((size = read(fd, temp, sizeof(temp) - 1)) < 0) {
-		log_sys_error("read", path);
+		log_sys_debug("read", path);
 		goto bad;
 	}
 	temp[size] = 0;
 	errno = 0;
 	*value = strtoll(temp, NULL, 0);
 	if (errno) {
-		log_sys_error("strtool", path);
+		log_sys_debug("strtool", path);
 		goto bad;
 	}
 
 	r = 1;
 bad:
 	if (fd >= 0 && close(fd))
-		log_sys_error("close", path);
+		log_sys_debug("close", path);
 
 	return r;
 }
 
 int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
-			  const char *params, struct lv_status_vdo *status)
+			  const char *params, const struct dm_info *dminfo,
+			  struct lv_status_vdo *status)
 {
 	struct dm_vdo_status_parse_result result;
 	char *dm_name;
@@ -190,15 +198,11 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 
 	status->vdo = result.status;
 
-	if (result.status->operating_mode == DM_VDO_MODE_NORMAL) {
-		if (!_sysfs_get_kvdo_value(dm_name, "statistics/data_blocks_used",
-					   &status->data_blocks_used))
-			return_0;
-
-		if (!_sysfs_get_kvdo_value(dm_name, "statistics/logical_blocks_used",
-					   &status->logical_blocks_used))
-			return_0;
-
+	if ((result.status->operating_mode == DM_VDO_MODE_NORMAL) &&
+	    _sysfs_get_kvdo_value(dm_name, dminfo, "statistics/data_blocks_used",
+				  &status->data_blocks_used) &&
+	    _sysfs_get_kvdo_value(dm_name, dminfo, "statistics/logical_blocks_used",
+				  &status->logical_blocks_used)) {
 		status->usage = dm_make_percent(result.status->used_blocks,
 						result.status->total_blocks);
 		status->saving = dm_make_percent(status->logical_blocks_used - status->data_blocks_used,


