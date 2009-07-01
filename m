From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jul 2009 09:31:47 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090701093147.18228.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-01 09:31:46

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.199&r2=1.200
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1160&r2=1.1161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.281&r2=1.282

--- LVM2/VERSION	2009/06/30 18:41:47	1.199
+++ LVM2/VERSION	2009/07/01 09:31:46	1.200
@@ -1 +1 @@
-2.02.48-cvs (2009-06-30)
+2.02.49-cvs (2009-06-30)
--- LVM2/VERSION_DM	2009/06/30 18:41:47	1.12
+++ LVM2/VERSION_DM	2009/07/01 09:31:46	1.13
@@ -1 +1 @@
-1.02.33-cvs (2009-06-30)
+1.02.34-cvs (2009-06-30)
--- LVM2/WHATS_NEW	2009/06/30 18:41:47	1.1160
+++ LVM2/WHATS_NEW	2009/07/01 09:31:46	1.1161
@@ -1,3 +1,6 @@
+Version 2.02.49 - 
+================================
+
 Version 2.02.48 - 30th June 2009
 ================================
   Abort if automatic metadata correction fails when reading VG to update it.
--- LVM2/WHATS_NEW_DM	2009/06/30 18:41:47	1.281
+++ LVM2/WHATS_NEW_DM	2009/07/01 09:31:46	1.282
@@ -1,3 +1,6 @@
+Version 1.02.34 - 
+================================
+
 Version 1.02.33 - 30th June 2009
 ================================
   Don't fallback to default major number: use dm_task_set_major_minor. (1.02.31)


