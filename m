From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 14:50:35 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/13-dm-disk.rules
Message-ID: <20120215145035.5652.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 14:50:34

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 13-dm-disk.rules 

Log message:
	Add watch rule to 13-dm-disk.rules.
	
	We don't have anything better yet...
	
	The problems the watch rule caused when removing devices should be covered
	now with the "retry remove" logic. It's also better to have this maintained
	by us, rather than having this rule anywhere else without proper control.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.566&r2=1.567
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW_DM	2012/02/15 13:56:47	1.566
+++ LVM2/WHATS_NEW_DM	2012/02/15 14:50:33	1.567
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add "watch" rule to 13-dm-disk.rules.
   Detect failing fifo and skip 20s retry communication period.
   Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
   Add dm_lib_init to automatically initialise device-mapper library on load.
--- LVM2/udev/13-dm-disk.rules	2009/11/13 12:33:27	1.5
+++ LVM2/udev/13-dm-disk.rules	2012/02/15 14:50:34	1.6
@@ -24,4 +24,15 @@
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
+# Add inotify watch to track changes on this device.
+# Using the watch rule is not optimal - it generetes a lot of spurious
+# and useless events whenever the device opened for read-write is closed.
+# The best would be to generete the event directly in the tool changing
+# relevant information so only relevant events will be processed
+# (like creating a filesystem, changing filesystem label etc.).
+#
+# But let's use this until we have something better...
+
+OPTIONS+="watch"
+
 LABEL="dm_end"


