From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 14:02:33 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110110140233.6105.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 14:02:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c lvm-functions.h 
	lib/activate   : activate.c activate.h dev_manager.c fs.c fs.h 
	lib/locking    : file_locking.c 
	lib/metadata   : lv_manip.c 

Log message:
	Speedup consequent activation calls
	
	Stop calling fs_unlock() from lv_de/activate().
	Start using internal lvm fs cookie for dm_tree.
	Stop directly calling dm_udev_wait() and
	dm_tree_set/get_cookie() from activate code -
	it's now called through fs_unlock() function.
	
	Add lvm_do_fs_unlock()
	
	Call fs_unlock() when unlocking vg where implicit unlock solves the
	problem also for cluster - thus no extra command for clustering
	environment is required - only lvm_do_fs_unlock() function is added
	to call lvm's fs_unlock() while holding lvm_lock mutex in clvmd.
	
	Add fs_unlock() also to set_lv() so the command waits until devices
	are ready for regular open (i.e. wiping its begining).
	
	Move fs_unlock() prototype to activation.h to keep fs.h private
	in lib/activate dir and not expose other functions from this header.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1869&r2=1.1870
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242

--- LVM2/WHATS_NEW	2011/01/10 13:44:39	1.1869
+++ LVM2/WHATS_NEW	2011/01/10 14:02:30	1.1870
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Speedup consequent activation calls by using internal cookie.
   Add internal lvm library cookie.
   Speedup command processing by caching resolved config tree.
   Pass config_tree to renamed function import_vg_from_config_tree().
--- LVM2/daemons/clvmd/clvmd-command.c	2010/12/22 12:14:11	1.45
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/01/10 14:02:30	1.46
@@ -214,6 +214,7 @@
 	if (lkid == 0)
 	    return EINVAL;
 
+	lvm_do_fs_unlock(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
--- LVM2/daemons/clvmd/lvm-functions.c	2010/12/08 20:50:48	1.104
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/01/10 14:02:30	1.105
@@ -894,6 +894,13 @@
 	return v;
 }
 
+void lvm_do_fs_unlock(void)
+{
+	pthread_mutex_lock(&lvm_lock);
+	fs_unlock();
+	pthread_mutex_unlock(&lvm_lock);
+}
+
 /* Called to initialise the LVM context of the daemon */
 int init_clvm(int using_gulm, char **argv)
 {
--- LVM2/daemons/clvmd/lvm-functions.h	2010/08/17 16:25:32	1.14
+++ LVM2/daemons/clvmd/lvm-functions.h	2011/01/10 14:02:30	1.15
@@ -36,5 +36,6 @@
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
 extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
+void lvm_do_fs_unlock(void);
 
 #endif
--- LVM2/lib/activate/activate.c	2010/12/20 13:37:26	1.184
+++ LVM2/lib/activate/activate.c	2011/01/10 14:02:31	1.185
@@ -1206,7 +1206,6 @@
 	memlock_inc(cmd);
 	r = _lv_deactivate(lv);
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
 		r = 0;
@@ -1305,7 +1304,6 @@
 	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
--- LVM2/lib/activate/activate.h	2010/11/30 11:53:31	1.72
+++ LVM2/lib/activate/activate.h	2011/01/10 14:02:31	1.73
@@ -121,4 +121,9 @@
  */
 int device_is_usable(struct device *dev);
 
+/*
+ * Declaration moved here from fs.h to keep header fs.h hidden
+ */
+void fs_unlock(void);
+
 #endif
--- LVM2/lib/activate/dev_manager.c	2011/01/05 14:03:37	1.211
+++ LVM2/lib/activate/dev_manager.c	2011/01/10 14:02:31	1.212
@@ -1622,7 +1622,6 @@
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
-	int r;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -1644,12 +1643,7 @@
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		dm_tree_set_cookie(root, 0);
-		r = dm_tree_deactivate_children(root, uuid, strlen(uuid));
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
-
-		if (!r)
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
 			return_0;
 	}
 
@@ -1669,9 +1663,12 @@
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
 		log_error("Lost dependency tree root node");
-		goto out;
+		goto out_no_root;
 	}
 
+	/* Restore fs cookie */
+	dm_tree_set_cookie(root, fs_get_cookie());
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
 		goto_out;
 
@@ -1684,10 +1681,7 @@
 		break;
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
@@ -1708,10 +1702,7 @@
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 
@@ -1719,10 +1710,7 @@
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			dm_tree_set_cookie(root, 0);
 			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-			if (!dm_udev_wait(dm_tree_get_cookie(root)))
-				stack;
 			if (!r)
 				goto_out;
 			if (!_create_lv_symlinks(dm, root)) {
@@ -1740,6 +1728,9 @@
 	r = 1;
 
 out:
+	/* Save fs cookie for udev settle, do not wait here */
+	fs_set_cookie(dm_tree_get_cookie(root));
+out_no_root:
 	dm_tree_free(dtree);
 
 	return r;
--- LVM2/lib/activate/fs.c	2011/01/10 13:44:39	1.54
+++ LVM2/lib/activate/fs.c	2011/01/10 14:02:31	1.55
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "fs.h"
+#include "activate.h"
 #include "toolcontext.h"
 #include "lvm-string.h"
 #include "lvm-file.h"
--- LVM2/lib/activate/fs.h	2011/01/10 13:44:39	1.15
+++ LVM2/lib/activate/fs.h	2011/01/10 14:02:31	1.16
@@ -29,7 +29,7 @@
 		     const char *lv_name, int check_udev);
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
 		 const char *old_vgname, const char *old_lvname);
-void fs_unlock(void);
+/* void fs_unlock(void);  moved to activate.h */
 uint32_t fs_get_cookie(void);
 void fs_set_cookie(uint32_t cookie);
 
--- LVM2/lib/locking/file_locking.c	2011/01/05 15:10:30	1.52
+++ LVM2/lib/locking/file_locking.c	2011/01/10 14:02:31	1.53
@@ -215,6 +215,7 @@
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
+		fs_unlock(); /* Wait until devices are available */
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
--- LVM2/lib/metadata/lv_manip.c	2010/12/20 14:38:22	1.241
+++ LVM2/lib/metadata/lv_manip.c	2011/01/10 14:02:31	1.242
@@ -3022,6 +3022,8 @@
 		return 0;
 	}
 
+	fs_unlock();  /* Wait until devices are available */
+
 	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
 
 	if (!(dev = dev_cache_get(name, NULL))) {


