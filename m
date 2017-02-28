From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Feb 2017 16:40:55 -0500
Subject: master - lvconvert: libdm RAID API compatibility versioning
Message-ID: <201702282140.v1SLetfe017546@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80a6de616a19e1be2e4125878ee904e5a1eeedf9
Commit:        80a6de616a19e1be2e4125878ee904e5a1eeedf9
Parent:        21456dcf7fc062518202f133ad27594eda4278fb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 28 22:34:00 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 28 22:34:00 2017 +0100

lvconvert: libdm RAID API compatibility versioning

Commit 27384c52cf6a lowered the maximum number of devices
back to 64 for compatibility.

Because more members have been added to the API in
'struct dm_tree_node_raid_params *', we have to version
the public libdm RAID API to not break any existing users.

Changes:

- keep the previous 'struct dm_tree_node_raid_params' and
  dm_tree_node_add_raid_target_with_params()/dm_tree_node_add_raid_target()
  in order to expose the already released public RAID API

- introduce 'struct dm_tree_node_raid_params_v2' and additional functions
  dm_tree_node_add_raid_target_with_params_v2()/dm_tree_node_add_raid_target_v2()
  to be used by the new lvm2 lib reshape extentions

With this new API, the bitfields for rebuild/writemostly legs in
'struct dm_tree_node_raid_params_v2' can be raised to 256 bits
again (253 legs maximum supported in MD kernel).

Mind that we can limit the maximum usable number via the
DEFAULT_RAID{1}_MAX_IMAGES definition in defaults.h.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/raid/raid.c                     |    4 +-
 libdm/.exported_symbols.DM_1_02_138 |    2 +
 libdm/libdevmapper.h                |   63 +++++++++++++++++++++++++-----
 libdm/libdm-deptree.c               |   73 +++++++++++++++++++++++++++++++---
 4 files changed, 123 insertions(+), 19 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 59db437..9ab2e6c 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -242,7 +242,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	uint64_t flags = 0;
 	uint64_t rebuilds[RAID_BITMAP_SIZE];
 	uint64_t writemostly[RAID_BITMAP_SIZE];
-	struct dm_tree_node_raid_params params;
+	struct dm_tree_node_raid_params_v2 params;
 
 	memset(&params, 0, sizeof(params));
 	memset(&rebuilds, 0, sizeof(rebuilds));
@@ -333,7 +333,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	params.stripe_size = seg->stripe_size;
 	params.flags = flags;
 
-	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
+	if (!dm_tree_node_add_raid_target_with_params_v2(node, len, &params))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 3ebc59d..43e4111 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -3,3 +3,5 @@ dm_bit_get_prev
 dm_stats_update_regions_from_fd
 dm_bitset_parse_list
 dm_stats_bind_from_fd
+dm_tree_node_add_raid_target_v2
+dm_tree_node_add_raid_target_with_params_v2
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7136261..b515f6d 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2006 Rackable Systems All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
@@ -1720,9 +1720,18 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t *rebuilds,
+				 uint64_t rebuilds,
 				 uint64_t flags);
 
+/* Version 2 coping with 253 (MD kernel limitation) devices */
+int dm_tree_node_add_raid_target_v2(struct dm_tree_node *node,
+				    uint64_t size,
+				    const char *raid_type,
+				    uint32_t region_size,
+				    uint32_t stripe_size,
+				    uint64_t *rebuilds,
+				    uint64_t flags);
+
 /*
  * Defines below are based on kernel's dm-cache.c defines
  * DM_CACHE_MIN_DATA_BLOCK_SIZE (32 * 1024 >> SECTOR_SHIFT)
@@ -1742,13 +1751,7 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 /*
  * Define number of elements in rebuild and writemostly arrays
  * 'of struct dm_tree_node_raid_params'.
- *
- * Set to one to keep the current libdm API!
- *
- * If we ever raise the maximum number of RAID devices past 64 thus
- * changing the API, we have to version it for backwards API compatibility.
  */
