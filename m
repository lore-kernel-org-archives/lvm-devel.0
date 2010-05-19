From: agk@sourceware.org <agk@sourceware.org>
Date: 19 May 2010 02:36:34 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.h lib/lock ...
Message-ID: <20100519023634.21918.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-19 02:36:33

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.h 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	lib/metadata   : metadata.c 

Log message:
	Add is_global_vg and split out from is_orphan_vg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1565&r2=1.1566
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.341&r2=1.342

--- LVM2/WHATS_NEW	2010/05/19 02:08:50	1.1565
+++ LVM2/WHATS_NEW	2010/05/19 02:36:33	1.1566
@@ -2,7 +2,7 @@
 ===============================
   Validate orphan and VG_GLOBAL lock order too.
   Accept orphan VG names as parameters to lock_vol() and related functions.
-  Use is_orphan_vg in place of hard-coded prefix tests.
+  Use is_orphan_vg in place of hard-coded prefix tests and add is_global_vg.
 
 Version 2.02.65 - 17th May 2010
 ===============================
--- LVM2/lib/cache/lvmcache.h	2010/03/17 02:11:18	1.30
+++ LVM2/lib/cache/lvmcache.h	2010/05/19 02:36:33	1.31
@@ -19,9 +19,10 @@
 #include "dev-cache.h"
 #include "uuid.h"
 #include "label.h"
+#include "locking.h"
 
-#define ORPHAN_PREFIX "#"
-#define ORPHAN_VG_NAME(fmt) ORPHAN_PREFIX "orphans_" fmt
+#define ORPHAN_PREFIX VG_ORPHANS
+#define ORPHAN_VG_NAME(fmt) ORPHAN_PREFIX "_" fmt
 
 #define CACHE_INVALID	0x00000001
 #define CACHE_LOCKED	0x00000002
--- LVM2/lib/locking/cluster_locking.c	2010/05/19 00:52:55	1.43
+++ LVM2/lib/locking/cluster_locking.c	2010/05/19 02:36:33	1.44
@@ -406,7 +406,7 @@
 		}
 
 		/* If the VG name is empty then lock the unused PVs */
-		if (is_orphan_vg(resource) || (flags & LCK_CACHE))
+		if (is_orphan_vg(resource) || is_global_vg(resource) || (flags & LCK_CACHE))
 			dm_snprintf(lockname, sizeof(lockname), "P_%s",
 				    resource);
 		else
--- LVM2/lib/locking/file_locking.c	2010/05/19 00:52:55	1.45
+++ LVM2/lib/locking/file_locking.c	2010/05/19 02:36:33	1.46
@@ -265,7 +265,7 @@
 		if (flags & LCK_CACHE)
 			break;
 
-		if (is_orphan_vg(resource))
+		if (is_orphan_vg(resource) || is_global_vg(resource))
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_%s", _lock_dir, resource + 1);
 		else
--- LVM2/lib/locking/locking.c	2010/05/19 02:08:51	1.83
+++ LVM2/lib/locking/locking.c	2010/05/19 02:36:33	1.84
@@ -325,7 +325,7 @@
 	char path[PATH_MAX];
 
 	/* We'll allow operations on orphans */
-	if (is_orphan_vg(vgname))
+	if (is_orphan_vg(vgname) || is_global_vg(vgname))
 		return 1;
 
 	/* LVM1 is only present in 2.4 kernels. */
@@ -369,7 +369,7 @@
 		return 0;
 	}
 
-	if (is_orphan_vg(resource) && (flags & LCK_CACHE)) {
+	if ((is_orphan_vg(resource) || is_global_vg(resource)) && (flags & LCK_CACHE)) {
 		log_error(INTERNAL_ERROR "P_%s referenced", resource);
 		return 0;
 	}
--- LVM2/lib/metadata/metadata.c	2010/05/19 02:08:51	1.341
+++ LVM2/lib/metadata/metadata.c	2010/05/19 02:36:33	1.342
@@ -3337,7 +3337,7 @@
  */
 int is_orphan_vg(const char *vg_name)
 {
-	return (vg_name && vg_name[0] == ORPHAN_PREFIX[0]) ? 1 : 0;
+	return (vg_name && !strncmp(vg_name, ORPHAN_PREFIX, sizeof(ORPHAN_PREFIX) - 1)) ? 1 : 0;
 }
 
 /**


