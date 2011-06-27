From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2011 21:44:01 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM doc/example.co ...
Message-ID: <20110627214401.19396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-27 21:43:59

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	doc            : example.conf.in 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	libdm          : libdm-common.c libdm-common.h libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Move udev_only logic inside stacked node op code.
	(We still need to treat add+readhead+del as a no-op.)
	Rename udev_fallback to verify_udev_operations.
	Rename --udevfallback to --verifyudev

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2026&r2=1.2027
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.474&r2=1.475
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/WHATS_NEW	2011/06/23 14:00:58	1.2026
+++ LVM2/WHATS_NEW	2011/06/27 21:43:58	1.2027
@@ -3,7 +3,7 @@
   Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
   Fix issue preventing cluster mirror creation.
-  Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
+  Add activation/verify_udev_operations to lvm.conf, disabled by default.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
   Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
--- LVM2/WHATS_NEW_DM	2011/06/24 19:33:41	1.474
+++ LVM2/WHATS_NEW_DM	2011/06/27 21:43:58	1.475
@@ -1,7 +1,7 @@
 Version 1.02.65 - 
 ==================================
-  Return immediately dm_lib_exit() if called more than once.
-  Disable udev fallback by default and add --udevfallback option to dmsetup.
+  Return immediately from dm_lib_exit() if called more than once.
+  Disable udev fallback by default and add --verifyudev option to dmsetup.
   Warn if a table is loaded while a device is known to be in suspended state.
   Add dm_get_suspended_counter() for number of devs in suspended state by lib.
   Fix "all" report field prefix matching to include label fields with pv_all.
--- LVM2/doc/example.conf.in	2011/06/17 14:50:53	1.26
+++ LVM2/doc/example.conf.in	2011/06/27 21:43:59	1.27
@@ -428,12 +428,11 @@
     # while any logical volumes are active.
     udev_rules = 1
 
-    # Set to 1 to enable udev fallback. This will enable additional checks and
-    # possible repairs done on entries in the device directory after udev has
-    # completed processing the events. This is normally not needed if udev
-    # works correctly but it may be used in some problematic situations or
-    # for debugging purposes.
-    udev_fallback = 0
+    # Set to 1 for LVM2 to verify operations performed by udev. This turns on
+    # additional checks (and if necessary, repairs) on entries in the device
+    # directory after udev has completed processing its events. 
+    # Useful for diagnosing problems with LVM2/udev interactions.
+    verify_udev_operations = 0
 
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
--- LVM2/lib/commands/toolcontext.c	2011/06/17 14:50:54	1.120
+++ LVM2/lib/commands/toolcontext.c	2011/06/27 21:43:59	1.121
@@ -293,8 +293,8 @@
 	 * without any fallback.
 	 */
 	cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
-					find_config_tree_int(cmd, "activation/udev_fallback",
-							     DEFAULT_UDEV_FALLBACK) : 1;
+					find_config_tree_int(cmd, "activation/verify_udev_operations",
+							     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1;
 	#else
 	/* We must use old node/symlink creation code if not compiled with udev support at all! */
 	cmd->default_settings.udev_fallback = 1;
--- LVM2/lib/config/defaults.h	2011/06/17 14:50:54	1.76
+++ LVM2/lib/config/defaults.h	2011/06/27 21:43:59	1.77
@@ -78,7 +78,7 @@
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 0
-#define DEFAULT_UDEV_FALLBACK 0
+#define DEFAULT_VERIFY_UDEV_OPERATIONS 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
--- LVM2/libdm/libdm-common.c	2011/06/13 03:32:46	1.118
+++ LVM2/libdm/libdm-common.c	2011/06/27 21:43:59	1.119
@@ -501,8 +501,13 @@
 #endif
 }
 
+static int _warn_if_op_needed(int warn_if_udev_failed)
+{
+    return warn_if_udev_failed && dm_udev_get_sync_support() && dm_udev_get_checking();
+}
+
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
-			 uid_t uid, gid_t gid, mode_t mode, int check_udev)
+			 uid_t uid, gid_t gid, mode_t mode, int warn_if_udev_failed)
 {
 	char path[PATH_MAX];
 	struct stat info;
@@ -527,8 +532,7 @@
 				  dev_name);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
