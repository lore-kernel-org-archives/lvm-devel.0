From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Apr 2011 17:33:38 -0000
Subject: LVM2 lib/misc/lvm-globals.h lib/config/default ...
Message-ID: <20110428173338.14524.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-28 17:33:35

Modified files:
	lib/misc       : lvm-globals.h 
	lib/config     : defaults.h 
	lib/commands   : toolcontext.c 
	doc            : example.conf.in 

Log message:
	Set pv_min_size to 2048KB to exclude floppy drives.
	Previously was 512.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/misc/lvm-globals.h	2011/04/22 12:05:33	1.10
+++ LVM2/lib/misc/lvm-globals.h	2011/04/28 17:33:34	1.11
@@ -18,7 +18,6 @@
 
 #define VERBOSE_BASE_LEVEL _LOG_WARN
 #define SECURITY_LEVEL 0
-#define DEFAULT_PV_MIN_SIZE_KB		512		/* 512 KB */
 
 void init_verbose(int level);
 void init_test(int level);
--- LVM2/lib/config/defaults.h	2011/04/22 12:05:32	1.74
+++ LVM2/lib/config/defaults.h	2011/04/28 17:33:35	1.75
@@ -39,6 +39,7 @@
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 #define DEFAULT_ISSUE_DISCARDS 0
+#define DEFAULT_PV_MIN_SIZE_KB 2048
 
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
--- LVM2/lib/commands/toolcontext.c	2011/04/22 12:05:32	1.116
+++ LVM2/lib/commands/toolcontext.c	2011/04/28 17:33:35	1.117
@@ -325,7 +325,7 @@
 			 pv_min_kb, DEFAULT_PV_MIN_SIZE_KB);
 		pv_min_kb = DEFAULT_PV_MIN_SIZE_KB;
 	}
-	/* lvm internally works with device size in 512b sectors */
+	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
 	return 1;
--- LVM2/doc/example.conf.in	2011/04/26 09:09:24	1.24
+++ LVM2/doc/example.conf.in	2011/04/28 17:33:35	1.25
@@ -6,6 +6,9 @@
 #
 # To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
 # the environment variable LVM_SYSTEM_DIR before running the tools.
+#
+# N.B. Take care that each setting only appears once if uncommenting
+# example settings in this file.
 
 
 # This section allows you to configure which block devices should
@@ -155,12 +158,15 @@
     # Allow use of pvcreate --uuid without requiring --restorefile.
     require_restorefile_with_uuid = 1
 
-    # Minimal size (in KB) of the block device which can be used as a PV.
-    # In clustered environment all nodes have to use the same value.
+    # Minimum size (in KB) of block devices which can be used as PVs.
+    # In a clustered environment all nodes must use the same value.
     # Any value smaller than 512KB is ignored.
-    # Example: Ignore devices smaller than 2MB (i.e. floppy drives).
-    # pv_min_size = 2048
-    pv_min_size = 512
+
+    # Ignore devices smaller than 2MB such as floppy drives.
+    pv_min_size = 2048
+
+    # The original built-in setting was 512 up to and including version 2.02.84.
+    # pv_min_size = 512
 
     # Issue discards to a logical volumes's underlying physical volume(s) when
     # the logical volume is no longer using the physical volumes' space (e.g.

