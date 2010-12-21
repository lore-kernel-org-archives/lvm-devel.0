From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Dec 2010 01:08:30 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20101221010830.17827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-21 01:08:30

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.264&r2=1.265
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1848&r2=1.1849
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.432&r2=1.433

--- LVM2/VERSION	2010/12/06 22:13:10	1.264
+++ LVM2/VERSION	2010/12/21 01:08:29	1.265
@@ -1 +1 @@
-2.02.79(2)-cvs (2010-12-06)
+2.02.79(2)-cvs (2010-12-20)
--- LVM2/VERSION_DM	2010/12/06 22:13:10	1.73
+++ LVM2/VERSION_DM	2010/12/21 01:08:29	1.74
@@ -1 +1 @@
-1.02.60-cvs (2010-12-06)
+1.02.60-cvs (2010-12-20)
--- LVM2/WHATS_NEW	2010/12/20 14:38:22	1.1848
+++ LVM2/WHATS_NEW	2010/12/21 01:08:29	1.1849
@@ -1,16 +1,18 @@
-Version 2.02.79 -  
-===================================
+Version 2.02.79 - 20th December 2010
+====================================
+  Remove some unused variables.
   Add missing test for reallocation error in _find_parallel_space().
-  Add check for unlink error result in remove_lockfile() (dmeventd).
-  Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr (cmirrord).
   Add checks for allocation errors in config node clonning.
   Fix error path if regex engine cannot be created in _build_matcher().
-  Use char* arithmetic in target_version(), _process_all(), _targets().
+  Use char* arithmetic in target_version(), _process_all() & _targets().
   Fixing const cast gcc warnings in the code.
   Check read() and close() results in _get_cmdline().
   Add const for struct config_node usage.
   Fix NULL pointer check in error path in clvmd do_command(). (2.02.78)
   Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)
+  Add copy_percent and snap_percent to liblvm.
+  Enhance vg_validate to ensure integrity of LV and PV structs referenced.
+  Enhance vg_validate to check composition of pvmove LVs.
   Create /var/run/lvm directory during clvmd initialisation if missing.
   Use new dm_prepare_selinux_context instead of dm_set_selinux_context.
   Avoid revalidating the label cache immediately after scanning.
@@ -18,7 +20,7 @@
   Don't skip full scan when independent mdas are present even if memlock is set.
   Set cmd->independent_metadata_areas if metadata/dirs or disk_areas in use.
   Cope better with an undefined target_percent operation in _percent_run.
-  Fix write to released memory in vg_release and rename to free_vg.  (2.02.78)
+  Avoid writing to freed memory in vg_release and rename to free_vg.  (2.02.78)
 
 Version 2.02.78 - 6th December 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/12/20 13:23:11	1.432
+++ LVM2/WHATS_NEW_DM	2010/12/21 01:08:29	1.433
@@ -1,5 +1,8 @@
-Version 1.02.60 -
-===================================
+Version 1.02.60 - 20th December 2010
+====================================
+  Check for unlink failure in remove_lockfile() in dmeventd.
+  Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr in cmirrord.
+  Use char* arithmetic in _process_all() & _targets() in dmsetup.
   Change dm_regex_create() API to accept const char * const *patterns.
   Add new dm_prepare_selinux_context fn to libdevmapper and use it throughout.
   Detect existence of new SELinux selabel interface during configure.


