From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Oct 2009 14:29:36 -0000
Subject: LVM2 lib/activate/dev_manager.c libdm/libdevma ...
Message-ID: <20091026142936.15176.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-26 14:29:35

Modified files:
	lib/activate   : dev_manager.c 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 
	                 libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 
	udev           : 10-dm.rules.in 11-dm-lvm.rules 13-dm-disk.rules 
	                 Makefile.in 

Log message:
	Several changes to udev support code:
	
	- we have these levels when the udev rules are processed:
	10-dm.rules --> [11-dm-<subsystem>.rules] --> [12-dm-permissions.rules] -->
	13-dm-disk.rules --> [...all the other foreign rules...] --> 95-dm-notify.rules
	
	- each level can be disabled now by
	DM_UDEV_DISABLE_{DM, SUBSYSTEM, DISK, OTHER}_RULES_FLAG
	
	- add DM_UDEV_DISABLE_DM_RULES_FLAG to disable 10-dm.rules
	
	- add DM_UDEV_DISABLE_OTHER_RULES_FLAG to disable all the other (non-dm) rules.
	We cutoff these rules by using the 'last_rule', so this one should really be
	used with great care and in well-founded situations. We use this for lvm's
	hidden and layer devices now.
	
	- add a parameter for add_dev_node, rm_dev_node and rename_dev_node so it's
	possible to switch on/off udev checks
	
	- use DM_UDEV_DISABLE_DM_RULES_FLAG and DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG
	if there's no cookie set and we have resume, remove and rename ioctl.
	This could happen when someone uses the libdevmapper that is compiled with
	udev_sync but the software does not make use of it. This way we can switch
	off the rules and fallback to libdevmapper node creation so there's no
	udev/libdevmapper race.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/activate/dev_manager.c	2009/10/26 10:01:57	1.161
+++ LVM2/lib/activate/dev_manager.c	2009/10/26 14:29:33	1.162
@@ -1026,7 +1026,8 @@
 
 	if (layer || !lv_is_visible(lv))
 		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
-			      DM_UDEV_DISABLE_DISK_RULES_FLAG;
+			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
 
 	if (lv_is_cow(lv))
 		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
--- LVM2/libdm/libdevmapper.h	2009/10/22 13:00:07	1.99
+++ LVM2/libdm/libdevmapper.h	2009/10/26 14:29:33	1.100
@@ -1035,17 +1035,33 @@
 #define DM_COOKIE_MAGIC 0x0D4D
 #define DM_UDEV_FLAGS_MASK 0xFFFF0000
 #define DM_UDEV_FLAGS_SHIFT 16
+
+/*
+ * DM_UDEV_DISABLE_DM_RULES_FLAG is set in case we need to disable
+ * basic device-mapper udev rules that create symlinks in /dev/<DM_DIR>
+ * directory. However, we can't reliably prevent creating default
+ * nodes by udev (commonly /dev/dm-X, where X is a number).
+ */
+#define DM_UDEV_DISABLE_DM_RULES_FLAG 0x0001
 /*
  * DM_UDEV_DISABLE_SUBSYTEM_RULES_FLAG is set in case we need to disable
  * subsystem udev rules, but still we need the general DM udev rules to
  * be applied (to create the nodes and symlinks under /dev and /dev/disk).
  */
-#define DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG 0x0001
+#define DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG 0x0002
 /*
  * DM_UDEV_DISABLE_DISK_RULES_FLAG is set in case we need to disable
  * general DM rules that set symlinks in /dev/disk directory.
  */
-#define DM_UDEV_DISABLE_DISK_RULES_FLAG 0x0002
+#define DM_UDEV_DISABLE_DISK_RULES_FLAG 0x0004
+/*
+ * DM_UDEV_DISABLE_OTHER_RULES_FLAG is set in case we need to disable
+ * all the other rules that are not general device-mapper nor subsystem
+ * related (the rules belong to other software or packages). Use this
+ * flag with care since it will cutoff the rule processing after the
+ * last device-mapper/subsytem rule is applied.
+ */
+#define DM_UDEV_DISABLE_OTHER_RULES_FLAG 0x0008
 /*
  * DM_UDEV_LOW_PRIORITY_FLAG is set in case we need to instruct the
  * udev rules to give low priority to the device that is currently
@@ -1054,7 +1070,7 @@
  * Common situation is a name based on FS UUID while using origin and
  * snapshot devices.
  */
