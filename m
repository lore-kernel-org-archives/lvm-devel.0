From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 00:21:23 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/locking/lo ...
Message-ID: <20110429002123.27456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 00:21:16

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/locking    : locking.h 
	lib/log        : log.c 
	lib/mirror     : mirrored.c 
	lib/mm         : memlock.c 
	lib/snapshot   : snapshot.c 
	man            : dmsetup.8.in lvm.conf.5.in 
	tools          : vgsplit.c 

Log message:
	pre-release clean-ups

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1975&r2=1.1976
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.462&r2=1.463
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2011/04/22 12:05:32	1.1975
+++ LVM2/WHATS_NEW	2011/04/29 00:21:13	1.1976
@@ -3,9 +3,10 @@
   Add new obtain_device_list_from_udev setting to lvm.conf.
   Obtain device list from udev by default if LVM2 is compiled with udev support.
   Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
-  Fix use of released memory when duplicate PV is found.
+  Avoid use of released memory when duplicate PV is found.
   Add "devices/issue_discards" to lvm.conf.
   Issue discards on lvremove, lvreduce, etc if enabled and supported.
+  Add seg_pe_ranges and devices fields to liblvm.
   Fix incorrect tests for dm_snprintf() failure.
   Fix some unmatching sign comparation gcc warnings in the code.
   Allow lv_extend() to work on zero length intrinsically layered LVs.
@@ -17,7 +18,12 @@
   Replace several strncmp() calls with id_equal().
   Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
   Fix -Wold-style-definition gcc warnings.
+  Rename MIRROR_NOTSYNCED to LV_NOTSYNCED.
+  Fix _move_lv_segments to handle empty LVs.
   Fixes for lvconvert (including --repair) of temporary mirror stacks.
+  Avoid potential loop when removing mirror images.
+  Fix mirror removal always to take account of preferences as to which.
+  Fix MIRRORED flag usage.
   Mitigate annoying error warning from device is usable check if run as non-root.
   Add missing \0 for grown debug object in _bitset_with_random_bits().
   Fix allocation of system_id buffer in volume_group structure.
@@ -31,6 +37,7 @@
   Use new alloc_fid fn for common format instance initialisation.
   Optimise _get_token() and _eat_space().
   Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
+  Add gdbinit script for debugging.
   Use hash tables to speedup string search in vg_validate().
   Refactor allocation of VG structure, add alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
@@ -38,8 +45,7 @@
   Don't allocate unused VG mempool in _pvsegs_sub_single.
   Do not send uninitialised bytes in local clvmd messages.
   Support --help option for clvmd and return error for unknown option.
-  Use system page size and not hardcoded value in locking code check.
-  Fix reading of released memory for printing segment type.
+  Avoid reading freed memory when printing LV segment type.
   Fix syslog initialisation in clvmd to respect lvm.conf setting.
   Fix possible overflow in maximum stripe size and physical extent size.
   Add test for failed allocation from dm_task_set_uuid() in dmeventd.
@@ -48,26 +54,31 @@
   Improve cling policy to recognise PVs already used during the transaction.
   Improve normal allocation algorithm to include clinging to existing areas.
   Add allocation/maximise_cling & mirror_logs_require_separate_pvs to lvm.conf.
-  Fix metadata balance code to work with recent changes in metadata handling.
+  Adapt metadata balancing code to work with metadata handling changes.
   Add old_id field to physical_volume and fix pvchange -u for recent changes.
   Allow pvresize on a PV with two metadata areas.
   Change pvcreate to use new metadata handling interface.
-  Restructure existing pv_setup and pv_write fn, add pv_initialise fn.
+  Restructure existing pv_setup and pv_write and add pv_initialise.
   Add internal interface to support adding and removing metadata areas.
   Allow internal indexing of metadata areas (PV id + mda order).
   Generalise internal format_instance infrastrusture for PV and VG use.
   Handle decimal digits with --units instead of ignoring them silently.
   Fix remaining warnings and compile with -Wpointer-arith.
-  Fix gcc warnings for unused variables.
+  Fix gcc warnings for unused variables and const casts.
   Add stack backtraces for error paths in process_each_lv().
