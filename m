From: David Teigland <teigland@sourceware.org>
Date: Mon, 4 Mar 2019 13:23:28 -0500
Subject: master - config: add new setting io_memory_size
Message-ID: <201903041823.x24INSR5014595@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd8d0837950ae72939b13c3a1eb4cff902bbccdd
Commit:        dd8d0837950ae72939b13c3a1eb4cff902bbccdd
Parent:        3ed9256985bd9fadcbbb8f419b8d44bf22e93ef2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 1 13:55:59 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 11:36:21 2019 -0600

config: add new setting io_memory_size

which defines the amount of memory that lvm will allocate
for bcache.  Increasing this setting is required if it is
smaller than a single copy of VG metadata.
---
 lib/commands/toolcontext.c   |    2 ++
 lib/config/config_settings.h |    8 ++++++++
 lib/config/defaults.h        |    2 ++
 lib/label/label.c            |   40 ++++++++++++++++++++--------------------
 lib/misc/lvm-globals.c       |   10 ++++++++++
 lib/misc/lvm-globals.h       |    2 ++
 6 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0b88dca..15e3499 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -715,6 +715,8 @@ static int _process_config(struct cmd_context *cmd)
 	if (!_init_system_id(cmd))
 		return_0;
 
+	init_io_memory_size(find_config_tree_int(cmd, global_io_memory_size_CFG, NULL));
+
 	return 1;
 }
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fc66117..a2df3ce 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1224,6 +1224,14 @@ cfg(global_notify_dbus_CFG, "notify_dbus", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"When enabled, an LVM command that changes PVs, changes VG metadata,\n"
 	"or changes the activation state of an LV will send a notification.\n")
 
+cfg(global_io_memory_size_CFG, "io_memory_size", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_IO_MEMORY_SIZE_KB, vsn(2, 3, 2), NULL, 0, NULL,
+	"The amount of memory in KiB that LVM allocates to perform disk io.\n"
+	"LVM performance may benefit from more io memory when there are many\n"
+	"disks or VG metadata is large. Increasing this size may be necessary\n"
+	"when a single copy of VG metadata is larger than the current setting.\n"
+	"This value should usually not be decreased from the default; setting\n"
+	"it too low can result in lvm failing to read VGs.\n")
+
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
 	"The --nodevsync option overrides this setting.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index affb4c9..ee6ca3a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -314,4 +314,6 @@
 
 #define DEFAULT_HINTS "all"
 
+#define DEFAULT_IO_MEMORY_SIZE_KB 4096
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/label/label.c b/lib/label/label.c
index 7d5073e..a877b38 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -775,33 +775,33 @@ out:
 }
 
 /*
- * How many blocks to set up in bcache?  Is 1024 a good max?
+ * num_devs is the number of devices the caller is going to scan.
+ * When 0 the caller doesn't know, and we use the default cache size.
+ * When non-zero, allocate at least num_devs bcache blocks.
+ * num_devs doesn't really tell us how many bcache blocks we'll use
+ * because it includes lvm devs and non-lvm devs, and each lvm dev
+ * will often use a number of bcache blocks.
  *
- * Currently, we tell bcache to set up N blocks where N
- * is the number of devices that are going to be scanned.
- * Reasons why this number may not be be a good choice:
- *
- * - there may be a lot of non-lvm devices, which
- *   would make this number larger than necessary
- *
- * - each lvm device may use more than one cache
- *   block if the metadata is large enough or it
- *   uses more than one metadata area, which
- *   would make this number smaller than it
- *   should be for the best performance.
- *
- * This is even more tricky to estimate when lvmetad
- * is used, because it's hard to predict how many
- * devs might need to be scanned when using lvmetad.
- * This currently just sets up bcache with MIN blocks.
+ * We don't know ahead of time if we will find some VG metadata 
+ * that is larger than the total size of the bcache, which would
+ * prevent us from reading/writing the VG since we do not dynamically
+ * increase the bcache size when we find it's too small.  In these
+ * cases the user would need to set io_memory_size to be larger
+ * than the max VG metadata size (lvm does not impose any limit on
+ * the metadata size.)
  */
 
-#define MIN_BCACHE_BLOCKS 32
+#define MIN_BCACHE_BLOCKS 32    /* 4MB, currently matches DEFAULT_IO_MEMORY_SIZE_KB */
 #define MAX_BCACHE_BLOCKS 1024
 
-static int _setup_bcache(int cache_blocks)
+static int _setup_bcache(int num_devs)
 {
 	struct io_engine *ioe = NULL;
+	int iomem_kb = io_memory_size();
+	int block_size_kb = (BCACHE_BLOCK_SIZE_IN_SECTORS * 512) / 1024;
+	int cache_blocks;
+
+	cache_blocks = iomem_kb / block_size_kb;
 
 	if (cache_blocks < MIN_BCACHE_BLOCKS)
 		cache_blocks = MIN_BCACHE_BLOCKS;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 1ddd2fb..6d3bf02 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -53,6 +53,7 @@ static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 static const char *_unknown_device_name = DEFAULT_UNKNOWN_DEVICE_NAME;
+static int _io_memory_size_kb = DEFAULT_IO_MEMORY_SIZE_KB;
 
 void init_verbose(int level)
 {
@@ -393,3 +394,12 @@ void init_unknown_device_name(const char *name)
 	_unknown_device_name = name;
 }
 
+int io_memory_size(void)
+{
+	return _io_memory_size_kb;
+}
+
+void init_io_memory_size(int val)
+{
+	_io_memory_size_kb = val;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index c69b99a..944b822 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -51,6 +51,7 @@ void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_retry_deactivation(int retry);
 void init_unknown_device_name(const char *name);
+void init_io_memory_size(int val);
 
 void set_cmd_name(const char *cmd_name);
 const char *get_cmd_name(void);
@@ -83,6 +84,7 @@ uint64_t pv_min_size(void);
 int activation_checks(void);
 int retry_deactivation(void);
 const char *unknown_device_name(void);
+int io_memory_size(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);


