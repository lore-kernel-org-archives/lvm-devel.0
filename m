From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 May 2007 14:42:03 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20070515144203.642.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-05-15 14:42:02

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c fs.c fs.h 

Log message:
	Remove symlinks if parent volume is deactivated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.617&r2=1.618
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/05/15 13:01:40	1.617
+++ LVM2/WHATS_NEW	2007/05/15 14:42:01	1.618
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Remove symlinks if parent volume is deactivated.
   Fix and clarify vgsplit error messages.
   Fix a segfault if a device has no target (no table)
   Add some more debuglogs to clvmd startup.
--- LVM2/lib/activate/dev_manager.c	2007/05/14 11:27:34	1.123
+++ LVM2/lib/activate/dev_manager.c	2007/05/15 14:42:01	1.124
@@ -937,6 +937,10 @@
 	return 1;
 }
 
+/* FIXME: symlinks should be created/destroyed at the same time
+ * as the kernel devices but we can't do that from within libdevmapper
+ * at present so we must walk the tree twice instead. */
+
 /*
  * Create LV symlinks for children of supplied root node.
  */
@@ -969,6 +973,32 @@
 	return r;
 }
 
+/*
+ * Remove LV symlinks for children of supplied root node.
+ */
+static int _remove_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root)
+{
+	void *handle = NULL;
+	struct dm_tree_node *child;
+	char *vgname, *lvname, *layer;
+	int r = 1;
+
+	while ((child = dm_tree_next_child(&handle, root, 0))) {
+        	if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child), &vgname, &lvname, &layer)) {
+			r = 0;
+			continue;
+		}
+
+		/* only top level layer has symlinks */
+		if (*layer)
+			continue;
+
+		fs_del_lv_byname(dm->cmd->dev_dir, vgname, lvname);
+	}
+
+	return r;
+}
+
 static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root)
 {
 	void *handle = NULL;
@@ -1028,6 +1058,8 @@
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
+		if (!_remove_lv_symlinks(dm, root))
+			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
--- LVM2/lib/activate/fs.c	2006/08/21 12:54:51	1.38
+++ LVM2/lib/activate/fs.c	2007/05/15 14:42:01	1.39
@@ -338,6 +338,11 @@
 		      "", "");
 }
 
+int fs_del_lv_byname(const char *dev_dir, const char *vg_name, const char *lv_name)
+{
+	return _fs_op(FS_DEL, dev_dir, vg_name, lv_name, "", "");
+}
+
 int fs_rename_lv(struct logical_volume *lv,
 		 const char *dev, const char *old_name)
 {
--- LVM2/lib/activate/fs.h	2004/03/30 19:35:37	1.10
+++ LVM2/lib/activate/fs.h	2007/05/15 14:42:01	1.11
@@ -25,6 +25,7 @@
  */
 int fs_add_lv(const struct logical_volume *lv, const char *dev);
 int fs_del_lv(const struct logical_volume *lv);
+int fs_del_lv_byname(const char *dev_dir, const char *vg_name, const char *lv_name);
 int fs_rename_lv(struct logical_volume *lv,
 		 const char *dev, const char *old_name);
 void fs_unlock(void);


