From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Nov 2009 19:04:24 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20091124190424.5154.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-24 19:04:23

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	Post-release.
	Fingers crossed this one's more successful that the last one!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1329&r2=1.1330
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.319&r2=1.320

--- LVM2/VERSION	2009/11/24 18:26:08	1.216
+++ LVM2/VERSION	2009/11/24 19:04:23	1.217
@@ -1 +1 @@
-2.02.56(1)-cvs (2009-11-24)
+2.02.57(1)-cvs (2009-11-24)
--- LVM2/VERSION_DM	2009/11/24 18:26:08	1.28
+++ LVM2/VERSION_DM	2009/11/24 19:04:23	1.29
@@ -1 +1 @@
-1.02.40-cvs (2009-11-24)
+1.02.41-cvs (2009-11-24)
--- LVM2/WHATS_NEW	2009/11/24 18:54:23	1.1329
+++ LVM2/WHATS_NEW	2009/11/24 19:04:23	1.1330
@@ -1,3 +1,6 @@
+Version 2.02.57 -
+====================================
+
 Version 2.02.56 - 24th November 2009
 ====================================
   Add missing vg_release to pvs and pvdisplay to fix memory leak.
--- LVM2/WHATS_NEW_DM	2009/11/24 18:26:08	1.319
+++ LVM2/WHATS_NEW_DM	2009/11/24 19:04:23	1.320
@@ -1,3 +1,6 @@
+Version 1.02.41 -
+====================================
+
 Version 1.02.40 - 19th November 2009
 ====================================
   Fix install_device-mapper Makefile target to not build dmeventd plugins.


