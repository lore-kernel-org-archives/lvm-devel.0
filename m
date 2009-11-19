From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2009 19:00:37 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20091119190037.23032.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-19 19:00:35

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.213&r2=1.214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1317&r2=1.1318
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.315&r2=1.316

--- LVM2/VERSION	2009/10/27 01:13:20	1.213
+++ LVM2/VERSION	2009/11/19 19:00:34	1.214
@@ -1 +1 @@
-2.02.55(1)-cvs (2009-10-26)
+2.02.55(1)-cvs (2009-11-19)
--- LVM2/VERSION_DM	2009/10/27 01:13:20	1.25
+++ LVM2/VERSION_DM	2009/11/19 19:00:34	1.26
@@ -1 +1 @@
-1.02.40-cvs (2009-10-26)
+1.02.40-cvs (2009-11-19)
--- LVM2/WHATS_NEW	2009/11/19 01:17:01	1.1317
+++ LVM2/WHATS_NEW	2009/11/19 19:00:34	1.1318
@@ -1,5 +1,5 @@
-Version 2.02.55 -
-===================================
+Version 2.02.55 - 19th November 2009
+====================================
   Fix a possible deadlock in mirror code due to memlock refcount mismatch.
   Enable dmeventd event handlers to properly scan devices.
   Do not activate directly not visible volumes in vgchange.
--- LVM2/WHATS_NEW_DM	2009/11/13 12:48:01	1.315
+++ LVM2/WHATS_NEW_DM	2009/11/19 19:00:34	1.316
@@ -1,5 +1,5 @@
-Version 1.02.40 - 
-===================================
+Version 1.02.40 - 19th November 2009
+====================================
   Fix install_device-mapper Makefile target to not build dmeventd plugins.
   Support udev flags even when udev_sync is disabled or not compiled in.
   Remove 'last_rule' from udev rules: honor ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}.


