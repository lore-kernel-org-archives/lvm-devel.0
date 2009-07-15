From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 14:59:17 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090715145917.5856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 14:59:14

Modified files:
	.              : WHATS_NEW 

Log message:
	pre-release clarification

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1185&r2=1.1186

--- LVM2/WHATS_NEW	2009/07/15 13:20:06	1.1185
+++ LVM2/WHATS_NEW	2009/07/15 14:59:14	1.1186
@@ -1,33 +1,31 @@
 Version 2.02.49 - 15th July 2009
 ================================
-  Fix vgck and vgremove segfault if non-existent vg given.
-  Enable use of new multi-segment registration for static registration too.
   Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
   Add unit test case for liblvm VG create/delete APIs.
   Add liblvm APIs to implement creation and deletion of VGs.
   Initialize cmd->cmd_line to "liblvm" in new liblvm library.
   Place handles to liblvm objects for pv, vg, lv, lvseg, pvseg inside lvm.h.
   Refactor vgsplit and vgextend to remove READ_REQUIRE_RESIZEABLE flag.
-  Changed exit() to _exit() after fork() to avoid flushing libc buffers twice.
+  Use _exit() not exit() after forking to avoid flushing libc buffers twice.
   Add cast to log_info arg in _find_labeller to avoid Sparc64 warning.
   Make cmd->cmd_line const.
   Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.
-  Make all tools consistent with lock ordering - obtain VG_ORPHAN lock second.
-  Check MD devices for a partition table during device scan.
-  Add extended device (blkext) and MD partition (mdp) types to filters.
-  Fix and precise metadata read errors for segment areas.
-  Fix segment metadata read function errors to use proper segment name.
+  Make all tools use consistent lock ordering obtaining VG_ORPHAN lock second.
+  Check md devices for a partition table during device scan.
+  Add extended device (blkext) and md partition (mdp) types to filters.
+  Make text metadata read errors for segment areas more precise.
+  Fix text segment metadata read errors to mention correct segment name.
+  Include segment and LV names in text segment import error messages.
   Add parent node to config_node structure.
-  Fix segment import functions to print segment name and logical volume name.
-  Update vgsplit and vgcreate to call the new vg_create, then call 'set' fns.
+  Update vgsplit and vgcreate to call new vg_create and 'set' functions.
   Change vg_create to take minimal parameters, obtain a lock, and return vg_t.
   Refactor vgchange extent_size, max_lv, max_pv, and alloc_policy for liblvm.
   Update t-vgcreate-usage.sh to test for default vg properties.
   Fix memory leak in vgsplit when re-reading the vg.
   Make exit/cleanup code more robust when some lvm init function fails.
-  Use implicit set of LCK_NONBLOCK instead of explicit vg_read() flag.
-  Remove unnecessary locking and existence code from new vg_read() interface.
+  Use LCK_NONBLOCK implicitly instead of explicit vg_read() flag.
+  Remove unnecessary locking and existence tests from new vg_read() interface.
   Permit several segment types to be registered by a single shared object.
   Update the man pages to document size units uniformly.
   Allow commandline sizes to be specified in terms of bytes and sectors.


