From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:43:20 -0000
Subject: LVM2 ./WHATS_NEW_DM test/lvm-utils.sh test/tes ...
Message-ID: <20100111154320.5371.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:43:19

Modified files:
	.              : WHATS_NEW_DM 
	test           : lvm-utils.sh test-utils.sh 

Log message:
	Enable udev_sync and udev_rules in lvm.conf by default while running tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.327&r2=1.328
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW_DM	2010/01/11 15:36:24	1.327
+++ LVM2/WHATS_NEW_DM	2010/01/11 15:43:19	1.328
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Enable udev_sync and udev_rules in lvm.conf by default while running tests.
   Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.
--- LVM2/test/lvm-utils.sh	2009/05/08 06:10:45	1.18
+++ LVM2/test/lvm-utils.sh	2010/01/11 15:43:19	1.19
@@ -202,6 +202,10 @@
   global {
     library_dir = "$G_root_/lib"
   }
+  activation {
+    udev_sync = 1
+    udev_rules = 1
+  }
 EOF
 }
 
--- LVM2/test/test-utils.sh	2009/12/28 18:33:04	1.16
+++ LVM2/test/test-utils.sh	2010/01/11 15:43:19	1.17
@@ -203,6 +203,10 @@
     library_dir = "$G_root_/lib"
     locking_dir = "$G_root_/var/lock/lvm"
   }
+  activation {
+    udev_sync = 1
+    udev_rules = 1
+  }
 EOF
 }
 


