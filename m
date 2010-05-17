From: agk@sourceware.org <agk@sourceware.org>
Date: 17 May 2010 18:39:04 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100517183904.32003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-17 18:39:03

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/filters    : filter.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.234&r2=1.235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1560&r2=1.1561
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.369&r2=1.370
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/VERSION	2010/04/30 15:48:38	1.234
+++ LVM2/VERSION	2010/05/17 18:39:01	1.235
@@ -1 +1 @@
-2.02.65(2)-cvs (2010-04-30)
+2.02.65(2)-cvs (2010-05-17)
--- LVM2/VERSION_DM	2010/04/30 15:48:39	1.45
+++ LVM2/VERSION_DM	2010/05/17 18:39:01	1.46
@@ -1 +1 @@
-1.02.48-cvs (2010-04-30)
+1.02.48-cvs (2010-05-17)
--- LVM2/WHATS_NEW	2010/05/17 03:18:27	1.1560
+++ LVM2/WHATS_NEW	2010/05/17 18:39:01	1.1561
@@ -1,19 +1,22 @@
-Version 2.02.65 - 
-=================================
-  Fix clvmd init script to not deactive non-clustered volume groups.
-  Disallow cluster attr toggling if there are active mirrors or snapshots.
+Version 2.02.65 - 17th May 2010
+===============================
+  Fix clvmd init script never to deactivate non-clustered volume groups.
+  Disallow vgchange --clustered if there are active mirrors or snapshots.
+  Introduce lv_is_mirrored.
   Use /bin/bash for scripts with bashisms.
-  Skip internal lvm devices in scan if ignore suspended devices is requested.
+  Skip internal lvm devices in scan if ignore_suspended_devices is set.
   Do not merge old device cache after we run full scan. (2.02.56)
   Add pkgconfigdir Makefile variable for make install override.
-  Switch usage of Libs.private: to Requires.private: in devmapper.pc, lvm2app.pc.
-  Use field Requires.private: for devmapper-event.pc.
-  Add devmapper library to linked libdevmapper-event.so.
-  Link liblvm2cmd.so with devmapper-event and devmapper libs.
+  Configure pkgconfig udev and selinux dependencies.
+  Switch Libs.private to Requires.private in devmapper.pc and lvm2app.pc.
+  Use pkgconfig Requires.private for devmapper-event.pc.
+  Add libdevmapper to linked libdevmapper-event.so.
+  Link liblvm2cmd.so with libdevmapper-event and libdevmapper.
   Fix truncated total size displayed by pvscan.
-  Add new --sysinit option for vgchange and lvchange.
-  Suppress duplicate error messages about read failures and missing devices.
-  Install plugins to $(libdir)/device-mapper and $(libdir)/lvm2.
+  Add new --sysinit compound option to vgchange and lvchange.
+  Drop duplicate errors for read failures and missing devices to verbose level.
+  Use $(libdir)/lvm2 with make install_lvm2_plugin.
+  Use $(libdir)/device-mapper with make install_dm_plugin.
   Add dm_list_splice() function to join two lists together.
 
 Version 2.02.64 - 30th April 2010
--- LVM2/WHATS_NEW_DM	2010/05/14 14:56:39	1.369
+++ LVM2/WHATS_NEW_DM	2010/05/17 18:39:01	1.370
@@ -1,8 +1,10 @@
-Version 1.02.48 -
-=================================
+Version 1.02.48 - 17th May 2010
+================================
   Use -d to control level of messages sent to syslog by dmeventd.
   Change -d to -f to run dmeventd in foreground.
   Do not print encryption key in message debug output (cryptsetup luksResume).
+  Fix dmeventd static build library dependencies.
+  Fix udev flags on remove in create_and_load error path.
 
 Version 1.02.47 - 30th April 2010
 =================================
--- LVM2/lib/filters/filter.c	2010/05/13 18:38:40	1.52
+++ LVM2/lib/filters/filter.c	2010/05/17 18:39:03	1.53
@@ -130,6 +130,7 @@
 		return 0;
 	}
 
+	/* FIXME Always check 'layer' regardless of ignore_suspended_devices */
 	/* Skip suspended devices */
 	if (MAJOR(dev->dev) == _device_mapper_major &&
 	    ignore_suspended_devices() && !device_is_usable(dev)) {


