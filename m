From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:26 +0100
Subject: [PATCH 02/15] Replace PV_MIN_SIZE with function pv_min_size()
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <64482b61e47e7f94d7581081ca172b2734353584.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add configurable option for defining minimal size of PV.
pv_min_size() is added to lvm-globals and it's being
initialized through _init_globals.

Macro PV_MIN_SIZE is unusued and removed.
Add new define DEFAULT_PV_MIN_SIZE_KB used in lvm-global
- unlike PV_MIN_SIZE it uses Kilobytes units.

Should help user with various slow devices attached to the system,
which cannot be easily filtered out:
https://bugzilla.redhat.com/show_bug.cgi?id=644578

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 doc/example.conf.in              |    5 +++++
 lib/commands/toolcontext.c       |    8 +++++++-
 lib/filters/filter.c             |    2 +-
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    6 +++---
 lib/metadata/metadata.h          |    1 -
 lib/misc/lvm-globals.c           |   12 ++++++++++++
 lib/misc/lvm-globals.h           |    5 ++++-
 tools/pvresize.c                 |    6 +++---
 9 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 8504f5d..4853862 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -144,6 +144,11 @@ devices {
 
     # Allow use of pvcreate --uuid without requiring --restorefile.
     require_restorefile_with_uuid = 1
+
+    # Minimal size (in KB) of PV partion which will be consider to be able
+    # to hold PV. It allows to automatically skip too small partitions
+    # like FDD devices from scan. Any value smaller then 512 is ignored.
+    pv_min_size = 512
 }
 
 # This section allows you to configure the way in which LVM selects
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4799016..5d99137 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1111,9 +1111,15 @@ static void _init_rand(struct cmd_context *cmd)
 
 static void _init_globals(struct cmd_context *cmd)
 {
+	int64_t pvmin = find_config_tree_int64(cmd, "devices/pv_min_size",
+					       DEFAULT_PV_MIN_SIZE_KB);
+	if (pvmin < DEFAULT_PV_MIN_SIZE_KB)
+		log_warn("Ignoring too small pv_min_size = %" PRId64, pvmin);
+	else
+		/* lvm internally works with device size in sectors */
+		init_pv_min_size((uint64_t)pvmin * 1024 >> SECTOR_SHIFT);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
-
 }
 
 /* Entry point */
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 58d7c79..314a1f0 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -158,7 +158,7 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((un
 		goto out;
 	}
 
-	if (size < PV_MIN_SIZE) {
+	if (size < pv_min_size()) {
 		log_debug("%s: Skipping: Too small to hold a PV", name);
 		goto out;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a9709d6..4e2463a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -33,7 +33,6 @@
 #define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 #define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
-#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 
 /* Layer suffix */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 771cdb0..a9c7830 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1626,9 +1626,9 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 		pv->size = size;
 	}
 
-	if (pv->size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
-			  pv_dev_name(pv), PV_MIN_SIZE);
+	if (pv->size < pv_min_size()) {
+		log_error("%s: Size must exceed minimum of %" PRIu64 " sectors.",
+			  pv_dev_name(pv), pv_min_size());
 		goto bad;
 	}
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c0f9148..3d51c5b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -32,7 +32,6 @@
 //#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 //#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
-//#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
 #define VG_MEMPOOL_CHUNK	10240	/* in bytes, hint only */
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9da61fe..44c8d7e 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "lvm-file.h"
 #include "defaults.h"
+#include "metadata-exported.h"
 
 #include <stdarg.h>
 
@@ -42,6 +43,7 @@ static unsigned _is_static = 0;
 static int _udev_checking = 1;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
+static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 
 void init_verbose(int level)
 {
@@ -128,6 +130,11 @@ void init_dev_disable_after_error_count(int value)
 	_dev_disable_after_error_count = value;
 }
 
+void init_pv_min_size(uint64_t value)
+{
+	_pv_min_size = value;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -247,3 +254,8 @@ int dev_disable_after_error_count(void)
 {
 	return _dev_disable_after_error_count;
 }
+
+uint64_t pv_min_size(void)
+{
+	return _pv_min_size;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 2fabbc7..bb383f4 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,6 +18,7 @@
 
 #define VERBOSE_BASE_LEVEL _LOG_WARN
 #define SECURITY_LEVEL 0
+#define DEFAULT_PV_MIN_SIZE_KB		512		/* 512 KB */
 
 void init_verbose(int level);
 void init_test(int level);
@@ -38,6 +39,7 @@ void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
+void init_pv_min_size(uint64_t sectors);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -59,6 +61,7 @@ const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);
 const char *sysfs_dir_path(void);
+uint64_t pv_min_size(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 8582ef4..a471f36 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -111,9 +111,9 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		size = new_size;
 	}
 
-	if (size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
-			  pv_name, PV_MIN_SIZE);
+	if (size < pv_min_size()) {
+		log_error("%s: Size must exceed minimum of %" PRIu64 " sectors.",
+			  pv_name, pv_min_size());
 		goto out;
 	}
 
-- 
1.7.3.5


