From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Apr 2011 12:05:35 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
Message-ID: <20110422120535.19597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-22 12:05:33

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/device     : dev-cache.c dev-cache.h 
	lib/filters    : filter-persistent.c 
	lib/misc       : lvm-globals.c lvm-globals.h 
	tools          : lvmcmdline.c 

Log message:
	Obtain device list from udev by default if LVM2 is compiled with udev support.
	
	Also, add a new 'obtain_device_list_from_udev' setting to lvm.conf with which
	we can turn this feature on or off if needed.
	
	If set, the cache of block device nodes with all associated symlinks
	will be constructed out of the existing udev database content.
	This avoids using and opening any inapplicable non-block devices or
	subdirectories found in the device directory. This setting is applied
	to udev-managed device directory only, other directories will be scanned
	fully. LVM2 needs to be compiled with udev support for this setting to
	take effect. N.B. Any device node or symlink not managed by udev in
	udev directory will be ignored with this setting on.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1974&r2=1.1975
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/WHATS_NEW	2011/04/21 17:03:38	1.1974
+++ LVM2/WHATS_NEW	2011/04/22 12:05:32	1.1975
@@ -1,5 +1,7 @@
 Version 2.02.85 - 
 ===================================
+  Add new obtain_device_list_from_udev setting to lvm.conf.
+  Obtain device list from udev by default if LVM2 is compiled with udev support.
   Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
   Fix use of released memory when duplicate PV is found.
   Add "devices/issue_discards" to lvm.conf.
--- LVM2/doc/example.conf.in	2011/04/13 18:26:39	1.22
+++ LVM2/doc/example.conf.in	2011/04/22 12:05:32	1.23
@@ -19,6 +19,16 @@
     # to use with LVM2.
     scan = [ "/dev" ]
 
+    # If set, the cache of block device nodes with all associated symlinks
+    # will be constructed out of the existing udev database content.
+    # This avoids using and opening any inapplicable non-block devices or
+    # subdirectories found in the device directory. This setting is applied
+    # to udev-managed device directory only, other directories will be scanned
+    # fully. LVM2 needs to be compiled with udev support for this setting to
+    # take effect. N.B. Any device node or symlink not managed by udev in
+    # udev directory will be ignored with this setting on.
+    # obtain_device_list_from_udev = 1
+
     # If several entries in the scanned directories correspond to the
     # same block device and the tools need to display a name for device,
     # all the pathnames are matched against each item in the following