-#define DM_UDEV_LOW_PRIORITY_FLAG 0x0004
+#define DM_UDEV_LOW_PRIORITY_FLAG 0x0010
 
 int dm_cookie_supported(void);
 
--- LVM2/libdm/libdm-common.c	2009/10/22 12:55:47	1.87
+++ LVM2/libdm/libdm-common.c	2009/10/26 14:29:34	1.88
@@ -179,6 +179,7 @@
 	dmt->no_open_count = 0;
 	dmt->read_ahead = DM_READ_AHEAD_AUTO;
 	dmt->read_ahead_flags = 0;
+	dmt->event_nr = 0;
 	dmt->cookie_set = 0;
 
 	return dmt;
@@ -401,7 +402,7 @@
 }
 
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
-			 uid_t uid, gid_t gid, mode_t mode)
+			 uid_t uid, gid_t gid, mode_t mode, int check_udev)
 {
 	char path[PATH_MAX];
 	struct stat info;
@@ -426,7 +427,7 @@
 				  dev_name);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support())
+	} else if (dm_udev_get_sync_support() && check_udev)
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
@@ -451,7 +452,7 @@
 	return 1;
 }
 
-static int _rm_dev_node(const char *dev_name)
+static int _rm_dev_node(const char *dev_name, int check_udev)
 {
 	char path[PATH_MAX];
 	struct stat info;
@@ -460,7 +461,7 @@
 
 	if (stat(path, &info) < 0)
 		return 1;
-	else if (dm_udev_get_sync_support())
+	else if (dm_udev_get_sync_support() && check_udev)
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
@@ -474,7 +475,8 @@
 	return 1;
 }
 
-static int _rename_dev_node(const char *old_name, const char *new_name)
+static int _rename_dev_node(const char *old_name, const char *new_name,
+			    int check_udev)
 {
 	char oldpath[PATH_MAX];
 	char newpath[PATH_MAX];
@@ -489,7 +491,7 @@
 				  "is already present", newpath);
 			return 0;
 		}
-		else if (dm_udev_get_sync_support()) {
+		else if (dm_udev_get_sync_support() && check_udev) {
 			if (stat(oldpath, &info) < 0 &&
 				 errno == ENOENT)
 				/* assume udev already deleted this */
@@ -499,7 +501,7 @@
 					 "by udev but old node is still present. "
 					 "Falling back to direct old node removal.",
 					 oldpath, newpath);
-				return _rm_dev_node(old_name);
+				return _rm_dev_node(old_name, 0);
 			}
 		}
 
@@ -513,7 +515,7 @@
 			return 0;
 		}
 	}
-	else if (dm_udev_get_sync_support())
+	else if (dm_udev_get_sync_support() && check_udev)
 		log_warn("The node %s should have been renamed to %s "
 			 "by udev but new node is not present. "
 			 "Falling back to direct node rename.",
@@ -652,15 +654,16 @@
 static int _do_node_op(node_op_t type, const char *dev_name, uint32_t major,
 		       uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 		       const char *old_name, uint32_t read_ahead,
-		       uint32_t read_ahead_flags)
+		       uint32_t read_ahead_flags, int check_udev)
 {
 	switch (type) {
 	case NODE_ADD:
-		return _add_dev_node(dev_name, major, minor, uid, gid, mode);
+		return _add_dev_node(dev_name, major, minor, uid, gid,
+				     mode, check_udev);
 	case NODE_DEL:
-		return _rm_dev_node(dev_name);
+		return _rm_dev_node(dev_name, check_udev);
 	case NODE_RENAME:
-		return _rename_dev_node(old_name, dev_name);
+		return _rename_dev_node(old_name, dev_name, check_udev);
 	case NODE_READ_AHEAD:
 		return _set_dev_node_read_ahead(dev_name, read_ahead,
 						read_ahead_flags);
@@ -683,6 +686,7 @@
 	uint32_t read_ahead;
 	uint32_t read_ahead_flags;
 	char *old_name;
+	int check_udev;
 	char names[0];
 };
 
@@ -696,7 +700,7 @@
 static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 			  uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 			  const char *old_name, uint32_t read_ahead,
-			  uint32_t read_ahead_flags)
+			  uint32_t read_ahead_flags, int check_udev)
 {
 	struct node_op_parms *nop;
 	struct dm_list *noph, *nopht;
@@ -730,6 +734,7 @@
 	nop->mode = mode;
 	nop->read_ahead = read_ahead;
 	nop->read_ahead_flags = read_ahead_flags;
+	nop->check_udev = check_udev;
 
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
@@ -748,35 +753,37 @@
 		nop = dm_list_item(noph, struct node_op_parms);
 		_do_node_op(nop->type, nop->dev_name, nop->major, nop->minor,
 			    nop->uid, nop->gid, nop->mode, nop->old_name,
-			    nop->read_ahead, nop->read_ahead_flags);
+			    nop->read_ahead, nop->read_ahead_flags,
+			    nop->check_udev);
 		dm_list_del(&nop->list);
 		dm_free(nop);
 	}
 }
 
 int add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
-		 uid_t uid, gid_t gid, mode_t mode)
+		 uid_t uid, gid_t gid, mode_t mode, int check_udev)
 {
 	log_debug("%s: Stacking NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o",
 		  dev_name, major, minor, uid, gid, mode);
 
-	return _stack_node_op(NODE_ADD, dev_name, major, minor, uid, gid, mode,
-			      "", 0, 0);
+	return _stack_node_op(NODE_ADD, dev_name, major, minor, uid,
+			      gid, mode, "", 0, 0, check_udev);
 }
 
-int rename_dev_node(const char *old_name, const char *new_name)
+int rename_dev_node(const char *old_name, const char *new_name, int check_udev)
 {
 	log_debug("%s: Stacking NODE_RENAME to %s", old_name, new_name);
 
-	return _stack_node_op(NODE_RENAME, new_name, 0, 0, 0, 0, 0, old_name,
-			      0, 0);
+	return _stack_node_op(NODE_RENAME, new_name, 0, 0, 0,
+			      0, 0, old_name, 0, 0, check_udev);
 }
 
-int rm_dev_node(const char *dev_name)
+int rm_dev_node(const char *dev_name, int check_udev)
 {
 	log_debug("%s: Stacking NODE_DEL (replaces other stacked ops)", dev_name);
 
-	return _stack_node_op(NODE_DEL, dev_name, 0, 0, 0, 0, 0, "", 0, 0);
+	return _stack_node_op(NODE_DEL, dev_name, 0, 0, 0,
+			      0, 0, "", 0, 0, check_udev);
 }
 
 int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
@@ -788,8 +795,8 @@
 	log_debug("%s: Stacking NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32
 		  ")", dev_name, read_ahead, read_ahead_flags);
 
-	return _stack_node_op(NODE_READ_AHEAD, dev_name, 0, 0, 0, 0, 0, "",
-			      read_ahead, read_ahead_flags);
+	return _stack_node_op(NODE_READ_AHEAD, dev_name, 0, 0, 0, 0,
+                              0, "", read_ahead, read_ahead_flags, 0);
 }
 
 void update_devs(void)
--- LVM2/libdm/libdm-common.h	2007/11/30 14:59:57	1.5
+++ LVM2/libdm/libdm-common.h	2009/10/26 14:29:34	1.6
@@ -23,9 +23,10 @@
 			     const char *type, const char *params);
 
 int add_dev_node(const char *dev_name, uint32_t minor, uint32_t major,
-		 uid_t uid, gid_t gid, mode_t mode);
-int rm_dev_node(const char *dev_name);
-int rename_dev_node(const char *old_name, const char *new_name);
+		 uid_t uid, gid_t gid, mode_t mode, int check_udev);
+int rm_dev_node(const char *dev_name, int check_udev);
+int rename_dev_node(const char *old_name, const char *new_name,
+		    int check_udev);
 int get_dev_node_read_ahead(const char *dev_name, uint32_t *read_ahead);
 int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
 			    uint32_t read_ahead_flags);
--- LVM2/libdm/libdm-deptree.c	2009/10/22 13:00:07	1.60
+++ LVM2/libdm/libdm-deptree.c	2009/10/26 14:29:34	1.61
@@ -873,7 +873,7 @@
 	r = dm_task_run(dmt);
 
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
-	rm_dev_node(name);
+	rm_dev_node(name, dmt->cookie_set);
 
 	/* FIXME Remove node from tree or mark invalid? */
 
--- LVM2/libdm/ioctl/libdm-iface.c	2009/10/22 12:55:48	1.63
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/10/26 14:29:34	1.64
@@ -731,24 +731,24 @@
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
 		add_dev_node(dmt->dev_name, MAJOR(dmi->dev), MINOR(dmi->dev),
-			     dmt->uid, dmt->gid, dmt->mode);
+			     dmt->uid, dmt->gid, dmt->mode, 0);
 		break;
 
 	case DM_DEVICE_REMOVE:
