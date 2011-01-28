From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jan 2011 11:41:53 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in
Message-ID: <20110128114153.25193.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-01-28 11:41:52

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 

Log message:
	Set DM_UDEV_DISABLE_OTHER_RULES_FLAG for suspended DM devices in udev rules.
	
	This is to avoid any scanning and processing of DM devices while they are in
	suspended state (e.g. a rename while the device is suspended - a CHANGE event
	is generated!). Otherwise, any scanning in the rules could end up with locking
	the calling process until the device is resumed and so we don't receive a
	notification about udev rules completion until then (and that effectively
	locks out the process awaiting the notification!).
	
	However, we still keep 'disk' and any 'subsystem' related udev rules running.
	We trust these and these should check themselves whether a device is suspended
	or not, not trying to run any scanning if it is.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.439&r2=1.440
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW_DM	2011/01/25 21:51:30	1.439
+++ LVM2/WHATS_NEW_DM	2011/01/28 11:41:51	1.440
@@ -1,5 +1,6 @@
 Version 1.02.62 - 
 ===================================
+  Set DM_UDEV_DISABLE_OTHER_RULES_FLAG for suspended DM devices in udev rules.
   Initialize pool object for each row in _output_as_rows().
 
 Version 1.02.61 - 10th January 2011
--- LVM2/udev/10-dm.rules.in	2010/08/12 13:41:19	1.12
+++ LVM2/udev/10-dm.rules.in	2011/01/28 11:41:52	1.13
@@ -119,6 +119,11 @@
 ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_disable"
 ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_disable"
 
+# Avoid processing and scanning a DM device in the other (foreign)
+# rules if it is in suspended state. However, we still keep 'disk'
+# and 'DM subsystem' related rules enabled in this case.
+ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
+
 GOTO="dm_end"
 
 LABEL="dm_disable"