-		   check_udev)
+	} else if (_warn_if_op_needed(warn_if_udev_failed))
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
@@ -553,7 +557,7 @@
 	return 1;
 }
 
-static int _rm_dev_node(const char *dev_name, int check_udev)
+static int _rm_dev_node(const char *dev_name, int warn_if_udev_failed)
 {
 	char path[PATH_MAX];
 	struct stat info;
@@ -562,8 +566,7 @@
 
 	if (stat(path, &info) < 0)
 		return 1;
-	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
-		 check_udev)
+	else if (_warn_if_op_needed(warn_if_udev_failed))
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
@@ -578,7 +581,7 @@
 }
 
 static int _rename_dev_node(const char *old_name, const char *new_name,
-			    int check_udev)
+			    int warn_if_udev_failed)
 {
 	char oldpath[PATH_MAX];
 	char newpath[PATH_MAX];
@@ -593,8 +596,7 @@
 				  "is already present", newpath);
 			return 0;
 		}
-		else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
-			 check_udev) {
+		else if (_warn_if_op_needed(warn_if_udev_failed)) {
 			if (stat(oldpath, &info) < 0 &&
 				 errno == ENOENT)
 				/* assume udev already deleted this */
@@ -618,8 +620,7 @@
 			return 0;
 		}
 	}
-	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
-		 check_udev)
+	else if (_warn_if_op_needed(warn_if_udev_failed))
 		log_warn("The node %s should have been renamed to %s "
 			 "by udev but new node is not present. "
 			 "Falling back to direct node rename.",
@@ -759,16 +760,16 @@
 static int _do_node_op(node_op_t type, const char *dev_name, uint32_t major,
 		       uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 		       const char *old_name, uint32_t read_ahead,
-		       uint32_t read_ahead_flags, int check_udev)
+		       uint32_t read_ahead_flags, int warn_if_udev_failed)
 {
 	switch (type) {
 	case NODE_ADD:
 		return _add_dev_node(dev_name, major, minor, uid, gid,
-				     mode, check_udev);
+				     mode, warn_if_udev_failed);
 	case NODE_DEL:
-		return _rm_dev_node(dev_name, check_udev);
+		return _rm_dev_node(dev_name, warn_if_udev_failed);
 	case NODE_RENAME:
-		return _rename_dev_node(old_name, dev_name, check_udev);
+		return _rename_dev_node(old_name, dev_name, warn_if_udev_failed);
 	case NODE_READ_AHEAD:
 		return _set_dev_node_read_ahead(dev_name, read_ahead,
 						read_ahead_flags);
@@ -794,7 +795,8 @@
 	uint32_t read_ahead;
 	uint32_t read_ahead_flags;
 	char *old_name;
-	int check_udev;
+	int warn_if_udev_failed;
+	unsigned rely_on_udev;
 	char names[0];
 };
 
@@ -824,16 +826,33 @@
 	return 0;
 }
 
-/* Check if udev is supposed to create nodes */
-static int _check_udev(int check_udev)
+static void _log_node_op(const char *action_str, struct node_op_parms *nop)
 {
-    return check_udev && dm_udev_get_sync_support() && dm_udev_get_checking();
+	switch (nop->type) {
+	case NODE_ADD:
+		log_debug("%s: %s NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o",
+			  nop->dev_name, action_str, nop->major, nop->minor, nop->uid, nop->gid, nop->mode);
+		break;
+	case NODE_DEL:
+		log_debug("%s: %s NODE_DEL", nop->dev_name, action_str);
+		break;
+	case NODE_RENAME:
+		log_debug("%s: %s NODE_RENAME to %s", nop->old_name, action_str, nop->dev_name);
+		break;
+	case NODE_READ_AHEAD:
+		log_debug("%s: %s NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32
+			  ")", nop->dev_name, action_str, nop->read_ahead, nop->read_ahead_flags);
+		break;
+	default:
+		; /* NOTREACHED */
+	}
 }
 
 static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 			  uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 			  const char *old_name, uint32_t read_ahead,
