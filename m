From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:12 +0000 (UTC)
Subject: master - libdm: cache target arg validation
Message-ID: <20150812124112.BCF8660072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08f047eb51375f6b96b0612e766cc9e0edae6ca0
Commit:        08f047eb51375f6b96b0612e766cc9e0edae6ca0
Parent:        9edd2258ffc7ae7593a6e193760861090d0fb273
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 11 13:31:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:15 2015 +0200

libdm: cache target arg validation

Add some arg validation for dm_tree_node_add_cache_target().
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e857241..a72d3e0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.105 - 
 ===================================
+  Add more arg validation for dm_tree_node_add_cache_target().
 
 Version 1.02.104 - 10th August 2015
 ===================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 36befff..bbbd2d8 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3358,6 +3358,32 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	struct dm_config_node *cn;
 	struct load_segment *seg;
 
+	switch (feature_flags &
+		(DM_CACHE_FEATURE_PASSTHROUGH |
+		 DM_CACHE_FEATURE_WRITETHROUGH |
+		 DM_CACHE_FEATURE_WRITEBACK)) {
+		 case DM_CACHE_FEATURE_PASSTHROUGH:
+		 case DM_CACHE_FEATURE_WRITETHROUGH:
+		 case DM_CACHE_FEATURE_WRITEBACK:
+			 break;
+		 default:
+			 log_error("Invalid cache's feature flag " FMTu64 ".",
+				   feature_flags);
+			 return 0;
+	}
+
+	if (data_block_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) {
+		log_error("Data block size %u is lower then %u sectors.",
+			  data_block_size, DM_CACHE_MIN_DATA_BLOCK_SIZE);
+		return 0;
+	}
+
+	if (data_block_size > DM_CACHE_MAX_DATA_BLOCK_SIZE) {
+		log_error("Data block size %u is higher then %u sectors.",
+			  data_block_size, DM_CACHE_MAX_DATA_BLOCK_SIZE);
+		return 0;
+	}
+
 	if (!(seg = _add_segment(node, SEG_CACHE, size)))
 		return_0;
 


