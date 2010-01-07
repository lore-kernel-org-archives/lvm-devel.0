From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Jan 2010 19:54:26 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM doc/example.co ...
Message-ID: <20100107195426.22742.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-07 19:54:23

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	doc            : example.conf 
	lib/activate   : dev_manager.c fs.c fs.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Add activation/udev_rules config option in lvm.conf.
	Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1370&r2=1.1371
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.325&r2=1.326
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2010/01/07 14:45:28	1.1370
+++ LVM2/WHATS_NEW	2010/01/07 19:54:21	1.1371
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add activation/udev_rules config option in lvm.conf.
   Add macro outfc() and export out_text_with_comment().
   Add macros outsize() and outhint().
   Use offsetof() macro for FIELD() macro in lib/report/report.c.
--- LVM2/WHATS_NEW_DM	2010/01/07 19:45:12	1.325
+++ LVM2/WHATS_NEW_DM	2010/01/07 19:54:21	1.326
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.
   Update code to show all fields for 'dmsetup info -c -o all'.
   Return error from dm_tree_deactivate_children().
--- LVM2/doc/example.conf	2010/01/06 13:27:07	1.53
+++ LVM2/doc/example.conf	2010/01/07 19:54:21	1.54
@@ -323,7 +323,7 @@
 }
 
 activation {
-    # Set to 0 to disable udev syncronisation (if compiled into the binaries).
+    # Set to 0 to disable udev synchronisation (if compiled into the binaries).
     # Processes will not wait for notification from udev.
     # They will continue irrespective of any possible udev processing
     # in the background.  You should only use this if udev is not running
@@ -333,6 +333,13 @@
     # waiting for udev, run 'dmsetup udevcomplete_all' manually to wake them up.
     udev_sync = 1
 
+    # Set to 0 to disable the udev rules installed by LVM2 (if built with
+    # --enable-udev_rules). LVM2 will then manage the /dev nodes and symlinks
+    # for active logical volumes directly itself.
+    # N.B. Manual intervention may be required if this setting is changed
+    # while any logical volumes are active.
+    udev_rules = 1
+
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
     # I/O errors on access.  You can instead use a device path, in which 
--- LVM2/lib/activate/dev_manager.c	2009/12/16 19:22:11	1.167
+++ LVM2/lib/activate/dev_manager.c	2010/01/07 19:54:21	1.168
@@ -658,6 +658,7 @@
 {
 	char *dlid, *name;
 	struct dm_info info, info2;
+	uint16_t udev_flags = 0;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -695,7 +696,20 @@
 		}
 	}
 
-	if (info.exists && !dm_tree_add_dev(dtree, info.major, info.minor)) {
+	if (layer || !lv_is_visible(lv))
+		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
+			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
+
+	if (lv_is_cow(lv))
+		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
+
+	if (!dm->cmd->current_settings.udev_rules)
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
+	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major,
+							    info.minor, udev_flags)) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
@@ -1034,6 +1048,10 @@
 	if (lv_is_cow(lv))
 		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
 
+	if (!dm->cmd->current_settings.udev_rules)
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
 	/*
 	 * Add LV to dtree.
 	 * If we're working with precommitted metadata, clear any
@@ -1151,7 +1169,8 @@
 		if (*layer)
 			continue;
 
-		fs_del_lv_byname(dm->cmd->dev_dir, vgname, lvname);
+		fs_del_lv_byname(dm->cmd->dev_dir, vgname, lvname,
+				 dm->cmd->current_settings.udev_rules);
 	}
 
 	return r;
--- LVM2/lib/activate/fs.c	2009/10/12 04:06:42	1.49
+++ LVM2/lib/activate/fs.c	2010/01/07 19:54:21	1.50
@@ -108,7 +108,7 @@
 }
 
 static int _mk_link(const char *dev_dir, const char *vg_name,
-		    const char *lv_name, const char *dev)
+		    const char *lv_name, const char *dev, int check_udev)
 {
 	char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
 	char vg_path[PATH_MAX];
@@ -166,7 +166,7 @@
 			return 0;
 		}
 
-		if (dm_udev_get_sync_support()) {
+		if (dm_udev_get_sync_support() && check_udev) {
 			/* Check udev created the correct link. */
 			if (!stat(link_path, &buf_lp) &&
 			    !stat(lv_path, &buf)) {
@@ -190,7 +190,7 @@
 			log_sys_error("unlink", lv_path);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support())
+	} else if (dm_udev_get_sync_support() && check_udev)
 		log_warn("The link %s should had been created by udev "
 			  "but it was not found. Falling back to "
 			  "direct link creation.", lv_path);
