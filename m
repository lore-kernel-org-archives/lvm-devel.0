From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 16:12:23 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110429161223.29191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 16:12:22

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.276&r2=1.277
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1976&r2=1.1977
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.463&r2=1.464

--- LVM2/VERSION	2011/02/09 12:11:21	1.276
+++ LVM2/VERSION	2011/04/29 16:12:21	1.277
@@ -1 +1 @@
-2.02.85(2)-cvs (2011-02-09)
+2.02.85(2)-cvs (2011-04-29)
--- LVM2/VERSION_DM	2011/02/09 12:11:21	1.83
+++ LVM2/VERSION_DM	2011/04/29 16:12:21	1.84
@@ -1 +1 @@
-1.02.64-cvs (2011-02-09)
+1.02.64-cvs (2011-04-29)
--- LVM2/WHATS_NEW	2011/04/29 00:21:13	1.1976
+++ LVM2/WHATS_NEW	2011/04/29 16:12:21	1.1977
@@ -1,19 +1,19 @@
-Version 2.02.85 - 
-===================================
+Version 2.02.85 - 29th April 2011
+=================================
   Add new obtain_device_list_from_udev setting to lvm.conf.
   Obtain device list from udev by default if LVM2 is compiled with udev support.
-  Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
+  Add test for vgimportclone and querying of vgnames with duplicate pvs.
   Avoid use of released memory when duplicate PV is found.
   Add "devices/issue_discards" to lvm.conf.
-  Issue discards on lvremove, lvreduce, etc if enabled and supported.
+  Issue discards on lvremove and lvreduce etc. if enabled and supported.
   Add seg_pe_ranges and devices fields to liblvm.
   Fix incorrect tests for dm_snprintf() failure.
   Fix some unmatching sign comparation gcc warnings in the code.
-  Allow lv_extend() to work on zero length intrinsically layered LVs.
-  Keep the cache content when the exported vg buffer is matching.
-  Extend the set of memory regions, that are not locked to memory.
-  Enhance usability with the valgrind memcheck tool.
-  Support regular quit of the lvm_thread_fn function in clvmd.
+  Support lv_extend() on empty LVs.
+  Avoid regenerating cache content when exported VG buffer is unchanged.
+  Extend the set of memory regions that are not locked to memory.
+  Workaround some problems when compiled for valgrind memcheck.
+  Support controlled quit of the lvm_thread_fn function in clvmd.
   Fix reading of unallocated memory in lvm1 format import function.
   Replace several strncmp() calls with id_equal().
   Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
@@ -24,7 +24,7 @@
   Avoid potential loop when removing mirror images.
   Fix mirror removal always to take account of preferences as to which.
   Fix MIRRORED flag usage.
-  Mitigate annoying error warning from device is usable check if run as non-root.
+  Remove error messages issued by device_is_usable when run as non-root.
   Add missing \0 for grown debug object in _bitset_with_random_bits().
   Fix allocation of system_id buffer in volume_group structure.
   Fix readlink usage inside get_primary_dev().
@@ -39,7 +39,7 @@
   Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
   Add gdbinit script for debugging.
   Use hash tables to speedup string search in vg_validate().
-  Refactor allocation of VG structure, add alloc_vg().
+  Refactor allocation of VG structure adding alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
   Don't allocate unused VG mempool in _pvsegs_sub_single.
@@ -48,7 +48,6 @@
   Avoid reading freed memory when printing LV segment type.
   Fix syslog initialisation in clvmd to respect lvm.conf setting.
   Fix possible overflow in maximum stripe size and physical extent size.
-  Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Improve pvremove error message when PV belongs to a VG.
   Extend normal policy to allow mirror logs on same PVs as images if necessary.
   Improve cling policy to recognise PVs already used during the transaction.
--- LVM2/WHATS_NEW_DM	2011/04/29 00:21:13	1.463
+++ LVM2/WHATS_NEW_DM	2011/04/29 16:12:21	1.464
@@ -1,17 +1,18 @@
-Version 1.02.64 - 
-===================================
+Version 1.02.64 - 29th April 2011
+==================================
   Require libudev >= 143 when compiling with udev support.
   Use word alignment for dm_pool_strdup() and dm_pool_strndup().
-  Use dm_snprintf() to fix signess warning in dm_set_dev_dir().
-  Use unsigned loop counter to fix signess warning in _other_node_ops().
+  Use dm_snprintf() to fix signedness warning in dm_set_dev_dir().
+  Use unsigned loop counter to fix signedness warning in _other_node_ops().
   Fix const cast in dmsetup calls of dm_report_field_string().
   Streamline /dev/mapper/control node code for common cases.
   Use hard-coded dm control node device number for 2.6.36 kernels and above.
   Improve stack debug reporting in dm_task_create().
   Fallback to control node creation only if node doesn't exist yet.
-  Change dm_hash API for binary data to accept const void *key.
+  Change dm_hash binary functions to take void *key instead of char *.
   Fix uninitialised memory use with empty params in _reload_with_suppression_v4.
   Lower severity of selabel_lookup and matchpathcon failure to log_debug.
+  Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Add dm_event_get_version to dmeventd for use with -R.
   Avoid dmeventd core dumps when handling request with unknown command ID.
   Have dmeventd -R start up even when no existing copy is running.

