From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:57 +0200
Subject: [PATCH 6/7] Add verify_vg_crc
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <44551c07884866aa40b05d5ca2b1f5c3d7a7efa5.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add config option to enable crc checking of VG structures.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 doc/example.conf.in        |    5 +++++
 lib/cache/lvmcache.c       |    2 +-
 lib/commands/toolcontext.c |    2 ++
 lib/metadata/vg.c          |    3 ++-
 lib/misc/lvm-globals.c     |   11 +++++++++++
 lib/misc/lvm-globals.h     |    2 ++
 test/lib/aux.sh            |    1 +
 7 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index a721984..9e5c09c 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -402,6 +402,11 @@ global {
     # encountered the internal error. Please only enable for debugging.
     abort_on_internal_errors = 0
 
+    # Check whether CRC is matching when parsed VG is used multiple times.
+    # This is useful to catch unexpected internal volume group structure
+    # modification. Please only enable for debugging.
+    verify_vg_crc = 0
+
     # If set to 1, no operations that change on-disk metadata will be permitted.
     # Additionally, read-only commands that encounter metadata in need of repair
     # will still be allowed to proceed exactly as if the repair had been 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0df8b65..e3c6ae9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -694,7 +694,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	vginfo->cached_vg = vg;
 	vg->vginfo = vginfo;
 
-	if (!dm_pool_lock(vg->vgmem, 1))
+	if (!dm_pool_lock(vg->vgmem, verify_vg_crc()))
 		goto_bad;
 
 out:
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d7e3e44..14fefa3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -373,6 +373,8 @@ static int _process_config(struct cmd_context *cmd)
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
+	init_verify_vg_crc(find_config_tree_int(cmd, "global/verify_vg_crc", 0));
+
 	return 1;
 }
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 00677b4..4c89b67 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -101,7 +101,8 @@ void release_vg(struct volume_group *vg)
 	log_debug("Releasing VG %s with %d holder(s) at %p.", vg->name, vg->holders, vg);
 
 	/* Debug perform crc check only when it's been used more then once */
-	if (lck && !dm_pool_unlock(vg->vgmem, (vg->vginfo &&
+	if (lck && !dm_pool_unlock(vg->vgmem, (verify_vg_crc() &&
+					       vg->vginfo &&
 					       vg->vginfo->use_count > 1 &&
 					       vg->holders == 1)))
 		stack;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index b9ece7f..e30d138 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -46,6 +46,7 @@ static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
+static int _verify_vg_crc = 0;
 
 void init_verbose(int level)
 {
@@ -150,6 +151,11 @@ void init_pv_min_size(uint64_t sectors)
 	_pv_min_size = sectors;
 }
 
+void init_verify_vg_crc(int verify)
+{
+	_verify_vg_crc = verify;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -284,3 +290,8 @@ uint64_t pv_min_size(void)
 {
 	return _pv_min_size;
 }
+
+int verify_vg_crc(void)
+{
+	return _verify_vg_crc;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 2cdfdd1..a0100bb 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -41,6 +41,7 @@ void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
+void init_verify_vg_crc(int verify);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -65,6 +66,7 @@ int udev_checking(void);
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
+int verify_vg_crc(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5a9bf91..7bb2910 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -391,6 +391,7 @@ global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
 global/si_unit_consistency = 1
 global/fallback_to_local_locking = 0
+global/verify_vg_crc = 1
 activation/checks = 1
 activation/udev_sync = 1
 activation/udev_rules = 1
-- 
1.7.6


