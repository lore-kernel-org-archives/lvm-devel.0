From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Jul 2010 11:22:47 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in udev/1 ...
Message-ID: <20100707112247.8237.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-07-07 11:22:46

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 11-dm-lvm.rules 

Log message:
	Use "nowatch" udev rule for known inappropriate devices.
	
	For now, this is just a precaution. Normally, all the other (non-dm) rules
	should check DM_UDEV_DISABLE_OTHER_RULES_FLAG and therefore avoid setting
	any inotify watches as well. But let's make sure.
	
	Support for final assignment of the "nowatch" rule (the use of ":=") will
	appear in next udev release, v160. This should also work in previous udev
	versions but the setting won't be sealed so any further OPTIONS="watch" will
	always prevail there.
	
	We may want to add more specific "nowatch" rules later if needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.391&r2=1.392
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW_DM	2010/07/07 02:37:28	1.391
+++ LVM2/WHATS_NEW_DM	2010/07/07 11:22:46	1.392
@@ -1,5 +1,6 @@
 Version 1.02.53 -
 ===============================
+  Use "nowatch" udev rule for inappropriate devices.
 
 Version 1.02.52 - 6th July 2010
 ===============================
--- LVM2/udev/10-dm.rules.in	2010/06/23 17:00:32	1.9
+++ LVM2/udev/10-dm.rules.in	2010/07/07 11:22:46	1.10
@@ -119,5 +119,6 @@
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}="1"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
+OPTIONS:="nowatch"
 
 LABEL="dm_end"
--- LVM2/udev/11-dm-lvm.rules	2010/02/15 16:38:23	1.6
+++ LVM2/udev/11-dm-lvm.rules	2010/07/07 11:22:46	1.7
@@ -32,5 +32,6 @@
 LABEL="lvm_disable"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
+OPTIONS:="nowatch"
 
 LABEL="lvm_end"


