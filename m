From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Feb 2012 18:26:29 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120223182629.7532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-23 18:26:29

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2305&r2=1.2306
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.572&r2=1.573
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.295&r2=1.296
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2012/02/23 18:22:09	1.2305
+++ LVM2/WHATS_NEW	2012/02/23 18:26:28	1.2306
@@ -1,3 +1,7 @@
+Version 2.02.94 - 
+====================================
+  Integrate client-side lvmetad into build.
+
 Version 2.02.93 - 23rd February 2012
 ====================================
   Require number of stripes to be greater than parity devices in higher RAID.
--- LVM2/WHATS_NEW_DM	2012/02/23 18:22:09	1.572
+++ LVM2/WHATS_NEW_DM	2012/02/23 18:26:28	1.573
@@ -1,3 +1,6 @@
+Version 1.02.73 - 
+====================================
+
 Version 1.02.72 - 23rd February 2012
 ====================================
   Avoid memory reallocation for dm_asprintf.
--- LVM2/VERSION	2012/02/23 18:22:09	1.295
+++ LVM2/VERSION	2012/02/23 18:26:28	1.296
@@ -1 +1 @@
-2.02.93(2)-cvs (2012-02-23)
+2.02.94(2)-cvs (2012-02-23)
--- LVM2/VERSION_DM	2012/02/23 18:22:09	1.100
+++ LVM2/VERSION_DM	2012/02/23 18:26:28	1.101
@@ -1 +1 @@
-1.02.72-cvs (2012-02-23)
+1.02.73-cvs (2012-02-23)


