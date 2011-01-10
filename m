From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2011 14:28:19 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM ...
Message-ID: <20110110142819.16930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-10 14:28:18

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 
	                 configure 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1870&r2=1.1871
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.436&r2=1.437
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.266&r2=1.267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/WHATS_NEW	2011/01/10 14:02:30	1.1870
+++ LVM2/WHATS_NEW	2011/01/10 14:28:17	1.1871
@@ -1,19 +1,20 @@
-Version 2.02.80 - 
-====================================
-  Speedup consequent activation calls by using internal cookie.
-  Add internal lvm library cookie.
-  Speedup command processing by caching resolved config tree.
+Version 2.02.80 - 10th January 2011
+===================================
+  Use same dm cookie for consecutive dm ops in same VG to reduce udev waits.
+  Speed up command processing by caching resolved config tree.
   Pass config_tree to renamed function import_vg_from_config_tree().
   Detect NULL handle in get_property().
   Fix superfluous /usr in ocf_scriptdir instalation path.
   Add --with-ocfdir configurable option.
   Add aclocal.m4 (for pkgconfig).
-  Fix memory leak in filter creation error path.
-  Add missing tests in _setup_task().
-  Fail poll daemon creation when lvmcache_init() fails.
-  Return defined value for errors in _copy_percent() and _snap_percent().
-  Correct return code of cmirrord when issuing 'start' when already running.
-  Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)
+  Fix memory leak in persistent filter creation error path.
+  Check for errors setting up dm_task struct in _setup_task().
+  Fail polldaemon creation when lvmcache_init() fails.
+  Return PERCENT_INVALID for errors in _copy_percent() and _snap_percent().
+  Remove some unused variables.
+  Improve general lvconvert man page description.
+  Return 0 from cmirrord initscript 'start' if daemon is already running.
+  Fix wrongly paired unlocking of VG_GLOBAL in pvchange. (2.02.66)
   Add backtraces for backup and backup_remove fail paths.
   Detect errors from dm_task_set calls in _get_device_info (dmeventd).
   Add backtraces for archive and backup_locally in check_current_backup().
--- LVM2/WHATS_NEW_DM	2011/01/10 13:42:31	1.436
+++ LVM2/WHATS_NEW_DM	2011/01/10 14:28:18	1.437
@@ -1,5 +1,5 @@
-Version 1.02.61 - 
-====================================
+Version 1.02.61 - 10th January 2011
+===================================
   Add DM_COOKIE_AUTO_CREATE to libdevmapper.h.
   Export DM_CONTROL_NODE_UMASK and use it while creating /dev/mapper/control.
 
--- LVM2/VERSION	2010/12/21 21:08:52	1.266
+++ LVM2/VERSION	2011/01/10 14:28:18	1.267
@@ -1 +1 @@
-2.02.80(2)-cvs (2010-12-21)
+2.02.80(2)-cvs (2011-01-10)
--- LVM2/VERSION_DM	2010/12/21 21:08:52	1.75
+++ LVM2/VERSION_DM	2011/01/10 14:28:18	1.76
@@ -1 +1 @@
-1.02.61-cvs (2010-12-21)
+1.02.61-cvs (2011-01-10)
--- LVM2/configure	2011/01/07 14:38:34	1.144
+++ LVM2/configure	2011/01/10 14:28:18	1.145
@@ -619,6 +619,7 @@
 POOL
 PKGCONFIG
 REPLICATORS
+OCFDIR
 OCF
 MIRRORS
 LVM_RELEASE_DATE
@@ -797,6 +798,7 @@
 enable_readline
 enable_realtime
 enable_ocf
+with_ocfdir
 with_clvmd
 with_clvmd_pidfile
 enable_cmirrord
@@ -1536,6 +1538,8 @@
                           [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
+  --with-ocfdir=DIR       install OCF files in DIR
+                          [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
@@ -6908,6 +6912,14 @@
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $OCF" >&5
 $as_echo "$OCF" >&6; }
 
+# Check whether --with-ocfdir was given.
+if test "${with_ocfdir+set}" = set; then :
+  withval=$with_ocfdir; OCFDIR=$withval
+else
+  OCFDIR='${prefix}/lib/ocf/resource.d/lvm2'
+fi
+
+
 ################################################################################
 pkg_config_init() {
 
@@ -10284,6 +10296,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


