From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2011 09:33:43 +0200
Subject: [PATCH 4/5] Add detect_internal_vg_cache_corruption option
In-Reply-To: <cover.1313047685.git.zkabelac@redhat.com>
References: <cover.1313047685.git.zkabelac@redhat.com>
Message-ID: <4339c78e273f5787724861abb79835b643cdc15c.1313047685.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add config option to enable crc checking of VG structures.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 doc/example.conf.in        |    5 +++++
 lib/cache/lvmcache.c       |    3 ++-
 lib/commands/toolcontext.c |    4 ++++
 lib/config/defaults.h      |    1 +
 lib/misc/lvm-globals.c     |   12 ++++++++++++
 lib/misc/lvm-globals.h     |    2 ++
 test/lib/aux.sh            |    1 +
 7 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 7fe8d59..5788060 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -402,6 +402,11 @@ global {
     # encountered the internal error. Please only enable for debugging.
     abort_on_internal_errors = 0
 
+    # Check whether CRC is matching when parsed VG is used multiple times.
+    # This is useful to catch unexpected internal cached volume group
+    # structure modification. Please only enable for debugging.
+    detect_internal_vg_cache_corruption = 0
+
     # If set to 1, no operations that change on-disk metadata will be permitted.
     # Additionally, read-only commands that encounter metadata in need of repair
     # will still be allowed to proceed exactly as if the repair had been 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 38d8934..4a9f2cb 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -689,7 +689,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	vginfo->use_count = 0;
 	vg->vginfo = vginfo;
 
-	if (!dm_pool_lock(vg->vgmem, 1))
+	if (!dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
 		goto_bad;
 
 out:
@@ -720,6 +720,7 @@ int lvmcache_decrement_holders(struct lvmcache_vginfo *vginfo)
 
 	/* Debug perform crc check only when it's been used more then once */
 	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
+			    detect_internal_vg_cache_corruption() &&
 			    (vginfo->use_count > 1)))
 		stack;
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b3d368a..3cbd29d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -373,6 +373,10 @@ static int _process_config(struct cmd_context *cmd)
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
+	init_detect_internal_vg_cache_corruption
+		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption()",
+				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
+
 	return 1;
 }
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cfac4d5..8b8e09b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -103,6 +103,7 @@
 #define DEFAULT_LOGLEVEL 0
 #define DEFAULT_INDENT 1
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
+#define DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION 0
 #define DEFAULT_UNITS "h"
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index b9ece7f..f774512 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -46,6 +46,8 @@ static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
+static int _detect_internal_vg_cache_corruption =
+	DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION;
 
 void init_verbose(int level)
 {
@@ -150,6 +152,11 @@ void init_pv_min_size(uint64_t sectors)
 	_pv_min_size = sectors;
 }
 
+void init_detect_internal_vg_cache_corruption(int detect)
+{
+	_detect_internal_vg_cache_corruption = detect;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -284,3 +291,8 @@ uint64_t pv_min_size(void)
 {
 	return _pv_min_size;
 }
+
+int detect_internal_vg_cache_corruption(void)
+{
+	return _detect_internal_vg_cache_corruption;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 2cdfdd1..fcba687 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -41,6 +41,7 @@ void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
+void init_detect_internal_vg_cache_corruption(int detect);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -65,6 +66,7 @@ int udev_checking(void);
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
+int detect_internal_vg_cache_corruption(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5a9bf91..4410007 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -386,6 +386,7 @@ log/activation = 1
 backup/backup = 0
 backup/archive = 0
 global/abort_on_internal_errors = 1
+global/detect_internal_vg_cache_corruption = 1
 global/library_dir = "$TESTDIR/lib"
 global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
-- 
1.7.6


