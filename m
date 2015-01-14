From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:56 +0000 (UTC)
Subject: master - thin: errrorwhenfull support
Message-ID: <20150114135456.DFE6260C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2908ab3eed4d7feb041c99a4e2fca98a5bcf6922
Commit:        2908ab3eed4d7feb041c99a4e2fca98a5bcf6922
Parent:        1e050a77ff333fd1849eb8068b6d22cb9411fc06
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 13 15:23:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:52:05 2015 +0100

thin: errrorwhenfull support

Support error_if_no_space feature for thin pools.
Report more info about thinpool status:
(out_of_data (D), metadata_read_only (M), failed  (F) also as health
attribute.)
---
 WHATS_NEW                        |    1 +
 WHATS_NEW_DM                     |    2 ++
 conf/example.conf.in             |    5 +++++
 lib/config/config_settings.h     |    1 +
 lib/config/defaults.h            |    1 +
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv.c                |   16 ++++++++++++++++
 lib/metadata/lv.h                |    1 +
 lib/metadata/lv_manip.c          |    2 ++
 lib/metadata/merge.c             |    7 +++++++
 lib/metadata/metadata-exported.h |    4 +++-
 lib/metadata/segtype.h           |    3 +++
 lib/report/columns.h             |    1 +
 lib/report/properties.c          |    2 ++
 lib/report/report.c              |   21 +++++++++++++++++++++
 lib/report/values.h              |    1 +
 lib/thin/thin.c                  |   11 ++++++++++-
 libdm/libdevmapper.h             |   12 ++++++++++--
 libdm/libdm-deptree.c            |   34 +++++++++++++++++++++++++++++-----
 tools/args.h                     |    1 +
 tools/commands.h                 |    3 ++-
 tools/lvcreate.c                 |   15 +++++++++++++++
 22 files changed, 135 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bbb45c4..3881d5d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Add support for lvcreate --errorwhenfull y|n for thin pools.
   Fix lvconvert --repair to honour resilience requirement for segmented RAID LV.
   Filter out partitioned device-mapper devices as unsuitable for use as PVs.
   Also notify lvmetad about filtered device if using pvscan --cache DevicePath.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 02b8045..98f98b6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.93 -
 ====================================
+  Report more info from thin pool status (out of data, metadata-ro, fail).
+  Support error_if_no_space for thin pool target.
   Fix segfault while using selection with regex and unbuffered reporting.
   Add dm_report_compact_fields to remove empty fields from report output.
   Remove unimplemented dm_report_set_output_selection from libdevmapper.h.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 70d3e6b..21b963b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -777,6 +777,7 @@ global {
     #   external_origin
     #   metadata_resize
     #   external_origin_extend
+    #   error_if_no_space
     #
     # thin_disabled_features = [ "discards", "block_size" ]
 
@@ -937,6 +938,10 @@ activation {
     # enables or disables this automatic setting of the flag while LVs are created.
     # auto_set_activation_skip = 1
 
+    # Control error behavior when provisioned device becomes full.
+    # Set to 1 to instant error when there is missing free space in device.
+    # error_when_full = 0
+
     # For RAID or 'mirror' segment types, 'raid_region_size' is the
     # size (in KiB) of each:
     # - synchronization operation when initializing
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6de948e..8978b5b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -205,6 +205,7 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL)
 cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL)
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL)
+cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL)
 cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL)
 cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL)
 cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index e15926c..1431de2 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -44,6 +44,7 @@
 #define DEFAULT_PV_MIN_SIZE_KB 2048
 
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
+#define DEFAULT_ERROR_WHEN_FULL 0
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index e3a00a6..cf01271 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -61,6 +61,7 @@ static const struct flag _lv_flags[] = {
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
+	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index fb1cd78..8682535 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -210,6 +210,11 @@ uint64_t lvseg_size(const struct lv_segment *seg)
 	return (uint64_t) seg->len * seg->lv->vg->extent_size;
 }
 
