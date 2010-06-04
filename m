From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Jun 2010 17:23:50 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100604172350.17445.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-04 17:23:49

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.238&r2=1.239
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1607&r2=1.1608
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.376&r2=1.377

--- LVM2/VERSION	2010/05/20 23:21:53	1.238
+++ LVM2/VERSION	2010/06/04 17:23:49	1.239
@@ -1 +1 @@
-2.02.67(2)-cvs (2010-05-20)
+2.02.67(2)-cvs (2010-06-04)
--- LVM2/VERSION_DM	2010/05/20 23:21:53	1.49
+++ LVM2/VERSION_DM	2010/06/04 17:23:49	1.50
@@ -1 +1 @@
-1.02.49-cvs (2010-05-20)
+1.02.49-cvs (2010-06-04)
--- LVM2/WHATS_NEW	2010/06/04 12:59:30	1.1607
+++ LVM2/WHATS_NEW	2010/06/04 17:23:49	1.1608
@@ -1,8 +1,8 @@
-Version 2.02.67 -
+Version 2.02.67 - 4th June 2010
 ===============================
   Handle failed restart of clvmd using -S switch properly.
   Fix clvmd initscript restart command to start clvmd if not yet running.
-  Use absolute paths for clvmd restart.
+  Use built-in absolute paths in clvmd (clvmd restart and PV and LV queries).
   Require partial option in lvchange --refresh for partial LVs.
   Do not fail lvm_init() if init_logging() or _init_rand() generates an errno.
   Don't merge unchanged persistent cache file before dumping if tool scanned.
@@ -11,26 +11,17 @@
   Replace strncmp kernel version number checks with proper ones.
   Avoid selecting names under /dev/block if there is an alternative.
   Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
-  Activate only first head of Replicator for vgchange -ay.
-  Add Replicators' LVs to dtree for activation.
-  Avoid print activation message if there is a missing VG (Replicator).
-  Fixed scripts/relpath.awk to work in mawk
-  Add _add_partial_replicator_to_dtree().
-  Activation code read and releases also remote VGs (Replicator).
-  Check for missing VGs before taking lock_vol (Replicator).
-  Update process_each_lv_in_vg() to use cmd_vg structure.
-  Update _process_one_vg() to work with cmd_vg structure.
-  Add functions for read and release VGs list.
-  Add find_replicator_vgs() to discover all needed VGs for replicator-dev LV.
-  Add functions for handling cmd_vg structure.
-  Extend _lv_each_dependency() with Replicator dependencies.
-  Add check_replicator_segment() for catching internal Replicator errors.
-  Initial lvm2 support for Replicator metadata handling.
-  Checking open_count in all parents of presuspend_node.
-  Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
-  Initial libdm support for Replicator target (API is not stable yet).
-  Extend process_each_lv_in_vg() with support for list of failed lvnames.
-  Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv().
+  Add replicators' LVs to dtree for activation.
+  Supress activation message if there is a missing replicator VG.
+  Fix scripts/relpath.awk to work in mawk
+  Extend lock_vol to check for missing replicator VGs first.
+  Update _process_one_vg and process_each_lv_in_vg to populate cmd_vg.
+  Add cmd_vg structure and associated functions for replicator.
+  Extend _lv_each_dependency() to handle replicator dependencies.
+  Add check_replicator_segment() to catch internal replicator errors.
+  Initial support for replicator metadata.
+  Extend process_each_lv_in_vg() to provide list of failed lvnames.
+  Consistently return ECMD_FAILED if process_each_*lv() is interrupted.
 
 Version 2.02.66 - 20th May 2010
 ===============================
--- LVM2/WHATS_NEW_DM	2010/06/01 16:08:13	1.376
+++ LVM2/WHATS_NEW_DM	2010/06/04 17:23:49	1.377
@@ -1,8 +1,10 @@
-Version 1.02.49 - 
-================================
-  Add support for dm-mod module autoload.
+Version 1.02.49 - 4th June 2010
+===============================
+  Support autoloading of dm-mod module for kernels from 2.6.35.
   Document 'clear' in dmsetup man page.
-  Use expected union semun for arguments in selected semaphore operations.
+  Fix semctl parameter (union) to avoid misaligned parameter on some arches.
+  Add dm_tree_node_set_presuspend_node() to presuspend child when deactivating.
+  Initial support for replicator target.
 
 Version 1.02.48 - 17th May 2010
 ================================


