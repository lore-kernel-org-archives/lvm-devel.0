From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 08:53:49 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110929085349.14351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 08:53:49

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add supporting function for thinp
	
	New dm_tree_node_add_thin_pool_target() and  dm_tree_node_add_thin_target()
	This API is highly experimental and unstable for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.507&r2=1.508
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW_DM	2011/09/25 19:38:59	1.507
+++ LVM2/WHATS_NEW_DM	2011/09/29 08:53:48	1.508
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add functions to support thin provisioning target (API unstable).
   Improve libdm-config error path reporting.
   Update dmsetup resume man with --addnodeonresume/create options.
   Add dependency for dm man pages to man subdirectory make target all:.
--- LVM2/libdm/libdevmapper.h	2011/09/22 17:36:50	1.153
+++ LVM2/libdm/libdevmapper.h	2011/09/29 08:53:48	1.154
@@ -535,6 +535,22 @@
 					   uint32_t slog_region_size);
 /* End of Replicator API */
 
+/* API for thin provisioning is experimental, DO NOT USE. */
+int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
+				      uint64_t size,
+				      uint64_t transation_id,
+				      const char *pool_uuid,
+				      const char *metadata_uuid,
+				      uint32_t data_block_size,
+				      uint64_t low_water_mark,
+				      unsigned skip_block_zeroeing); /* Maybe separate _set_ call ? */
+
+int dm_tree_node_add_thin_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 uint64_t transation_id,
+				 const char *thin_pool_uuid,
+				 uint32_t device_id);
+
 void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
 				      struct dm_tree_node *presuspend_node);
 
--- LVM2/libdm/libdm-deptree.c	2011/09/29 08:50:54	1.114
+++ LVM2/libdm/libdm-deptree.c	2011/09/29 08:53:48	1.115
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -29,6 +29,12 @@
 
 #define REPLICATOR_LOCAL_SITE 0
 
+#define THIN_MIN_DATA_SIZE 128
+#define THIN_MAX_DATA_SIZE 2097152
+#define THIN_MAX_DEVICE_ID ((1 << 24) - 1)
+
+#define QUOTE(x) #x
+
 /* Supported segment types */
 enum {
 	SEG_CRYPT,
@@ -42,6 +48,8 @@
 	SEG_SNAPSHOT_MERGE,
 	SEG_STRIPED,
 	SEG_ZERO,
+	SEG_THIN_POOL,
+	SEG_THIN,
 	SEG_RAID1,
 	SEG_RAID4,
 	SEG_RAID5_LA,
@@ -71,6 +79,8 @@
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
+	{ SEG_THIN_POOL, "thin-pool"},
+	{ SEG_THIN, "thin"},
 	{ SEG_RAID1, "raid1"},
 	{ SEG_RAID4, "raid4"},
 	{ SEG_RAID5_LA, "raid5_la"},
@@ -156,6 +166,14 @@
 	uint64_t rdevice_index;		/* Replicator-dev */
 
 	uint64_t rebuilds;	      /* raid */
+
+	struct dm_tree_node *metadata;	/* Thin_pool */
+	struct dm_tree_node *pool;	/* Thin_pool, Thin */
+	uint32_t data_block_size;       /* Thin_pool */
+	uint64_t low_water_mark;	/* Thin_pool */
+	unsigned skip_block_zeroeing;	/* Thin_pool */
+	uint32_t device_id;		/* Thin */
+
 };
 
 /* Per-device properties */
@@ -1825,6 +1843,7 @@
 	int r;
 	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
+	char pool[DM_FORMAT_DEV_BUFSIZE], metadata[DM_FORMAT_DEV_BUFSIZE];
 
 	switch(seg->type) {
 	case SEG_ERROR:
@@ -1892,6 +1911,20 @@
 			return_0;
 
 		break;
+	case SEG_THIN_POOL:
+		if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
+			return_0;
+		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+			return_0;
+		EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %s", metadata, pool,
+			    seg->data_block_size, seg->low_water_mark,
+			    seg->skip_block_zeroeing ? "1 skip_block_zeroing" : "");
+		break;
+	case SEG_THIN:
+		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+			return_0;
+		EMIT_PARAMS(pos, "%s %d", pool, seg->device_id);
+		break;
 	}
 
 	switch(seg->type) {
@@ -1901,6 +1934,8 @@
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_SNAPSHOT_MERGE:
 	case SEG_ZERO:
+	case SEG_THIN_POOL:
+	case SEG_THIN:
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
@@ -2602,6 +2637,85 @@
 	return 1;
 }
 
+int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
+				      uint64_t size,
+				      uint64_t transation_id,
+				      const char *pool_uuid,
+				      const char *metadata_uuid,
+				      uint32_t data_block_size,
+				      uint64_t low_water_mark,
+				      unsigned skip_block_zeroeing)
+{
+	struct load_segment *seg;
+
+	if (data_block_size < THIN_MIN_DATA_SIZE) {
+		log_error("Data block size %d is lower then "
+			  QUOTE(THIN_MIN_DATA_SIZE) " sectors.",
+			  data_block_size);
+		return 0;
+	}
+
+	if (data_block_size > THIN_MAX_DATA_SIZE) {
+		log_error("Data block size %d is higher then "
+			  QUOTE(THIN_MAX_DATA_SIZE) " sectors.",
+			  data_block_size);
+		return 0;
+	}
+
+	if (!(seg = _add_segment(node, SEG_THIN_POOL, size)))
+		return_0;
+
+	if (!(seg->metadata = dm_tree_find_node_by_uuid(node->dtree, metadata_uuid))) {
+		log_error("Missing metadata uuid %s.", metadata_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, seg->metadata))
+		return_0;
+
+	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, pool_uuid))) {
+		log_error("Missing pool uuid %s.", pool_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, seg->pool))
+		return_0;
+
+	seg->data_block_size = data_block_size;
+	seg->low_water_mark = low_water_mark;
+	seg->skip_block_zeroeing = skip_block_zeroeing;
+
+	return 1;
+}
+
+int dm_tree_node_add_thin_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 uint64_t transation_id,
+				 const char *thin_pool_uuid,
+				 uint32_t device_id)
+{
+	struct load_segment *seg;
+
+	if (device_id > THIN_MAX_DEVICE_ID) {
+		log_error("Device id %d is higher then " QUOTE(THIN_MAX_DEVICE_ID) ".",
+			  device_id);
+		return 0;
+	}
+
+	if (!(seg = _add_segment(node, SEG_THIN, size)))
+		return_0;
+
+	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, thin_pool_uuid))) {
+		log_error("Missing thin pool uuid %s.", thin_pool_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, seg->pool))
+		return_0;
+
+	return 1;
+}
+
 static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct dm_tree_node *dev_node, uint64_t offset)
 {
 	struct seg_area *area;