+uint32_t lv_error_when_full(const struct logical_volume *lv)
+{
+	return (lv_is_thin_pool(lv) && (lv->status & LV_ERROR_WHEN_FULL)) ? 1 : 0;
+}
+
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 {
 	struct lvinfo info;
@@ -644,6 +649,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	dm_percent_t snap_percent;
 	struct lvinfo info;
 	struct lv_segment *seg;
+	struct lv_seg_status seg_status;
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(mem, 11))) {
@@ -797,6 +803,16 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
+	} else if (lv_is_thin_pool(lv)) {
+		seg_status.mem = lv->vg->cmd->mem;
+		if (!lv_status(lv->vg->cmd, first_seg(lv), &seg_status))
+			repstr[8] = 'X'; /* Unknown */
+		else if (((struct dm_status_thin_pool *)seg_status.status)->fail)
+			repstr[8] = 'F';
+		else if (((struct dm_status_thin_pool *)seg_status.status)->out_of_data_space)
+			repstr[8] = 'D';
+		else if (((struct dm_status_thin_pool *)seg_status.status)->read_only)
+			repstr[8] = 'M';
 	}
 
 	if (lv->status & LV_ACTIVATION_SKIP)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 8064ba2..6c6df73 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -88,6 +88,7 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+uint32_t lv_error_when_full(const struct logical_volume *lv);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 457cf9e..8a3b779 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7010,6 +7010,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			stack;
 			goto revert_new_lv;
 		}
+		if (lp->error_when_full)
+			lv->status |= LV_ERROR_WHEN_FULL;
 	} else if (pool_lv && seg_is_thin_volume(lp)) {
 		seg = first_seg(lv);
 		pool_seg = first_seg(pool_lv);
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 5e09123..6d661f8 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -147,6 +147,13 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
+		if ((lv->status & LV_ERROR_WHEN_FULL) &&
+		    !seg_can_error_when_full(seg)) {
+			log_error("LV %s: segment %u (%s) does not support flag "
+				  "ERROR_WHEN_FULL.", lv->name, seg_count, seg->segtype->name);
+			inc_error_count;
+		}
+
 		if (complete_vg && seg->log_lv &&
 		    !seg_is_mirrored(seg) && !(seg->status & RAID_IMAGE)) {
 			log_error("LV %s: segment %u log LV %s is not a "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 14a5ef5..a48aef2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -118,8 +118,9 @@
 #define CACHE			UINT64_C(0x0001000000000000)    /* LV - Internal use only */
 
 #define LV_PENDING_DELETE	UINT64_C(0x0004000000000000)    /* LV - Internal use only */
+#define LV_ERROR_WHEN_FULL	UINT64_C(0x0008000000000000)    /* LV - error when full */
 
-/* Next unused flag:		UINT64_C(0x0008000000000000)    */
+/* Next unused flag:		UINT64_C(0x0010000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -871,6 +872,7 @@ struct lvcreate_params {
 	struct dm_list *pvh; /* all */
 
 	uint64_t permission; /* all */
+	unsigned error_when_full; /* when segment supports it */
 	uint32_t read_ahead; /* all */
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index ecb598d..4b2df78 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -45,6 +45,7 @@ struct dev_manager;
 #define SEG_CACHE_POOL		0x00004000U
 #define SEG_MIRROR		0x00008000U
 #define SEG_ONLY_EXCLUSIVE	0x00010000U /* In cluster only exlusive activation */
+#define SEG_CAN_ERROR_WHEN_FULL	0x00020000U
 #define SEG_UNKNOWN		0x80000000U
 
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
@@ -80,6 +81,7 @@ struct dev_manager;
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
 #define seg_only_exclusive(seg)	((seg)->segtype->flags & SEG_ONLY_EXCLUSIVE ? 1 : 0)
+#define seg_can_error_when_full(seg) ((seg)->segtype->flags & SEG_CAN_ERROR_WHEN_FULL ? 1 : 0)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */
@@ -179,6 +181,7 @@ int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seg
 #define THIN_FEATURE_DISCARDS_NON_POWER_2	(1U << 4)
 #define THIN_FEATURE_METADATA_RESIZE		(1U << 5)
 #define THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND	(1U << 6)
+#define THIN_FEATURE_ERROR_IF_NO_SPACE		(1U << 7)
 
 #ifdef THIN_INTERNAL
 int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 1dd2ae0..9f64ac8 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -52,6 +52,7 @@ FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Se
 FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
+FIELD(LVS, lv, BIN, "WhenFull", lvid, 15, lverrorwhenfull, lv_error_when_full, "For thin pools, behavior when full.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, BIN, "ActLocal", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
 FIELD(LVS, lv, BIN, "ActRemote", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 4796000..cece62c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -281,6 +281,8 @@ GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
 #define _lv_major_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
+#define _lv_error_when_full_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(lv_error_when_full, lv_error_when_full(lv))
 #define _lv_minor_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_read_ahead, lv->read_ahead * SECTOR_SIZE)
 #define _lv_read_ahead_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index be80e77..1b1ccca 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -726,6 +726,16 @@ static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	return dm_report_field_int32(rh, field, data);
 }
 
+static int _lverrorwhenfull_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	return _binary_disp(rh, mem, field, lv_error_when_full(lv),
+			    GET_FIRST_RESERVED_NAME(lv_error_when_full_y), private);
+}
+
 static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
@@ -1761,6 +1771,7 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct lv_seg_status seg_status;
 	const char *health = "";
 	uint64_t n;
 
@@ -1776,6 +1787,16 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				health = "mismatches exist";
 		} else if (lv->status & LV_WRITEMOSTLY)
 			health = "writemostly";
+	} else if (lv_is_thin_pool(lv)) {
+		seg_status.mem = lv->vg->cmd->mem;
+		if (!lv_status(lv->vg->cmd, first_seg(lv), &seg_status))
+			health = "unknown";
+		else if (((struct dm_status_thin_pool *)seg_status.status)->fail)
+			health = "failed";
+		else if (((struct dm_status_thin_pool *)seg_status.status)->out_of_data_space)
+			health = "out_of_data";
+		else if (((struct dm_status_thin_pool *)seg_status.status)->read_only)
+			health = "metadata_read_only";
 	}
 
 	return _string_disp(rh, mem, field, &health, private);
diff --git a/lib/report/values.h b/lib/report/values.h
index 4ea92bd..4323c17 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -68,6 +68,7 @@ FIELD_RESERVED_BINARY_VALUE(lv_image_synced, lv_image_synced, "", "image synced"
 FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "", "merging")
 FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "", "converting")
 FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "", "allocation locked", "locked")
