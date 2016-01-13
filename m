From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:53 +0000 (UTC)
Subject: master - cleanup: cleanup lv.h and put fns into categories for better readability
Message-ID: <20160113134653.A947B60679@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84a9f750fe00cd47c4ea5139ed66e0b175b66f00
Commit:        84a9f750fe00cd47c4ea5139ed66e0b175b66f00
Parent:        293abbb8d2f438c84d43f7f80570bd09fc5228ea
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 11:45:17 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 12:17:00 2016 +0100

cleanup: cleanup lv.h and put fns into categories for better readability

---
 lib/metadata/lv.h |   79 +++++++++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 36 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 2834ae5..bbd4564 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -58,21 +58,61 @@ struct logical_volume {
 
 struct lv_with_info_and_seg_status;
 
+/* LV dependencies */
+struct logical_volume *lv_parent(const struct logical_volume *lv);
+struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
+struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
+struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv);
+struct logical_volume *lv_data_lv(const struct logical_volume *lv);
+struct logical_volume *lv_convert(const struct logical_volume *lv);
+struct logical_volume *lv_origin(const struct logical_volume *lv);
+struct logical_volume *lv_mirror_log(const struct logical_volume *lv);
+struct logical_volume *lv_data(const struct logical_volume *lv);
+struct logical_volume *lv_metadata_lv(const struct logical_volume *lv);
+struct logical_volume *lv_pool_lv(const struct logical_volume *lv);
+
+/* LV properties */
 uint64_t lv_size(const struct logical_volume *lv);
+uint64_t lvseg_size(const struct lv_segment *seg);
+uint64_t lvseg_chunksize(const struct lv_segment *seg);
+uint64_t lv_origin_size(const struct logical_volume *lv);
 uint64_t lv_metadata_size(const struct logical_volume *lv);
+struct profile *lv_config_profile(const struct logical_volume *lv);
+const char *lv_layer(const struct logical_volume *lv);
+const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
+const struct logical_volume *lv_committed(const struct logical_volume *lv);
+int lv_mirror_image_in_sync(const struct logical_volume *lv);
+int lv_raid_image_in_sync(const struct logical_volume *lv);
+int lv_raid_healthy(const struct logical_volume *lv);
+const char *lvseg_name(const struct lv_segment *seg);
+uint64_t lvseg_start(const struct lv_segment *seg);
+char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+
+/* LV kernel properties */
+int lv_kernel_major(const struct logical_volume *lv);
+int lv_kernel_minor(const struct logical_volume *lv);
+uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
+
+/* LV modification functions */
+int lv_set_creation(struct logical_volume *lv,
+		    const char *hostname, uint64_t timestamp);
+int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
+		     enum activation_change activate, int needs_exlusive);
+
+/* LV dup functions */
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv);
-uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_move_pv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
-int lv_kernel_major(const struct logical_volume *lv);
-int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_mirror_log_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
@@ -81,53 +121,20 @@ char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
-
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
-struct logical_volume *lv_parent(const struct logical_volume *lv);
-struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
-struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
-struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv);
-struct logical_volume *lv_data_lv(const struct logical_volume *lv);
-struct logical_volume *lv_convert(const struct logical_volume *lv);
-struct logical_volume *lv_origin(const struct logical_volume *lv);
-struct logical_volume *lv_mirror_log(const struct logical_volume *lv);
-struct logical_volume *lv_data(const struct logical_volume *lv);
-struct logical_volume *lv_metadata_lv(const struct logical_volume *lv);
-struct logical_volume *lv_pool_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
-
-uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
-const char *lvseg_name(const struct lv_segment *seg);
-uint64_t lvseg_start(const struct lv_segment *seg);
-uint64_t lvseg_size(const struct lv_segment *seg);
-uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
-char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
-int lv_set_creation(struct logical_volume *lv,
-		    const char *hostname, uint64_t timestamp);
-const char *lv_layer(const struct logical_volume *lv);
-int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate, int needs_exlusive);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
-const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
-const struct logical_volume *lv_committed(const struct logical_volume *lv);
-struct profile *lv_config_profile(const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
-int lv_mirror_image_in_sync(const struct logical_volume *lv);
-int lv_raid_image_in_sync(const struct logical_volume *lv);
-int lv_raid_healthy(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


