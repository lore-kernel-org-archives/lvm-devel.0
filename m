From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 10:02:28 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111011100228.17009.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 10:02:28

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Use constant for the repeated dlid size specification

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244

--- LVM2/lib/activate/dev_manager.c	2011/10/11 09:03:33	1.243
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 10:02:28	1.244
@@ -1852,6 +1852,7 @@
 static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, action_t action)
 {
+	const size_t DLID_SIZE = ID_LEN + sizeof(UUID_PREFIX) - 1;
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
 	char *dlid;
@@ -1882,7 +1883,7 @@
 		if (retry_deactivation())
 			dm_tree_retry_remove(root);
 		/* Deactivate LV and all devices it references that nothing else has open. */
-		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_deactivate_children(root, dlid, DLID_SIZE))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
 			log_warn("Failed to remove all device symlinks associated with %s.", lv->name);
@@ -1893,7 +1894,7 @@
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:
-		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_suspend_children(root, dlid, DLID_SIZE))
 			goto_out;
 		break;
 	case PRELOAD:
@@ -1903,14 +1904,14 @@
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_preload_children(root, dlid, DLID_SIZE))
 			goto_out;
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+			if (!dm_tree_activate_children(root, dlid, DLID_SIZE))
 				goto_out;
 			if (!_create_lv_symlinks(dm, root))
 				log_warn("Failed to create symlinks for %s.", lv->name);


