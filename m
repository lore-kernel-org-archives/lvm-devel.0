From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Feb 2012 15:17:05 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120201151705.18728.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-01 15:17:04

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2254&r2=1.2255
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.536&r2=1.537
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.288&r2=1.289
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2012/02/01 13:50:36	1.2254
+++ LVM2/WHATS_NEW	2012/02/01 15:17:04	1.2255
@@ -1,8 +1,8 @@
-Version 2.02.90 - 
+Version 2.02.90 - 1st February 2012
 ===================================
-  Add synchronization point in mirror log initialization.
+  sync_local_dev_names before (re)activating mirror log for initialisation.
   Disable partial activation for thin LVs and LVs with all missing segments.
-  Do not print warning for pv_min_size set in range between 512KB and 2MB.
+  Do not print warning for pv_min_size between 512KB and 2MB.
   Clean up systemd unit ordering and requirements.
   Fix lcov reports when srcdir != builddir.
   Allow ALLOC_NORMAL to track reserved extents for log and data on same PV.
--- LVM2/WHATS_NEW_DM	2012/01/27 01:23:40	1.536
+++ LVM2/WHATS_NEW_DM	2012/02/01 15:17:04	1.537
@@ -1,5 +1,6 @@
-Version 1.02.69 - 
+Version 1.02.69 - 1st February 2012
 ===================================
+  Clean up dmeventd systemd unit ordering and requirements.
 
 Version 1.02.68 - 26th January 2012
 ===================================
--- LVM2/VERSION	2012/01/27 01:23:40	1.288
+++ LVM2/VERSION	2012/02/01 15:17:04	1.289
@@ -1 +1 @@
-2.02.90(2)-cvs (2012-01-27)
+2.02.90(2)-cvs (2012-02-01)
--- LVM2/VERSION_DM	2012/01/27 01:23:40	1.93
+++ LVM2/VERSION_DM	2012/02/01 15:17:04	1.94
@@ -1 +1 @@
-1.02.69-cvs (2012-01-27)
+1.02.69-cvs (2012-02-01)


