From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2008 19:17:31 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/file_locking.c li ...
Message-ID: <20080407191731.27733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-04-07 19:17:30

Modified files:
	.              : WHATS_NEW 
	lib/locking    : file_locking.c locking.c no_locking.c 

Log message:
	Update lvmcache VG lock state for all locking types now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.827&r2=1.828
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2008/04/07 13:53:26	1.827
+++ LVM2/WHATS_NEW	2008/04/07 19:17:29	1.828
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Update lvmcache VG lock state for all locking types now.
   Fix output if overriding command_names on cmdline.
   Add detection of clustered mirror log capability.
   Add check to vg_commit() ensuring VG lock held before writing new VG metadata.
--- LVM2/lib/locking/file_locking.c	2008/04/03 18:56:40	1.35
+++ LVM2/lib/locking/file_locking.c	2008/04/07 19:17:29	1.36
@@ -21,7 +21,6 @@
 #include "defaults.h"
 #include "lvm-file.h"
 #include "lvm-string.h"
-#include "lvmcache.h"
 
 #include <limits.h>
 #include <unistd.h>
@@ -222,16 +221,6 @@
 
 		if (!_lock_file(lockfile, flags))
 			return_0;
-
-		switch (flags & LCK_TYPE_MASK) {
-		case LCK_UNLOCK:
-			lvmcache_unlock_vgname(resource);
-			break;
-		default:
-			lvmcache_lock_vgname(resource,
-					     (flags & LCK_TYPE_MASK) ==
-					     LCK_READ);
-		}
 		break;
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
--- LVM2/lib/locking/locking.c	2008/01/30 13:59:59	1.44
+++ LVM2/lib/locking/locking.c	2008/04/07 19:17:29	1.45
@@ -21,6 +21,7 @@
 #include "toolcontext.h"
 #include "memlock.h"
 #include "defaults.h"
+#include "lvmcache.h"
 
 #include <signal.h>
 #include <sys/stat.h>
@@ -315,22 +316,29 @@
  */
 static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
 {
+	int ret = 0;
+
 	_block_signals(flags);
 	_lock_memory(flags);
 
 	assert(resource);
 
-	if (!(_locking.lock_resource(cmd, resource, flags))) {
-		_unlock_memory(flags);
-		_unblock_signals();
-		return 0;
+	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
+		if ((flags & LCK_SCOPE_MASK) == LCK_VG) {
+			if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
+				lvmcache_unlock_vgname(resource);
+			else
+				lvmcache_lock_vgname(resource, (flags & LCK_TYPE_MASK)
+								== LCK_READ);
+		}
+
+		_update_vg_lock_count(flags);
 	}
 
-	_update_vg_lock_count(flags);
 	_unlock_memory(flags);
 	_unblock_signals();
 
-	return 1;
+	return ret;
 }
 
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
--- LVM2/lib/locking/no_locking.c	2008/01/30 13:59:59	1.14
+++ LVM2/lib/locking/no_locking.c	2008/04/07 19:17:29	1.15
@@ -18,7 +18,6 @@
 #include "locking_types.h"
 #include "lvm-string.h"
 #include "activate.h"
-#include "lvmcache.h"
 
 #include <signal.h>
 
@@ -41,15 +40,6 @@
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		switch (flags & LCK_TYPE_MASK) {
-		case LCK_UNLOCK:
-			lvmcache_unlock_vgname(resource);
-			break;
-		default:
-			lvmcache_lock_vgname(resource,
-					     (flags & LCK_TYPE_MASK) ==
-					     LCK_READ);
-		}
 		break;
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {


