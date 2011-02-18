From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:11:26 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
Message-ID: <20110218141126.1391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:11:24

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/commands   : toolcontext.c 
	lib/filters    : filter.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	lib/misc       : lvm-globals.c lvm-globals.h 
	tools          : pvresize.c 
Added files:
	test           : t-pv-min-size.sh 

Log message:
	Replace PV_MIN_SIZE with function pv_min_size()
	
	Add configurable option to define minimal size of
	of block device usable as a PV.
	
	pv_min_size() is added to lvm-globals and it's being
	initialized through _process_config.
	
	Macro PV_MIN_SIZE is unused and removed.
	
	New define DEFAULT_PV_MIN_SIZE_KB is added to lvm-global
	and unlike PV_MIN_SIZE it uses KB units.
	
	Should help users with various slow devices attached to the system,
	which cannot be easily filtered out (like FDD on /dev/sdX):
	https://bugzilla.redhat.com/show_bug.cgi?id=644578

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1914&r2=1.1915
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.421&r2=1.422
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-min-size.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2011/02/18 14:08:22	1.1914
+++ LVM2/WHATS_NEW	2011/02/18 14:11:22	1.1915
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add configurable pv_min_size to select block devices by its size.
   Add function to read 64bit ints from config find_config_tree_int64.
   Fix to make resuming exclusive cluster mirror use local target type.
 
--- LVM2/doc/example.conf.in	2010/11/09 12:34:41	1.17
+++ LVM2/doc/example.conf.in	2011/02/18 14:11:22	1.18
@@ -144,6 +144,14 @@
 
     # Allow use of pvcreate --uuid without requiring --restorefile.
     require_restorefile_with_uuid = 1
+
+    # Minimal size (in KB) of the block device which can be used as a PV.
+    # In clustered environment all nodes have to use the same value.
+    # Any value smaller then 512KB is ignored.
+    pv_min_size = 512
+
+    # Example: Ignore devices smaller then 2MB (i.e. floppy drives).
+    # pv_min_size = 2048
 }
 
 # This section allows you to configure the way in which LVM selects
--- LVM2/lib/commands/toolcontext.c	2011/01/06 15:29:24	1.114
+++ LVM2/lib/commands/toolcontext.c	2011/02/18 14:11:22	1.115
@@ -205,6 +205,7 @@
 	struct stat st;
 	const struct config_node *cn;
 	const struct config_value *cv;
+	int64_t pv_min_kb;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -318,6 +319,15 @@
 	cmd->metadata_read_only = find_config_tree_int(cmd, "global/metadata_read_only",
 						       DEFAULT_METADATA_READ_ONLY);
 
+	pv_min_kb = find_config_tree_int64(cmd, "devices/pv_min_size", DEFAULT_PV_MIN_SIZE_KB);
+	if (pv_min_kb < DEFAULT_PV_MIN_SIZE_KB) {
+		log_warn("Ignoring too small pv_min_size %" PRId64 "KB, using default %dKB.",
+			 pv_min_kb, DEFAULT_PV_MIN_SIZE_KB);
+		pv_min_kb = DEFAULT_PV_MIN_SIZE_KB;
+	}
+	/* lvm internally works with device size in 512b sectors */
+	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
+
 	return 1;
 }
 
@@ -1113,7 +1123,6 @@
 {
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
-
 }
 
 /* Entry point */
--- LVM2/lib/filters/filter.c	2011/01/27 00:21:37	1.60
+++ LVM2/lib/filters/filter.c	2011/02/18 14:11:23	1.61
@@ -158,7 +158,7 @@
 		goto out;
 	}
 
-	if (size < PV_MIN_SIZE) {
+	if (size < pv_min_size()) {
 		log_debug("%s: Skipping: Too small to hold a PV", name);
 		goto out;
 	}
--- LVM2/lib/metadata/metadata-exported.h	2011/01/12 20:42:51	1.174
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/18 14:11:23	1.175
@@ -33,7 +33,6 @@
 #define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 #define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
-#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 
 /* Layer suffix */
--- LVM2/lib/metadata/metadata.c	2011/02/14 19:27:05	1.421
+++ LVM2/lib/metadata/metadata.c	2011/02/18 14:11:23	1.422
@@ -1626,9 +1626,9 @@
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
 
--- LVM2/lib/metadata/metadata.h	2011/01/10 13:13:43	1.228
+++ LVM2/lib/metadata/metadata.h	2011/02/18 14:11:23	1.229
@@ -32,7 +32,6 @@
 //#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 //#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
-//#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
 #define VG_MEMPOOL_CHUNK	10240	/* in bytes, hint only */
--- LVM2/lib/misc/lvm-globals.c	2011/01/24 14:19:05	1.8
+++ LVM2/lib/misc/lvm-globals.c	2011/02/18 14:11:23	1.9
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "lvm-file.h"
 #include "defaults.h"
+#include "metadata-exported.h"
 
 #include <stdarg.h>
 
@@ -42,6 +43,7 @@
 static int _udev_checking = 1;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
+static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 
 void init_verbose(int level)
 {
@@ -128,6 +130,11 @@
 	_dev_disable_after_error_count = value;
 }
 
+void init_pv_min_size(uint64_t sectors)
+{
+	_pv_min_size = sectors;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -247,3 +254,8 @@
 {
 	return _dev_disable_after_error_count;
 }
+
+uint64_t pv_min_size(void)
+{
+	return _pv_min_size;
+}
--- LVM2/lib/misc/lvm-globals.h	2010/10/13 15:40:39	1.8
+++ LVM2/lib/misc/lvm-globals.h	2011/02/18 14:11:23	1.9
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
@@ -38,6 +39,7 @@
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
+void init_pv_min_size(uint64_t sectors);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -59,6 +61,7 @@
 unsigned is_static(void);
 int udev_checking(void);
 const char *sysfs_dir_path(void);
+uint64_t pv_min_size(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
/cvs/lvm2/LVM2/test/t-pv-min-size.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pv-min-size.sh
+++ -	2011-02-18 14:11:25.704477000 +0000
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# use small default size  - 512KB
+aux lvmconf 'devices/pv_min_size = 512'
+
+aux prepare_pvs 1 8
+
+check pv_field $dev1 pv_name $dev1
+
+# increase min size beyond created PV size 10MB
+aux lvmconf 'devices/pv_min_size = 10240'
+
+# and test device is not visible
+not check pv_field $dev1 pv_name $dev1
+
+# set too low value errornous value
+aux lvmconf 'devices/pv_min_size = -100'
+
+# check the incorrect value is printed
+pvs $dev1 2>&1 | grep -- -100
--- LVM2/tools/pvresize.c	2010/12/08 20:50:51	1.37
+++ LVM2/tools/pvresize.c	2011/02/18 14:11:23	1.38
@@ -111,9 +111,9 @@
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
 


