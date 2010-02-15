From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:38:24 -0000
Subject: LVM2 ./WHATS_NEW udev/11-dm-lvm.rules
Message-ID: <20100215163824.3642.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:38:23

Modified files:
	.              : WHATS_NEW 
	udev           : 11-dm-lvm.rules 

Log message:
	Remove hard-coded rule to skip _mimage devices in 11-dm-lvm.rules.
	
	There's a tiny period of time when the _mimage device is visible during
	downconversion from mirror to linear. Since it is visible, we need to
	create the symlinks, otherwise warning messages will be issued about udev
	not creating those symlinks. We have to rely on udev flags completely.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1428&r2=1.1429
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2010/02/15 16:30:13	1.1428
+++ LVM2/WHATS_NEW	2010/02/15 16:38:22	1.1429
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Remove hard-coded rule to skip _mimage devices in 11-dm-lvm.rules.
   Use udev transactions in testsuite.
   Don't use LVM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
   Add lvm2app exports lvm_pv_get_size(), lvm_pv_get_free(), and lvm_pv_get_dev_size().
--- LVM2/udev/11-dm-lvm.rules	2010/01/07 20:01:55	1.5
+++ LVM2/udev/11-dm-lvm.rules	2010/02/15 16:38:23	1.6
@@ -23,7 +23,7 @@
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
 # Do not create symlinks for inappropriate subdevices.
-ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_disable"
+ENV{DM_LV_NAME}=="pvmove?*|?*_vorigin", GOTO="lvm_disable"
 ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
 
 # Create symlinks for top-level devices only.


