From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 21 Mar 2011 15:44:25 +0100
Subject: [PATCH 2/3] Query udev database to obtain device list for device cache
Message-ID: <4D876449.5040500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use libudev to obtain the list of all block device nodes and associated symlinks
and construct the device cache from this information. This avoids accessing
inappropriate devices or subdirectories found in /dev that is managed by udev.

There's a new lvm.conf setting that controls this: obtain_device_list_from_udev
to control this feature.

If udev is not running or we're scanning a directory that is not managed by
udev, the device scan will fallback to original ("full scan") mode.

LVM2 needs to be compiled with udev support (--enable-udev_sync) for this setting
to take effect.

Since we need to access the libudev context quite often, we set it once in init_lvm
and finalize it in lvm_fin. The common udev wrappers are in lvm-wrappers.[ch]. This
avoids calling udev_new frequently (udev_new reads udev config file etc.).

Peter
---
 doc/example.conf.in             |   10 +++
 lib/commands/toolcontext.c      |    4 +
 lib/config/defaults.h           |    1 +
 lib/device/dev-cache.c          |  130 +++++++++++++++++++++++++++++++++++---
 lib/device/dev-cache.h          |    1 +
 lib/filters/filter-persistent.c |   14 ++++
 lib/misc/lvm-globals.c          |   11 +++
 lib/misc/lvm-globals.h          |    2 +
 lib/misc/lvm-wrappers.c         |   72 +++++++++++++++++++++
 lib/misc/lvm-wrappers.h         |    9 +++
 make.tmpl.in                    |    2 +-
 tools/lvmcmdline.c              |    3 +
 12 files changed, 247 insertions(+), 12 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 6e9f1b9..2e0d8b6 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -19,6 +19,16 @@ devices {
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
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 30c8fc6..4e63075 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -592,6 +592,10 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		return 1;
 	}
 
+	init_obtain_device_list_from_udev(udev_is_running() ?
+		find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
+				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0);
+
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
 			log_error("Invalid string in config file: "
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2e20f93..c554058 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -29,6 +29,7 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
+#define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8ba8515..22c82be 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -52,7 +52,7 @@ static struct {
 #define _free(x) dm_pool_free(_cache.mem, (x))
 #define _strdup(x) dm_pool_strdup(_cache.mem, (x))
 
-static int _insert(const char *path, int rec);
+static int _insert(const char *path, int rec, int check_with_udev_db);
 
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct str_list *alias, int use_malloc)
@@ -319,8 +319,7 @@ static int _add_alias(struct device *dev, const char *path)
 		}
 	}
 
-	if (!(sl->str = dm_pool_strdup(_cache.mem, path)))
-		return_0;
+	sl->str = path;
 
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
@@ -348,6 +347,7 @@ static int _insert_dev(const char *path, dev_t d)
 	struct device *dev;
 	static dev_t loopfile_count = 0;
 	int loopfile = 0;
+	char *path_copy;
 
 	/* Generate pretend device numbers for loopfiles */
 	if (!d) {
@@ -374,12 +374,15 @@ static int _insert_dev(const char *path, dev_t d)
 		}
 	}
 
-	if (!loopfile && !_add_alias(dev, path)) {
+	if (!(path_copy = dm_pool_strdup(_cache.mem, path)))
+		return_0;
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
@@ -437,7 +440,7 @@ static int _insert_dir(const char *dir)
 				return_0;
 
 			_collapse_slashes(path);
-			r &= _insert(path, 1);
+			r &= _insert(path, 1, 0);
 			dm_free(path);
 
 			free(dirent[n]);
@@ -468,7 +471,108 @@ static int _insert_file(const char *path)
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
+	int with_udev = obtain_device_list_from_udev();
+	struct udev *udev;
+	const char *udev_dir;
+
+	if (with_udev &&
+	    (!(udev = udev_get_library_context()) ||
+	     !(udev_dir = udev_get_dev_path(udev)))) {
+		log_debug("Failed to set up udev context for "
+			  "device directory content enumeration.");
+		with_udev = 0;
+	}
+
+	dm_list_iterate_items(dl, &_cache.dirs) {
+		if (with_udev && !strncmp(dl->dir, udev_dir, strlen(udev_dir))) {
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
@@ -478,6 +582,11 @@ static int _insert(const char *path, int rec)
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
@@ -515,8 +624,7 @@ static void _full_scan(int dev_scan)
 	if (_cache.has_scanned && !dev_scan)
 		return;
 
-	dm_list_iterate_items(dl, &_cache.dirs)
-		_insert_dir(dl->dir);
+	_insert_dirs(&_cache.dirs);
 
 	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
@@ -760,7 +868,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 		if (dm_list_size(&dev->aliases) > 1) {
 			dm_list_del(dev->aliases.n);
 			if (!r)
-				_insert(name, 0);
+				_insert(name, 0, obtain_device_list_from_udev());
 			continue;
 		}
 
@@ -788,7 +896,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 	}
 
 	if (!d) {
-		_insert(name, 0);
+		_insert(name, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
 			_full_scan(0);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index c1c86d6..5db5226 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -17,6 +17,7 @@
 #define _LVM_DEV_CACHE_H
 
 #include "device.h"
+#include "lvm-wrappers.h"
 
 /*
  * predicate for devices.
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3025e68..cb0b695 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -103,6 +103,17 @@ int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out)
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
@@ -180,6 +191,9 @@ int persistent_filter_dump(struct dev_filter *f, int merge_existing)
 	int lockfd;
 	int r = 0;
 
+	if (obtain_device_list_from_udev())
+		return 1;
+
 	if (!f)
 		return_0;
 	pf = (struct pfilter *) f->private;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 7adb5e3..f489f1d 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -28,6 +28,7 @@ static int _test = 0;
 static int _md_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
+static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _log_cmd_name = 0;
@@ -72,6 +73,11 @@ void init_full_scan_done(int level)
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
@@ -185,6 +191,11 @@ int full_scan_done()
 	return _full_scan_done;
 }
 
+int obtain_device_list_from_udev()
+{
+	return _obtain_device_list_from_udev;
+}
+
 int trust_cache()
 {
 	return _trust_cache;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index bb383f4..6694da6 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -25,6 +25,7 @@ void init_test(int level);
 void init_md_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
+void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_cmd_name(int status);
@@ -48,6 +49,7 @@ int test_mode(void);
 int md_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
+int obtain_device_list_from_udev(void);
 int trust_cache(void);
 int verbose_level(void);
 int debug_level(void);
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 3ab8a71..59fdb4e 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -17,6 +17,78 @@
 #include <unistd.h>
 #include <fcntl.h>
 
+#ifdef UDEV_SYNC_SUPPORT
+
+#include <libudev.h>
+static struct udev *_udev = NULL;
+
+int udev_init_library_context(void)
+{
+	if (_udev)
+		udev_unref(_udev);
+
+	if (!(_udev = udev_new())) {
+		log_error("Failed to create udev library context.");
+		return 0;
+	}
+
+	return 1;
+}
+
+void udev_fin_library_context(void)
+{
+	udev_unref(_udev);
+	_udev = NULL;
+}
+
+int udev_is_running(void)
+{
+	struct udev_queue *udev_queue;
+	int r;
+
+	if (!_udev) {
+		log_debug("Udev library context not set.");
+		goto bad;
+	}
+
+	if (!(udev_queue = udev_queue_new(_udev))) {
+		log_debug("Could not get udev state.");
+		goto bad;
+	}
+
+	r = udev_queue_get_udev_is_active(udev_queue);
+	udev_queue_unref(udev_queue);
+
+	return r;
+
+bad:
+	log_debug("Assuming udev is not running.");
+	return 0;
+}
+
+struct udev* udev_get_library_context(void)
+{
+	return _udev;
+}
+
+#else	/* UDEV_SYNC_SUPPORT */
+
+int udev_init_library_context(void)
+{
+	return 1;
+}
+
+void udev_fin_library_context(void)
+{
+}
+
+int udev_is_running(void)
+{
+	return 0;
+}
+
+#endif	/* UDEV_SYNC_SUPPORT */
+
 int lvm_getpagesize(void)
 {
 	return getpagesize();
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index 19a7f03..e43f831 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -16,6 +16,15 @@
 #ifndef _LVM_WRAPPERS_H
 #define _LVM_WRAPPERS_H
 
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+struct udev *udev_get_library_context(void);
+#endif
+
+int udev_init_library_context(void);
+void udev_fin_library_context(void);
+int udev_is_running(void);
+
 int lvm_getpagesize(void);
 
 /*
diff --git a/make.tmpl.in b/make.tmpl.in
index 5380b5e..cd8ae35 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -38,7 +38,7 @@ CLDFLAGS += @CLDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(UDEV_LIBS) $(DL_LIBS)
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 45c3703..efe7f4e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1282,6 +1282,8 @@ struct cmd_context *init_lvm(void)
 {
 	struct cmd_context *cmd;
 
+	(void) udev_init_library_context();
+
 	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
@@ -1313,6 +1315,7 @@ void lvm_fin(struct cmd_context *cmd)
 {
 	_fin_commands();
 	destroy_toolcontext(cmd);
+	udev_fin_library_context();
 }
 
 static int _run_script(struct cmd_context *cmd, int argc, char **argv)


