From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 19 Dec 2008 14:22:52 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20081219142252.6140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2008-12-19 14:22:49

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c fs.c fs.h 
	tools          : lvchange.c toollib.c toollib.h vgrename.c 

Log message:
	Fix vgrename using UUID in case there are VGs with the same name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1009&r2=1.1010
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2008/12/15 13:30:45	1.1009
+++ LVM2/WHATS_NEW	2008/12/19 14:22:48	1.1010
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix vgrename using UUID in case there are VGs with the same name.
   Fix segfault when invalid field given in reporting commands.
   Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.
--- LVM2/lib/activate/activate.c	2008/12/04 15:54:26	1.141
+++ LVM2/lib/activate/activate.c	2008/12/19 14:22:48	1.142
@@ -1084,9 +1084,10 @@
 	if (!_lv_info(cmd, lv, 1, &info, 0, 0, 0))
 		return_0;
 
-	if (info.exists)
-		r = dev_manager_lv_mknodes(lv);
-	else
+	if (info.exists) {
+		if (lv_is_visible(lv))
+			r = dev_manager_lv_mknodes(lv);
+	} else
 		r = dev_manager_lv_rmnodes(lv);
 
 	fs_unlock();
--- LVM2/lib/activate/dev_manager.c	2008/11/03 22:14:27	1.142
+++ LVM2/lib/activate/dev_manager.c	2008/12/19 14:22:48	1.143
@@ -1005,7 +1005,8 @@
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct lv_layer *lvlayer;
-	char *vgname, *lvname, *layer;
+	char *old_vgname, *old_lvname, *old_layer;
+	char *new_vgname, *new_lvname, *new_layer;
 	const char *name;
 	int r = 1;
 
@@ -1017,11 +1018,16 @@
 		name = dm_tree_node_get_name(child);
 
 		if (name && lvlayer->old_name && *lvlayer->old_name && strcmp(name, lvlayer->old_name)) {
-			if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &vgname, &lvname, &layer)) {
+			if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &old_vgname, &old_lvname, &old_layer)) {
 				log_error("_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
 				return 0;
 			}
-			fs_rename_lv(lvlayer->lv, name, lvname);
+			if (!dm_split_lvm_name(dm->mem, name, &new_vgname, &new_lvname, &new_layer)) {
+				log_error("_create_lv_symlinks: Couldn't split up new device name %s", name);
+				return 0;
+			}
+			if (!fs_rename_lv(lvlayer->lv, name, old_vgname, old_lvname))
+				r = 0;
 		} else if (!dev_manager_lv_mknodes(lvlayer->lv))
 			r = 0;
 	}
--- LVM2/lib/activate/fs.c	2008/11/03 22:14:27	1.43
+++ LVM2/lib/activate/fs.c	2008/12/19 14:22:48	1.44
@@ -335,11 +335,17 @@
 	return _fs_op(FS_DEL, dev_dir, vg_name, lv_name, "", "");
 }
 
-int fs_rename_lv(struct logical_volume *lv,
-		 const char *dev, const char *old_name)
+int fs_rename_lv(struct logical_volume *lv, const char *dev, 
+		const char *old_vgname, const char *old_lvname)
 {
-	return _fs_op(FS_RENAME, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
-		      dev, old_name);
+	if (strcmp(old_vgname, lv->vg->name)) {
+		return
+			(_fs_op(FS_DEL, lv->vg->cmd->dev_dir, old_vgname, old_lvname, "", "") &&
+			 _fs_op(FS_ADD, lv->vg->cmd->dev_dir, lv->vg->name, lv->name, dev, ""));
+	}
+	else 
+		return _fs_op(FS_RENAME, lv->vg->cmd->dev_dir, lv->vg->name, lv->name,
+			      dev, old_lvname);
 }
 
 void fs_unlock(void)
--- LVM2/lib/activate/fs.h	2007/08/20 20:55:24	1.12
+++ LVM2/lib/activate/fs.h	2008/12/19 14:22:48	1.13
@@ -26,8 +26,8 @@
 int fs_add_lv(const struct logical_volume *lv, const char *dev);
 int fs_del_lv(const struct logical_volume *lv);
 int fs_del_lv_byname(const char *dev_dir, const char *vg_name, const char *lv_name);
-int fs_rename_lv(struct logical_volume *lv,
-		 const char *dev, const char *old_name);
+int fs_rename_lv(struct logical_volume *lv, const char *dev, 
+		const char *old_vgname, const char *old_lvname);
 void fs_unlock(void);
 
 #endif
--- LVM2/tools/lvchange.c	2008/12/18 05:27:18	1.95
+++ LVM2/tools/lvchange.c	2008/12/19 14:22:48	1.96
@@ -168,10 +168,7 @@
 static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
-	if (!suspend_lv(cmd, lv) || !resume_lv(cmd, lv))
-		return 0;
-
-	return 1;
+	return lv_refresh(cmd, lv);
 }
 
 static int lvchange_resync(struct cmd_context *cmd,
--- LVM2/tools/toollib.c	2008/12/17 16:45:32	1.138
+++ LVM2/tools/toollib.c	2008/12/19 14:22:48	1.139
@@ -1232,3 +1232,8 @@
 
 	return 0;
 }
+
+int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	return suspend_lv(cmd, lv) && resume_lv(cmd, lv);
+}
--- LVM2/tools/toollib.h	2008/11/03 22:14:30	1.58
+++ LVM2/tools/toollib.h	2008/12/19 14:22:48	1.59
@@ -100,4 +100,6 @@
 int fill_vg_create_params(struct cmd_context *cmd,
 			  char *vg_name, struct vgcreate_params *vp_new,
 			  struct vgcreate_params *vp_def);
+
+int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 #endif
--- LVM2/tools/vgrename.c	2008/11/03 22:14:30	1.55
+++ LVM2/tools/vgrename.c	2008/12/19 14:22:48	1.56
@@ -23,7 +23,9 @@
 	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
+	int symlinks_refresh_ok = 1;
 	struct dm_list *vgids;
+	struct lv_list *lvl;
 	struct str_list *sl;
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
@@ -122,24 +124,33 @@
 	/* Change the volume group name */
 	vg_rename(cmd, vg, vg_name_new);
 
+	/* store it on disks */
+	log_verbose("Writing out updated volume group");
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		goto error;
+	}
+
 	sprintf(old_path, "%s%s", dev_dir, vg_name_old);
 	sprintf(new_path, "%s%s", dev_dir, vg_name_new);
 
 	if (activation() && dir_exists(old_path)) {
 		log_verbose("Renaming \"%s\" to \"%s\"", old_path, new_path);
+
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename.");
-		else if (rename(old_path, new_path)) {
-			log_error("Renaming \"%s\" to \"%s\" failed: %s",
-				  old_path, new_path, strerror(errno));
-			goto error;
-		}
-	}
 
-	/* store it on disks */
-	log_verbose("Writing out updated volume group");
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		goto error;
+		else if (lvs_in_vg_activated_by_uuid_only(vg)) {
+			dm_list_iterate_items(lvl, &vg->lvs)
+				if (lv_is_visible(lvl->lv))
+					if (!lv_refresh(cmd, lvl->lv))
+						symlinks_refresh_ok = 0;
+
+			if (!symlinks_refresh_ok) {
+				log_error("Renaming \"%s\" to \"%s\" failed", 
+					old_path, new_path);
+				goto error;
+			}
+		}
 	}
 
 /******* FIXME Rename any active LVs! *****/


