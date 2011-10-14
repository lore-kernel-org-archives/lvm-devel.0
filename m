From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Oct 2011 13:34:20 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20111014133420.24391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-14 13:34:19

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Use pool for dm_tree allocation
	
	Using the same pool allocation strategy as we use for vg,
	so dm_tree structure is part of the pool itself.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.509&r2=1.510
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW_DM	2011/10/03 18:28:25	1.509
+++ LVM2/WHATS_NEW_DM	2011/10/14 13:34:19	1.510
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Allocate dm_tree structure from dm_tree pool.
   Update debug logging for _resume_node.
   Add functions to support thin provisioning target (API unstable).
   Improve libdm-config error path reporting.
--- LVM2/libdm/libdm-deptree.c	2011/10/06 14:45:42	1.122
+++ LVM2/libdm/libdm-deptree.c	2011/10/14 13:34:19	1.123
@@ -248,10 +248,14 @@
 
 struct dm_tree *dm_tree_create(void)
 {
+	struct dm_pool *dmem;
 	struct dm_tree *dtree;
 
-	if (!(dtree = dm_zalloc(sizeof(*dtree)))) {
-		log_error("dm_tree_create malloc failed");
+	if (!(dmem = dm_pool_create("dtree", 1024)) ||
+	    !(dtree = dm_pool_zalloc(dmem, sizeof(*dtree)))) {
+		log_error("Failed to allocate dtree.");
+		if (dmem)
+			dm_pool_destroy(dmem);
 		return NULL;
 	}
 
@@ -260,17 +264,11 @@
 	dm_list_init(&dtree->root.used_by);
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
-
-	if (!(dtree->mem = dm_pool_create("dtree", 1024))) {
-		log_error("dtree pool creation failed");
-		dm_free(dtree);
-		return NULL;
-	}
+	dtree->mem = dmem;
 
 	if (!(dtree->devs = dm_hash_create(8))) {
 		log_error("dtree hash creation failed");
 		dm_pool_destroy(dtree->mem);
-		dm_free(dtree);
 		return NULL;
 	}
 
@@ -278,7 +276,6 @@
 		log_error("dtree uuid hash creation failed");
 		dm_hash_destroy(dtree->devs);
 		dm_pool_destroy(dtree->mem);
-		dm_free(dtree);
 		return NULL;
 	}
 
@@ -293,7 +290,6 @@
 	dm_hash_destroy(dtree->uuids);
 	dm_hash_destroy(dtree->devs);
 	dm_pool_destroy(dtree->mem);
-	dm_free(dtree);
 }
 
 static int _nodes_are_linked(const struct dm_tree_node *parent,


