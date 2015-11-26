From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 08:48:44 +0000 (UTC)
Subject: master - libdm: const raid params and error for unsupported type
Message-ID: <20151126084844.ABC0D60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d582be43d4cee8c74ee4e251d299a321ded474fa
Commit:        d582be43d4cee8c74ee4e251d299a321ded474fa
Parent:        1ea8afd3caa54259e58d8e3443389c819281c8c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 26 09:18:46 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 09:27:04 2015 +0100

libdm: const raid params and error for unsupported type

Accept const struct with raid params (No API change).
Also add extra error message when raid type is unsupported.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    2 +-
 libdm/libdm-deptree.c |    8 +++++---
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 600c5b7..a510938 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.112 - 
 =====================================
+  Show error message when trying to create unsupported raid type.
   Improve preloading sequence of an active thin-pool target.
   Drop extra space from cache target line to fix unneded table reloads.
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 6619aa7..310ceb7 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1441,7 +1441,7 @@ struct dm_tree_node_raid_params {
 
 int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 					     uint64_t size,
-					     struct dm_tree_node_raid_params *p);
+					     const struct dm_tree_node_raid_params *p);
 
 /* Cache feature_flags */
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 0b33ad3..73f2e4c 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3207,7 +3207,7 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 
 int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 					     uint64_t size,
-					     struct dm_tree_node_raid_params *p)
+					     const struct dm_tree_node_raid_params *p)
 {
 	unsigned i;
 	struct load_segment *seg = NULL;
@@ -3217,8 +3217,10 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 			if (!(seg = _add_segment(node,
 						 _dm_segtypes[i].type, size)))
 				return_0;
-	if (!seg)
-		return_0;
+	if (!seg) {
+		log_error("Unsupported raid type %s.", p->raid_type);
+		return 0;
+	}
 
 	seg->region_size = p->region_size;
 	seg->stripe_size = p->stripe_size;


