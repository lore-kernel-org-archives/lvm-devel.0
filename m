From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:16 -0500
Subject: master - dm: ensure migration_threshold is big enough
Message-ID: <201901211155.x0LBtGb9024445@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30a3dda9d60ad0d53c1cff361bdd7af540790d5c
Commit:        30a3dda9d60ad0d53c1cff361bdd7af540790d5c
Parent:        9a0535e354d3027ec085d802ac6d016fec17ec75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 11:45:10 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:48:50 2019 +0100

dm: ensure migration_threshold is big enough

When using caches with BIG pool size (>TB) there is required
to use relatively huge chunk size.  Once the chunksize has
got over 1MiB - kernel cache target stopped writing such chunks
back on this if the migration_threshold remained on default 1MiB
(2048 sectors) size.

This patch ensure, DM layer will not let pass table line which
has not big enough migration threshold that can let pass
at least 8 chunks (independently of lvm2 metadata).
---
 WHATS_NEW                     |    1 +
 device_mapper/libdm-deptree.c |   20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 74def38..c8ea3d4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Ensure migration_threshold for cache is at least 8 chunks.
   Restore missing man info lvcreate --zero for thin-pools.
   Drop misleadning comment for metadata minimum_io_size for VDO segment.
   Add device hints to reduce scanning.
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 91ccdd4..4c030fc 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -203,6 +203,7 @@ struct load_segment {
 	uint64_t transaction_id;	/* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool + cache */
+	uint32_t migration_threshold;   /* Cache */
 	unsigned skip_block_zeroing;	/* Thin_pool */
 	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
 	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
@@ -2610,10 +2611,14 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 
 	EMIT_PARAMS(pos, " %s", name);
 
-	EMIT_PARAMS(pos, " %u", seg->policy_argc * 2);
+	/* Do not pass migration_threshold 2048 which is default */
+	EMIT_PARAMS(pos, " %u", (seg->policy_argc + (seg->migration_threshold != 2048) ? 1 : 0) * 2);
+	if (seg->migration_threshold != 2048)
+		    EMIT_PARAMS(pos, " migration_threshold %u", seg->migration_threshold);
 	if (seg->policy_settings)
 		for (cn = seg->policy_settings->child; cn; cn = cn->sib)
-			EMIT_PARAMS(pos, " %s %" PRIu64, cn->key, cn->v->v.i);
+			if (cn->v) /* Skip deleted entry */
+				EMIT_PARAMS(pos, " %s %" PRIu64, cn->key, cn->v->v.i);
 
 	return 1;
 }
@@ -3665,6 +3670,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	seg->data_block_size = data_block_size;
 	seg->flags = feature_flags;
 	seg->policy_name = policy_name;
+	seg->migration_threshold = 2048; /* Default migration threshold 1MiB */
 
 	/* FIXME: better validation missing */
 	if (policy_settings) {
@@ -3677,10 +3683,18 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				log_error("Cache policy parameter %s is without integer value.", cn->key);
 				return 0;
 			}
-			seg->policy_argc++;
+			if (strcmp(cn->key, "migration_threshold") == 0) {
+				seg->migration_threshold = cn->v->v.i;
+				cn->v = NULL; /* skip this entry */
+			} else
+				seg->policy_argc++;
 		}
 	}
 
+	/* Always some throughput available for cache to proceed */
+	if (seg->migration_threshold < data_block_size * 8)
+		seg->migration_threshold = data_block_size * 8;
+
 	return 1;
 }
 


