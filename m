From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:25 -0400
Subject: master - device_mapper: basic support for vdo dm target
Message-ID: <201807091334.w69DYP4t030628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8a41f22e9a68b0424ee18b1859fb6369c712622
Commit:        d8a41f22e9a68b0424ee18b1859fb6369c712622
Parent:        0d9a4c69896137f1b440ec6da187387f6394d1fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:08:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

device_mapper: basic support for vdo dm target

---
 device_mapper/Makefile         |    4 +-
 device_mapper/all.h            |    9 ++
 device_mapper/libdm-deptree.c  |  162 ++++++++++++++++++++++++++++++++++++++++
 device_mapper/vdo/target.h     |   40 ++++++++++
 device_mapper/vdo/vdo_target.c |  121 ++++++++++++++++++++++++++++++
 5 files changed, 335 insertions(+), 1 deletions(-)

diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 30717b6..d74a751 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -24,7 +24,9 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/regex/matcher.c \
 	device_mapper/regex/parse_rx.c \
 	device_mapper/regex/ttree.c \
-	device_mapper/ioctl/libdm-iface.c
+	device_mapper/ioctl/libdm-iface.c \
+	device_mapper/vdo/vdo_target.c \
+	device_mapper/vdo/status.c
 
 DEVICE_MAPPER_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(DEVICE_MAPPER_SOURCE)))
 DEVICE_MAPPER_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(DEVICE_MAPPER_SOURCE)))
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 602b7ba..e56bae9 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -19,6 +19,7 @@
 
 #include "base/data-struct/list.h"
 #include "base/data-struct/hash.h"
+#include "vdo/target.h"
 
 #include <inttypes.h>
 #include <stdarg.h>
@@ -914,6 +915,14 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint32_t data_block_size);
 
 /*
+ * VDO target
+ */
+int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
+				uint64_t size,
+				const char *data_uuid,
+				const struct dm_vdo_target_params *param);
+
+/*
  * FIXME Add individual cache policy pairs  <key> = value, like:
  * int dm_tree_node_add_cache_policy_arg(struct dm_tree_node *dnode,
  *				      const char *key, uint64_t value);
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 2dc33ae..f49675c 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -17,6 +17,7 @@
 #include "libdm-common.h"
 #include "misc/kdev_t.h"
 #include "misc/dm-ioctl.h"
+#include "vdo/target.h"
 
 #include <stdarg.h>
 #include <string.h>
@@ -39,6 +40,7 @@ enum {
 	SEG_ZERO,
 	SEG_THIN_POOL,
 	SEG_THIN,
+	SEG_VDO,
 	SEG_RAID0,
 	SEG_RAID0_META,
 	SEG_RAID1,
@@ -77,6 +79,7 @@ static const struct {
 	{ SEG_ZERO, "zero"},
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
+	{ SEG_VDO, "vdo" },
 	{ SEG_RAID0, "raid0"},
 	{ SEG_RAID0_META, "raid0_meta"},
 	{ SEG_RAID1, "raid1"},
@@ -142,6 +145,7 @@ struct thin_message {
 };
 
 /* Per-segment properties */
+// FIXME: use a union to discriminate between target types.
 struct load_segment {
 	struct dm_list list;
 
@@ -200,6 +204,10 @@ struct load_segment {
 	unsigned read_only;		/* Thin pool target vsn 1.3 */
 	uint32_t device_id;		/* Thin */
 
+	// VDO params
+	struct dm_tree_node *vdo_data;  /* VDO */
+	struct dm_vdo_target_params vdo_params; /* VDO */
+	const char *vdo_name;           /* VDO - device name is ALSO passed as table arg */
 };
 
 /* Per-device properties */
@@ -1442,6 +1450,39 @@ out:
 	return r;
 }
 
