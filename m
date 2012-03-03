From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2012 01:00:51 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20120303010051.3887.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-03 01:00:50

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.296&r2=1.297
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2335&r2=1.2336
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.583&r2=1.584

--- LVM2/VERSION	2012/02/23 18:26:28	1.296
+++ LVM2/VERSION	2012/03/03 01:00:49	1.297
@@ -1 +1 @@
-2.02.94(2)-cvs (2012-02-23)
+2.02.94(2)-cvs (2012-03-03)
--- LVM2/VERSION_DM	2012/02/23 18:26:28	1.101
+++ LVM2/VERSION_DM	2012/03/03 01:00:49	1.102
@@ -1 +1 @@
-1.02.73-cvs (2012-02-23)
+1.02.73-cvs (2012-03-03)
--- LVM2/WHATS_NEW	2012/03/02 22:57:25	1.2335
+++ LVM2/WHATS_NEW	2012/03/03 01:00:49	1.2336
@@ -1,5 +1,5 @@
-Version 2.02.94 - 
-====================================
+Version 2.02.94 - 3rd March 2012
+================================
   Add support to execute thin_check with each de/active of thin pool.
   Fix automatic estimation of metadata device size for thin pool.
   Test for alloc fail from _alloc_pv_segment() in _extend_pv().
@@ -11,14 +11,14 @@
   Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
   Revert free of allocated segtype in init segment error path (2.02.89).
   Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
-  Ensure clvmd message is always \0 terminated after read.
+  Ensure clvmd message is always NUL-terminated after read.
   Add some close() and dev_close() error path backtraces.
-  For polling daemon reopen stdin,stdout,stderr to /dev/null.
+  Set stdin/stdout/stderr to /dev/null for polldaemon.
   Limit the max size of processed clvmd message to ~8KB.
-  Do not send uninitilised bytes in cluster error reply messages.
+  Do not send uninitialised bytes in cluster error reply messages.
   Use unsigned type for bitmask instead of enum type for lvm properties.
   Add missing cleanup of excl_uuid hash on some exit paths of clvmd.
-  Check for existance of vg_name in _format1/_pool_vg_read().
+  Check for existence of vg_name in _format1/_pool_vg_read().
   Fix missing break in _format_pvsegs (2.02.92).
   Test seg pointer for non-null it in raid_target_percent error path.
   Check for errors in _init_tags() during config loading.
@@ -28,6 +28,7 @@
   Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
   Use same signed numbers in _mirrored_transient_status().
+  Provide new metadata daemon for testing with configure --enable-lvmetad .
   Integrate client-side lvmetad into build.
 
 Version 2.02.93 - 23rd February 2012
--- LVM2/WHATS_NEW_DM	2012/03/02 22:57:25	1.583
+++ LVM2/WHATS_NEW_DM	2012/03/03 01:00:50	1.584
@@ -1,11 +1,11 @@
-Version 1.02.73 - 
-====================================
+Version 1.02.73 - 3rd March 2012
+================================
   Test _thread_registry list with holding mutex in dmeventd.
-  Added dm_tree_node_set_callback() for preload and deactivation hooks.
+  Add dm_tree_node_set_callback() for preload and deactivation hooks.
   Drop unsupported TRIM message for thin pool.
   Improve logging for fifo startup in dmeventd.
   Better detection of missing dmeventd fifo connection (1.02.71).
-  Add few pointer validation in dmsetup.
+  Add a few pointer validations in dmsetup.
   Support dm_task_get_driver_version() query without version string.
   Log failure of pthread_join when cleaning unused threads in dmeventd.
   Fix empty string warning logic in _find_config_str. (1.02.68)