+FIELD_RESERVED_BINARY_VALUE(lv_error_when_full, lv_error_when_full, "", "error when full", "error if no space", "error")
 FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "", "fixed minor", "fixed")
 FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "", "active locally", "active", "locally")
 FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "", "active remotely", "active", "remotely")
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index f27f240..377d6ad 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -259,6 +259,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	static int _no_discards = 0;
+	static int _no_error_if_no_space = 0;
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 	const struct logical_volume *origin;
@@ -314,6 +315,12 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
 				  "not support discards (needs kernel >= 3.4).");
 
+	if (attr & THIN_FEATURE_ERROR_IF_NO_SPACE)
+		dm_tree_node_set_thin_pool_error_if_no_space(node, (seg->lv->status & LV_ERROR_WHEN_FULL) ? 1 : 0);
+	else if (seg->lv->status & LV_ERROR_WHEN_FULL)
+		log_warn_suppress(_no_error_if_no_space++, "WARNING: Thin pool target does "
+				  "not support error if no space (needs version >= 1.10).");
+
 	/*
 	 * Add messages only for activation tree.
 	 * Otherwise avoid checking for existence of suspended origin.
@@ -639,6 +646,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
 		{ 1, 10, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
 		{ 9, 11, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND, "external_origin_extend" },
+		{ 1, 10, THIN_FEATURE_ERROR_IF_NO_SPACE, "error_if_no_space" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";
@@ -753,7 +761,8 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 		const char name[16];
 		uint32_t flags;
 	} reg_segtypes[] = {
-		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE },
+		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL | SEG_CANNOT_BE_ZEROED |
+		SEG_ONLY_EXCLUSIVE | SEG_CAN_ERROR_WHEN_FULL },
 		/* FIXME Maybe use SEG_THIN_VOLUME instead of SEG_VIRTUAL */
 		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL | SEG_ONLY_EXCLUSIVE }
 	};
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 48adf22..b164b51 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -366,8 +366,12 @@ struct dm_status_thin_pool {
 	uint64_t used_data_blocks;
 	uint64_t total_data_blocks;
 	uint64_t held_metadata_root;
-	uint32_t read_only;
+	uint32_t read_only;		/* metadata may not be changed */
 	dm_thin_discards_t discards;
+	uint32_t fail : 1;		/* all I/O fails */
+	uint32_t error_if_no_space : 1;	/* otherwise queue_if_no_space */
+	uint32_t out_of_data_space : 1;	/* metadata may be changed, but data may not be allocated */
+	uint32_t reserved : 29;
 };
 
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
@@ -886,7 +890,11 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
 				       unsigned ignore,
 				       unsigned no_passdown);
-
+/*
+ * Set error if no space, instead of queueing for thin pool.
+ */
+int dm_tree_node_set_thin_pool_error_if_no_space(struct dm_tree_node *node,
+						 unsigned error_if_no_space);
 /*
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
  * MAX_DEV_ID ((1 << 24) - 1)
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index c3a5df6..cd63061 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -204,6 +204,7 @@ struct load_segment {
 	unsigned skip_block_zeroing;	/* Thin_pool */
 	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
 	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
