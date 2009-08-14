From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Aug 2009 14:37:47 -0000
Subject: LVM2/udev 12-dm-disk.rules
Message-ID: <20090814143747.16906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-14 14:37:47

Modified files:
	udev           : 12-dm-disk.rules 

Log message:
	Use new blkid instead of vol_id in udev rules.
	
	Thanks to Daniel Mierswa for reminding us.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-disk.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/udev/12-dm-disk.rules	2009/08/03 18:44:54	1.1
+++ LVM2/udev/12-dm-disk.rules	2009/08/14 14:37:46	1.2
@@ -21,7 +21,7 @@
 
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
-IMPORT{program}="vol_id --export $tempnode"
+IMPORT{program}="/sbin/blkid -o udev -p $tempnode"
 OPTIONS="link_priority=-100"
 ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"


