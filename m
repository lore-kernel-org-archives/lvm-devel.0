From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Jul 2009 11:01:28 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20090714110128.13039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-14 11:01:26

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again. (mbroz)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1181&r2=1.1182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2009/07/14 03:08:56	1.1181
+++ LVM2/WHATS_NEW	2009/07/14 11:01:26	1.1182
@@ -1,12 +1,13 @@
 Version 2.02.49 - 
 ================================
+  Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
   Add unit test case for liblvm VG create/delete APIs.
   Add liblvm APIs to implement creation and deletion of VGs.
-  Initialize cmd->cmd_line to "liblvm".
-  Place handles to liblvm objects for pv, vg, lv, lvseg, pvseg inside lvm.h
+  Initialize cmd->cmd_line to "liblvm" in new liblvm library.
+  Place handles to liblvm objects for pv, vg, lv, lvseg, pvseg inside lvm.h.
   Refactor vgsplit and vgextend to remove READ_REQUIRE_RESIZEABLE flag.
-  Changed exit() to _exit() after fork(); avoid flushing libc buffers twice.
-  Fixed invalid type being passed as printf argument on Sparc64.
+  Changed exit() to _exit() after fork() to avoid flushing libc buffers twice.
+  Add cast to log_info arg in _find_labeller to avoid Sparc64 warning.
   Make cmd->cmd_line const.
   Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.
--- LVM2/lib/locking/locking.c	2009/05/21 03:04:53	1.60
+++ LVM2/lib/locking/locking.c	2009/07/14 11:01:26	1.61
@@ -189,10 +189,12 @@
 		_unblock_signals();
 }
 
-static void _update_vg_lock_count(uint32_t flags)
+static void _update_vg_lock_count(const char *resource, uint32_t flags)
 {
+	/* Ignore locks not associated with updating VG metadata */
 	if ((flags & LCK_SCOPE_MASK) != LCK_VG ||
-	    (flags & LCK_CACHE))
+	    (flags & LCK_CACHE) ||
+	    !strcmp(resource, VG_GLOBAL))
 		return;
 
 	if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
@@ -356,7 +358,7 @@
 								== LCK_READ);
 		}
 
-		_update_vg_lock_count(flags);
+		_update_vg_lock_count(resource, flags);
 	}
 
 	_unlock_memory(flags);


