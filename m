From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:47 -0500
Subject: master - libdm: better code to enforce writethrough
Message-ID: <201703101836.v2AIaldb028672@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf79fb1a337b707ae6d44e42c7b43c62cfac2bdd
Commit:        bf79fb1a337b707ae6d44e42c7b43c62cfac2bdd
Parent:        edf5e43f9ad6bdd5f3066f92e12a7f3c60dd656a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 23:35:40 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

libdm: better code to enforce writethrough

Better code to enforce writethrough caching for cleaner policy.
Only check for cleaner when DM_CACHE_FEATURE_PASSTHROUGH or
DM_CACHE_FEATURE_WRITEBACK is set.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   36 +++++++++++++++++++++---------------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index bfa6d55..4056854 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Improve code to handle mode mask for cache nodes.
   Cache status check for passthrough also require trailing space.
   Add extra memory page when limiting pthread stack size in dmeventd.
   Avoids immediate resume when preloaded device is smaller.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a78fbcc..5ec20a6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3398,19 +3398,26 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 {
 	struct dm_config_node *cn;
 	struct load_segment *seg;
-
-	switch (feature_flags &
-		(DM_CACHE_FEATURE_PASSTHROUGH |
-		 DM_CACHE_FEATURE_WRITETHROUGH |
-		 DM_CACHE_FEATURE_WRITEBACK)) {
-		 case DM_CACHE_FEATURE_PASSTHROUGH:
-		 case DM_CACHE_FEATURE_WRITETHROUGH:
-		 case DM_CACHE_FEATURE_WRITEBACK:
-			 break;
-		 default:
-			 log_error("Invalid cache's feature flag " FMTu64 ".",
-				   feature_flags);
-			 return 0;
+	static const uint64_t _modemask =
+		DM_CACHE_FEATURE_PASSTHROUGH |
+		DM_CACHE_FEATURE_WRITETHROUGH |
+		DM_CACHE_FEATURE_WRITEBACK;
+
+	switch (feature_flags & _modemask) {
+	case DM_CACHE_FEATURE_PASSTHROUGH:
+	case DM_CACHE_FEATURE_WRITEBACK:
+		if (strcmp(policy_name, "cleaner") == 0) {
+			/* Enforce writethrough mode for cleaner policy */
+			feature_flags = ~_modemask;
+			feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+		}
+                /* Fall through */
+	case DM_CACHE_FEATURE_WRITETHROUGH:
+		break;
+	default:
+		log_error("Invalid cache's feature flag " FMTu64 ".",
+			  feature_flags);
+		return 0;
 	}
 
 	if (data_block_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) {
@@ -3456,8 +3463,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 		return_0;
 
 	seg->data_block_size = data_block_size;
-	/* Enforce WriteThough mode for cleaner policy */
-	seg->flags = (strcmp(policy_name, "cleaner") == 0) ? DM_CACHE_FEATURE_WRITETHROUGH : feature_flags;
+	seg->flags = feature_flags;
 	seg->policy_name = policy_name;
 
 	/* FIXME: better validation missing */


