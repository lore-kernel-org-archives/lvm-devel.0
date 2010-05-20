From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 22:27:27 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100520222727.14892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 22:27:26

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1572&r2=1.1573
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.371&r2=1.372

--- LVM2/VERSION	2010/05/17 20:18:13	1.236
+++ LVM2/VERSION	2010/05/20 22:27:26	1.237
@@ -1 +1 @@
-2.02.66(2)-cvs (2010-05-17)
+2.02.66(2)-cvs (2010-05-20)
--- LVM2/VERSION_DM	2010/05/17 20:18:13	1.47
+++ LVM2/VERSION_DM	2010/05/20 22:27:26	1.48
@@ -1 +1 @@
-1.02.49-cvs (2010-05-17)
+1.02.48-cvs (2010-05-20)
--- LVM2/WHATS_NEW	2010/05/20 22:24:33	1.1572
+++ LVM2/WHATS_NEW	2010/05/20 22:27:26	1.1573
@@ -1,4 +1,4 @@
-Version 2.02.66 - 
+Version 2.02.66 - 20th May 2010
 ===============================
   If unable to obtain snapshot percentage leave value blank on reports.
   Add install_system_dirs and install_initscripts makefile targets.
@@ -9,7 +9,7 @@
   Add tests for lvm_vgname_from_{pvid|device}.
   Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
   Update pvchange to always obtain a vg handle for each pv to process.
-  Add Add find_vgname_from_{pvname|pvid} functions.
+  Add find_vgname_from_{pvname|pvid} functions.
   Add pvid_from_devname and lvmcache_vgname_from_pvid lvmcache functions.
   Validate orphan and VG_GLOBAL lock order too.
   Accept orphan VG names as parameters to lock_vol() and related functions.
--- LVM2/WHATS_NEW_DM	2010/05/17 20:18:13	1.371
+++ LVM2/WHATS_NEW_DM	2010/05/20 22:27:26	1.372
@@ -1,6 +1,3 @@
-Version 1.02.49 - 
-================================
-
 Version 1.02.48 - 17th May 2010
 ================================
   Use -d to control level of messages sent to syslog by dmeventd.