+	unsigned error_if_no_space;	/* Thin pool target vsn 1.10 */
 	uint32_t device_id;		/* Thin */
 
 };
@@ -2417,9 +2418,10 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 {
 	int pos = 0;
 	char pool[DM_FORMAT_DEV_BUFSIZE], metadata[DM_FORMAT_DEV_BUFSIZE];
-	int features = (seg->skip_block_zeroing ? 1 : 0) +
-			(seg->ignore_discard ? 1 : 0) +
-			(seg->no_discard_passdown ? 1 : 0);
+	int features = (seg->error_if_no_space ? 1 : 0) +
+		 (seg->ignore_discard ? 1 : 0) +
+		 (seg->no_discard_passdown ? 1 : 0) +
+		 (seg->skip_block_zeroing ? 1 : 0);
 
 	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
 		return_0;
@@ -2427,8 +2429,9 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 	if (!_build_dev_string(pool, sizeof(pool), seg->pool))
 		return_0;
 
-	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s", metadata, pool,
+	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s%s", metadata, pool,
 		    seg->data_block_size, seg->low_water_mark, features,
+		    seg->error_if_no_space ? " error_if_no_space" : "",
 		    seg->skip_block_zeroing ? " skip_block_zeroing" : "",
 		    seg->ignore_discard ? " ignore_discard" : "",
 		    seg->no_discard_passdown ? " no_discard_passdown" : ""
@@ -3848,6 +3851,19 @@ int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_set_thin_pool_error_if_no_space(struct dm_tree_node *node,
+						 unsigned error_if_no_space)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _get_single_load_segment(node, SEG_THIN_POOL)))
+		return_0;
+
+	seg->error_if_no_space = error_if_no_space;
+
+	return 1;
+}
+
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
 				 const char *pool_uuid,
@@ -3936,7 +3952,15 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 	else /* default discard_passdown */
 		s->discards = DM_THIN_DISCARDS_PASSDOWN;
 
-	s->read_only = (strstr(params + pos, "ro ")) ? 1 : 0;
+	if (strstr(params + pos, "ro "))
+		s->read_only = 1;
+	else if (strstr(params + pos, "fail"))
+		s->fail = 1;
+	else if (strstr(params + pos, "out_of_data_space"))
+		s->out_of_data_space = 1;
+
+	if (strstr(params + pos, "error_if_no_space"))
+		s->error_if_no_space = 1;
 
 	*status = s;
 
diff --git a/tools/args.h b/tools/args.h
index 1abe0eb..80e9155 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -39,6 +39,7 @@ arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
+arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 8b6b607..6eb8cc5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -267,6 +267,7 @@ xx(lvcreate,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--errorwhenfull {y|n}]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
@@ -339,7 +340,7 @@ xx(lvcreate,
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    cache_ARG, cachemode_ARG, cachepool_ARG, cachepolicy_ARG, cachesettings_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, errorwhenfull_ARG,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
    minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7236ffc..fd5ac39 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -582,6 +582,14 @@ static int _read_activation_params(struct cmd_context *cmd,
 	lp->activate = (activation_change_t)
 		arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
+	/* Error when full */
+	if (arg_is_set(cmd, errorwhenfull_ARG)) {
+		lp->error_when_full = arg_uint_value(cmd, errorwhenfull_ARG, 0);
+	} else
+		lp->error_when_full =
+			seg_can_error_when_full(lp) &&
+			find_config_tree_bool(cmd, activation_error_when_full_CFG, NULL);
+
 	/* Read ahead */
 	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 					cmd->default_settings.read_ahead);
@@ -856,6 +864,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					    SIZE_ARGS,
 					    THIN_POOL_ARGS,
 					    chunksize_ARG,
+					    errorwhenfull_ARG,
 					    snapshot_ARG,
 					    thin_ARG,
 					    virtualsize_ARG,
@@ -875,6 +884,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 						SIZE_ARGS,
 						chunksize_ARG,
 						discards_ARG,
+						errorwhenfull_ARG,
 						zero_ARG,
 						-1))
 			return_0;
@@ -941,6 +951,11 @@ static int _lvcreate_params(struct cmd_context *cmd,
 				 -1))
 		return_0;
 
+	if (!seg_can_error_when_full(lp) && arg_is_set(cmd, errorwhenfull_ARG)) {
+		log_error("Segment type %s does not support --errorwhenfull.", lp->segtype->name);
+		return 0;
+	}
+
 	/* Basic segment type validation finished here */
 
 	if (activation() && lp->segtype->ops->target_present) {


