From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2010 21:28:05 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-re ...
Message-ID: <20100111212805.17059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-11 21:28:04

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Add missing items to WHATS_NEW files.
	Continue to use 'field' to describe reporting elements.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1378&r2=1.1379
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.329&r2=1.330
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2010/01/11 15:40:03	1.1378
+++ LVM2/WHATS_NEW	2010/01/11 21:28:04	1.1379
@@ -1,52 +1,66 @@
 Version 2.02.57 -
 ====================================
-  Add support to disable udev checking: LVM_UDEV_DISABLE_CHECKING=1 env. var.
-  Add redundant mirror log option.
-  Add capability to split off and keep mirror legs to lvconvert.
+  Ensure exactly one process returns from poll_daemon(), never two.
+  Reset _vgs_locked in lvmcache_init() in child after forking.
+  Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 environment variables during tests.
+  Enable udev_sync and udev_rules in lvm.conf by default while running tests.
+  If LVM_UDEV_DISABLE_CHECKING in set in environment, disable udev warnings.
+Add redundant mirror log option.  FIXME - rename to 'duplicated' or similar?
+  Add --splitmirrors to lvconvert to split off part of a mirror.
   Change background polldaemon's process name to "(lvm2)".
-  Allow vgremove of a VG with PVs missing.
+  Allow vgremove to remove a VG with PVs missing after a prompt.
+  Return success in lvconvert --repair --use-policies on failed allocation.
   Keep log type consistent when changing mirror image count.
   Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
   Add activation/udev_rules config option in lvm.conf.
-  Add macro outfc() and export out_text_with_comment().
-  Add macros outsize() and outhint().
-  Use offsetof() macro for FIELD() macro in lib/report/report.c.
+  Add consts to text metadata flag structs.
+  Add macros outfc, outsize, outhint and function out_text_with_comment.
+  Reimplement report FIELD macro using offsetof instead of static structs.
+  Fix fsadm man page typo (fsdam).
   Rename mirror_device_fault_policy to mirror_image_fault policy.
   Remove empty PV devices if lvconvert --repair is using defined policies.
   Use fixed buffer to prevent stack overflow in persistent filter dump.
-  Use snapshot metadata usage to determine if a snapshot is empty.
-  Insert missing stack macros to all activate_lv and deactivate_lv callers.
-  Insert missing stack macros to all suspend_lv and resume_lv callers.
-  Add --poll flag to vgchange and lvchange.
-  Propagate commit and revert metadata notification to other nodes in cluster.
+  Use extended status of new kernel snapshot target 1.8.0 to detect when empty.
+  Insert stack macros in suspend_lv, resume_lv & (de)activate_lv callers.
+  Add --poll flag to vgchange and lvchange to control background daemon launch.
+  Propagate metadata commit and revert notifications to other cluster nodes.
   Use proper mask for VG lock mode in clvmd.
-  Add possibility to drop precommitted metadata in lvmcache.
+  Allow precommitted metadata to be dropped from lvmcache.
   Move processing of VG locks to separate function in clvmd.
-  Properly decode flags even for VG locks.
-  Properly handle precommitted flag in cache when commited data only present.
+  Properly decode all flags in clvmd messages including VG locks.
+  Properly handle precommitted cache flag when only committed metadata present.
   Resume renamed volumes in reverse order to preserve memlock pairing.
-  Drop metadata cache after device was autorepaired and removed from VG.
-  Remove missing flag in metadata if PV reappeared and is empty.
+  Drop cached metadata after device was auto-repaired and removed from VG.
+  Clear MISSING_PV flag if PV reappeared and is empty.
+  Fix removal of multiple devices from a mirror.
+  Also clean up PVs flagged as missing in vgreduce --removemissing --force.
+  Introduce INTERNAL_ERROR macro for error messages and use throughout.
+  Remove superfluous returns from void functions.
   Destroy allocated mempool in _vg_read_orphans() error path.
