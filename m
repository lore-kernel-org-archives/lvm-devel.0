From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:51 -0400
Subject: master - vdo_manip: parsing status of VDO device
Message-ID: <201807091334.w69DYpo8030704@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dafd159a862aa76a950a3568eba32a73c0422cc
Commit:        0dafd159a862aa76a950a3568eba32a73c0422cc
Parent:        aa63dfbe39860f04d8965e2afc4959cd20988411
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 2 17:20:30 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo_manip: parsing status of VDO device

---
 lib/activate/activate.h          |    2 +
 lib/activate/dev_manager.c       |    4 ++
 lib/metadata/metadata-exported.h |   10 +++++
 lib/metadata/vdo_manip.c         |   83 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 09cd688..6d70f64 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -37,6 +37,7 @@ typedef enum {
 	SEG_STATUS_SNAPSHOT,
 	SEG_STATUS_THIN,
 	SEG_STATUS_THIN_POOL,
+	SEG_STATUS_VDO_POOL,
 	SEG_STATUS_UNKNOWN
 } lv_seg_status_type_t;
 
@@ -50,6 +51,7 @@ struct lv_seg_status {
 		struct dm_status_snapshot *snapshot;
 		struct dm_status_thin *thin;
 		struct dm_status_thin_pool *thin_pool;
+		struct lv_status_vdo vdo_pool;
 	};
 };
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 07fc93e..25d5e69 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -209,6 +209,10 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!dm_get_status_snapshot(seg_status->mem, params, &seg_status->snapshot))
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
+	} else if (segtype_is_vdo_pool(segtype)) {
+		if (!parse_vdo_pool_status(seg_status->mem, seg->lv, params, &seg_status->vdo_pool))
+			return_0;
+		seg_status->type = SEG_STATUS_VDO_POOL;
 	} else
 		/*
 		 * TODO: Add support for other segment types too!
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b221139..b6ac4cb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1250,11 +1250,21 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 
 
 /* ++  metadata/vdo_manip.c */
+struct lv_status_vdo {
+	struct dm_pool *mem;
+	struct dm_vdo_status *vdo;
+	uint64_t data_blocks_used;	/* grabbed from /sys/kvdo */
+	uint64_t logical_blocks_used;	/* grabbed from /sys/kvdo */
+	dm_percent_t usage;
+	dm_percent_t saving;
+};
 
 const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state);
 const char *get_vdo_index_state_name(enum dm_vdo_index_state state);
 const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
+int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
+			  const char *params, struct lv_status_vdo *status);
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents);
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 8aee3dc..5801a1b 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -93,6 +93,89 @@ uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg)
 				 vdo_pool_seg->vdo_pool_header_size);
 }
 
+static int _sysfs_get_kvdo_value(const char *dm_name, const char *vdo_param, uint64_t *value)
+{
+	char path[PATH_MAX];
+	char temp[64];
+	int fd, size, r = 0;
+
+	if (dm_snprintf(path, sizeof(path), "%skvdo/%s/%s",
+			dm_sysfs_dir(), dm_name, vdo_param) < 0) {
+		log_error("Failed to build kmod path.");
+		goto bad;
+	}
+
+	if ((fd = open(path, O_RDONLY)) < 0) {
+		if (errno != ENOENT)
+			log_sys_error("open", path);
+		else
+			log_sys_debug("open", path);
+		goto bad;
+	}
+
+	if ((size = read(fd, temp, sizeof(temp) - 1)) < 0) {
+		log_sys_error("read", path);
+		goto bad;
+	}
+	temp[size] = 0;
+	errno = 0;
+	*value = strtoll(temp, NULL, 0);
+	if (errno) {
+		log_sys_error("strtool", path);
+		goto bad;
+	}
+
+	r = 1;
+bad:
+	if (fd >= 0 && close(fd))
+		log_sys_error("close", path);
+
+	return r;
+}
+
+int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
+			  const char *params, struct lv_status_vdo *status)
+{
+	struct dm_vdo_status_parse_result result;
+	char *dm_name;
+
+	status->usage = DM_PERCENT_INVALID;
+	status->saving = DM_PERCENT_INVALID;
+
+	if (!(dm_name = dm_build_dm_name(mem, vdo_pool_lv->vg->name,
+					 vdo_pool_lv->name, NULL))) {
+		log_error("Failed to build VDO DM name %s.",
+			  display_lvname(vdo_pool_lv));
+		return 0;
+	}
+
+	if (!dm_vdo_status_parse(mem, params, &result)) {
+		log_error("Cannot parse %s VDO pool status %s.",
+			  display_lvname(vdo_pool_lv), result.error);
+		return 0;
+	}
+
+	status->vdo = result.status;
+
+	if (result.status->operating_mode == DM_VDO_MODE_NORMAL) {
+		if (!_sysfs_get_kvdo_value(dm_name, "statistics/data_blocks_used",
+					   &status->data_blocks_used))
+			return_0;
+
+		if (!_sysfs_get_kvdo_value(dm_name, "statistics/logical_blocks_used",
+					   &status->logical_blocks_used))
+			return_0;
+
+		status->usage = dm_make_percent(result.status->used_blocks,
+						result.status->total_blocks);
+		status->saving = dm_make_percent(status->logical_blocks_used - status->data_blocks_used,
+						 status->logical_blocks_used);
+	}
+
+	return 1;
+}
+
+
 /*
  * Formats data LV for a use as a VDO pool LV.
  *


