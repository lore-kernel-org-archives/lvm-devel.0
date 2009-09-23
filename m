From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Sep 2009 12:52:53 -0000
Subject: LVM2 man/dmsetup.8.in udev/12-dm-permissions.rules
Message-ID: <20090923125253.1442.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-23 12:52:53

Modified files:
	man            : dmsetup.8.in 
	udev           : 12-dm-permissions.rules 

Log message:
	Add more hints in 12-dm-permissions.rules. Add 'dmsetup splitname' and 'y|--yes' to dmsetup manpage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/dmsetup.8.in	2009/09/11 16:06:31	1.25
+++ LVM2/man/dmsetup.8.in	2009/09/23 12:52:52	1.26
@@ -78,6 +78,10 @@
 .B dmsetup setgeometry
 .I device_name cyl head sect start
 .br
+.B dmsetup splitname
+.I device_name
+.I [subsystem]
+.br
 
 .B devmap_name
 .I major minor
@@ -138,6 +142,9 @@
 .IP \fB-u|--uuid
 .br
 Specify the uuid.
+.IP \fB-y|--yes
+.br
+Answer yes to all prompts automatically.
 .IP \fB-v|--verbose\ [-v|--verbose]
 .br
 Produce additional output.
@@ -260,6 +267,12 @@
 .I device_name cyl head sect start
 .br
 Sets the device geometry to C/H/S.
+.IP \fBsplitname
+.I device_name
+.I [subsystem]
+.br
+Splits given device name into subsystem constituents.
+Default subsystem is LVM.
 .IP \fBstatus
 .I [--target target_type]
 .I [device_name]
--- LVM2/udev/12-dm-permissions.rules	2009/09/22 12:03:32	1.3
+++ LVM2/udev/12-dm-permissions.rules	2009/09/23 12:52:52	1.4
@@ -20,7 +20,56 @@
 ACTION!="change", GOTO="dm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 
-# Just an example...
-# ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
+# A few demonstrational examples...
+
+
+# PLAIN DM DEVICES
+#
+# Set permissions for a DM device named 'my_device' exactly
+# ENV{DM_NAME}=="my_device", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for all DM devices having 'MY_UUID-' UUID prefix
+# ENV{DM_UUID}=="MY_UUID-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+
+# LVM DEVICES
+#
+# Set permissions for all LVM devices
+# ENV{DM_UUID}=="LVM-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for all devices that belong to one LVM VG
+# ENV{DM_VG_NAME}=="VolGroup00", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for an LVM device with VG named VolGroup00 and LV named LogVol00 exactly
+# ENV{DM_VG_NAME}=="VolGroup00", ENV{DM_LV_NAME}=="LogVol00", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for all LVM devices that does not belong to a VG named VolGroup00
+# ENV{DM_VG_NAME}!="VolGroup00", OWNER:="root", GROUP:="root", MODE:="660"
+
+
+# ENCRYPTED DEVICES (using cryptsetup >= 1.1)
+#
+# Set permissions for all encrypted devices created by cryptsetup (plain devices)
+# ENV{DM_UUID}=="CRYPT-PLAIN-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for all encrypted devices created by cryptsetup (LUKS extension)
+# ENV{DM_UUID}=="CRYPT-LUKS1-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for an encrypted device created by cryptsetup and having an exact luks UUID
+# ENV{DM_UUID}=="CRYPT-LUKS1-22fce5c8313c43c68d84b50a3b0fee78-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+
+# MULTIPATH DEVICES
+#
+# Set permissions for all multipath devices
+# ENV{DM_UUID}=="mpath-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+# Set permissions for first two partitions created on a multipath device (and detected by kpartx)
+# ENV{DM_UUID}=="part[1-2]-mpath-?*", OWNER:="root", GROUP:="root", MODE:="660"
+
+
+# ...you can use any combination of the comparisons with the environment variables
+# listed at the beginning of this file (udev provides simple pattern matching by
+# using *, ? and [] that you can use, see 'man udev' for more information).
 
 LABEL="dm_end"


