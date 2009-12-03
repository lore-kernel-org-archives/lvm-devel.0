From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Dec 2009 09:58:31 -0000
Subject: LVM2 lib/activate/dev_manager.c libdm/libdm-de ...
Message-ID: <20091203095831.9522.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-03 09:58:30

Modified files:
	lib/activate   : dev_manager.c 
	libdm          : libdm-deptree.c 

Log message:
	minor whitespace indentation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/activate/dev_manager.c	2009/11/04 14:56:35	1.163
+++ LVM2/lib/activate/dev_manager.c	2009/12/03 09:58:30	1.164
@@ -783,7 +783,7 @@
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid))) 
+	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid)))
 		return_NULL;
 
 	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
@@ -1269,7 +1269,7 @@
 	default:
 		log_error("_tree_action: Action %u not supported.", action);
 		goto out;
-	}	
+	}
 
 	r = 1;
 
--- LVM2/libdm/libdm-deptree.c	2009/11/13 12:43:22	1.62
+++ LVM2/libdm/libdm-deptree.c	2009/12/03 09:58:30	1.63
@@ -645,7 +645,7 @@
 void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 				 uint32_t read_ahead,
 				 uint32_t read_ahead_flags)
-{                          
+{
 	dnode->props.read_ahead = read_ahead;
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
@@ -1064,8 +1064,8 @@
 }
 
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
@@ -1849,7 +1849,7 @@
 
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
-					  unsigned clustered, 
+					  unsigned clustered,
 					  const char *log_uuid,
 					  unsigned area_count,
 					  uint32_t flags)