-			  uint32_t read_ahead_flags, int check_udev)
+			  uint32_t read_ahead_flags, int warn_if_udev_failed,
+			  unsigned rely_on_udev)
 {
 	struct node_op_parms *nop;
 	struct dm_list *noph, *nopht;
@@ -841,7 +860,7 @@
 	char *pos;
 
 	/*
-	 * Note: check_udev must have valid content
+	 * Note: warn_if_udev_failed must have valid content
 	 */
 	if ((type == NODE_DEL) && _other_node_ops(type))
 		/*
@@ -850,27 +869,29 @@
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
 			if (!strcmp(dev_name, nop->dev_name)) {
+				_log_node_op("Unstacking", nop);
 				_del_node_op(nop);
 				if (!_other_node_ops(type))
 					break; /* no other non DEL ops */
 			}
 		}
-	else if ((type == NODE_ADD) && _count_node_ops[NODE_DEL] && _check_udev(check_udev))
+	else if ((type == NODE_ADD) && _count_node_ops[NODE_DEL])
 		/*
-		 * If udev is running ignore previous DEL operation on added node.
+		 * Ignore previous DEL operation on added node.
 		 * (No other operations for this device then DEL could be stacked here).
 		 */
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
 			if ((nop->type == NODE_DEL) &&
 			    !strcmp(dev_name, nop->dev_name)) {
+				_log_node_op("Unstacking", nop);
 				_del_node_op(nop);
 				break; /* no other DEL ops */
 			}
 		}
-	else if ((type == NODE_RENAME) && _check_udev(check_udev))
+	else if ((type == NODE_RENAME))
 		/*
-		 * If udev is running ignore any outstanding operations if renaming it.
+		 * Ignore any outstanding operations if renaming it.
 		 *
 		 * Currently  RENAME operation happens through 'suspend -> resume'.
 		 * On 'resume' device is added with read_ahead settings, so it is
@@ -880,6 +901,7 @@
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
 			if (!strcmp(old_name, nop->dev_name))
+				_log_node_op("Unstacking", nop);
 				_del_node_op(nop);
 		}
 
@@ -897,7 +919,8 @@
 	nop->mode = mode;
 	nop->read_ahead = read_ahead;
 	nop->read_ahead_flags = read_ahead_flags;
-	nop->check_udev = check_udev;
+	nop->warn_if_udev_failed = warn_if_udev_failed;
+	nop->rely_on_udev = rely_on_udev;
 
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
@@ -905,6 +928,8 @@
 	_count_node_ops[type]++;
 	dm_list_add(&_node_ops, &nop->list);
 
+	_log_node_op("Stacking", nop);
+
 	return 1;
 }
 
@@ -915,38 +940,35 @@
 
 	dm_list_iterate_safe(noph, nopht, &_node_ops) {
 		nop = dm_list_item(noph, struct node_op_parms);
-		_do_node_op(nop->type, nop->dev_name, nop->major, nop->minor,
-			    nop->uid, nop->gid, nop->mode, nop->old_name,
-			    nop->read_ahead, nop->read_ahead_flags,
-			    nop->check_udev);
+		if (!nop->rely_on_udev) {
+			_log_node_op("Processing", nop);
+			_do_node_op(nop->type, nop->dev_name, nop->major, nop->minor,
+				    nop->uid, nop->gid, nop->mode, nop->old_name,
+				    nop->read_ahead, nop->read_ahead_flags,
+				    nop->warn_if_udev_failed);
+		} else
+			_log_node_op("Skipping (udev)", nop);
 		_del_node_op(nop);
 	}
 }
 
 int add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
-		 uid_t uid, gid_t gid, mode_t mode, int check_udev)
+		 uid_t uid, gid_t gid, mode_t mode, int check_udev, unsigned rely_on_udev)
 {
-	log_debug("%s: Stacking NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o",
-		  dev_name, major, minor, uid, gid, mode);
-
 	return _stack_node_op(NODE_ADD, dev_name, major, minor, uid,
-			      gid, mode, "", 0, 0, check_udev);
+			      gid, mode, "", 0, 0, check_udev, rely_on_udev);
 }
 
-int rename_dev_node(const char *old_name, const char *new_name, int check_udev)
+int rename_dev_node(const char *old_name, const char *new_name, int check_udev, unsigned rely_on_udev)
 {
-	log_debug("%s: Stacking NODE_RENAME to %s", old_name, new_name);
-
 	return _stack_node_op(NODE_RENAME, new_name, 0, 0, 0,
-			      0, 0, old_name, 0, 0, check_udev);
+			      0, 0, old_name, 0, 0, check_udev, rely_on_udev);
 }
 
-int rm_dev_node(const char *dev_name, int check_udev)
+int rm_dev_node(const char *dev_name, int check_udev, unsigned rely_on_udev)
 {
-	log_debug("%s: Stacking NODE_DEL (replaces other stacked ops)", dev_name);
-
 	return _stack_node_op(NODE_DEL, dev_name, 0, 0, 0,
-			      0, 0, "", 0, 0, check_udev);
+			      0, 0, "", 0, 0, check_udev, rely_on_udev);
 }
 
 int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
@@ -955,11 +977,8 @@
 	if (read_ahead == DM_READ_AHEAD_AUTO)
 		return 1;
 
-	log_debug("%s: Stacking NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32
-		  ")", dev_name, read_ahead, read_ahead_flags);
-
 	return _stack_node_op(NODE_READ_AHEAD, dev_name, 0, 0, 0, 0,
-                              0, "", read_ahead, read_ahead_flags, 0);
+                              0, "", read_ahead, read_ahead_flags, 0, 0);
 }
 
 void update_devs(void)
@@ -1428,7 +1447,7 @@
 		return 0;
 	}
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d): Waiting for zero",
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) waiting for zero",
 		  cookie, semid);
 
 repeat_wait:
--- LVM2/libdm/libdm-common.h	2011/06/13 03:32:46	1.8
+++ LVM2/libdm/libdm-common.h	2011/06/27 21:43:59	1.9
@@ -23,10 +23,10 @@
 			     const char *type, const char *params);
 
 int add_dev_node(const char *dev_name, uint32_t minor, uint32_t major,
-		 uid_t uid, gid_t gid, mode_t mode, int check_udev);
-int rm_dev_node(const char *dev_name, int check_udev);
+		 uid_t uid, gid_t gid, mode_t mode, int check_udev, unsigned rely_on_udev);
+int rm_dev_node(const char *dev_name, int check_udev, unsigned rely_on_udev);
 int rename_dev_node(const char *old_name, const char *new_name,
-		    int check_udev);
+		    int check_udev, unsigned rely_on_udev);
 int get_dev_node_read_ahead(const char *dev_name, uint32_t *read_ahead);
 int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
 			    uint32_t read_ahead_flags);
--- LVM2/libdm/libdm-deptree.c	2011/06/24 19:33:41	1.98
+++ LVM2/libdm/libdm-deptree.c	2011/06/27 21:43:59	1.99
@@ -983,10 +983,9 @@
 
 	r = dm_task_run(dmt);
 
-	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
-	if (!(udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK))
-		rm_dev_node(name, dmt->cookie_set &&
-				  !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG));
+	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
+	rm_dev_node(name, dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG),
+			  dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
 
 	/* FIXME Remove node from tree or mark invalid? */
 
