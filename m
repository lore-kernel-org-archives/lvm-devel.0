From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Feb 2011 22:07:45 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20110204220745.21500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-04 22:07:44

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/activate   : fs.c 
	libdm          : libdm-common.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.272&r2=1.273
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1906&r2=1.1907
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.441&r2=1.442
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/VERSION	2011/01/24 23:34:46	1.272
+++ LVM2/VERSION	2011/02/04 22:07:43	1.273
@@ -1 +1 @@
-2.02.83(2)-cvs (2011-01-24)
+2.02.83(2)-cvs (2011-02-04)
--- LVM2/VERSION_DM	2011/01/24 23:24:06	1.79
+++ LVM2/VERSION_DM	2011/02/04 22:07:43	1.80
@@ -1 +1 @@
-1.02.62-cvs (2011-01-24)
+1.02.62-cvs (2011-02-04)
--- LVM2/WHATS_NEW	2011/02/04 20:30:17	1.1906
+++ LVM2/WHATS_NEW	2011/02/04 22:07:43	1.1907
@@ -1,9 +1,9 @@
-Version 2.02.83 - 
+Version 2.02.83 - 4th February 2011
 ===================================
   Allow exclusive activation of snapshots in a cluster.
-  Add --addnodeonresume, --addnodeoncreate options for dmsetup create.
-  Use cluster-wide message to request device name sync.
-  Fix operation node stacking for consecutive dm ops.
+  Leave EX lock unchanged when suspending a device in clvmd.
+  Use sync_dev_names in unlock_vg macro for cluster-wide dev name sync.
+  Fix fs operation stack handling when multiple operations on same device.
   Increase hash table size to 1024 lv names and 64 pv uuids.
   Remove fs_unlock() from lv_resume path.
   Fix wipe size when setting up mda.
@@ -12,10 +12,10 @@
   Allow CLVMD_CMD_SYNC_NAMES to be propagated around the cluster if requested.
   Add "dmsetup ls --tree" output to lvmdump.
   Fix udev synchronization with no-locking --sysinit (2.02.80).
-  Updating man pages for pvcreate, pvremove, pvresize, pvscan.
+  Improve man page style consistency for pvcreate, pvremove, pvresize, pvscan.
   Avoid rebuilding of uuid validation table.
+  Improve lvcreate error text from insufficient "extents" to "free space".
   Always use O_DIRECT when opening block devices to check for partitioning.
-  Improve lvcreate "insufficient extents" errors to "insufficient free space".
 
 Version 2.02.82 - 24th January 2011
 ===================================
--- LVM2/WHATS_NEW_DM	2011/02/04 16:08:11	1.441
+++ LVM2/WHATS_NEW_DM	2011/02/04 22:07:44	1.442
@@ -1,8 +1,12 @@
-Version 1.02.62 - 
+Version 1.02.62 - 4th February 2011
 ===================================
+  Add --addnodeonresume and --addnodeoncreate options to dmsetup.
+  Add dm_task_set_add_node to libdevmapper to control dev node creation time.
   Add dm_task_secure_data to libdevmapper to wipe ioctl buffers in kernel.
+  Log debug message when expected uevent is not generated.
+  Only compile memory debugging code when DEBUG_MEM is set.
   Set DM_UDEV_DISABLE_OTHER_RULES_FLAG for suspended DM devices in udev rules.
-  Initialize pool object for each row in _output_as_rows().
+  Begin a new pool object for each row in _output_as_rows() correctly.
 
 Version 1.02.61 - 10th January 2011
 ===================================
--- LVM2/lib/activate/fs.c	2011/02/04 19:14:40	1.59
+++ LVM2/lib/activate/fs.c	2011/02/04 22:07:44	1.60
@@ -284,7 +284,8 @@
 
 		if (!_mk_link(dev_dir, vg_name, lv_name, dev, check_udev))
 			stack;
-	default:;
+	default:
+		; /* NOTREACHED */
 	}
 
 	return 1;
@@ -367,7 +368,7 @@
 	else if ((type == FS_ADD) && _count_fs_ops[FS_DEL] && _check_udev(check_udev))
 		/*
 		 * If udev is running ignore previous DEL operation on added fs_op.
-		 * (No other operations for this device then DEL could be staked here).
+		 * (No other operations for this device then DEL could be stacked here).
 		 */
 		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
 			fsp = dm_list_item(fsph, struct fs_op_parms);
--- LVM2/libdm/libdm-common.c	2011/02/04 19:14:40	1.109
+++ LVM2/libdm/libdm-common.c	2011/02/04 22:07:44	1.110
@@ -745,7 +745,8 @@
 	case NODE_READ_AHEAD:
 		return _set_dev_node_read_ahead(dev_name, read_ahead,
 						read_ahead_flags);
-	default:;
+	default:
+		; /* NOTREACHED */
 	}
 
 	return 1;
@@ -830,7 +831,7 @@
 	else if ((type == NODE_ADD) && _count_node_ops[NODE_DEL] && _check_udev(check_udev))
 		/*
 		 * If udev is running ignore previous DEL operation on added node.
-		 * (No other operations for this device then DEL could be staked here).
+		 * (No other operations for this device then DEL could be stacked here).
 		 */
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);


