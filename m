From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:51 +0000 (UTC)
Subject: master - activation: add _add_layer_target_to_dtree
Message-ID: <20130223094151.0D3B940A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0631d233d84cc451380155b8062bd37c6f22c2f7
Commit:        0631d233d84cc451380155b8062bd37c6f22c2f7
Parent:        520cc9a7f86282a230d8e6eef0edcac9dd94a8cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 21 10:24:28 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:29:08 2013 +0100

activation: add _add_layer_target_to_dtree

Add function for creation of simple linear mapping over layer device.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f4228b..68baaf1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add _add_layer_target_to_dtree() for adding linear layer into dtree.
   Extend _cached_info() to accept layer string.
   Allow identical table reload for RAID to restore transiently failed PVs.
   vgimport '--force' now allows users to import VGs with missing PVs.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c0cee4c..5f0457b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1831,6 +1831,25 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 	return 1;
 }
 
+static int _add_layer_target_to_dtree(struct dev_manager *dm,
+				      struct dm_tree_node *dnode,
+				      struct logical_volume *lv)
+{
+	const char *layer_dlid;
+
+	if (!(layer_dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+		return_0;
+
+	/* Add linear mapping over layered LV */
+	if (!add_linear_area_to_dtree(dnode, lv->size, lv->vg->extent_size,
+				      lv->vg->cmd->use_linear_target,
+				      lv->vg->name, lv->name) ||
+	    !dm_tree_node_add_target_area(dnode, NULL, layer_dlid, 0))
+		return_0;
+
+	return 1;
+}
+
 static int _add_origin_target_to_dtree(struct dev_manager *dm,
 					 struct dm_tree_node *dnode,
 					 struct logical_volume *lv)