@@ -208,7 +208,7 @@
 }
 
 static int _rm_link(const char *dev_dir, const char *vg_name,
-		    const char *lv_name)
+		    const char *lv_name, int check_udev)
 {
 	struct stat buf;
 	char lv_path[PATH_MAX];
@@ -221,7 +221,7 @@
 
 	if (lstat(lv_path, &buf) && errno == ENOENT)
 		return 1;
-	else if (dm_udev_get_sync_support())
+	else if (dm_udev_get_sync_support() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
@@ -248,25 +248,26 @@
 
 static int _do_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 		     const char *lv_name, const char *dev,
-		     const char *old_lv_name)
+		     const char *old_lv_name, int check_udev)
 {
 	switch (type) {
 	case FS_ADD:
 		if (!_mk_dir(dev_dir, vg_name) ||
-		    !_mk_link(dev_dir, vg_name, lv_name, dev))
+		    !_mk_link(dev_dir, vg_name, lv_name, dev, check_udev))
 			return_0;
 		break;
 	case FS_DEL:
-		if (!_rm_link(dev_dir, vg_name, lv_name) ||
+		if (!_rm_link(dev_dir, vg_name, lv_name, check_udev) ||
 		    !_rm_dir(dev_dir, vg_name))
 			return_0;
 		break;
 		/* FIXME Use rename() */
 	case FS_RENAME:
-		if (old_lv_name && !_rm_link(dev_dir, vg_name, old_lv_name))
+		if (old_lv_name && !_rm_link(dev_dir, vg_name, old_lv_name,
+					     check_udev))
 			stack;
 
-		if (!_mk_link(dev_dir, vg_name, lv_name, dev))
+		if (!_mk_link(dev_dir, vg_name, lv_name, dev, check_udev))
 			stack;
 	}
 
@@ -278,6 +279,7 @@
 struct fs_op_parms {
 	struct dm_list list;
 	fs_op_t type;
+	int check_udev;
 	char *dev_dir;
 	char *vg_name;
 	char *lv_name;
@@ -295,7 +297,7 @@
 
 static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 			const char *lv_name, const char *dev,
-			const char *old_lv_name)
+			const char *old_lv_name, int check_udev)
 {
 	struct fs_op_parms *fsp;
 	size_t len = strlen(dev_dir) + strlen(vg_name) + strlen(lv_name) +
@@ -309,6 +311,7 @@
 
 	pos = fsp->names;
 	fsp->type = type;
+	fsp->check_udev = check_udev;
 
 	_store_str(&pos, &fsp->dev_dir, dev_dir);
 	_store_str(&pos, &fsp->vg_name, vg_name);
@@ -329,40 +332,43 @@
 	dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
 		fsp = dm_list_item(fsph, struct fs_op_parms);
 		_do_fs_op(fsp->type, fsp->dev_dir, fsp->vg_name, fsp->lv_name,
-			  fsp->dev, fsp->old_lv_name);
+			  fsp->dev, fsp->old_lv_name, fsp->check_udev);
 		dm_list_del(&fsp->list);
 		dm_free(fsp);
 	}
 }
 
 static int _fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
-		  const char *lv_name, const char *dev, const char *old_lv_name)
+		  const char *lv_name, const char *dev, const char *old_lv_name,
+		  int check_udev)
 {
 	if (memlock()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
-				  old_lv_name))
+				  old_lv_name, check_udev))
 			return_0;
 		return 1;
 	}
 
-	return _do_fs_op(type, dev_dir, vg_name, lv_name, dev, old_lv_name);
+	return _do_fs_op(type, dev_dir, vg_name, lv_name, dev,
+			 old_lv_name, check_udev);
 }
 
 int fs_add_lv(const struct logical_volume *lv, const char *dev)
 {
 	return _fs_op(FS_ADD, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
-		      dev, "");
+		      dev, "", lv->vg->cmd->current_settings.udev_rules);
 }
 
 int fs_del_lv(const struct logical_volume *lv)
 {
 	return _fs_op(FS_DEL, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
-		      "", "");
+		      "", "", lv->vg->cmd->current_settings.udev_rules);
 }
 
-int fs_del_lv_byname(const char *dev_dir, const char *vg_name, const char *lv_name)
+int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
+		     const char *lv_name, int check_udev)
 {
-	return _fs_op(FS_DEL, dev_dir, vg_name, lv_name, "", "");
+	return _fs_op(FS_DEL, dev_dir, vg_name, lv_name, "", "", check_udev);
 }
 
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
@@ -370,12 +376,14 @@
 {
 	if (strcmp(old_vgname, lv->vg->name)) {
 		return
-			(_fs_op(FS_DEL, lv->vg->cmd->dev_dir, old_vgname, old_lvname, "", "") &&
-			 _fs_op(FS_ADD, lv->vg->cmd->dev_dir, lv->vg->name, lv->name, dev, ""));
+			(_fs_op(FS_DEL, lv->vg->cmd->dev_dir, old_vgname,
+				old_lvname, "", "", lv->vg->cmd->current_settings.udev_rules) &&
+			 _fs_op(FS_ADD, lv->vg->cmd->dev_dir, lv->vg->name,
+				lv->name, dev, "", lv->vg->cmd->current_settings.udev_rules));
 	}
 	else 
 		return _fs_op(FS_RENAME, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
-			      dev, old_lvname);
+			      dev, old_lvname, lv->vg->cmd->current_settings.udev_rules);
 }
 
 void fs_unlock(void)
