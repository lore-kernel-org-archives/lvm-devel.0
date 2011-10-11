From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 08:54:02 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111011085402.28190.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 08:54:02

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Skip r assignment
	
	Cosmetic, since r is already 0 for the error path, no need to assign it there,
	and r is assigned to 1 after switch command.
	Also makes the code more readable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238

--- LVM2/lib/activate/dev_manager.c	2011/10/06 14:45:41	1.237
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 08:54:01	1.238
@@ -1882,9 +1882,8 @@
 	case DEACTIVATE:
 		if (retry_deactivation())
 			dm_tree_retry_remove(root);
- 		/* Deactivate LV and all devices it references that nothing else has open. */
-		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!r)
+		/* Deactivate LV and all devices it references that nothing else has open. */
+		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
 			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
@@ -1905,16 +1904,14 @@
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!r)
+		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-			if (!r)
+			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 				goto_out;
 			if (!_create_lv_symlinks(dm, root)) {
 				log_error("Failed to create symlinks for %s.", lv->name);