--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/24 19:33:41	1.107
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/27 21:43:59	1.108
@@ -2025,7 +2025,7 @@
 	struct dm_ioctl *dmi;
 	unsigned command;
 	int check_udev;
-	int udev_only;
+	int rely_on_udev;
 	int suspended_counter;
 
 #ifdef DM_COMPAT
@@ -2097,40 +2097,43 @@
 		}
 	}
 
+	/*
+	 * Are we expecting a udev operation to occur that we need to check for?
+	 */
 	check_udev = dmt->cookie_set &&
 		     !(dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
 		       DM_UDEV_DISABLE_DM_RULES_FLAG);
 
-	udev_only = dmt->cookie_set ? (dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
-					DM_UDEV_DISABLE_LIBRARY_FALLBACK) : 0;
+	rely_on_udev = dmt->cookie_set ? (dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
+					  DM_UDEV_DISABLE_LIBRARY_FALLBACK) : 0;
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
 		if ((dmt->add_node == DM_ADD_NODE_ON_CREATE) &&
-		    dmt->dev_name && *dmt->dev_name && !udev_only)
+		    dmt->dev_name && *dmt->dev_name && !rely_on_udev)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode, check_udev);
+				     dmt->mode, check_udev, rely_on_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (dmt->dev_name && !udev_only)
-			rm_dev_node(dmt->dev_name, check_udev);
+		if (dmt->dev_name && !rely_on_udev)
+			rm_dev_node(dmt->dev_name, check_udev, rely_on_udev);
 		break;
 
 	case DM_DEVICE_RENAME:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (!dmt->new_uuid && dmt->dev_name && !udev_only)
