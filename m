From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Jan 2011 19:52:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110131195242.14845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-31 19:52:41

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/locking    : file_locking.c locking.c 
Added files:
	test           : t-vgchange-sysinit.sh 

Log message:
	Fix udev synchronization for no-locking mode
	
	Instead of implicitly syncing udev operation in clustered and
	file locking code -  call synchronization directly in lock_vol() when
	the operation unlocks VG
	
	The problem is missing implicit fs_unlock() in the no_locking code.
	This is used with --sysinit on read-only filesystem locking dir.
	In this case vgchange -ay could exit before all udev nodes are properly
	synchronised and may cause problems with accessing such node right after
	vgchange --sysinint command is finished.
	
	Add test case for vgchange --sysinit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1895&r2=1.1896
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-sysinit.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2011/01/28 16:03:38	1.1895
+++ LVM2/WHATS_NEW	2011/01/31 19:52:40	1.1896
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Fix udev synchronization with no-locking --sysinit (2.02.80).
   Updating man pages for pvcreate, pvremove, pvresize, pvscan.
   Avoid rebuilding of uuid validation table.
   Always use O_DIRECT when opening block devices to check for partitioning.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/01/19 23:09:31	1.49
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/01/31 19:52:41	1.50
@@ -217,7 +217,6 @@
 	if (lkid == 0)
 	    return EINVAL;
 
-	lvm_do_fs_unlock(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
--- LVM2/lib/locking/file_locking.c	2011/01/12 20:42:50	1.54
+++ LVM2/lib/locking/file_locking.c	2011/01/31 19:52:41	1.55
@@ -215,7 +215,6 @@
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
-		fs_unlock(); /* Wait until devices are available */
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
--- LVM2/lib/locking/locking.c	2011/01/13 14:56:17	1.89
+++ LVM2/lib/locking/locking.c	2011/01/31 19:52:41	1.90
@@ -442,6 +442,10 @@
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
 			return_0;
+
+		/* Before unlocking VG wait until devices are available. */
+		if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
+			sync_local_dev_names(cmd);
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
/cvs/lvm2/LVM2/test/t-vgchange-sysinit.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgchange-sysinit.sh
+++ -	2011-01-31 19:52:42.890998000 +0000
@@ -0,0 +1,50 @@
+#!/bin/bash
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+which mkfs.ext3 || exit 200
+
+aux prepare_pvs 2 8
+
+var_lock="$DM_DEV_DIR/$vg1/$lv1"
+# keep in sync with aux configured lockingdir
+mount_dir="$TESTDIR/var/lock/lvm"
+
+cleanup_mounted_and_teardown()
+{
+	umount $mount_dir || true
+	aux teardown
+}
+
+vgcreate -c n $vg1 $dev1
+vgcreate -c n $vg2 $dev2
+
+lvcreate -l 1 -n $lv2 $vg2
+vgchange -an $vg2
+
+lvcreate -n $lv1 -l 100%FREE $vg1
+mkfs.ext3 -b4096 -j $var_lock
+
+trap 'cleanup_mounted_and_teardown' EXIT
+mount -n -r $var_lock $mount_dir
+
+# locking must fail on read-only filesystem
+not vgchange -ay $vg2
+
+# no-locking with --sysinit
+vgchange --sysinit -ay $vg2
+test -b "$DM_DEV_DIR/$vg2/$lv2"
+
+vgchange --sysinit -an $vg2
+test ! -b "$DM_DEV_DIR/$vg2/$lv2"
+
+vgchange --ignorelockingfailure -ay $vg2