+static int _vdo_get_status(struct dm_tree_node *dnode,
+			   struct dm_vdo_status_parse_result *s)
+{
+	struct dm_task *dmt;
+	int r = 0;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+
+	if (!(dmt = _dm_task_create_device_status(dnode->info.major,
+						  dnode->info.minor)))
+		return_0;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+
+	if (!type || (strcmp(type, "vdo") != 0)) {
+		log_error("Expected vdo target for %s and got %s.",
+			  _node_name(dnode), type ? : "no target");
+		goto out;
+	}
+
+	log_debug("Parsing VDO status: %s", params);
+
+	if (!dm_vdo_status_parse(NULL, params, s))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 static int _node_message(uint32_t major, uint32_t minor,
 			 int expected_errno, const char *message)
 {
@@ -1587,6 +1628,55 @@ static int _thin_pool_node_send_messages(struct dm_tree_node *dnode,
 	return 1;
 }
 
+static int _vdo_node_send_messages(struct dm_tree_node *dnode,
+				   struct load_segment *seg,
+				   int send)
+{
+	struct dm_vdo_status_parse_result vdo_status;
+	int send_compression_message = 0;
+	int send_deduplication_message = 0;
+	int r = 0;
+
+	if (!_vdo_get_status(dnode, &vdo_status))
+		return_0;
+
+	if (seg->vdo_params.use_compression) {
+		if (vdo_status.status->compression_state == DM_VDO_COMPRESSION_OFFLINE)
+			send_compression_message = 1;
+	} else if (vdo_status.status->compression_state != DM_VDO_COMPRESSION_OFFLINE)
+		send_compression_message = 1;
+
+	if (seg->vdo_params.use_deduplication) {
+		if (vdo_status.status->index_state == DM_VDO_INDEX_OFFLINE)
+			send_deduplication_message = 1;
+	} else if (vdo_status.status->index_state != DM_VDO_INDEX_OFFLINE)
+		send_deduplication_message = 1;
+
+	log_debug("VDO needs message for compression %u(%u) and deduplication %u(%u).",
+		  send_compression_message, vdo_status.status->index_state,
+		  send_deduplication_message, vdo_status.status->compression_state);
+
+	if (send_compression_message &&
+	    !_node_message(dnode->info.major, dnode->info.minor, 0,
+			   seg->vdo_params.use_compression ?
+			   "compression on" : "compression off"))
+		goto_out;
+
+	if (send_deduplication_message &&
+	    !_node_message(dnode->info.major, dnode->info.minor, 0,
+			   seg->vdo_params.use_deduplication ?
+			   "index-enable" : "index-disable"))
+		goto_out;
+
+	r = 1;
+out:
+	free(vdo_status.status->device);
+	free(vdo_status.status);
+
+	return r;
+}
+
+
 static int _node_send_messages(struct dm_tree_node *dnode,
 			       const char *uuid_prefix,
 			       size_t uuid_prefix_len,
@@ -1611,6 +1701,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 
 	switch (seg->type) {
 	case SEG_THIN_POOL: return _thin_pool_node_send_messages(dnode, seg, send);
+	case SEG_VDO:	    return _vdo_node_send_messages(dnode, seg, send);
 	}
 
 	return 1;
@@ -2536,6 +2627,44 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 	return 1;
 }
 
+static int _vdo_emit_segment_line(struct dm_task *dmt,
+				  struct load_segment *seg,
+				  char *params, size_t paramsize)
+{
+	int pos = 0;
+	char data[DM_FORMAT_DEV_BUFSIZE];
+	char data_dev[128]; // for /dev/dm-XXXX
+
+	if (!_build_dev_string(data, sizeof(data), seg->vdo_data))
+		return_0;
+	/* Unlike normal targets, current VDO requires device path */
+	if (dm_snprintf(data_dev, sizeof(data_dev), "/dev/dm-%u", seg->vdo_data->info.minor) < 0) {
+		log_error("Can create VDO data volume path for %s.", data);
+		return_0;
+	}
+
+	EMIT_PARAMS(pos, "%s %u %s " FMTu64 " " FMTu64 " %u on %s %s "
+		    "ack=%u,bio=%u,bioRotationInterval=%u,cpu=%u,hash=%u,logical=%u,physical=%u",
+		    data_dev,
+		    (seg->vdo_params.emulate_512_sectors == 0) ? 4096 : 512,
+		    seg->vdo_params.use_read_cache ? "enabled" : "disabled",
+		    seg->vdo_params.read_cache_size_mb * UINT64_C(256),		// 1MiB -> 4KiB units
+		    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
+		    seg->vdo_params.block_map_period,
+		    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_SYNC) ? "sync" :
+			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" : "auto", // policy
+		    seg->vdo_name,
+		    seg->vdo_params.ack_threads,
+		    seg->vdo_params.bio_threads,
+		    seg->vdo_params.bio_rotation,
+		    seg->vdo_params.cpu_threads,
+		    seg->vdo_params.hash_zone_threads,
+		    seg->vdo_params.logical_threads,
+		    seg->vdo_params.physical_threads);
+
+	return 1;
+}
+
 static int _thin_emit_segment_line(struct dm_task *dmt,
 				   struct load_segment *seg,
 				   char *params, size_t paramsize)
@@ -2599,6 +2728,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_STRIPED:
 		EMIT_PARAMS(pos, "%u %u ", seg->area_count, seg->stripe_size);
 		break;
+	case SEG_VDO:
+		if (!(r = _vdo_emit_segment_line(dmt, seg, params, paramsize)))
+		      return_0;
+		break;
 	case SEG_CRYPT:
 		EMIT_PARAMS(pos, "%s%s%s%s%s %s %" PRIu64 " ", seg->cipher,
 			    seg->chainmode ? "-" : "", seg->chainmode ?: "",
@@ -3893,3 +4026,32 @@ int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 					     policy_name, policy_settings, data_block_size);
 }
 #endif
