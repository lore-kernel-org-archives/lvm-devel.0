From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 17:55:30 -0000
Subject: LVM2 ./WHATS_NEW udev/10-dm.rules.in
Message-ID: <20110811175530.29111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 17:55:30

Modified files:
	.              : WHATS_NEW 
	udev           : 10-dm.rules.in 

Log message:
	Update udev rules to skip DM flags decoding for removed devices
	
	Skip decoding of DM flags when device is removed.
	
	We currently need DM flags only for add|change events. So forking
	dmsetup process for removed devices is a waste of CPU time.
	
	Udev is already quite slow, so make it just a tiny bit faster.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2067&r2=1.2068
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/08/11 17:46:13	1.2067
+++ LVM2/WHATS_NEW	2011/08/11 17:55:29	1.2068
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Update udev rules to skip DM flags decoding for removed devices.
   Add detect_internal_vg_cache_corruption to lvm.conf, disabled by default.
   Use memory pool locking to check for corruption of internal VG structs.
   Cache and share generated VG structs.
--- LVM2/udev/10-dm.rules.in	2011/01/28 11:41:52	1.13
+++ LVM2/udev/10-dm.rules.in	2011/08/11 17:55:29	1.14
@@ -24,12 +24,6 @@
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 
-# Decode udev control flags and set environment variables appropriately.
-# These flags are encoded in DM_COOKIE variable that was introduced in
-# kernel version 2.6.31. Therefore, we can use this feature with
-# kernels >= 2.6.31 only.
-ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
-
 # Device created, major and minor number assigned - "add" event generated.
 # Table loaded - no event generated.
 # Device resumed (or renamed) - "change" event generated.
@@ -42,6 +36,12 @@
 # is not recommended.
 ACTION!="add|change", GOTO="dm_end"
 
+# Decode udev control flags and set environment variables appropriately.
+# These flags are encoded in DM_COOKIE variable that was introduced in
+# kernel version 2.6.31. Therefore, we can use this feature with
+# kernels >= 2.6.31 only. Cookie is not decoded for remove event.
+ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+
 # Rule out easy-to-detect inappropriate events first.
 ENV{DISK_RO}=="1", GOTO="dm_disable"
 


