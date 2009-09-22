From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2009 12:03:33 -0000
Subject: LVM2/udev 12-dm-permissions.rules
Message-ID: <20090922120333.1729.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-22 12:03:33

Modified files:
	udev           : 12-dm-permissions.rules 

Log message:
	Add some advisory comments for users in 12-dm-permissions.rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/udev/12-dm-permissions.rules	2009/09/11 16:05:20	1.2
+++ LVM2/udev/12-dm-permissions.rules	2009/09/22 12:03:32	1.3
@@ -1,7 +1,12 @@
 # Udev rules for device-mapper devices.
 #
-# These rules set permissions for DM devices. There are some environment
-# variables set that can be used:
+# These rules set permissions for DM devices.
+#
+# This file is considered to be a template where users can put their
+# own entries and then put a copy of it manually to a usual place with
+# user-edited udev rules (usually /etc/udev/rules.d).
+#
+# There are some environment variables set that can be used:
 #   DM_UDEV_RULES_VSN - DM udev rules version
 #   DM_NAME - actual DM device's name
 #   DM_UUID - UUID set for DM device (blank if not specified)
@@ -15,6 +20,7 @@
 ACTION!="change", GOTO="dm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 
-#ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
+# Just an example...
+# ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
 
 LABEL="dm_end"


