From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:22 +0000 (GMT)
Subject: main - libdm: eliminate some abi-dumper errors
Message-ID: <20210406200722.C7BDA3846079@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1d3648dc786a8fad53a32cbd334a44b36c53767
Commit:        f1d3648dc786a8fad53a32cbd334a44b36c53767
Parent:        14ea63cfc7ba7a8a47197e7fae0c045eda68e749
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 14:25:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

libdm: eliminate some abi-dumper errors

ABI dumper does not like missing enum/union/struct names,
so add them with _e, _u suffix.

Usage reference:

https://doc.dpdk.org/guides-16.04/contributing/versioning.html
---
 daemons/cmirrord/cluster.c  |  2 +-
 daemons/cmirrord/cluster.h  |  2 +-
 libdm/ioctl/libdm-targets.h |  2 +-
 libdm/libdevmapper.h        | 38 +++++++++++++++++++-------------------
 libdm/libdm-report.c        |  6 +++---
 5 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 9df321a4c..23308e7a9 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1548,7 +1548,7 @@ static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gnam
 				   member_list, member_list_entries);
 }
 
-cpg_callbacks_t cpg_callbacks = {
+static cpg_callbacks_t cpg_callbacks = {
 	.cpg_deliver_fn = cpg_message_callback,
 	.cpg_confchg_fn = cpg_config_callback,
 };
diff --git a/daemons/cmirrord/cluster.h b/daemons/cmirrord/cluster.h
index ccb2f358f..10032bd43 100644
--- a/daemons/cmirrord/cluster.h
+++ b/daemons/cmirrord/cluster.h
@@ -39,7 +39,7 @@ struct clog_request {
 	 * machine.  If the two are equal, there is no need
 	 * to do endian conversions.
 	 */
-	union {
+	union version_u {
 		uint64_t version[2]; /* LE version and native version */
 		struct dm_list list;
 	} u;
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index b5b20d5e9..294210d2b 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -47,7 +47,7 @@ struct dm_task {
 	mode_t mode;
 	uint32_t read_ahead;
 	uint32_t read_ahead_flags;
-	union {
+	union dmi_u {
 		struct dm_ioctl *v4;
 	} dmi;
 	char *newname;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 26d64bf4e..ac31b59da 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -247,7 +247,7 @@ struct dm_timestamp *dm_task_get_ioctl_timestamp(struct dm_task *dmt);
  */
 int dm_task_enable_checks(struct dm_task *dmt);
 
-typedef enum {
+typedef enum dm_add_node_e {
 	DM_ADD_NODE_ON_RESUME, /* add /dev/mapper node with dmsetup resume */
 	DM_ADD_NODE_ON_CREATE  /* add /dev/mapper node with dmsetup create */
 } dm_add_node_t;
@@ -294,7 +294,7 @@ void *dm_get_next_target(struct dm_task *dmt,
  */
 
 /* Parse params from STATUS call for mirror target */
-typedef enum {
+typedef enum dm_status_mirror_health_e {
 	DM_STATUS_MIRROR_ALIVE	      = 'A',/* No failures */
 	DM_STATUS_MIRROR_FLUSH_FAILED = 'F',/* Mirror out-of-sync */
 	DM_STATUS_MIRROR_WRITE_FAILED = 'D',/* Mirror out-of-sync */
@@ -307,14 +307,14 @@ struct dm_status_mirror {
 	uint64_t total_regions;
 	uint64_t insync_regions;
 	uint32_t dev_count;             /* # of devs[] elements (<= 8) */
-	struct {
+	struct dm_dev_leg_health_s {
 		dm_status_mirror_health_t health;
 		uint32_t major;
 		uint32_t minor;
 	} *devs;                        /* array with individual legs */
 	const char *log_type;           /* core, disk,.... */
 	uint32_t log_count;		/* # of logs[] elements */
-	struct {
+	struct dm_dev_log_health_s {
 		dm_status_mirror_health_t health;
 		uint32_t major;
 		uint32_t minor;
@@ -404,7 +404,7 @@ int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 			   struct dm_status_snapshot **status);
 
 /* Parse params from STATUS call for thin_pool target */
-typedef enum {
+typedef enum dm_thin_discards_e {
 	DM_THIN_DISCARDS_IGNORE,
 	DM_THIN_DISCARDS_NO_PASSDOWN,
 	DM_THIN_DISCARDS_PASSDOWN
@@ -992,7 +992,7 @@ const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
 const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
 					 uint64_t region_id);
 
-typedef enum {
+typedef enum dm_stats_obj_type_e {
 	DM_STATS_OBJECT_TYPE_NONE,
 	DM_STATS_OBJECT_TYPE_AREA,
 	DM_STATS_OBJECT_TYPE_REGION,
@@ -1405,7 +1405,7 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
  * and placing a new file at the same path.
  */
 
-typedef enum {
+typedef enum dm_filemapd_mode_e {
 	DM_FILEMAPD_FOLLOW_INODE,
 	DM_FILEMAPD_FOLLOW_PATH,
 	DM_FILEMAPD_FOLLOW_NONE
@@ -1464,7 +1464,7 @@ void dm_task_update_nodes(void);
  * HEX mangling format: \xNN, NN being the hex value of the character.
  * (whitelist and format supported by udev)
 */
-typedef enum {
+typedef enum dm_string_mangling_e {
 	DM_STRING_MANGLING_NONE, /* do not mangle@all */
 	DM_STRING_MANGLING_AUTO, /* mangle only if not already mangled with hex, error when mixed */
 	DM_STRING_MANGLING_HEX	 /* always mangle with hex encoding, no matter what the input is */
@@ -1930,7 +1930,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
  * Replicator operation mode
  * Note: API for Replicator is not yet stable
  */
-typedef enum {
+typedef enum dm_replicator_mode_e {
 	DM_REPLICATOR_SYNC,			/* Synchronous replication */
 	DM_REPLICATOR_ASYNC_WARN,		/* Warn if async replicator is slow */
 	DM_REPLICATOR_ASYNC_STALL,		/* Stall replicator if not fast enough */
@@ -1995,7 +1995,7 @@ int dm_tree_node_add_thin_pool_target_v1(struct dm_tree_node *node,
 					 unsigned crop_metadata);
 
 /* Supported messages for thin provision target */
-typedef enum {
+typedef enum dm_thin_message_e {
 	DM_THIN_MESSAGE_CREATE_SNAP,		/* device_id, origin_id */
 	DM_THIN_MESSAGE_CREATE_THIN,		/* device_id */
 	DM_THIN_MESSAGE_DELETE,			/* device_id */
@@ -2066,7 +2066,7 @@ void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
  * Callback is called before 'activation' of node for activation tree,
  * or 'deactivation' of node for deactivation tree.
  */
-typedef enum {
+typedef enum dm_node_callback_e {
 	DM_NODE_CALLBACK_PRELOADED,   /* Node has preload deps */
 	DM_NODE_CALLBACK_DEACTIVATED, /* Node is deactivated */
 } dm_node_callback_t;
@@ -2728,7 +2728,7 @@ uint64_t dm_units_to_factor(const char *units, char *unit_type,
 /*
  * Type of unit specifier used by dm_size_to_string().
  */
-typedef enum {
+typedef enum dm_size_suffix_e {
 	DM_SIZE_LONG = 0,	/* Megabyte */
 	DM_SIZE_SHORT = 1,	/* MB or MiB */
 	DM_SIZE_UNIT = 2	/* M or m */
@@ -2844,7 +2844,7 @@ uint32_t dm_regex_fingerprint(struct dm_regex *regex);
 */
 #define DM_PERCENT_CHAR '%'
 
-typedef enum {
+typedef enum dm_percent_range_e {
 	DM_PERCENT_0 = 0,
 	DM_PERCENT_1 = 1000000,
 	DM_PERCENT_100 = 100 * DM_PERCENT_1,
@@ -3007,7 +3007,7 @@ struct dm_report_reserved_value {
 /*
  * Available actions for dm_report_reserved_value_handler.
  */
-typedef enum {
+typedef enum dm_report_reserved_action_e {
 	DM_REPORT_RESERVED_PARSE_FUZZY_NAME,
 	DM_REPORT_RESERVED_GET_DYNAMIC_VALUE,
 } dm_report_reserved_action_t;
@@ -3166,7 +3166,7 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
  */
 struct dm_report_group;
 
-typedef enum {
+typedef enum dm_report_group_type_e {
 	DM_REPORT_GROUP_SINGLE,
 	DM_REPORT_GROUP_BASIC,
 	DM_REPORT_GROUP_JSON
@@ -3218,7 +3218,7 @@ int dm_report_group_destroy(struct dm_report_group *group);
 #define DM_STATS_REGION_CURRENT UINT64_MAX
 #define DM_STATS_AREA_CURRENT UINT64_MAX
 
-typedef enum {
+typedef enum dm_stats_counter_e {
 	DM_STATS_READS_COUNT,
 	DM_STATS_READS_MERGED_COUNT,
 	DM_STATS_READ_SECTORS_COUNT,
@@ -3305,7 +3305,7 @@ uint64_t dm_stats_get_total_write_nsecs(const struct dm_stats *dms,
  * average_wr_wait_time: the average write wait time
  */
 
-typedef enum {
+typedef enum dm_stats_metric_e {
 	DM_STATS_RD_MERGES_PER_SEC,
 	DM_STATS_WR_MERGES_PER_SEC,
 	DM_STATS_READS_PER_SEC,
@@ -3495,7 +3495,7 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 /*************************
  * config file parse/print
  *************************/
-typedef enum {
+typedef enum dm_config_value_type_e {
 	DM_CFG_INT,
 	DM_CFG_FLOAT,
 	DM_CFG_STRING,
@@ -3505,7 +3505,7 @@ typedef enum {
 struct dm_config_value {
 	dm_config_value_type_t type;
 
-	union {
+	union dm_config_value_u {
 		int64_t i;
 		float f;
 		double d;       	/* Unused. */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index a1c07badd..5433e74ae 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -90,7 +90,7 @@ struct report_group_item {
 	struct dm_list list;
 	struct dm_report_group *group;
 	struct dm_report *report;
-	union {
+	union store_u {
 		uint32_t orig_report_flags;
 		uint32_t finished_count;
 	} store;
@@ -207,7 +207,7 @@ struct selection_str_list {
 };
 
 struct field_selection_value {
-	union {
+	union value_u {
 		const char *s;
 		uint64_t i;
 		time_t t;
@@ -227,7 +227,7 @@ struct field_selection {
 struct selection_node {
 	struct dm_list list;
 	uint32_t type;
-	union {
+	union selection_u {
 		struct field_selection *item;
 		struct dm_list set;
 	} selection;


