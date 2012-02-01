From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Feb 2012 13:42:20 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20120201134220.17877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-01 13:42:19

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/misc       : lvm-globals.h 

Log message:
	Avoid warning for small pv_min_size
	
	Do not print warning for pv_min_size set in range between 512KB and 2MB.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2251&r2=1.2252
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2012/02/01 13:08:39	1.2251
+++ LVM2/WHATS_NEW	2012/02/01 13:42:18	1.2252
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Do not print warning for pv_min_size set in range between 512KB and 2MB.
   Clean up systemd unit ordering and requirements.
   Fix lcov reports when srcdir != builddir.
   Allow ALLOC_NORMAL to track reserved extents for log and data on same PV.
--- LVM2/lib/commands/toolcontext.c	2012/01/23 17:46:32	1.147
+++ LVM2/lib/commands/toolcontext.c	2012/02/01 13:42:19	1.148
@@ -377,10 +377,10 @@
 						       DEFAULT_METADATA_READ_ONLY);
 
 	pv_min_kb = find_config_tree_int64(cmd, "devices/pv_min_size", DEFAULT_PV_MIN_SIZE_KB);
-	if (pv_min_kb < DEFAULT_PV_MIN_SIZE_KB) {
+	if (pv_min_kb < PV_MIN_SIZE_KB) {
 		log_warn("Ignoring too small pv_min_size %" PRId64 "KB, using default %dKB.",
-			 pv_min_kb, DEFAULT_PV_MIN_SIZE_KB);
-		pv_min_kb = DEFAULT_PV_MIN_SIZE_KB;
+			 pv_min_kb, PV_MIN_SIZE_KB);
+		pv_min_kb = PV_MIN_SIZE_KB;
 	}
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
--- LVM2/lib/misc/lvm-globals.h	2011/09/22 17:39:57	1.14
+++ LVM2/lib/misc/lvm-globals.h	2012/02/01 13:42:19	1.15
@@ -18,6 +18,7 @@
 
 #define VERBOSE_BASE_LEVEL _LOG_WARN
 #define SECURITY_LEVEL 0
+#define PV_MIN_SIZE_KB 512
 
 void init_verbose(int level);
 void init_test(int level);


