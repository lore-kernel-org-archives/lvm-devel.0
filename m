From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2012 10:11:30 -0000
Subject: LVM2 WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120126101130.22048.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-26 10:11:30

Modified files:
	.              : WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.533&r2=1.534
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.286&r2=1.287
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/WHATS_NEW_DM	2012/01/25 21:50:50	1.533
+++ LVM2/WHATS_NEW_DM	2012/01/26 10:11:30	1.534
@@ -1,15 +1,15 @@
-Version 1.02.68 -
-==================================
+Version 1.02.68 - 26th January 2012
+===================================
   Reset all members of info struct in dm_tree_add_new_dev_with_udev_flags.
   Add dmsetup wipe_table to replace table with one that uses error target.
-  Add 'blkdevname' and 'blkdevs_used' field to dmsetup info -c -o.
+  Add 'blkdevname' and 'blkdevs_used' fields to dmsetup info -c -o.
   Add 'blkdevname' option to dmsetup ls --tree to see block device names.
-  Add '-o options' to dmsetup deps and ls to select device name type on output.
+  Add -o devno/blkdevname/devname to dmsetup deps and ls.
   Add dm_device_get_name to get map name or block device name for given devno.
   Remove empty devices when clearing left-over inactive tables in deptree.
   Add dm_uuid_prefix/dm_set_uuid_prefix to override hard-coded LVM- prefix.
-  Improve dmsetup man page about readahead parameter.
-  Use sysfs to set/get of read-ahead setting if possible.
+  Improve dmsetup man page description of readahead parameter.
+  Use sysfs to set/get readahead if possible.
   Fix lvm2-monitor init script to use normalized output when using vgs.
   Add test for max length (DM_MAX_TYPE_NAME) of target type name.
   Include a copy of kernel DM documentation in doc/kernel.
@@ -26,14 +26,14 @@
   Fix alignment warning in bitcount calculation for raid segment.
   Allocate dm_tree structure from dm_tree pool.
   Update debug logging for _resume_node.
-  Add functions to support thin provisioning target (API unstable).
+  Add functions to support thin provisioning target.
   Improve libdm-config error path reporting.
   Update dmsetup resume man with --addnodeonresume/create options.
-  Add dependency for dm man pages to man subdirectory make target all:.
+  Add dependency for dm man pages to man subdirectory make all target.
   Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.
   Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
   Add dm_device_has_holders fn to to check use of the device by another device.
-  Add dm_sysfs_dir to libdevmapper to retrieve sysfs location thas is set.
+  Add dm_sysfs_dir to libdevmapper to retrieve sysfs location set.
   Add dm_set_sysfs_dir to libdevmapper to set sysfs location.
   Add --retry option for dmsetup remove to retry removal if not successful.
   Add dm_task_retry_remove fn to use retry logic for device removal.
--- LVM2/VERSION	2011/08/19 19:42:39	1.286
+++ LVM2/VERSION	2012/01/26 10:11:30	1.287
@@ -1 +1 @@
-2.02.89(2)-cvs (2011-08-19)
+2.02.89(2)-cvs (2012-01-26)
--- LVM2/VERSION_DM	2011/08/19 19:42:39	1.91
+++ LVM2/VERSION_DM	2012/01/26 10:11:30	1.92
@@ -1 +1 @@
-1.02.68-cvs (2011-08-19)
+1.02.68-cvs (2012-01-26)


