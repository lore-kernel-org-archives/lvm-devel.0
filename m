From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Dec 2007 22:19:24 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20071205221924.28926.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-05 22:19:24

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release
	
	N.B. This is a big release and some regressions are inevitable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.742&r2=1.743

--- LVM2/VERSION	2007/08/24 21:05:15	1.158
+++ LVM2/VERSION	2007/12/05 22:19:24	1.159
@@ -1 +1 @@
-2.02.29-cvs (2007-08-24)
+2.02.29-cvs (2007-12-05)
--- LVM2/WHATS_NEW	2007/12/05 22:11:19	1.742
+++ LVM2/WHATS_NEW	2007/12/05 22:19:24	1.743
@@ -1,5 +1,5 @@
-Version 2.02.29 -
-==================================
+Version 2.02.29 - 5th December 2007
+===================================
   Make clvmd backup vg metadata on remote nodes.
   Refactor pvmove allocation code.
   Decode cluster locking state in log message.
@@ -36,12 +36,12 @@
   Add const attributes to pv accessor functions.
   Refactor vg_add_snapshot() and lv_create_empty().
   Handle new sysfs subsystem/block/devices directory structure.
-  Tests are run with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
+  Run test with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
   Fix underquotations in lvm_dump.sh.
   Refactor lvcreate stripe and mirror parameter validation.
-  All tools: print --help output to stdout, not stderr.
-  After a diagnostic, suggest --help, rather than printing all --help output.
+  Print --help output to stdout, not stderr.
+  After a cmdline processing error, don't print help text but suggest --help.
   Add %PVS extents option to lvresize, lvextend, and lvcreate.
   Add 'make check' to run tests in new subdirectory 'test'.
   Moved the obsolete test subdirectory to old-tests.


