From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:12:47 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20110128161247.1277.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:12:46

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Replacei sleep wait with udev settle
	
	Use new udev_wait command instead of unpredictable sleep waiting.
	As with more devices in the system, udev processing is slower.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 01:04:47	1.13
+++ LVM2/test/t-pvcreate-operation-md.sh	2011/01/28 16:12:45	1.14
@@ -34,8 +34,9 @@
 cleanup_md() {
     # sleeps offer hack to defeat: 'md: md127 still in use'
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
-    sleep 2
+    aux udev_wait
     mdadm --stop $mddev || true
+    aux udev_wait
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
 	sleep 2
@@ -102,6 +103,11 @@
     base_mddev_p=`basename $mddev_p_sysfs_name`
     mddev_p=/dev/${base_mddev_p}
 
+    # in case the system is running without devtmpfs /dev
+    # wait here for created device node on tmpfs
+    aux udev_wait $mddev_p
+    test -b $mddev_p || exit 200
+
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
     sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset


