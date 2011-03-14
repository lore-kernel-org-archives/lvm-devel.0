From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 14 Mar 2011 13:24:08 +0100
Subject: [PATCH] Query udev database to avoid stat-ing and opening inappropriate devices in /dev
Message-ID: <4D7E08E8.3020301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We can use udev database to iterate over block devices (together with all
related symlinks) and use this to fill the cache during _full_scan call. This
way, we can avoid stat-ing and opening inappropriate devices and directories
(see also https://bugzilla.redhat.com/show_bug.cgi?id=682018).

There's also a new "enumerate_udev_device_directory" setting in lvm.conf with
which we can turn this feature on or off.

Keep in mind that when we use udev, then any nodes created manually will be
ignored (since they won't be recorded in udev database). If there are any other
directories used that differ from udev directory, the scan operation fallbacks
to normal non-udev way...

PS: I've used "+LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS) -ludev" for now in
    make.tmpl.in. But there should be a better place for this - but I wanted to
    test this quickly for now :)

Peter
---

 doc/example.conf.in        |    9 ++++
 lib/commands/toolcontext.c |    4 ++
 lib/config/defaults.h      |    1 +
 lib/device/dev-cache.c     |   90 +++++++++++++++++++++++++++++++++++++++++---
 lib/misc/lvm-globals.c     |   11 +++++
 lib/misc/lvm-globals.h     |    2 +
 make.tmpl.in               |    2 +-
 7 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 6e9f1b9..82f02cd 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -19,6 +19,15 @@ devices {
     # to use with LVM2.
     scan = [ "/dev" ]
 
+    # If set, the cache of block device nodes with all associated symlinks
+    # will be constructed out of the existing udev database content.
+    # This avoids using and opening any inapplicable non-block devices or
+    # subdirectories found in the device directory. This setting is applied
+    # to udev-managed device directory only, other directories will be scanned
+    # fully. N.B. Any device node or symlink not managed by udev in udev
+    # directory will be ignored with this setting on.
+    enumerate_udev_device_directory = 1
+
     # If several entries in the scanned directories correspond to the
     # same block device and the tools need to display a name for device,
     # all the pathnames are matched against each item in the following
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 30c8fc6..3a39c0e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -592,6 +592,10 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		return 1;
 	}
 
+	init_enumerate_udev_dev_dir(
+		find_config_tree_bool(cmd, "devices/enumerate_udev_device_directory",
+				      DEFAULT_ENUMERATE_UDEV_DEV_DIR));
+
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
 			log_error("Invalid string in config file: "
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2e20f93..5a33be6 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -29,6 +29,7 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
+#define DEFAULT_ENUMERATE_UDEV_DEV_DIR 1
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8ba8515..a03815e 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -25,6 +25,11 @@
 #include <sys/param.h>
 #include <dirent.h>
 
+#ifdef UDEV_SYNC_SUPPORT
+#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
+#  include <libudev.h>
+#endif
+
 struct dev_iter {
 	struct btree_iter *current;
 	struct dev_filter *filter;
@@ -319,8 +324,7 @@ static int _add_alias(struct device *dev, const char *path)
 		}
 	}
 
-	if (!(sl->str = dm_pool_strdup(_cache.mem, path)))
-		return_0;
+	sl->str = path;
 
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
@@ -348,6 +352,7 @@ static int _insert_dev(const char *path, dev_t d)
 	struct device *dev;
 	static dev_t loopfile_count = 0;
 	int loopfile = 0;
+	char *path_copy;
 
 	/* Generate pretend device numbers for loopfiles */
 	if (!d) {
@@ -374,12 +379,15 @@ static int _insert_dev(const char *path, dev_t d)
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
@@ -448,6 +456,46 @@ static int _insert_dir(const char *dir)
 	return r;
 }
 
+#ifdef UDEV_SYNC_SUPPORT
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
+		r &= _insert(node_name, 0);
+
+		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
+			symlink_name = udev_list_entry_get_name(symlink_entry);
+			r &= _insert(symlink_name, 0);
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
+#endif	/* UDEV_SYNC_SUPPORT */
+
 static int _insert_file(const char *path)
 {
 	struct stat info;
@@ -508,6 +556,37 @@ static int _insert(const char *path, int rec)
 	return r;
 }
 
+static void _insert_dirs(struct dm_list *dirs)
+{
+	struct dir_list *dl;
+
+	#ifdef UDEV_SYNC_SUPPORT
+	int with_udev = enumerate_udev_dev_dir();
+	struct udev *udev = NULL;
+	const char *udev_dir;
+
+	if (with_udev &&
+	    (!(udev = udev_new()) ||
+	     !(udev_dir = udev_get_dev_path(udev)))) {
+		log_debug("Failed to set up udev context for "
+			  "device directory content enumeration.");
+		with_udev = 0;
+	}
+
+	dm_list_iterate_items(dl, &_cache.dirs) {
+		if (with_udev && !strncmp(dl->dir, udev_dir, strlen(udev_dir)))
+			_insert_udev_dir(udev, dl->dir);
+		else
+			_insert_dir(dl->dir);
+	}
+
+	udev_unref(udev);
+	#else
+	dm_list_iterate_items(dl, &_cache.dirs)
+		_insert_dir(dl->dir);
+	#endif
+}
+
 static void _full_scan(int dev_scan)
 {
 	struct dir_list *dl;
@@ -515,8 +594,7 @@ static void _full_scan(int dev_scan)
 	if (_cache.has_scanned && !dev_scan)
 		return;
 
-	dm_list_iterate_items(dl, &_cache.dirs)
-		_insert_dir(dl->dir);
+	_insert_dirs(&_cache.dirs);
 
 	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 7adb5e3..40c04c4 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -28,6 +28,7 @@ static int _test = 0;
 static int _md_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
+static int _enumerate_udev_dev_dir = DEFAULT_ENUMERATE_UDEV_DEV_DIR;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _log_cmd_name = 0;
@@ -72,6 +73,11 @@ void init_full_scan_done(int level)
 	_full_scan_done = level;
 }
 
+void init_enumerate_udev_dev_dir(int enumerate)
+{
+	_enumerate_udev_dev_dir = enumerate;
+}
+
 void init_trust_cache(int trustcache)
 {
 	_trust_cache = trustcache;
@@ -185,6 +191,11 @@ int full_scan_done()
 	return _full_scan_done;
 }
 
+int enumerate_udev_dev_dir()
+{
+	return _enumerate_udev_dev_dir;
+}
+
 int trust_cache()
 {
 	return _trust_cache;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index bb383f4..efef589 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -25,6 +25,7 @@ void init_test(int level);
 void init_md_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
+void init_enumerate_udev_dev_dir(int enumerate);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_cmd_name(int status);
@@ -48,6 +49,7 @@ int test_mode(void);
 int md_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
+int enumerate_udev_dev_dir(void);
 int trust_cache(void);
 int verbose_level(void);
 int debug_level(void);
diff --git a/make.tmpl.in b/make.tmpl.in
index 5380b5e..e771ade 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -38,7 +38,7 @@ CLDFLAGS += @CLDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS) -ludev
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@


