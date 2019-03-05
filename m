From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:56 -0500
Subject: stable-2.02 - dm: migration_threshold for old linked tools
Message-ID: <201903051353.x25DrurG006822@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc6ae7030ad3c620fadce2654c106f78a5bc2350
Commit:        bc6ae7030ad3c620fadce2654c106f78a5bc2350
Parent:        167aa349268008b47e333ce9e5423e06bb29d95f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 11:45:27 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 13:01:19 2019 +0100

dm: migration_threshold for old linked tools

Just like with precending  lvm2 device_mapper patch, ensure
that old users of libdm will also get fixed migration threshold
for caches.

(cherry picked from commit 74ae1c5bc1150005ae6e82c90415c433f4a24cbd)

Conflicts:
	WHATS_NEW_DM
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f92e4d8..5d3c9db 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.156 - 
 =====================================
+  Ensure migration_threshold for cache is at least 8 chunks.
   Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a9d71a2..f41a338 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -192,6 +192,7 @@ struct load_segment {
 	uint64_t transaction_id;	/* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool + cache */
+	uint32_t migration_threshold;   /* Cache */
 	unsigned skip_block_zeroing;	/* Thin_pool */
 	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
 	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
@@ -2462,10 +2463,14 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 
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
@@ -3373,6 +3378,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	seg->data_block_size = data_block_size;
 	seg->flags = feature_flags;
 	seg->policy_name = policy_name;
+	seg->migration_threshold = 2048; /* Default migration threshold 1MiB */
 
 	/* FIXME: better validation missing */
 	if (policy_settings) {
@@ -3385,10 +3391,18 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
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
 


