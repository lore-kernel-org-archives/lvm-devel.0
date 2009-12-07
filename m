From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Dec 2009 12:03:47 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in
Message-ID: <20091207120347.20090.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-12-07 12:03:47

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 

Log message:
	Disable udev rules on change event with DISK_RO=1.
	
	There's a new change udev event generated since kernel 2.6.32 that
	notifies userspace about a change in read-only attribute for block
	devices (with DISK_RO=1 environment variable set).
	
	We need to detect this and disable the rule application so the
	meaning of this change event is not interchanged with the regular
	change event used while resuming/renaming DM devices.
	
	If there's anybody awaiting this notification in foreign rules,
	he can still check for this env var and do the appropriate actions
	separately.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.320&r2=1.321
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW_DM	2009/11/24 19:04:23	1.320
+++ LVM2/WHATS_NEW_DM	2009/12/07 12:03:47	1.321
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Disable udev rules for change events with DISK_RO set.
 
 Version 1.02.40 - 19th November 2009
 ====================================
--- LVM2/udev/10-dm.rules.in	2009/11/01 18:01:31	1.6
+++ LVM2/udev/10-dm.rules.in	2009/12/07 12:03:47	1.7
@@ -19,6 +19,13 @@
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 
+# There is a new change event generated in block layer since kernel
+# version 2.6.32. It adds notification for changes in read-only
+# attribute. We don't want to misinterpret the regular meaning of change
+# events for DM devices and we don't want to apply the rules prematurely,
+# therefore we disable them in this situation.
+ENV{DISK_RO}=="1", GOTO="dm_disable"
+
 # Set proper sbin path, /sbin has higher priority than /usr/sbin.
 ENV{DM_SBIN_PATH}="/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"


