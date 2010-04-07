From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Apr 2010 23:51:35 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100407235135.14727.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-07 23:51:34

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Only fail if the top-level LV fails to be deactivated - allow deactivation
	of its dependencies to fail.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/libdm/libdm-deptree.c	2010/04/07 21:25:09	1.74
+++ LVM2/libdm/libdm-deptree.c	2010/04/07 23:51:34	1.75
@@ -1013,9 +1013,13 @@
 	return r;
 }
 
-int dm_tree_deactivate_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+/*
+ * FIXME Don't attempt to deactivate known internal dependencies.
+ */
+static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
+					const char *uuid_prefix,
+					size_t uuid_prefix_len,
+					unsigned level)
 {
 	int r = 1;
 	void *handle = NULL;
@@ -1051,10 +1055,13 @@
 			continue;
 
 		if (info.open_count) {
-			log_error("Unable to deactivate open %s (%" PRIu32
-				  ":%" PRIu32 ")", name, info.major,
-				  info.minor);
-			r = 0;
+			/* Only report error from (likely non-internal) dependency at top level */
+			if (!level) {
+				log_error("Unable to deactivate open %s (%" PRIu32
+					  ":%" PRIu32 ")", name, info.major,
+				  	info.minor);
+				r = 0;
+			}
 			continue;
 		}
 
@@ -1067,14 +1074,22 @@
 			continue;
 		}
 
-		if (dm_tree_node_num_children(child, 0))
-			if (!dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len))
+		if (dm_tree_node_num_children(child, 0)) {
+			if (!_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
 				return_0;
+		}
 	}
 
 	return r;
 }
 
+int dm_tree_deactivate_children(struct dm_tree_node *dnode,
+				   const char *uuid_prefix,
+				   size_t uuid_prefix_len)
+{
+	return _dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len, 0);
+}
+
 void dm_tree_skip_lockfs(struct dm_tree_node *dnode)
 {
 	dnode->dtree->skip_lockfs = 1;


