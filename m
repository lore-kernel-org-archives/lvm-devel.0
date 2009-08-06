From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:10:59 -0000
Subject: LVM2/udev 12-dm-permissions.rules
Message-ID: <20090806151059.2607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:10:58

Added files:
	udev           : 12-dm-permissions.rules 

Log message:
	Rename template rule file 11-dm-permissions.rules to 12-dm-permissions.rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/udev/12-dm-permissions.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/12-dm-permissions.rules
+++ -	2009-08-06 15:10:58.968635000 +0000
@@ -0,0 +1,18 @@
+# Udev rules for device-mapper devices.
+#
+# These rules set permissions for DM devices. There are some environment
+# variables set that can be used:
+#   DM_NAME - actual DM device's name
+#   DM_UUID - UUID set for DM device (blank if not specified)
+#   DM_SUSPENDED - suspended state of DM device (0 or 1)
+#   DM_LV_NAME - logical volume name (not set if LVM device not present)
+#   DM_VG_NAME - volume group name (not set if LVM device not present)
+#   DM_LV_LAYER - logical volume layer (not set if LVM device not present)
+
+SUBSYSTEM!="block", GOTO="dm_end"
+KERNEL!="dm-[0-9]*", GOTO="dm_end"
+ACTION!="change", GOTO="dm_end"
+
+#ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
+
+LABEL="dm_end"


