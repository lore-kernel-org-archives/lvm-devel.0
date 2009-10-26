From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Oct 2009 22:42:08 -0000
Subject: LVM2/udev 11-dm-lvm.rules 12-dm-permissions.ru ...
Message-ID: <20091026224208.20280.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-26 22:42:07

Modified files:
	udev           : 11-dm-lvm.rules 12-dm-permissions.rules 
	                 13-dm-disk.rules 95-dm-notify.rules 

Log message:
	add copyright lines

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/95-dm-notify.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/udev/11-dm-lvm.rules	2009/10/26 14:29:34	1.2
+++ LVM2/udev/11-dm-lvm.rules	2009/10/26 22:42:07	1.3
@@ -1,3 +1,7 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
 # Udev rules for LVM.
 #
 # These rules create symlinks for LVM logical volumes in
--- LVM2/udev/12-dm-permissions.rules	2009/10/22 13:11:33	1.5
+++ LVM2/udev/12-dm-permissions.rules	2009/10/26 22:42:07	1.6
@@ -1,3 +1,7 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
 # Udev rules for device-mapper devices.
 #
 # These rules set permissions for DM devices.
--- LVM2/udev/13-dm-disk.rules	2009/10/26 21:38:35	1.3
+++ LVM2/udev/13-dm-disk.rules	2009/10/26 22:42:07	1.4
@@ -1,3 +1,7 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
 # Udev rules for device-mapper devices.
 #
 # These rules create symlinks in /dev/disk directory.
--- LVM2/udev/95-dm-notify.rules	2009/10/22 13:11:33	1.3
+++ LVM2/udev/95-dm-notify.rules	2009/10/26 22:42:07	1.4
@@ -1,3 +1,7 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
 # Udev rules for device-mapper devices.
 #
 # These rules are responsible for sending a notification to a process