-  Fixing some const cast gcc warnings in the code.
-  Use char* arithmetic in _text_write(), _text_read() & send_message().
-  Fix compilation when devmapper is dissabled.
+  Temporarily suppress error from calling yes_no_prompt while locks are held.
+  Replace void* with char* arithmetic in _text_write, _text_read & send_message.
+  Fix compilation without DEVMAPPER_SUPPORT.
   Remove fs_unlock() from lv_suspend error path.
-  Change memory locking semantic and use critical sections.
-  Add configurable pv_min_size to select block devices by its size.
-  Add function to read 64bit ints from config find_config_tree_int64.
-  Fix to make resuming exclusive cluster mirror use local target type.
+  Allow memory to stay locked between leaving and re-entering critical sections.
+  Rename memlock to critical_section throughout.
+  Make pv_min_size configurable and increase to 2048KB to exclude floppy drives.
+  Add find_config_tree_int64 to read 64-bit ints from config.
+  Ensure resuming exclusive cluster mirror continues to use local mirror target.
+  Clear temporary postorder LV status flags to allow re-use with same LV struct.
+  Remove invalid snapshot umount mesg which floods syslog from dmeventd plugin.
+  Add extended examples to pvmove man page.
+  Support LVM_TEST_DEVDIR env var for private /dev during testing.
 
 Version 2.02.84 - 9th February 2011
 ===================================
--- LVM2/WHATS_NEW_DM	2011/04/22 11:56:41	1.462
+++ LVM2/WHATS_NEW_DM	2011/04/29 00:21:13	1.463
@@ -10,15 +10,18 @@
   Improve stack debug reporting in dm_task_create().
   Fallback to control node creation only if node doesn't exist yet.
   Change dm_hash API for binary data to accept const void *key.
-  Fix memory access of empty params string in _reload_with_suppression_v4().
+  Fix uninitialised memory use with empty params in _reload_with_suppression_v4.
   Lower severity of selabel_lookup and matchpathcon failure to log_debug.
+  Add dm_event_get_version to dmeventd for use with -R.
+  Avoid dmeventd core dumps when handling request with unknown command ID.
+  Have dmeventd -R start up even when no existing copy is running.
   Accept multiple mapped device names on many dmsetup command lines.
   Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
   Include an implicit dm_task_update_nodes() within dm_udev_wait().
   Fix _create_and_load_v4 not to lose the --addnodeoncreate setting (1.02.62).
   Add inactive table query support for kernel driver >= 4.11.6 (RHEL 5.7).
   Log debug open_count in _node_has_closed_parents().
-  Change dm_report_field_string() API to accept const char *const *data.
+  Add a const to dm_report_field_string() data parameter.
 
 Version 1.02.63 - 9th February 2011
 ===================================
--- LVM2/lib/locking/locking.h	2011/04/28 20:29:59	1.64
+++ LVM2/lib/locking/locking.h	2011/04/29 00:21:14	1.65
@@ -39,8 +39,8 @@
  *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
  *   VG_ORPHANS last.
  *
- *   Use VG_SYNC_NAMES to wait for any outstanding asynchronous /dev nodes 
- *   events to complete.
+ *   Use VG_SYNC_NAMES to ensure /dev is up-to-date for example, with udev,
+ *   by waiting for any asynchronous events issued to have completed.
  *
  * LCK_LV:
  *   Lock/unlock an individual logical volume
--- LVM2/lib/log/log.c	2011/04/08 14:13:08	1.63
+++ LVM2/lib/log/log.c	2011/04/29 00:21:14	1.64
@@ -234,6 +234,7 @@
 		message = &buf2[0];
 	}
 