-  Fix unlocking vg in some pvresize and toollib error paths.
+  Fix some pvresize and toollib error paths with missing VG releases/unlocks.
   Explicitly call suspend for temporary mirror layer.
-  Allow use precommited metadata when a PV is missing.
+  Allow use of precommitted metadata when a PV is missing.
   Add memlock information to do_lock_lv debug output.
-  Never use distributed lock for LV in non-clustered VG.
-  Allow implicit lock conversion in pre/post callbacks on local node.
-  Allow implicit convert to the same cluster lock mode.
+  Always bypass calls to remote cluster nodes for non-clustered VGs.
+  Permit implicit cluster lock conversion in pre/post callbacks on local node.
+  Permit implicit cluster lock conversion to the lock mode already held.
+  Fix lock flag masking in clvmd so intended code paths get invoked.
   Replace magic masks in cluster locking code by defined masks.
-  Remove log volume from metadata if initial deactivation fails.
-  Give better error message for pvmove when all data is skipped.
-  Fix memory lock imbalance in lv_suspend if already suspended.
-  Fix pvmove test mode to not fail and do not poll.
-  Fix error message if VG already exist in vgcreate.
-  Fix tools to use log_error when stopped by user.
-  Fix lvcreate --readahead.
-  Fix clvmd memory leak in lv_info_by_lvid.
-  Do not allow creating mirrors of more than 8 images.
-  Use locking_type 3 (compiled in cluster locking) in lvmconf.
-  Remove duplicate dm_list macros and functions.
+  Remove newly-created mirror log from metadata if initial deactivation fails.
+  Correct activated or deactivated text in vgchange summary message.
+  Improve pvmove error message when all source LVs are skipped.
+  Fix memlock imbalance in lv_suspend if already suspended.
+  Fix pvmove test mode not to poll (and fail).
+  Fix vgcreate error message if VG already exists.
+  Fix tools to use log_error when aborted due to user response to prompt.
+  Fix ignored readahead setting in lvcreate --readahead.
+  Fix clvmd memory leak in lv_info_by_lvid by calling release_vg.
+  If aborting due to internal error, always send that message to stderr.
+  Add global/abort_on_internal_errors to lvm.conf to assist testing.
+  Fix test Makefiles when builddir and srcdir differ.
+  Impose limit of 8 mirror images to match the in-kernel kcopyd restriction.
+  Use locking_type 3 (compiled in) for lvmconf --enable-cluster.
+  Remove list.c and list.h with no-longer-used dm_list macros and functions.
   Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
   Extend internal PV/VG/LV/segment status variables from 32-bit to 64-bit.
 
--- LVM2/WHATS_NEW_DM	2010/01/11 15:48:49	1.329
+++ LVM2/WHATS_NEW_DM	2010/01/11 21:28:04	1.330
@@ -1,14 +1,10 @@
 Version 1.02.41 -
 ====================================
-  Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 env. variables for tests.
-  Enable udev_sync and udev_rules in lvm.conf by default while running tests.
-  Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
+  If LVM_UDEV_DISABLE_CHECKING in set in environment, disable udev warnings.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.
-  Update code to show all fields for 'dmsetup info -c -o all'.
-  Return error from dm_tree_deactivate_children().
-  Return error from dm_tree_suspend_children().
-  Return error from dm_tree_preload_children() and dm_tree_activate_children().
+  Fix 'dmsetup info -c -o all' to show all fields.
+  Return errors if dm_tree_*_children functions fail.
   Fix coredump and memory leak for 'dmsetup help -c'.
   Disable udev rules for change events with DISK_RO set.
 
--- LVM2/libdm/libdm-report.c	2010/01/07 14:32:44	1.32
+++ LVM2/libdm/libdm-report.c	2010/01/11 21:28:04	1.33
@@ -550,7 +550,7 @@
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			log_error("dm_report: Unrecognised key: %.*s",
+			log_error("dm_report: Unrecognised field: %.*s",
 				  (int) (we - ws), ws);
 			return 0;
 		}