+
+int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
+				uint64_t size,
+				const char *data_uuid,
+				const struct dm_vdo_target_params *vtp)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_VDO, size)))
+		return_0;
+
+	if (!(seg->vdo_data = dm_tree_find_node_by_uuid(node->dtree, data_uuid))) {
+		log_error("Missing VDO's data uuid %s.", data_uuid);
+		return 0;
+	}
+
+	if (!dm_vdo_validate_target_params(vtp, size))
+		return_0;
+
+	if (!_link_tree_nodes(node, seg->vdo_data))
+		return_0;
+
+	seg->vdo_params = *vtp;
+	seg->vdo_name = node->name;
+
+	node->props.send_messages = 2;
+
+	return 1;
+}
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index 3d8722b..c597491 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -66,6 +66,46 @@ struct dm_pool;
 bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
 			 struct dm_vdo_status_parse_result *result);
 
+enum dm_vdo_write_policy {
+	DM_VDO_WRITE_POLICY_AUTO = 0,
+	DM_VDO_WRITE_POLICY_SYNC,
+	DM_VDO_WRITE_POLICY_ASYNC
+};
+
+// FIXME: review whether we should use the createParams from the userlib
+struct dm_vdo_target_params {
+	uint32_t block_map_cache_size_mb;
+	uint32_t block_map_period;
+
+	uint32_t check_point_frequency;
+	uint32_t index_memory_size_mb;
+
+	uint32_t read_cache_size_mb;
+
+	uint32_t slab_size_mb;
+
+	// threads
+	uint32_t ack_threads;
+	uint32_t bio_threads;
+	uint32_t bio_rotation;
+	uint32_t cpu_threads;
+	uint32_t hash_zone_threads;
+	uint32_t logical_threads;
+	uint32_t physical_threads;
+
+	bool use_compression;
+	bool use_deduplication;
+	bool emulate_512_sectors;
+	bool use_sparse_index;
+	bool use_read_cache;
+
+	// write policy
+	enum dm_vdo_write_policy write_policy;
+};
+
+bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
+				   uint64_t vdo_size);
+
 //----------------------------------------------------------------
 
 #endif
diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
new file mode 100644
index 0000000..c488023
--- /dev/null
+++ b/device_mapper/vdo/vdo_target.c
@@ -0,0 +1,121 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "device_mapper/misc/dmlib.h"
+#include "device_mapper/all.h"
+
+#include "vdo_limits.h"
+#include "target.h"
+
+bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
+				   uint64_t vdo_size)
+{
+	bool valid = true;
+
+	if ((vtp->block_map_cache_size_mb < DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB) ||
+	    (vtp->block_map_cache_size_mb > DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB)) {
+		log_error("VDO block map cache size %u out of range.",
+			  vtp->block_map_cache_size_mb);
+		valid = false;
+	}
+
+	if ((vtp->index_memory_size_mb < DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB) ||
+	    (vtp->index_memory_size_mb > DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB)) {
+		log_error("VDO index memory size %u out of range.",
+			  vtp->index_memory_size_mb);
+		valid = false;
+	}
+
+	if (vtp->read_cache_size_mb > DM_VDO_READ_CACHE_SIZE_MAXIMUM_MB) {
+		log_error("VDO read cache size %u out of range.",
+			  vtp->read_cache_size_mb);
+		valid = false;
+	}
+
+	if ((vtp->slab_size_mb < DM_VDO_SLAB_SIZE_MINIMUM_MB) ||
+	    (vtp->slab_size_mb > DM_VDO_SLAB_SIZE_MAXIMUM_MB)) {
+		log_error("VDO slab size %u out of range.",
+			  vtp->slab_size_mb);
+		valid = false;
+	}
+
+	if (vtp->ack_threads > DM_VDO_ACK_THREADS_MAXIMUM) {
+		log_error("VDO ack threads %u out of range.", vtp->ack_threads);
+		valid = false;
+	}
+
+	if ((vtp->bio_threads < DM_VDO_BIO_THREADS_MINIMUM) ||
+	    (vtp->bio_threads > DM_VDO_BIO_THREADS_MAXIMUM)) {
+		log_error("VDO bio threads %u out of range.", vtp->bio_threads);
+		valid = false;
+	}
+
+	if ((vtp->bio_rotation < DM_VDO_BIO_ROTATION_MINIMUM) ||
+	    (vtp->bio_rotation > DM_VDO_BIO_ROTATION_MAXIMUM)) {
+		log_error("VDO bio rotation %u out of range.", vtp->bio_rotation);
+		valid = false;
+	}
+
+	if ((vtp->cpu_threads < DM_VDO_CPU_THREADS_MINIMUM) ||
+	    (vtp->cpu_threads > DM_VDO_CPU_THREADS_MAXIMUM)) {
+		log_error("VDO cpu threads %u out of range.", vtp->cpu_threads);
+		valid = false;
+	}
+
+	if (vtp->hash_zone_threads > DM_VDO_HASH_ZONE_THREADS_MAXIMUM) {
+		log_error("VDO hash zone threads %u out of range.", vtp->hash_zone_threads);
+		valid = false;
+	}
+
+	if (vtp->logical_threads > DM_VDO_LOGICAL_THREADS_MAXIMUM) {
+		log_error("VDO logical threads %u out of range.", vtp->logical_threads);
+		valid = false;
+	}
+
+	if (vtp->physical_threads > DM_VDO_PHYSICAL_THREADS_MAXIMUM) {
+		log_error("VDO physical threads %u out of range.", vtp->physical_threads);
+		valid = false;
+	}
+
+	switch (vtp->write_policy) {
+	case DM_VDO_WRITE_POLICY_SYNC:
+	case DM_VDO_WRITE_POLICY_ASYNC:
+	case DM_VDO_WRITE_POLICY_AUTO:
+		break;
+	default:
+		log_error(INTERNAL_ERROR "VDO write policy %u is unknown.", vtp->write_policy);
+		valid = false;
+	}
+
+	if ((vtp->hash_zone_threads ||
+	     vtp->logical_threads ||
+	     vtp->physical_threads) &&
+	    (!vtp->hash_zone_threads ||
+	     !vtp->logical_threads ||
+	     !vtp->physical_threads)) {
+		log_error("Value of vdo_hash_zone_threads(%u), vdo_logical_threads(%u), "
+			  "vdo_physical_threads(%u) must be all zero or all non-zero.",
+			  vtp->hash_zone_threads, vtp->logical_threads, vtp->physical_threads);
+		valid = false;
+	}
+
+	if (vdo_size >= (DM_VDO_LOGICAL_SIZE_MAXIMUM_MB * UINT64_C(1024 * 2))) {
+		log_error("VDO logical size is by " FMTu64 "KiB bigger then limit " FMTu64 "TiB.",
+			  (vdo_size - (DM_VDO_LOGICAL_SIZE_MAXIMUM_MB * UINT64_C(1024 * 2))) / 2,
+			  DM_VDO_LOGICAL_SIZE_MAXIMUM_MB / UINT64_C(1024) / UINT64_C(1024));
+		valid = false;
+	}
+
+	return valid;
+}


