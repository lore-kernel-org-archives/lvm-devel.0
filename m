From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Aug 2009 08:05:07 -0000
Subject: LVM2/udev 10-dm.rules.in 11-lvm.rules
Message-ID: <20090804080507.23077.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-04 08:05:06

Modified files:
	udev           : 10-dm.rules.in 11-lvm.rules 

Log message:
	Fix a typo in udev rule (splitname, NOT namesplit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-lvm.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/udev/10-dm.rules.in	2009/08/03 18:44:54	1.1
+++ LVM2/udev/10-dm.rules.in	2009/08/04 08:05:06	1.2
@@ -26,7 +26,7 @@
 # only (kernels >= 2.6.29). We have to check for its existence
 # and use dmsetup tool instead to get the DM name, uuid and 
 # suspended state if the "dm" subdirectory is not present.
-# The "suspended" item was added even later (kernels >= ???),
+# The "suspended" item was added even later (kernels >= 2.6.31),
 # so we also have to call dmsetup if the kernel version used
 # is in between these releases.
 TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
--- LVM2/udev/11-lvm.rules	2009/08/03 18:44:54	1.1
+++ LVM2/udev/11-lvm.rules	2009/08/04 08:05:06	1.2
@@ -20,7 +20,7 @@
 ACTION=="add", ENV{STARTUP}!="1", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
-IMPORT{program}="/sbin/dmsetup namesplit --nameprefixes --noheadings --rows $env{DM_NAME}"
+IMPORT{program}="/sbin/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
 # Do not create symlinks for hidden subdevices.
 ENV{DM_LV_NAME}=="?*_mlog", GOTO="lvm_end"


