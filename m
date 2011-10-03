From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:26:08 -0000
Subject: LVM2 lib/thin/thin.c libdm/libdevmapper.h libd ...
Message-ID: <20111003182608.608.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:26:08

Modified files:
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Transaction_id is property of thin_pool
	
	Remove Transaction_id from thin target.
	Store device_id for thin target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/lib/thin/thin.c	2011/09/29 08:56:39	1.13
+++ LVM2/lib/thin/thin.c	2011/10/03 18:26:07	1.14
@@ -199,7 +199,7 @@
 		return 0;
 	}
 
-	if (!dm_tree_node_add_thin_target(node, len, 0, thin_pool_dlid, seg->device_id))
+	if (!dm_tree_node_add_thin_target(node, len, thin_pool_dlid, seg->device_id))
 		return_0;
 
 	return 1;
--- LVM2/libdm/libdevmapper.h	2011/09/29 08:53:48	1.154
+++ LVM2/libdm/libdevmapper.h	2011/10/03 18:26:07	1.155
@@ -547,7 +547,6 @@
 
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
-				 uint64_t transation_id,
 				 const char *thin_pool_uuid,
 				 uint32_t device_id);
 
--- LVM2/libdm/libdm-deptree.c	2011/09/29 08:53:48	1.115
+++ LVM2/libdm/libdm-deptree.c	2011/10/03 18:26:07	1.116
@@ -2690,7 +2690,6 @@
 
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
-				 uint64_t transation_id,
 				 const char *thin_pool_uuid,
 				 uint32_t device_id)
 {
@@ -2713,6 +2712,8 @@
 	if (!_link_tree_nodes(node, seg->pool))
 		return_0;
 
+	seg->device_id = device_id;
+
 	return 1;
 }
 


