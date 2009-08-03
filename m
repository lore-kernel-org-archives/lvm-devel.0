From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 11:20:17 -0000
Subject: LVM2 tools/dmsetup.c libdm/libdm-common.c lib/ ...
Message-ID: <20090803112017.17487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 11:20:16

Modified files:
	tools          : dmsetup.c 
	libdm          : libdm-common.c 
	lib/activate   : dev_manager.c 

Log message:
	cleanup some ignored return values & 'stack's

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/tools/dmsetup.c	2009/07/31 17:51:46	1.118
+++ LVM2/tools/dmsetup.c	2009/08/03 11:20:15	1.119
@@ -593,7 +593,7 @@
 		goto out;
 	}
 
-	dm_udev_wait(cookie);
+	(void) dm_udev_wait(cookie);
 
 	r = 1;
 
@@ -631,7 +631,7 @@
 		goto out;
 	}
 
-	dm_udev_wait(cookie);
+	(void) dm_udev_wait(cookie);
 
 	r = 1;
 
--- LVM2/libdm/libdm-common.c	2009/08/03 11:01:26	1.70
+++ LVM2/libdm/libdm-common.c	2009/08/03 11:20:16	1.71
@@ -1065,7 +1065,7 @@
 		return 1;
 
 	if (!_get_cookie_sem(cookie, &semid))
-		return 0;
+		return_0;
 
 	return _udev_notify_sem_destroy(semid, cookie);
 }
--- LVM2/lib/activate/dev_manager.c	2009/07/31 18:30:31	1.154
+++ LVM2/lib/activate/dev_manager.c	2009/08/03 11:20:16	1.155
@@ -1133,10 +1133,11 @@
 
 		dm_tree_set_cookie(root, 0);
 		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid))) {
-			dm_udev_cleanup(dm_tree_get_cookie(root));
+			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
 			return_0;
 		}
-		dm_udev_wait(dm_tree_get_cookie(root));
+		if (!dm_udev_wait(dm_tree_get_cookie(root)))
+			stack;
 	}
 
 	return 1;
@@ -1171,10 +1172,11 @@
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		dm_tree_set_cookie(root, 0);
 		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-			dm_udev_cleanup(dm_tree_get_cookie(root));
+			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
 			goto_out;
 		}
-		dm_udev_wait(dm_tree_get_cookie(root));
+		if (!dm_udev_wait(dm_tree_get_cookie(root)))
+			stack;
 		if (!_remove_lv_symlinks(dm, root))
 			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
@@ -1195,10 +1197,11 @@
 		/* Preload any devices required before any suspensions */
 		dm_tree_set_cookie(root, 0);
 		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-			dm_udev_cleanup(dm_tree_get_cookie(root));
+			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
 			goto_out;
 		}
-		dm_udev_wait(dm_tree_get_cookie(root));
+		if (!dm_udev_wait(dm_tree_get_cookie(root)))
+			stack;
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
@@ -1206,10 +1209,11 @@
 		if (action == ACTIVATE) {
 			dm_tree_set_cookie(root, 0);
 			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-				dm_udev_cleanup(dm_tree_get_cookie(root));
+				(void) dm_udev_cleanup(dm_tree_get_cookie(root));
 				goto_out;
 			}
-			dm_udev_wait(dm_tree_get_cookie(root));
+			if (!dm_udev_wait(dm_tree_get_cookie(root)))
+				stack;
 		}
 
 		if (!_create_lv_symlinks(dm, root)) {