-#define	RAID_BITMAP_SIZE 1
 
 struct dm_tree_node_raid_params {
 	const char *raid_type;
@@ -1758,6 +1761,42 @@ struct dm_tree_node_raid_params {
 	uint32_t region_size;
 	uint32_t stripe_size;
 
+	/*
+	 * 'rebuilds' and 'writemostly' are bitfields that signify
+	 * which devices in the array are to be rebuilt or marked
+	 * writemostly.  The kernel supports up to 253 legs.
+	 * We limit ourselves by choosing a lower value
+	 * for DEFAULT_RAID{1}_MAX_IMAGES in defaults.h.
+	 */
+	uint64_t rebuilds;
+	uint64_t writemostly;
+	uint32_t writebehind;	    /* I/Os (kernel default COUNTER_MAX / 2) */
+	uint32_t sync_daemon_sleep; /* ms (kernel default = 5sec) */
+	uint32_t max_recovery_rate; /* kB/sec/disk */
+	uint32_t min_recovery_rate; /* kB/sec/disk */
+	uint32_t stripe_cache;      /* sectors */
+
+	uint64_t flags;             /* [no]sync */
+	uint32_t reserved2;
+};
+
+/*
+ * Version 2 of above node raid params struct to keeep API compatibility.
+ *
+ * Extended for more than 64 legs (max 253 in the MD kernel runtime!),
+ * delta_disks for disk add/remove reshaping,
+ * data_offset for out-of-place reshaping
+ * and data_copies for odd number of raid10 legs.
+ */
+#define	RAID_BITMAP_SIZE 4 /* 4 * 64 bit elements in rebuilds/writemostly arrays */
+struct dm_tree_node_raid_params_v2 {
+	const char *raid_type;
+
+	uint32_t stripes;
+	uint32_t mirrors;
+	uint32_t region_size;
+	uint32_t stripe_size;
+
 	int delta_disks; /* +/- number of disks to add/remove (reshaping) */
 	int data_offset; /* data offset to set (out-of-place reshaping) */
 
@@ -1771,20 +1810,24 @@ struct dm_tree_node_raid_params {
 	uint64_t rebuilds[RAID_BITMAP_SIZE];
 	uint64_t writemostly[RAID_BITMAP_SIZE];
 	uint32_t writebehind;	    /* I/Os (kernel default COUNTER_MAX / 2) */
+	uint32_t data_copies;	    /* RAID # of data copies */
 	uint32_t sync_daemon_sleep; /* ms (kernel default = 5sec) */
 	uint32_t max_recovery_rate; /* kB/sec/disk */
 	uint32_t min_recovery_rate; /* kB/sec/disk */
-	uint32_t data_copies;	    /* RAID # of data copies */
 	uint32_t stripe_cache;      /* sectors */
 
 	uint64_t flags;             /* [no]sync */
-	uint64_t reserved2;
 };
 
 int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 					     uint64_t size,
 					     const struct dm_tree_node_raid_params *p);
 
+/* Version 2 API function taking dm_tree_node_raid_params_v2 for aforementioned extensions. */
+int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
+						uint64_t size,
+						const struct dm_tree_node_raid_params_v2 *p);
+
 /* Cache feature_flags */
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a26cfcc..79117d2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3314,14 +3314,13 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 	seg->region_size = p->region_size;
 	seg->stripe_size = p->stripe_size;
 	seg->area_count = 0;
-	seg->delta_disks = p->delta_disks;
-	seg->data_offset = p->data_offset;
-	memcpy(seg->rebuilds, p->rebuilds, sizeof(seg->rebuilds));
-	memcpy(seg->writemostly, p->writemostly, sizeof(seg->writemostly));
+	memset(seg->rebuilds, 0, sizeof(seg->rebuilds));
+	seg->rebuilds[0] = p->rebuilds;
+	memset(seg->writemostly, 0, sizeof(seg->writemostly));
+	seg->writemostly[0] = p->writemostly;
 	seg->writebehind = p->writebehind;
 	seg->min_recovery_rate = p->min_recovery_rate;
 	seg->max_recovery_rate = p->max_recovery_rate;
-	seg->data_copies = p->data_copies;
 	seg->flags = p->flags;
 
 	return 1;
@@ -3332,19 +3331,79 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t *rebuilds,
+				 uint64_t rebuilds,
 				 uint64_t flags)
 {
 	struct dm_tree_node_raid_params params = {
 		.raid_type = raid_type,
 		.region_size = region_size,
 		.stripe_size = stripe_size,
+		.rebuilds = rebuilds,
+		.flags = flags
+	};
+
+	return dm_tree_node_add_raid_target_with_params(node, size, &params);
+}
+
+/*
+ * Version 2 of dm_tree_node_add_raid_target() allowing for:
+ *
+ * - maximum 253 legs in a raid set (MD kernel limitation)
+ * - delta_disks for disk add/remove reshaping
+ * - data_offset for out-of-place reshaping
+ * - data_copies to cope witth odd numbers of raid10 disks
+ */
+int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
+					        uint64_t size,
+						const struct dm_tree_node_raid_params_v2 *p)
+{
+	unsigned i;
+	struct load_segment *seg = NULL;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_dm_segtypes) && !seg; ++i)
+		if (!strcmp(p->raid_type, _dm_segtypes[i].target))
+			if (!(seg = _add_segment(node,
+						 _dm_segtypes[i].type, size)))
+				return_0;
+	if (!seg) {
+		log_error("Unsupported raid type %s.", p->raid_type);
+		return 0;
+	}
+
+	seg->region_size = p->region_size;
+	seg->stripe_size = p->stripe_size;
+	seg->area_count = 0;
+	seg->delta_disks = p->delta_disks;
+	seg->data_offset = p->data_offset;
+	memcpy(seg->rebuilds, p->rebuilds, sizeof(seg->rebuilds));
+	memcpy(seg->writemostly, p->writemostly, sizeof(seg->writemostly));
+	seg->writebehind = p->writebehind;
+	seg->data_copies = p->data_copies;
+	seg->min_recovery_rate = p->min_recovery_rate;
+	seg->max_recovery_rate = p->max_recovery_rate;
+	seg->flags = p->flags;
+
+	return 1;
+}
+
+int dm_tree_node_add_raid_target_v2(struct dm_tree_node *node,
+				    uint64_t size,
+				    const char *raid_type,
+				    uint32_t region_size,
+				    uint32_t stripe_size,
+				    uint64_t *rebuilds,
+				    uint64_t flags)
+{
+	struct dm_tree_node_raid_params_v2 params = {
+		.raid_type = raid_type,
+		.region_size = region_size,
+		.stripe_size = stripe_size,
 		.flags = flags
 	};
 
 	memcpy(params.rebuilds, rebuilds, sizeof(params.rebuilds));
 
-	return dm_tree_node_add_raid_target_with_params(node, size, &params);
+	return dm_tree_node_add_raid_target_with_params_v2(node, size, &params);
 }
 
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,