+		if (!dmt->new_uuid && dmt->dev_name)
 			rename_dev_node(dmt->dev_name, dmt->newname,
-					check_udev);
+					check_udev, rely_on_udev);
 		break;
 
 	case DM_DEVICE_RESUME:
 		if ((dmt->add_node == DM_ADD_NODE_ON_RESUME) &&
-		    dmt->dev_name && *dmt->dev_name && !udev_only)
+		    dmt->dev_name && *dmt->dev_name)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode, check_udev);
+				     dmt->mode, check_udev, rely_on_udev);
 		/* FIXME Kernel needs to fill in dmi->name */
 		set_dev_node_read_ahead(dmt->dev_name, dmt->read_ahead,
 					dmt->read_ahead_flags);
@@ -2140,9 +2143,9 @@
 		if (dmi->flags & DM_EXISTS_FLAG)
 			add_dev_node(dmi->name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid,
-				     dmt->gid, dmt->mode, 0);
+				     dmt->gid, dmt->mode, 0, rely_on_udev);
 		else if (dmt->dev_name)
-			rm_dev_node(dmt->dev_name, 0);
+			rm_dev_node(dmt->dev_name, 0, rely_on_udev);
 		break;
 
 	case DM_DEVICE_STATUS:
--- LVM2/man/dmsetup.8.in	2011/04/29 00:21:16	1.39
+++ LVM2/man/dmsetup.8.in	2011/06/27 21:43:59	1.40
@@ -181,6 +181,10 @@
 .IP \fB-v|--verbose\ [-v|--verbose]
 .br
 Produce additional output.
+.IP \fB--verifyudev
+If udev synchronisation is enabled, verify that udev operations get performed
+correctly and try to fix up the device nodes afterwards if not.
+.br
 .IP \fB--version
 .br
 Display the library and kernel driver version.
--- LVM2/tools/dmsetup.c	2011/06/17 14:55:51	1.161
+++ LVM2/tools/dmsetup.c	2011/06/27 21:43:59	1.162
@@ -135,7 +135,6 @@
 	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
-	UDEVFALLBACK_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
 	ROWS_ARG,
@@ -151,6 +150,7 @@
 	UNQUOTED_ARG,
 	UUID_ARG,
 	VERBOSE_ARG,
+	VERIFYUDEV_ARG,
 	VERSION_ARG,
 	YES_ARG,
 	ADD_NODE_ON_RESUME_ARG,
@@ -1007,7 +1007,7 @@
 	else
 		dirs_diff = strcmp(dev_dir, udev_dev_dir);
 
-	_udev_only = !dirs_diff && (_udev_cookie || !_switches[UDEVFALLBACK_ARG]);
+	_udev_only = !dirs_diff && (_udev_cookie || !_switches[VERIFYUDEV_ARG]);
 
 	if (dirs_diff) {
 		log_debug("The path %s used for creating device nodes that is "
@@ -2745,7 +2745,7 @@
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--udevcookie] [--noudevrules] [--noudevsync] [--udevfallback]\n"
+		"        [--udevcookie] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
@@ -3116,7 +3116,6 @@
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
-		{"udevfallback", 0, &ind, UDEVFALLBACK_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
@@ -3132,6 +3131,7 @@
 		{"unbuffered", 0, &ind, UNBUFFERED_ARG},
 		{"unquoted", 0, &ind, UNQUOTED_ARG},
 		{"verbose", 1, &ind, VERBOSE_ARG},
+		{"verifyudev", 0, &ind, VERIFYUDEV_ARG},
 		{"version", 0, &ind, VERSION_ARG},
 		{"yes", 0, &ind, YES_ARG},
 		{"addnodeonresume", 0, &ind, ADD_NODE_ON_RESUME_ARG},
@@ -3245,8 +3245,8 @@
 			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
 			_switches[NOUDEVSYNC_ARG]++;
-		if (ind == UDEVFALLBACK_ARG)
-			_switches[UDEVFALLBACK_ARG]++;
+		if (ind == VERIFYUDEV_ARG)
+			_switches[VERIFYUDEV_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);


