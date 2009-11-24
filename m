From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Nov 2009 18:26:09 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20091124182609.2560.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-24 18:26:09

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1327&r2=1.1328
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.318&r2=1.319

--- LVM2/VERSION	2009/11/19 19:53:58	1.215
+++ LVM2/VERSION	2009/11/24 18:26:08	1.216
@@ -1 +1 @@
-2.02.56(1)-cvs (2009-11-19)
+2.02.56(1)-cvs (2009-11-24)
--- LVM2/VERSION_DM	2009/11/19 19:53:58	1.27
+++ LVM2/VERSION_DM	2009/11/24 18:26:08	1.28
@@ -1 +1 @@
-1.02.41-cvs (2009-11-19)
+1.02.40-cvs (2009-11-24)
--- LVM2/WHATS_NEW	2009/11/24 17:07:09	1.1327
+++ LVM2/WHATS_NEW	2009/11/24 18:26:08	1.1328
@@ -1,4 +1,4 @@
-Version 2.02.56 - 
+Version 2.02.56 - 24th November 2009
 ====================================
   Add missing vg_release to pvs and pvdisplay to fix memory leak.
   Do not try to unlock VG which is not locked in _process_one_vg.
--- LVM2/WHATS_NEW_DM	2009/11/19 19:53:58	1.318
+++ LVM2/WHATS_NEW_DM	2009/11/24 18:26:08	1.319
@@ -1,6 +1,3 @@
-Version 1.02.41 - 
-====================================
-
 Version 1.02.40 - 19th November 2009
 ====================================
   Fix install_device-mapper Makefile target to not build dmeventd plugins.


