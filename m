From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 18:10:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100414181033.30414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 18:10:30

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1522&r2=1.1523

--- LVM2/WHATS_NEW	2010/04/14 17:50:49	1.1522
+++ LVM2/WHATS_NEW	2010/04/14 18:10:30	1.1523
@@ -8,12 +8,12 @@
   Use typedefs for toollib process_each functions.
   Use C locales and use_mlockall for clvmd.
   Refactor code related to vg->pvs list and add pv->vg link.
-  Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
+  Mask LCK_HOLD flag in cluster VG locks for backwards compatibility.
   Add activation/polling_interval to lvm.conf as --interval default.
   Don't ignore error if resuming any LV fails in resume_lvs.
   Skip closing persistent filter cache file if open failed.
-  Install .a .so links to $(usrlibdir).
-  Add --enable-write_install options to install user writable files.
+  Install .a and .so links into $(usrlibdir).
+  Add --enable-write_install options to install user-writable files.
   Use INSTALL_PROGRAM/DATA/WDATA target.
   Switch from using VPATH  to vpath in Makefiles.
   Permit mimage LVs to be striped in lvcreate, lvresize and lvconvert.
@@ -27,13 +27,13 @@
   Improve vg_validate to detect some loops in lists.
   Change most remaining log_error WARNING messages to log_warn.
   Always use blocking lock for VGs and orphan locks.
-  Allocate all segments memory from vg private mempool.
+  Allocate all memory for segments from private VG mempool.
   Return newly allocated PV segment after segment split.
-  Optimise PV segments search for the most last segment search case.
+  Optimise searching PV segments for seeking the most recently-added.
   Remove vg_validate call when parsing cached metadata.
   Use hash table of LVs to speed up parsing of text metadata with many LVs.
-  Fix two messages, add a whitespace and parentheses
-  When dmeventd is not forking because of -d flag, don't kill the parent process
+  Fix two vg_validate messages, adding whitespace and parentheses.
+  When dmeventd is not forking because of -d flag, don't kill parent process.
   Fix 'make install' when $(builddir) is different from $(srcdir).
   Fix dso resource leak in error path of dmeventd.
   Use C locales and use_mlockall for dmeventd.