-		rm_dev_node(dmt->dev_name);
+		rm_dev_node(dmt->dev_name, 0);
 		break;
 
 	case DM_DEVICE_RENAME:
-		rename_dev_node(dmt->dev_name, dmt->newname);
+		rename_dev_node(dmt->dev_name, dmt->newname, 0);
 		break;
 
 	case DM_DEVICE_MKNODES:
 		if (dmi->flags & DM_EXISTS_FLAG)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev),
-				     dmt->uid, dmt->gid, dmt->mode);
+				     MINOR(dmi->dev), dmt->uid,
+				     dmt->gid, dmt->mode, 0);
 		else
-			rm_dev_node(dmt->dev_name);
+			rm_dev_node(dmt->dev_name, 0);
 		break;
 
 	case DM_DEVICE_STATUS:
@@ -1534,6 +1534,8 @@
 	task->uid = dmt->uid;
 	task->gid = dmt->gid;
 	task->mode = dmt->mode;
+	/* FIXME: Just for udev_check in dm_task_run. Can we avoid this? */
+	task->cookie_set = dmt->cookie_set;
 
 	r = dm_task_run(task);
 	dm_task_destroy(task);
@@ -1690,6 +1692,36 @@
 	if (dmt->no_open_count)
 		dmi->flags |= DM_SKIP_BDGET_FLAG;
 
+	/*
+	 * Prevent udev vs. libdevmapper race when processing nodes and
+	 * symlinks. This can happen when the udev rules are installed and
+	 * udev synchronisation code is enabled in libdevmapper but the
+	 * software using libdevmapper does not make use of it (by not calling
+	 * dm_task_set_cookie before). We need to instruct the udev rules not
+	 * to be applied at all in this situation so we can gracefully fallback
+	 * to libdevmapper's node and symlink creation code.
+	 */
+	if (dm_udev_get_sync_support() && !dmt->cookie_set &&
+	    (dmt->type == DM_DEVICE_RESUME ||
+	     dmt->type == DM_DEVICE_REMOVE ||
+	     dmt->type == DM_DEVICE_RENAME)) {
+		log_debug("Cookie value is not set while trying to call "
+			  "DM_DEVICE_RESUME, DM_DEVICE_REMOVE or DM_DEVICE_RENAME "
+			  "ioctl. Please, consider using libdevmapper's udev "
+			  "synchronisation interface or disable it explicitly "
+			  "by calling dm_udev_set_sync_support(0).");
+		log_debug("Switching off device-mapper and all subsystem related "
+			  "udev rules. Falling back to libdevmapper node creation.");
+		/*
+		 * Disable general dm and subsystem rules but keep dm disk rules
+		 * if not flagged out explicitly before. We need /dev/disk content
+		 * for the software that expects it.
+		*/
+		dmi->event_nr |= (DM_UDEV_DISABLE_DM_RULES_FLAG |
+				  DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) <<
+				 DM_UDEV_FLAGS_SHIFT;
+	}
+
 	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
 		  "%s%c%c%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
@@ -1741,6 +1773,7 @@
 {
 	struct dm_ioctl *dmi;
 	unsigned command;
+	int check_udev;
 
 #ifdef DM_COMPAT
 	if (_dm_version == 1)
@@ -1795,24 +1828,28 @@
 		}
 	}
 
+	check_udev = dmt->cookie_set &&
+		     !(dmt->event_nr >> DM_UDEV_FLAGS_SHIFT &
+		       DM_UDEV_DISABLE_DM_RULES_FLAG);
+
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
 		if (dmt->dev_name && *dmt->dev_name)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
-				     dmt->mode);
+				     dmt->mode, check_udev);
 		break;
-
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
 		if (dmt->dev_name)
-			rm_dev_node(dmt->dev_name);
+			rm_dev_node(dmt->dev_name, check_udev);
 		break;
 
 	case DM_DEVICE_RENAME:
 		/* FIXME Kernel needs to fill in dmi->name */
 		if (dmt->dev_name)
-			rename_dev_node(dmt->dev_name, dmt->newname);
+			rename_dev_node(dmt->dev_name, dmt->newname,
+					check_udev);
 		break;
 
 	case DM_DEVICE_RESUME:
@@ -1824,10 +1861,10 @@
 	case DM_DEVICE_MKNODES:
 		if (dmi->flags & DM_EXISTS_FLAG)
 			add_dev_node(dmi->name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev),
