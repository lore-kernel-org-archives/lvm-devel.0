From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:33:52 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110922173352.32524.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:33:51

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/commands   : toolcontext.c 
	lib/metadata   : lv_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Replace open_count check with holders/mounted_fs check on lvremove path.
	
	Before, we used to display "Can't remove open logical volume" which was
	generic. There 3 possibilities of how a device could be opened:
	- used by another device
	- having a filesystem on that device which is mounted
	- opened directly by an application
	
	With the help of sysfs info, we can distinguish the first two situations.
	The third one will be subject to "remove retry" logic - if it's opened
	quickly (e.g. a parallel scan from within a udev rule run), this will
	finish quickly and we can remove it once it has finished. If it's a
	legitimate application that keeps the device opened, we'll do our best
	to remove the device, but we will fail finally after a few retries.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2130&r2=1.2131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.289&r2=1.290
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2011/09/22 15:36:21	1.2130
+++ LVM2/WHATS_NEW	2011/09/22 17:33:50	1.2131
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Replace open_count check with holders/mounted_fs check on lvremove path.
   Disallow the creation of mirrors (mirror or raid1 segtype) with only one leg.
   Cleanup restart clvmd code (no memory allocation, debug print passed args).
   Add all exclusive locks to clvmd restart option args.
--- LVM2/lib/activate/activate.c	2011/08/30 14:55:16	1.212
+++ LVM2/lib/activate/activate.c	2011/09/22 17:33:50	1.213
@@ -526,6 +526,31 @@
 	return r;
 }
 
+int lv_check_not_in_use(struct cmd_context *cmd __attribute__((unused)),
+			struct logical_volume *lv, struct lvinfo *info)
+{
+	if (!info->exists)
+		return 1;
+
+	/* If sysfs is not used, use open_count information only. */
+	if (!*dm_sysfs_dir())
+		return !info->open_count;
+
+	if (dm_device_has_holders(info->major, info->minor)) {
+		log_error("Logical volume %s/%s is used by another device.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (dm_device_has_mounted_fs(info->major, info->minor)) {
+		log_error("Logical volume %s/%s contains a filesystem in use.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
@@ -1437,11 +1462,9 @@
 	}
 
 	if (lv_is_visible(lv)) {
-		if (info.open_count) {
-			log_error("LV %s/%s in use: not deactivating",
-				  lv->vg->name, lv->name);
-			goto out;
-		}
+		if (!lv_check_not_in_use(cmd, lv, &info))
+			goto_out;
+
 		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
 			goto_out;
 	}
--- LVM2/lib/activate/activate.h	2011/08/11 18:24:41	1.79
+++ LVM2/lib/activate/activate.h	2011/09/22 17:33:51	1.80
@@ -80,6 +80,9 @@
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
+int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+			struct lvinfo *info);
+
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
  */
--- LVM2/lib/commands/toolcontext.c	2011/09/02 12:38:43	1.135
+++ LVM2/lib/commands/toolcontext.c	2011/09/22 17:33:51	1.136
@@ -264,6 +264,7 @@
 	/* FIXME Use global value of sysfs_dir everywhere instead cmd->sysfs_dir. */
 	_get_sysfs_dir(cmd);
 	set_sysfs_dir_path(cmd->sysfs_dir);
+	dm_set_sysfs_dir(cmd->sysfs_dir);
 
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_int(cmd,
--- LVM2/lib/metadata/lv_manip.c	2011/09/16 18:39:03	1.289
+++ LVM2/lib/metadata/lv_manip.c	2011/09/22 17:33:51	1.290
@@ -3099,11 +3099,8 @@
 	/* FIXME Ensure not referred to by another existing LVs */
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (info.open_count) {
-			log_error("Can't remove open logical volume \"%s\"",
-				  lv->name);
-			return 0;
-		}
+		if (!lv_check_not_in_use(cmd, lv, &info))
+			return_0;
 
 		if (lv_is_active(lv) && (force == PROMPT) &&
 		    lv_is_visible(lv) &&
--- LVM2/libdm/libdm-deptree.c	2011/09/07 08:37:48	1.109
+++ LVM2/libdm/libdm-deptree.c	2011/09/22 17:33:51	1.110
@@ -940,6 +940,30 @@
 	return r;
 }
 
+static int _check_device_not_in_use(struct dm_info *info)
+{
+	if (!info->exists)
+		return 1;
+
+	/* If sysfs is not used, use open_count information only. */
+	if (!*dm_sysfs_dir())
+		return !info->open_count;
+
+	if (dm_device_has_holders(info->major, info->minor)) {
+		log_error("Device %" PRIu32 ":%" PRIu32 " is used "
+			  "by another device.", info->major, info->minor);
+		return 0;
+	}
+
+	if (dm_device_has_mounted_fs(info->major, info->minor)) {
+		log_error("Device %" PRIu32 ":%" PRIu32 " contains "
+			  "a filesystem in use.", info->major, info->minor);
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Check if all parent nodes of given node have open_count == 0 */
 static int _node_has_closed_parents(struct dm_tree_node *node,
 				    const char *uuid_prefix,
@@ -1184,9 +1208,11 @@
 		    !info.exists)
 			continue;
 
+		if (!_check_device_not_in_use(&info))
+			continue;
+
 		/* Also checking open_count in parent nodes of presuspend_node */
-		if (info.open_count ||
-		    (child->presuspend_node &&
+		if ((child->presuspend_node &&
 		     !_node_has_closed_parents(child->presuspend_node,
 					       uuid_prefix, uuid_prefix_len))) {
 			/* Only report error from (likely non-internal) dependency at top level */


