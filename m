From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Feb 2012 18:22:15 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20120223182215.2211.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-23 18:22:09

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.294&r2=1.295
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2304&r2=1.2305
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.571&r2=1.572

--- LVM2/VERSION	2012/02/20 21:11:06	1.294
+++ LVM2/VERSION	2012/02/23 18:22:09	1.295
@@ -1 +1 @@
-2.02.93(2)-cvs (2012-02-20)
+2.02.93(2)-cvs (2012-02-23)
--- LVM2/VERSION_DM	2012/02/20 21:11:06	1.99
+++ LVM2/VERSION_DM	2012/02/23 18:22:09	1.100
@@ -1 +1 @@
-1.02.72-cvs (2012-02-20)
+1.02.72-cvs (2012-02-23)
--- LVM2/WHATS_NEW	2012/02/23 17:36:35	1.2304
+++ LVM2/WHATS_NEW	2012/02/23 18:22:09	1.2305
@@ -1,13 +1,13 @@
-Version 2.02.93 - 
+Version 2.02.93 - 23rd February 2012
 ====================================
   Require number of stripes to be greater than parity devices in higher RAID.
-  Add LVMetaD systemd units.
   Fix allocation code to allow replacement of single RAID 4/5/6 device.
   Check all tags and LV names are in a valid form in vg_validate.
   Add tmpfiles.d style configuration for lvm2 lock and run directory.
   Add configure --with-tmpfilesdir for dir holding volatile-file configuration.
-  Allow 'lvconvert --repair' to operate on RAID 4/5/6
-  Fix 'build_parallel_areas_from_lv' to work properly with RAID 4/5/6
+  Allow 'lvconvert --repair' to operate on RAID 4/5/6.
+  Fix build_parallel_areas_from_lv to account correctly for raid parity devices.
+  Print message when faulty raid devices have been replaced.
 
 Version 2.02.92 - 20th February 2012
 ====================================
--- LVM2/WHATS_NEW_DM	2012/02/23 18:05:12	1.571
+++ LVM2/WHATS_NEW_DM	2012/02/23 18:22:09	1.572
@@ -1,4 +1,4 @@
-Version 1.02.72 - 
+Version 1.02.72 - 23rd February 2012
 ====================================
   Avoid memory reallocation for dm_asprintf.
 


