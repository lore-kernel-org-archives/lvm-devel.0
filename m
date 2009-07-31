From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 18:30:33 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/activate/d ...
Message-ID: <20090731183033.5612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 18:30:32

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/activate   : dev_manager.c 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Set cookies in activation code and wait for udev to complete processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1222&r2=1.1223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.290&r2=1.291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2009/07/31 17:51:45	1.1222
+++ LVM2/WHATS_NEW	2009/07/31 18:30:31	1.1223
@@ -1,7 +1,6 @@
 Version 2.02.51 - 
 ================================
-  Add udevcomplete and --noudevwait to dmsetup.
-  Add libdevmapper functions to support synchronisation with udev.
+  Set cookies in activation code and wait for udev to complete processing.
   Added configure --enable-udev_rules --enable-udev_sync.
   Added configure --with-udev-prefix --with-udevdir.
   Added udev dir to hold udev rules.
--- LVM2/WHATS_NEW_DM	2009/07/28 20:47:40	1.290
+++ LVM2/WHATS_NEW_DM	2009/07/31 18:30:31	1.291
@@ -1,5 +1,7 @@
 Version 1.02.36 -
 ================================
+  Add udevcomplete and --noudevwait to dmsetup.
+  Add libdevmapper functions to support synchronisation with udev.
 
 Version 1.02.35 - 28th July 2009
 ================================
--- LVM2/lib/activate/dev_manager.c	2009/06/17 20:55:24	1.153
+++ LVM2/lib/activate/dev_manager.c	2009/07/31 18:30:31	1.154
@@ -1131,8 +1131,12 @@
 		if (!*layer)
 			continue;
 
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
+		dm_tree_set_cookie(root, 0);
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid))) {
+			dm_udev_cleanup(dm_tree_get_cookie(root));
 			return_0;
+		}
+		dm_udev_wait(dm_tree_get_cookie(root));
 	}
 
 	return 1;
@@ -1165,8 +1169,12 @@
 		break;
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
-		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		dm_tree_set_cookie(root, 0);
+		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
+			dm_udev_cleanup(dm_tree_get_cookie(root));
 			goto_out;
+		}
+		dm_udev_wait(dm_tree_get_cookie(root));
 		if (!_remove_lv_symlinks(dm, root))
 			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
@@ -1185,15 +1193,24 @@
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		dm_tree_set_cookie(root, 0);
+		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
+			dm_udev_cleanup(dm_tree_get_cookie(root));
 			goto_out;
+		}
+		dm_udev_wait(dm_tree_get_cookie(root));
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
-		if ((action == ACTIVATE) &&
-		    !dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
-			goto_out;
+		if (action == ACTIVATE) {
+			dm_tree_set_cookie(root, 0);
+			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
+				dm_udev_cleanup(dm_tree_get_cookie(root));
+				goto_out;
+			}
+			dm_udev_wait(dm_tree_get_cookie(root));
+		}
 
 		if (!_create_lv_symlinks(dm, root)) {
 			log_error("Failed to create symlinks for %s.", lv->name);
--- LVM2/libdm/.exported_symbols	2009/07/31 17:51:46	1.40
+++ LVM2/libdm/.exported_symbols	2009/07/31 18:30:31	1.41
@@ -79,6 +79,8 @@
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
+dm_tree_set_cookie
+dm_tree_get_cookie
 dm_is_dm_major
 dm_mknodes
 dm_malloc_aux
--- LVM2/libdm/libdevmapper.h	2009/07/31 17:51:46	1.93
+++ LVM2/libdm/libdevmapper.h	2009/07/31 18:30:32	1.94
@@ -433,6 +433,9 @@
 				 uint32_t read_ahead,
 				 uint32_t read_ahead_flags);
 
+void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie);
+uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
+
 /*****************************************************************************
  * Library functions
  *****************************************************************************/
--- LVM2/libdm/libdm-deptree.c	2009/07/07 16:36:05	1.53
+++ LVM2/libdm/libdm-deptree.c	2009/07/31 18:30:32	1.54
@@ -141,6 +141,7 @@
 	struct dm_tree_node root;
 	int skip_lockfs;		/* 1 skips lockfs (for non-snapshots) */
 	int no_flush;		/* 1 sets noflush (mirrors/multipath) */
+	uint32_t cookie;
 };
 
 struct dm_tree *dm_tree_create(void)
@@ -819,10 +820,10 @@
 	return r;
 }
 
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor)
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, uint32_t *cookie)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	log_verbose("Removing %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
@@ -833,26 +834,33 @@
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set device number for %s deactivation", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
+	if (!dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
+	if (!r)
+		(void) dm_udev_complete(*cookie);
+
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
 	rm_dev_node(name);
 
 	/* FIXME Remove node from tree or mark invalid? */
 
+out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
-static int _rename_node(const char *old_name, const char *new_name, uint32_t major, uint32_t minor)
+static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
+			uint32_t minor, uint32_t *cookie)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -875,8 +883,14 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
+	if (!dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
+	if (!r)
+		(void) dm_udev_complete(*cookie);
+
 out:
 	dm_task_destroy(dmt);
 
@@ -886,10 +900,10 @@
 /* FIXME Merge with _suspend_node? */
 static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 			uint32_t read_ahead, uint32_t read_ahead_flags,
-			struct dm_info *newinfo)
+			struct dm_info *newinfo, uint32_t *cookie)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
@@ -901,14 +915,12 @@
 	/* FIXME Kernel should fill in name on return instead */
 	if (!dm_task_set_name(dmt, name)) {
 		log_error("Failed to set readahead device name for %s", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set device number for %s resumption.", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
@@ -917,9 +929,15 @@
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
+	if (!dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, newinfo);
+	else
+		(void) dm_udev_complete(*cookie);
 
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1000,7 +1018,7 @@
 		    !info.exists || info.open_count)
 			continue;
 
-		if (!_deactivate_node(name, info.major, info.minor)) {
+		if (!_deactivate_node(name, info.major, info.minor, &dnode->dtree->cookie)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -1144,7 +1162,8 @@
 
 			/* Rename? */
 			if (child->props.new_name) {
-				if (!_rename_node(name, child->props.new_name, child->info.major, child->info.minor)) {
+				if (!_rename_node(name, child->props.new_name, child->info.major,
+						  child->info.minor, &child->dtree->cookie)) {
 					log_error("Failed to rename %s (%" PRIu32
 						  ":%" PRIu32 ") to %s", name, child->info.major,
 						  child->info.minor, child->props.new_name);
@@ -1158,8 +1177,8 @@
 				continue;
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
-					  child->props.read_ahead,
-					  child->props.read_ahead_flags, &newinfo)) {
+					  child->props.read_ahead, child->props.read_ahead_flags,
+					  &newinfo, &child->dtree->cookie)) {
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
@@ -1525,8 +1544,8 @@
 			continue;
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
-				  child->props.read_ahead,
-				  child->props.read_ahead_flags, &newinfo)) {
+				  child->props.read_ahead, child->props.read_ahead_flags,
+				  &newinfo, &child->dtree->cookie)) {
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
@@ -1842,3 +1861,13 @@
 
 	return 1;
 }
+
+void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie)
+{
+	node->dtree->cookie = cookie;
+}
+
+uint32_t dm_tree_get_cookie(struct dm_tree_node *node)
+{
+	return node->dtree->cookie;
+}