--- LVM2/lib/activate/fs.h	2008/12/19 14:22:48	1.13
+++ LVM2/lib/activate/fs.h	2010/01/07 19:54:21	1.14
@@ -25,9 +25,10 @@
  */
 int fs_add_lv(const struct logical_volume *lv, const char *dev);
 int fs_del_lv(const struct logical_volume *lv);
-int fs_del_lv_byname(const char *dev_dir, const char *vg_name, const char *lv_name);
+int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
+		     const char *lv_name, int check_udev);
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
-		const char *old_vgname, const char *old_lvname);
+		 const char *old_vgname, const char *old_lvname);
 void fs_unlock(void);
 
 #endif
--- LVM2/lib/commands/toolcontext.c	2009/11/30 17:17:11	1.89
+++ LVM2/lib/commands/toolcontext.c	2010/01/07 19:54:21	1.90
@@ -267,6 +267,10 @@
 		return 0;
 	}
 
+	cmd->default_settings.udev_rules = find_config_tree_int(cmd,
+								"activation/udev_rules",
+								DEFAULT_UDEV_RULES);
+
 	cmd->default_settings.udev_sync = find_config_tree_int(cmd,
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
--- LVM2/lib/commands/toolcontext.h	2009/11/24 16:10:26	1.36
+++ LVM2/lib/commands/toolcontext.h	2010/01/07 19:54:22	1.37
@@ -34,6 +34,7 @@
 	int archive;		/* should we archive ? */
 	int backup;		/* should we backup ? */
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
+	int udev_rules;
 	int udev_sync;
 	int cache_vgmetadata;
 	const char *msg_prefix;
--- LVM2/lib/config/defaults.h	2010/01/06 13:27:07	1.57
+++ LVM2/lib/config/defaults.h	2010/01/07 19:54:22	1.58
@@ -67,6 +67,7 @@
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
+#define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
--- LVM2/libdm/.exported_symbols	2009/11/06 00:43:08	1.45
+++ LVM2/libdm/.exported_symbols	2010/01/07 19:54:22	1.46
@@ -50,6 +50,7 @@
 dm_tree_create
 dm_tree_free
 dm_tree_add_dev
+dm_tree_add_dev_with_udev_flags
 dm_tree_add_new_dev
 dm_tree_add_new_dev_with_udev_flags
 dm_tree_node_get_name
--- LVM2/libdm/libdevmapper.h	2009/11/13 12:43:21	1.103
+++ LVM2/libdm/libdevmapper.h	2010/01/07 19:54:22	1.104
@@ -267,6 +267,8 @@
  * Add nodes to the tree for a given device and all the devices it uses.
  */
 int dm_tree_add_dev(struct dm_tree *tree, uint32_t major, uint32_t minor);
+int dm_tree_add_dev_with_udev_flags(struct dm_tree *tree, uint32_t major,
+				    uint32_t minor, uint16_t udev_flags);
 
 /*
  * Add a new node to the tree if it doesn't already exist.
--- LVM2/libdm/libdm-deptree.c	2010/01/05 21:06:26	1.67
+++ LVM2/libdm/libdm-deptree.c	2010/01/07 19:54:22	1.68
@@ -454,7 +454,8 @@
 
 static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
 				     struct dm_tree_node *parent,
-				     uint32_t major, uint32_t minor)
+				     uint32_t major, uint32_t minor,
+				     uint16_t udev_flags)
 {
 	struct dm_task *dmt = NULL;
 	struct dm_info info;
@@ -471,7 +472,7 @@
 			return_NULL;
 
 		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
-						  NULL, 0)))
+						  NULL, udev_flags)))
 			goto_out;
 		new = 1;
 	}
@@ -497,7 +498,7 @@
 	/* Add dependencies to tree */
 	for (i = 0; i < deps->count; i++)
 		if (!_add_dev(dtree, node, MAJOR(deps->device[i]),
-			      MINOR(deps->device[i]))) {
+			      MINOR(deps->device[i]), udev_flags)) {
 			node = NULL;
 			goto_out;
 		}
@@ -652,7 +653,13 @@
 
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
-	return _add_dev(dtree, &dtree->root, major, minor) ? 1 : 0;
+	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
+}
+
+int dm_tree_add_dev_with_udev_flags(struct dm_tree *dtree, uint32_t major,
+				    uint32_t minor, uint16_t udev_flags)
+{
+	return _add_dev(dtree, &dtree->root, major, minor, udev_flags) ? 1 : 0;
 }
 
 const char *dm_tree_node_get_name(struct dm_tree_node *node)
@@ -873,7 +880,8 @@
 	r = dm_task_run(dmt);
 
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
-	rm_dev_node(name, dmt->cookie_set);
+	rm_dev_node(name, dmt->cookie_set &&
+			  !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG));
 
 	/* FIXME Remove node from tree or mark invalid? */
 
@@ -1963,7 +1971,8 @@
 		}
 
 		/* FIXME Check correct macro use */
-		if (!(dev_node = _add_dev(node->dtree, node, MAJOR(info.st_rdev), MINOR(info.st_rdev))))
+		if (!(dev_node = _add_dev(node->dtree, node, MAJOR(info.st_rdev),
+					  MINOR(info.st_rdev), 0)))
 			return_0;
 	}
 


