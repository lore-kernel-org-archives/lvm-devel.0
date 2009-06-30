From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2009 18:41:48 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090630184148.12519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-30 18:41:48

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	update date

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1159&r2=1.1160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.280&r2=1.281

--- LVM2/VERSION	2009/06/30 18:39:31	1.198
+++ LVM2/VERSION	2009/06/30 18:41:47	1.199
@@ -1 +1 @@
-2.02.48-cvs (2009-06-29)
+2.02.48-cvs (2009-06-30)
--- LVM2/VERSION_DM	2009/06/30 18:39:31	1.11
+++ LVM2/VERSION_DM	2009/06/30 18:41:47	1.12
@@ -1 +1 @@
-1.02.33-cvs (2009-06-29)
+1.02.33-cvs (2009-06-30)
--- LVM2/WHATS_NEW	2009/06/30 18:39:31	1.1159
+++ LVM2/WHATS_NEW	2009/06/30 18:41:47	1.1160
@@ -1,4 +1,4 @@
-Version 2.02.48 - 29th June 2009
+Version 2.02.48 - 30th June 2009
 ================================
   Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
--- LVM2/WHATS_NEW_DM	2009/06/30 18:39:31	1.280
+++ LVM2/WHATS_NEW_DM	2009/06/30 18:41:47	1.281
@@ -1,4 +1,4 @@
-Version 1.02.33 - 29th June 2009
+Version 1.02.33 - 30th June 2009
 ================================
   Don't fallback to default major number: use dm_task_set_major_minor. (1.02.31)
   Do not fork daemon when dmeventd cannot be found.