--- LVM2/lib/commands/toolcontext.c	2011/02/18 14:11:22	1.115
+++ LVM2/lib/commands/toolcontext.c	2011/04/22 12:05:32	1.116
@@ -573,6 +573,9 @@
 {
 	const struct config_node *cn;
 	const struct config_value *cv;
+	size_t udev_dir_len, len;
+	int device_list_from_udev;
+	const char *udev_dir;
 
 	init_dev_disable_after_error_count(
 		find_config_tree_int(cmd, "devices/disable_after_error_count",
@@ -581,6 +584,14 @@
 	if (!dev_cache_init(cmd))
 		return_0;
 
+	if ((device_list_from_udev = udev_is_running() ?
+		find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
+				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0)) {
+		udev_dir = udev_get_dev_dir();
+		udev_dir_len = strlen(udev_dir);
+	}
+	init_obtain_device_list_from_udev(device_list_from_udev);
+
 	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
 		if (!dev_cache_add_dir("/dev")) {
 			log_error("Failed to add /dev to internal "
@@ -599,6 +610,16 @@
 			return 0;
 		}
 
+		if (device_list_from_udev) {
+			len = strlen(cv->v.str);
+			len = udev_dir_len > len ? len : udev_dir_len;
+			if (strncmp(udev_dir, cv->v.str, len) ||
+			    udev_dir[len] != cv->v.str[len]) {
+				device_list_from_udev = 0;
+				init_obtain_device_list_from_udev(0);
+			}
+		}
+
 		if (!dev_cache_add_dir(cv->v.str)) {
 			log_error("Failed to add %s to internal device cache",
 				  cv->v.str);
--- LVM2/lib/config/defaults.h	2011/04/12 21:59:01	1.73
+++ LVM2/lib/config/defaults.h	2011/04/22 12:05:32	1.74
@@ -29,6 +29,7 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
+#define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
--- LVM2/lib/device/dev-cache.c	2011/01/17 15:16:55	1.63
+++ LVM2/lib/device/dev-cache.c	2011/04/22 12:05:33	1.64
@@ -52,7 +52,7 @@
 #define _free(x) dm_pool_free(_cache.mem, (x))
 #define _strdup(x) dm_pool_strdup(_cache.mem, (x))
 
-static int _insert(const char *path, int rec);
+static int _insert(const char *path, int rec, int check_with_udev_db);
 
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct str_list *alias, int use_malloc)
@@ -319,8 +319,7 @@
 		}
 	}
 
-	if (!(sl->str = dm_pool_strdup(_cache.mem, path)))
-		return_0;
+	sl->str = path;
 
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
@@ -348,6 +347,7 @@
 	struct device *dev;
 	static dev_t loopfile_count = 0;
 	int loopfile = 0;
+	char *path_copy;
 
 	/* Generate pretend device numbers for loopfiles */
 	if (!d) {
@@ -374,12 +374,17 @@
 		}
 	}
 
-	if (!loopfile && !_add_alias(dev, path)) {
+	if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+		log_error("Failed to duplicate path string.");
+		return 0;
+	}
+
+	if (!loopfile && !_add_alias(dev, path_copy)) {
 		log_error("Couldn't add alias to dev cache.");
 		return 0;
 	}
 
-	if (!dm_hash_insert(_cache.names, path, dev)) {
+	if (!dm_hash_insert(_cache.names, path_copy, dev)) {
 		log_error("Couldn't add name to hash in dev cache.");
 		return 0;
 	}
@@ -437,7 +442,7 @@
 				return_0;
 
 			_collapse_slashes(path);
-			r &= _insert(path, 1);
+			r &= _insert(path, 1, 0);
 			dm_free(path);
 
 			free(dirent[n]);
@@ -468,7 +473,102 @@
 	return 1;
 }
 
-static int _insert(const char *path, int rec)
+#ifdef UDEV_SYNC_SUPPORT
+
+static int _device_in_udev_db(const dev_t d)
+{
+	struct udev *udev;
+	struct udev_device *udev_device;
+
+	if (!(udev = udev_get_library_context()))
+		return_0;
+
+	if ((udev_device = udev_device_new_from_devnum(udev, 'b', d))) {
+		udev_device_unref(udev_device);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int _insert_udev_dir(struct udev *udev, const char *dir)
+{
+	struct udev_enumerate *udev_enum = NULL;
+	struct udev_list_entry *device_entry, *symlink_entry;
+	const char *node_name, *symlink_name;
+	struct udev_device *device;
+	int r = 1;
+
+	if (!(udev_enum = udev_enumerate_new(udev)))
+		goto bad;
+
+	if (udev_enumerate_add_match_subsystem(udev_enum, "block") ||
+	    udev_enumerate_scan_devices(udev_enum))
+		goto bad;
+
+	udev_list_entry_foreach(device_entry, udev_enumerate_get_list_entry(udev_enum)) {
+		device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry));
+
+		node_name = udev_device_get_devnode(device);
+		r &= _insert(node_name, 0, 0);
+
+		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
+			symlink_name = udev_list_entry_get_name(symlink_entry);
+			r &= _insert(symlink_name, 0, 0);
+		}
+
+		udev_device_unref(device);
+	}
+
+	udev_enumerate_unref(udev_enum);
+	return r;
+
+bad:
+	log_error("Failed to enumerate udev device list.");
+	udev_enumerate_unref(udev_enum);
+	return 0;
+}
+
+static void _insert_dirs(struct dm_list *dirs)
+{
+	struct dir_list *dl;
+	struct udev *udev;
+	int with_udev;
+
+	with_udev = obtain_device_list_from_udev() &&
+		    (udev = udev_get_library_context());
+
+	dm_list_iterate_items(dl, &_cache.dirs) {
+		if (with_udev) {
+			if (!_insert_udev_dir(udev, dl->dir))
+				log_debug("%s: Failed to insert devices from "
+					  "udev-managed directory to device "
+					  "cache fully", dl->dir);
+		}
+		else if (!_insert_dir(dl->dir))
+			log_debug("%s: Failed to insert devices to"
+				  "device cache fully", dl->dir);
+	}
+}
+
+#else	/* UDEV_SYNC_SUPPORT */
+
+static int _device_in_udev_db(const dev_t d)
+{
+	return 0;
+}
+
+static void _insert_dirs(struct dm_list *dirs)
+{
+	struct dir_list *dl;
+
+	dm_list_iterate_items(dl, &_cache.dirs)
+		_insert_dir(dl->dir);
+}
+
+#endif	/* UDEV_SYNC_SUPPORT */
+
+static int _insert(const char *path, int rec, int check_with_udev_db)
 {
 	struct stat info;
 	int r = 0;
@@ -478,6 +578,11 @@
 		return 0;
 	}
 
+	if (check_with_udev_db && !_device_in_udev_db(info.st_rdev)) {
+		log_very_verbose("%s: Not in udev db", path);
+		return 0;
+	}
+
 	if (S_ISDIR(info.st_mode)) {	/* add a directory */
 		/* check it's not a symbolic link */
 		if (lstat(path, &info) < 0) {
@@ -515,8 +620,7 @@
 	if (_cache.has_scanned && !dev_scan)
 		return;
 
-	dm_list_iterate_items(dl, &_cache.dirs)
-		_insert_dir(dl->dir);
+	_insert_dirs(&_cache.dirs);
 
 	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
@@ -760,7 +864,7 @@
 		if (dm_list_size(&dev->aliases) > 1) {
 			dm_list_del(dev->aliases.n);
 			if (!r)
-				_insert(name, 0);
+				_insert(name, 0, obtain_device_list_from_udev());
 			continue;
 		}
 
@@ -788,7 +892,7 @@
 	}
 
 	if (!d) {
-		_insert(name, 0);
+		_insert(name, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
 			_full_scan(0);
--- LVM2/lib/device/dev-cache.h	2010/10/13 15:40:39	1.13
+++ LVM2/lib/device/dev-cache.h	2011/04/22 12:05:33	1.14
@@ -17,6 +17,7 @@
 #define _LVM_DEV_CACHE_H
 
 #include "device.h"
+#include "lvm-wrappers.h"
 
 /*
  * predicate for devices.
--- LVM2/lib/filters/filter-persistent.c	2011/01/06 15:29:24	1.48
+++ LVM2/lib/filters/filter-persistent.c	2011/04/22 12:05:33	1.49
@@ -103,6 +103,17 @@
 	struct stat info;
 	int r = 0;
 
+	if (obtain_device_list_from_udev()) {
+		if (!stat(pf->file, &info)) {
+			log_very_verbose("Obtaining device list from "
+					 "udev. Removing obolete %s.",
+					 pf->file);
+			if (unlink(pf->file) < 0)
+				log_sys_error("unlink", pf->file);
+		}
+		return 1;
+	}
+
 	if (!stat(pf->file, &info))
 		pf->ctime = info.st_ctime;
 	else {
@@ -180,6 +191,9 @@
 	int lockfd;
 	int r = 0;
 
+	if (obtain_device_list_from_udev())
+		return 1;
+
 	if (!f)
 		return_0;
 	pf = (struct pfilter *) f->private;
--- LVM2/lib/misc/lvm-globals.c	2011/03/29 20:30:08	1.10
+++ LVM2/lib/misc/lvm-globals.c	2011/04/22 12:05:33	1.11
@@ -28,6 +28,7 @@
 static int _md_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
+static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _log_cmd_name = 0;
@@ -72,6 +73,11 @@
 	_full_scan_done = level;
 }
 
+void init_obtain_device_list_from_udev(int device_list_from_udev)
+{
+	_obtain_device_list_from_udev = device_list_from_udev;
+}
+
 void init_trust_cache(int trustcache)
 {
 	_trust_cache = trustcache;
@@ -185,6 +191,11 @@
 	return _full_scan_done;
 }
 
+int obtain_device_list_from_udev()
+{
+	return _obtain_device_list_from_udev;
+}
+
 int trust_cache(void)
 {
 	return _trust_cache;
--- LVM2/lib/misc/lvm-globals.h	2011/02/18 14:11:23	1.9
+++ LVM2/lib/misc/lvm-globals.h	2011/04/22 12:05:33	1.10
@@ -25,6 +25,7 @@
 void init_md_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
+void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_cmd_name(int status);
@@ -48,6 +49,7 @@
 int md_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
+int obtain_device_list_from_udev(void);
 int trust_cache(void);
 int verbose_level(void);
 int debug_level(void);
--- LVM2/tools/lvmcmdline.c	2011/04/22 11:56:41	1.139
+++ LVM2/tools/lvmcmdline.c	2011/04/22 12:05:33	1.140
@@ -1282,6 +1282,9 @@
 {
 	struct cmd_context *cmd;
 
+	if (!udev_init_library_context())
+		stack;
+
 	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
@@ -1313,6 +1316,7 @@
 {
 	_fin_commands();
 	destroy_toolcontext(cmd);
+	udev_fin_library_context();
 }
 
 static int _run_script(struct cmd_context *cmd, int argc, char **argv)


