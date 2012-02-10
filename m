From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 14:42:30 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20120210144230.16600.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 14:42:29

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Add validation of name and uuid
	
	Do not accept NULL pointers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.546&r2=1.547
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW_DM	2012/02/10 14:00:07	1.546
+++ LVM2/WHATS_NEW_DM	2012/02/10 14:42:28	1.547
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Validate name and uuid params of dm_tree_add_new_dev_with_udev_flags().  
   Do not crash for dm_report_init() sort_key == NULL and behave like "".
   Return error for failing allocation in dm_asprintf().
   Add missing test for failing allocation in dm_realloc() code.
--- LVM2/libdm/libdm-deptree.c	2012/02/08 11:36:18	1.154
+++ LVM2/libdm/libdm-deptree.c	2012/02/10 14:42:28	1.155
@@ -1086,6 +1086,11 @@
 	const char *name2;
 	const char *uuid2;
 
+	if (!name || !uuid) {
+		log_error("Cannot add device without name and uuid.");
+		return NULL;
+	}
+
 	/* Do we need to add node to tree? */
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
 		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {


