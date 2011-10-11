From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 08:57:16 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20111011085716.29249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 08:57:16

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Change message severity
	
	Using log_warn to report missing symlinks as warning, since the command
	itself returns as successful, we should not produce log_error().
	log_warn is better fit here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2152&r2=1.2153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239

--- LVM2/WHATS_NEW	2011/10/07 14:56:01	1.2152
+++ LVM2/WHATS_NEW	2011/10/11 08:57:13	1.2153
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Change message severity to log_warn when symlink creation fails.
   Add ability to convert mirror segtype to RAID1 segtype.
   Add ability to convert from linear to RAID1.
   Add ability to extend mirrors with '--nosync' option.
--- LVM2/lib/activate/dev_manager.c	2011/10/11 08:54:01	1.238
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 08:57:16	1.239
@@ -1886,7 +1886,7 @@
 		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
-			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
+			log_warn("Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
@@ -1913,10 +1913,8 @@
 		if (action == ACTIVATE) {
 			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 				goto_out;
-			if (!_create_lv_symlinks(dm, root)) {
-				log_error("Failed to create symlinks for %s.", lv->name);
-				goto out;
-			}
+			if (!_create_lv_symlinks(dm, root))
+				log_warn("Failed to create symlinks for %s.", lv->name);
 		}
 
 		break;