-				     dmt->uid, dmt->gid, dmt->mode);
+				     MINOR(dmi->dev), dmt->uid,
+				     dmt->gid, dmt->mode, 0);
 		else if (dmt->dev_name)
-			rm_dev_node(dmt->dev_name);
+			rm_dev_node(dmt->dev_name, 0);
 		break;
 
 	case DM_DEVICE_STATUS:
--- LVM2/tools/dmsetup.c	2009/10/22 12:55:48	1.125
+++ LVM2/tools/dmsetup.c	2009/10/26 14:29:34	1.126
@@ -779,10 +779,12 @@
 	uint32_t cookie;
 	uint16_t flags;
 	int i;
-	static const char *dm_flag_names[] = {"DISABLE_SUBSYSTEM_RULES",
+	static const char *dm_flag_names[] = {"DISABLE_DM_RULES",
+					      "DISABLE_SUBSYSTEM_RULES",
 					      "DISABLE_DISK_RULES",
+					      "DISABLE_OTHER_RULES",
 					      "LOW_PRIORITY",
-					       0, 0, 0, 0, 0};
+					       0, 0, 0};
 
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
--- LVM2/udev/10-dm.rules.in	2009/10/22 13:11:33	1.4
+++ LVM2/udev/10-dm.rules.in	2009/10/26 14:29:34	1.5
@@ -21,8 +21,16 @@
 TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 
 # Decode udev control flags and set environment variables appropriately.
+# These flags are encoded in DM_COOKIE variable that was introduced in
+# kernel version 2.6.31. Therefore, we can use this feature with
+# kernels >= 2.6.31 only.
 ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
 
+# Normally, we would test for DM_UDEV_DISABLE_DM_RULES_FLAG here and skip
+# the rules if set. However, we need to set DM_* environment variables
+# for now to properly filter out inappropriate events. This dependency
+# might be removed in the future.
+
 ACTION!="add|change", GOTO="dm_end"
 
 # Normally, we operate on "change" events only. But when
@@ -58,18 +66,19 @@
 # possible future changes.
 ENV{DM_UDEV_RULES_VSN}="1"
 
-ENV{DM_NAME}=="?*", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
+ENV{DM_UDEV_DISABLE_DM_RULES_FLAG}!="1", ENV{DM_NAME}=="?*", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
 
 # We have to ignore further rule application for inappropriate events
 # and devices. But still send the notification if cookie exists.
-ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_last_rule"
-ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_last_rule"
-ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_last_rule"
+ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_disable"
+ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_disable"
+ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_disable"
 
 GOTO="dm_end"
 
-LABEL="dm_last_rule"
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
-OPTIONS+="last_rule"
+LABEL="dm_disable"
+ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}="1"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
 
 LABEL="dm_end"
--- LVM2/udev/11-dm-lvm.rules	2009/10/26 14:04:31	1.1
+++ LVM2/udev/11-dm-lvm.rules	2009/10/26 14:29:34	1.2
@@ -17,7 +17,7 @@
 # Use DM name and split it up into its VG/LV/layer constituents.
 IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
-# Do not create symlinks for hidden subdevices.
+# Do not create symlinks for inappropriate subdevices.
 ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_end"
 
 # Create symlinks for top-level devices only.
--- LVM2/udev/13-dm-disk.rules	2009/10/26 14:04:31	1.1
+++ LVM2/udev/13-dm-disk.rules	2009/10/26 14:29:34	1.2
@@ -7,17 +7,26 @@
 
 # "add" event is processed on coldplug only!
 ACTION!="add|change", GOTO="dm_end"
-ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
-ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_other"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_other"
 
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
-ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
+ENV{DM_SUSPENDED}=="1", GOTO="dm_other"
 
 IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
+# Cutoff all subsequent rules if instructed by a flag.
+# This flag should be used in well-founded situations only to prevent
+# any problems that could arise when processing this event further by
+# foreign rules (various temporary and hidden devices mostly).
+LABEL="dm_other"
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}!="1", GOTO="dm_end"
+ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
+OPTIONS+="last_rule"
+
 LABEL="dm_end"
--- LVM2/udev/Makefile.in	2009/10/02 19:10:38	1.3
+++ LVM2/udev/Makefile.in	2009/10/26 14:29:34	1.4
@@ -16,8 +16,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-DM_RULES=10-dm.rules 12-dm-disk.rules 95-dm-notify.rules
-LVM_RULES=11-lvm.rules
+DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
+LVM_RULES=11-dm-lvm.rules
 DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
 
 CLEAN_TARGETS=10-dm.rules


