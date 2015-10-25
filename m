From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 25 Oct 2015 20:09:58 +0000 (UTC)
Subject: master - libdm: dm_tree_node_size_changed recognizes reduction
Message-ID: <20151025200958.DA46A609CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ef820a2a5e174cd08097981d7879e1f4cbded01
Commit:        9ef820a2a5e174cd08097981d7879e1f4cbded01
Parent:        40eea582aea512db7fceafd8559bf66df0733b55
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 19:27:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:05:15 2015 +0100

libdm: dm_tree_node_size_changed recognizes reduction

Add more functionality to size_changed function.
While 'existing' API only detected  0 for
unchanged,  and !0 for changed,
new improved API will also detected if the
size has only went bigger - or there was
size reduction.

Function work for the whole dm-tree - so
no change is size is always 0.
only size extension  1.
and if some size reduction is there - returns -1.

This result can be used for better evaluation
whether we need to flush before suspend.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.Base        |    1 -
 libdm/.exported_symbols.DM_1_02_110 |    1 +
 libdm/libdevmapper.h                |    5 +++++
 libdm/libdm-deptree.c               |   25 ++++++++++++++++++++++---
 5 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 910f6d6..e09ab63 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Enhance dm_tree_node_size_changed() to recognize size reduction.
   Support exit on idle for dmenventd (1 hour).
   Add support to allow unmonitor device from plugin itself.
   New design for thread co-operation in dmeventd.
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index f9c3cb1..27fef53 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -262,7 +262,6 @@ dm_tree_node_set_thin_external_origin
 dm_tree_node_set_thin_pool_discard
 dm_tree_node_set_thin_pool_error_if_no_space
 dm_tree_node_set_udev_flags
-dm_tree_node_size_changed
 dm_tree_preload_children
 dm_tree_retry_remove
 dm_tree_set_cookie
diff --git a/libdm/.exported_symbols.DM_1_02_110 b/libdm/.exported_symbols.DM_1_02_110
index da742ee..eba5625 100644
--- a/libdm/.exported_symbols.DM_1_02_110
+++ b/libdm/.exported_symbols.DM_1_02_110
@@ -1,2 +1,3 @@
 dm_report_compact_given_fields
 dm_hold_control_dev
+dm_tree_node_size_changed
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 08b24fe..f7ab257 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1256,6 +1256,11 @@ const char *dm_tree_node_get_name(const struct dm_tree_node *node);
 const char *dm_tree_node_get_uuid(const struct dm_tree_node *node);
 const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node);
 void *dm_tree_node_get_context(const struct dm_tree_node *node);
+/*
+ * Returns  0 when node size and its children is unchanged.
+ * Returns  1 when node or any of its children has increased size.
+ * Rerurns -1 when node or any of its children has reduced size.
+ */
 int dm_tree_node_size_changed(const struct dm_tree_node *dnode);
 
 /*
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index afdce8d..d7e2143 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -220,7 +220,7 @@ struct load_properties {
 	uint32_t read_ahead_flags;
 
 	unsigned segment_count;
-	unsigned size_changed;
+	int size_changed;
 	struct dm_list segs;
 
 	const char *new_name;
@@ -2729,7 +2729,8 @@ static int _load_node(struct dm_tree_node *dnode)
 
 		existing_table_size = dm_task_get_existing_table_size(dmt);
 		if ((dnode->props.size_changed =
-		     (existing_table_size == seg_start) ? 0 : 1)) {
+		     (existing_table_size == seg_start) ? 0 :
+		     (existing_table_size > seg_start) ? -1 : 1)) {
 			/*
 			 * Kernel usually skips size validation on zero-length devices
 			 * now so no need to preload them.
@@ -2825,8 +2826,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		}
 
 		/* Propagate device size change change */
-		if (child->props.size_changed)
+		if (child->props.size_changed > 0 && !dnode->props.size_changed)
 			dnode->props.size_changed = 1;
+		else if (child->props.size_changed < 0)
+			dnode->props.size_changed = -1;
 
 		/* Resume device immediately if it has parents and its size changed */
 		if (!dm_tree_node_num_children(child, 1) || !child->props.size_changed)
@@ -3853,3 +3856,19 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
 	dnode->callback = cb;
 	dnode->callback_data = data;
 }
+
+/*
+ * Backward compatible dm_tree_node_size_changed() implementations.
+ *
+ * Keep these at the end of the file to avoid adding clutter around the
+ * current dm_tree_node_size_changed() version.
+ */
+#if defined(__GNUC__)
+int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode);
+DM_EXPORT_SYMBOL_BASE(dm_tree_node_size_changed);
+int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
+{
+	/* Base does not make difference between smaller and bigger */
+	return dm_tree_node_size_changed(dnode) ? 1 : 0;
+}
+#endif


