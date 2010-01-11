From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2010 21:44:36 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100111214436.27503.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-11 21:44:36

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.330&r2=1.331

--- LVM2/WHATS_NEW_DM	2010/01/11 21:28:04	1.330
+++ LVM2/WHATS_NEW_DM	2010/01/11 21:44:36	1.331
@@ -1,6 +1,6 @@
 Version 1.02.41 -
 ====================================
-  If LVM_UDEV_DISABLE_CHECKING in set in environment, disable udev warnings.
+  If DM_UDEV_DISABLE_CHECKING in set in environment, disable udev warnings.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.
   Fix 'dmsetup info -c -o all' to show all fields.


