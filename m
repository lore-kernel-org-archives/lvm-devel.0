From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 16 Feb 2012 14:39:04 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/13-dm-disk.rules
Message-ID: <20120216143904.13110.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-16 14:39:03

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 13-dm-disk.rules 

Log message:
	Switch to using built-in blkid in 13-dm-disk.rules.
	
	Available in udev since version 176.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.567&r2=1.568
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW_DM	2012/02/15 14:50:33	1.567
+++ LVM2/WHATS_NEW_DM	2012/02/16 14:39:02	1.568
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Switch to using built-in blkid in 13-dm-disk.rules.
   Add "watch" rule to 13-dm-disk.rules.
   Detect failing fifo and skip 20s retry communication period.
   Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
--- LVM2/udev/13-dm-disk.rules	2012/02/15 15:10:31	1.7
+++ LVM2/udev/13-dm-disk.rules	2012/02/16 14:39:02	1.8
@@ -19,7 +19,7 @@
 
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
-IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
+IMPORT{program}="blkid"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"


