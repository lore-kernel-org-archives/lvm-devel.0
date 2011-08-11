From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 17:46:16 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/cache ...
Message-ID: <20110811174616.22386.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 17:46:14

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/misc       : lvm-globals.c lvm-globals.h 
	test/lib       : aux.sh 

Log message:
	Add detect_internal_vg_cache_corruption to lvm.conf
	
	Add config option to enable crc checking of VG structures.
	Currently it's disabled by default.
	
	For the internal test-suite this check it is enabled.
	
	Note: In the case the internal error is detected, debug build with
	compile option DEBUG_ENFORCE_POOL_LOCKING helps to catch the source
	of the problem.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2066&r2=1.2067
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/08/11 17:34:30	1.2066
+++ LVM2/WHATS_NEW	2011/08/11 17:46:13	1.2067
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add detect_internal_vg_cache_corruption to lvm.conf, disabled by default.
   Use memory pool locking to check for corruption of internal VG structs.
   Cache and share generated VG structs.
   Fix possible format instance memory leaks and premature releases in _vg_read.
--- LVM2/doc/example.conf.in	2011/08/02 22:07:21	1.29
+++ LVM2/doc/example.conf.in	2011/08/11 17:46:13	1.30
@@ -402,6 +402,11 @@
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
--- LVM2/lib/cache/lvmcache.c	2011/08/11 17:34:30	1.115
+++ LVM2/lib/cache/lvmcache.c	2011/08/11 17:46:13	1.116
@@ -689,7 +689,7 @@
 	vginfo->vg_use_count = 0;
 	vg->vginfo = vginfo;
 
-	if (!dm_pool_lock(vg->vgmem, 1))
+	if (!dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
 		goto_bad;
 
 out:
@@ -720,6 +720,7 @@
 
 	/* Debug perform crc check only when it's been used more then once */
 	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
+			    detect_internal_vg_cache_corruption() &&
 			    (vginfo->vg_use_count > 1)))
 		stack;
 
--- LVM2/lib/commands/toolcontext.c	2011/08/02 22:07:22	1.127
+++ LVM2/lib/commands/toolcontext.c	2011/08/11 17:46:13	1.128
@@ -373,6 +373,10 @@
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
+	init_detect_internal_vg_cache_corruption
+		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption()",
+				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
+
 	return 1;
 }
 
--- LVM2/lib/config/defaults.h	2011/08/11 05:00:21	1.81
+++ LVM2/lib/config/defaults.h	2011/08/11 17:46:14	1.82
@@ -103,6 +103,7 @@
 #define DEFAULT_LOGLEVEL 0
 #define DEFAULT_INDENT 1
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
+#define DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION 0
 #define DEFAULT_UNITS "h"
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
--- LVM2/lib/misc/lvm-globals.c	2011/07/01 14:09:20	1.12
+++ LVM2/lib/misc/lvm-globals.c	2011/08/11 17:46:14	1.13
@@ -46,6 +46,8 @@
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
+static int _detect_internal_vg_cache_corruption =
+	DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION;
 
 void init_verbose(int level)
 {
@@ -150,6 +152,11 @@
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
@@ -284,3 +291,8 @@
 {
 	return _pv_min_size;
 }
+
+int detect_internal_vg_cache_corruption(void)
+{
+	return _detect_internal_vg_cache_corruption;
+}
--- LVM2/lib/misc/lvm-globals.h	2011/07/01 14:09:20	1.12
+++ LVM2/lib/misc/lvm-globals.h	2011/08/11 17:46:14	1.13
@@ -41,6 +41,7 @@
 void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
+void init_detect_internal_vg_cache_corruption(int detect);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -65,6 +66,7 @@
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
+int detect_internal_vg_cache_corruption(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/test/lib/aux.sh	2011/07/08 10:05:43	1.27
+++ LVM2/test/lib/aux.sh	2011/08/11 17:46:14	1.28
@@ -376,6 +376,7 @@
 backup/backup = 0
 backup/archive = 0
 global/abort_on_internal_errors = 1
+global/detect_internal_vg_cache_corruption = 1
 global/library_dir = "$TESTDIR/lib"
 global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING


