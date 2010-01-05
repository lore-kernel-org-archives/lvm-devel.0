From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:04:37 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100105210437.21880.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:04:37

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Return error to dm_tree_preload_children() and
	dm_tree_activate_children() callers.
	
	Otherwise resume_lv and its variants can fail silently.
	
	Catching these failures is especially important now that dm targets like
	crypt and snapshot-merge can fail in .preresume
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/libdm/libdm-deptree.c	2009/12/11 13:16:39	1.64
+++ LVM2/libdm/libdm-deptree.c	2010/01/05 21:04:37	1.65
@@ -1140,6 +1140,7 @@
 				 const char *uuid_prefix,
 				 size_t uuid_prefix_len)
 {
+	int r = 1;
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
 	struct dm_info newinfo;
@@ -1158,7 +1159,8 @@
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 	}
 
 	handle = NULL;
@@ -1204,6 +1206,7 @@
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
+				r = 0;
 				continue;
 			}
 
@@ -1214,7 +1217,7 @@
 
 	handle = NULL;
 
-	return 1;
+	return r;
 }
 
 static int _create_node(struct dm_tree_node *dnode)
@@ -1605,6 +1608,7 @@
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
 {
+	int r = 1;
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
@@ -1621,7 +1625,8 @@
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
 		if (!child->info.exists) {
@@ -1655,6 +1660,7 @@
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
+			r = 0;
 			continue;
 		}
 
@@ -1664,7 +1670,7 @@
 
 	handle = NULL;
 
-	return 1;
+	return r;
 }
 
 /*