+/* FIXME Avoid pointless use of message buffer when it'll never be read! */
 	if (_store_errmsg && (level <= _LOG_ERR) &&
 	    _lvm_errmsg_len < MAX_ERRMSG_LEN) {
 		msglen = strlen(message);
--- LVM2/lib/mirror/mirrored.c	2011/03/25 21:59:42	1.85
+++ LVM2/lib/mirror/mirrored.c	2011/04/29 00:21:14	1.86
@@ -613,11 +613,11 @@
 	.target_percent = _mirrored_target_percent,
 	.target_present = _mirrored_target_present,
 	.check_transient_status = _mirrored_transient_status,
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 	.target_monitored = _target_registered,
 	.target_monitor_events = _target_monitor_events,
 	.target_unmonitor_events = _target_unmonitor_events,
-#endif
+#  endif	/* DMEVENTD */
 #endif
 	.modules_needed = _mirrored_modules_needed,
 	.destroy = _mirrored_destroy,
@@ -642,10 +642,10 @@
 	segtype->flags = SEG_AREAS_MIRRORED;
 
 #ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 	if (_get_mirror_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
-#endif
+#  endif	/* DMEVENTD */
 #endif
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
--- LVM2/lib/mm/memlock.c	2011/04/08 14:40:20	1.40
+++ LVM2/lib/mm/memlock.c	2011/04/29 00:21:15	1.41
@@ -360,7 +360,8 @@
 					  "Maps lock %ld < unlock %ld",
 					  (long)_mstats, (long)unlock_mstats);
 			else
-				log_debug("Maps lock %ld < unlock %ld, 1 page difference!",
+				/* FIXME Believed due to incorrect use of yes_no_prompt while locks held */
+				log_debug("Suppressed internal error: Maps lock %ld < unlock %ld, a one-page difference.",
 					  (long)_mstats, (long)unlock_mstats);
 		}
 	}
--- LVM2/lib/snapshot/snapshot.c	2011/03/25 21:59:42	1.54
+++ LVM2/lib/snapshot/snapshot.c	2011/04/29 00:21:15	1.55
@@ -232,11 +232,11 @@
 #ifdef DEVMAPPER_SUPPORT
 	.target_percent = _snap_target_percent,
 	.target_present = _snap_target_present,
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 	.target_monitored = _target_registered,
 	.target_monitor_events = _target_register_events,
 	.target_unmonitor_events = _target_unregister_events,
-#endif
+#  endif	/* DMEVENTD */
 #endif
 	.modules_needed = _snap_modules_needed,
 	.destroy = _snap_destroy,
@@ -261,10 +261,10 @@
 	segtype->flags = SEG_SNAPSHOT;
 
 #ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 	if (_get_snapshot_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
-#endif
+#  endif	/* DMEVENTD */
 #endif
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
--- LVM2/man/dmsetup.8.in	2011/03/10 13:11:45	1.38
+++ LVM2/man/dmsetup.8.in	2011/04/29 00:21:16	1.39
@@ -290,7 +290,7 @@
 be removed because uninterruptible processes are waiting for
 I/O to return from them, adding --force will replace the table 
 with one that fails all I/O, which might allow the 
-process to be killed.  This also runs \fBmknodes\fP afterward.
+process to be killed.  This also runs \fBmknodes\fP afterwards.
 .IP \fBrename
 .I device_name new_name
 .br
--- LVM2/man/lvm.conf.5.in	2011/04/13 18:26:39	1.20
+++ LVM2/man/lvm.conf.5.in	2011/04/29 00:21:16	1.21
@@ -175,10 +175,9 @@
 \fBpv_min_size\fP \(em
 Minimal size (in KB) of the block device which can be used as a PV.
 In clustered environment all nodes have to use the same value.
-Any value smaller than 512KB is ignored.  An example to
-ignore devices smaller than 2MB (i.e. floppy drives):
-.IP
-pv_min_size = 2048
+Any value smaller than 512KB is ignored.  Up to and include version 2.02.84
+the default was 512KB.  From 2.02.85 onwards it was changed to 2MB to
+avoid floppy drives by default.
 .IP
 \fBissue_discards\fP \(em
 Issue discards to a logical volumes's underlying physical volume(s) when the
--- LVM2/tools/vgsplit.c	2011/03/30 14:35:01	1.106
+++ LVM2/tools/vgsplit.c	2011/04/29 00:21:16	1.107
@@ -488,8 +488,8 @@
 
 bad:
 	/*
-	 * Note: as vg_to is referencing moved elements from vg_from
-	 * the order of free_vg calls is mandatory.
+	 * vg_to references elements moved from vg_from
+	 * so vg_to has to be freed first.
 	 */
 	unlock_and_free_vg(cmd, vg_to, vg_name_to);
 	unlock_and_free_vg(cmd, vg_from, vg_name_from);

