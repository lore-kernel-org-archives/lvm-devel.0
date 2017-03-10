From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:51 -0500
Subject: master - libdm: support cache metadata2 feature flag
Message-ID: <201703101836.v2AIapjw004671@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddd5a7680153486c4edebb8a7946827e7abe93a0
Commit:        ddd5a7680153486c4edebb8a7946827e7abe93a0
Parent:        bf79fb1a337b707ae6d44e42c7b43c62cfac2bdd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 23:38:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

libdm: support cache metadata2 feature flag

Dm cache target version 1.10 introduces new cache metadata format
(upstream kernel >=4.11).

New format is enable by passing new target feature flag metadata2.
Interace side on libdm uses DM_CACHE_FEATURE_METADATA2.
This feature bit is now also recognized on status
and set in 'feature_flags' field of dm_status_cache structure.

Code also adds check for 'highest' supported feature flag bit.
So it rejects properly any 'unknown' feature bit set by application.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    3 ++-
 libdm/libdm-deptree.c |   22 +++++++++++++++++-----
 libdm/libdm-targets.c |    2 ++
 4 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4056854..6a56b3d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Support DM_CACHE_FEATURE_METADATA2, new cache metadata format 2.
   Improve code to handle mode mask for cache nodes.
   Cache status check for passthrough also require trailing space.
   Add extra memory page when limiting pthread stack size in dmeventd.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 42f9229..9e0a837 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -359,7 +359,7 @@ struct dm_status_cache {
 	uint64_t demotions;
 	uint64_t promotions;
 
-	uint64_t feature_flags;
+	uint64_t feature_flags;		/* DM_CACHE_FEATURE_? */
 
 	int core_argc;
 	char **core_argv;
@@ -1886,6 +1886,7 @@ int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
 #define DM_CACHE_FEATURE_PASSTHROUGH  0x00000004
+#define DM_CACHE_FEATURE_METADATA2    0x00000008 /* cache v1.10 */
 
 struct dm_config_node;
 /*
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5ec20a6..ea8d5ef 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2514,12 +2514,17 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	/* Features */
 	/* feature_count = hweight32(seg->flags); */
 	/* EMIT_PARAMS(pos, " %u", feature_count); */
+	if (seg->flags & DM_CACHE_FEATURE_METADATA2)
+		EMIT_PARAMS(pos, " 2 metadata2 ");
+	else
+		EMIT_PARAMS(pos, " 1 ");
+
 	if (seg->flags & DM_CACHE_FEATURE_PASSTHROUGH)
-		EMIT_PARAMS(pos, " 1 passthrough");
-	else if (seg->flags & DM_CACHE_FEATURE_WRITETHROUGH)
-		EMIT_PARAMS(pos, " 1 writethrough");
-	else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
-		EMIT_PARAMS(pos, " 1 writeback");
+		EMIT_PARAMS(pos, "passthrough");
+        else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
+		EMIT_PARAMS(pos, "writeback");
+	else
+		EMIT_PARAMS(pos, "writethrough");
 
 	/* Cache Policy */
 	name = seg->policy_name ? : "default";
@@ -3403,6 +3408,13 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 		DM_CACHE_FEATURE_WRITETHROUGH |
 		DM_CACHE_FEATURE_WRITEBACK;
 
+	/* Detect unknown (bigger) feature bit */
+	if (feature_flags >= (DM_CACHE_FEATURE_METADATA2 * 2)) {
+		log_error("Unsupported cache's feature flags set " FMTu64 ".",
+			  feature_flags);
+		return 0;
+	}
+
 	switch (feature_flags & _modemask) {
 	case DM_CACHE_FEATURE_PASSTHROUGH:
 	case DM_CACHE_FEATURE_WRITEBACK:
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 8c98790..f44abfd 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -276,6 +276,8 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			s->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
 		else if (!strncmp(p, "passthrough ", 12))
 			s->feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
+		else if (!strncmp(p, "metadata2 ", 10))
+			s->feature_flags |= DM_CACHE_FEATURE_METADATA2;
 		else
 			log_error("Unknown feature in status: %s", params);
 


