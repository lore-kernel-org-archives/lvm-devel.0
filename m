From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2009 02:43:52 -0000
Subject: LVM2 lib/device/dev-io.c ./WHATS_NEW
Message-ID: <20090110024352.19795.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-10 02:43:52

Modified files:
	lib/device     : dev-io.c 
	.              : WHATS_NEW 

Log message:
	Display a 'dev_size' of zero for missing devices in reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1017&r2=1.1018

--- LVM2/lib/device/dev-io.c	2008/11/03 22:14:27	1.63
+++ LVM2/lib/device/dev-io.c	2009/01/10 02:43:51	1.64
@@ -268,6 +268,9 @@
 
 int dev_get_size(const struct device *dev, uint64_t *size)
 {
+	if (!dev)
+		return 0;
+
 	if ((dev->flags & DEV_REGULAR))
 		return _dev_get_size_file(dev, size);
 	else
--- LVM2/WHATS_NEW	2009/01/09 22:48:22	1.1017
+++ LVM2/WHATS_NEW	2009/01/10 02:43:52	1.1018
@@ -1,13 +1,14 @@
 Version 2.02.44 - 
 ====================================
+  Display a 'dev_size' of zero for missing devices in reports.
   Add pv_mda_size to pvs and vg_mda_size to vgs.
   Fix lvmdump /sys listing to include virtual devices directory.
   Add "--refresh" functionality to vgchange and vgmknodes.
   Check for maximal LV size when wiping device.
   Calculate mirror log size instead of using 1 extent.
   Check if requested major/minor pair is already used.
-  Fix incorrect return value in help function.
-  Fix vgrename using UUID in case there are VGs with the same name.
+  Fix incorrect exit status from 'help <command>'.
+  Fix vgrename using UUID if there are VGs with identical names.
   Fix segfault when invalid field given in reporting commands.
   Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.


