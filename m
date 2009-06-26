From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2009 10:57:30 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090626105730.32551.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-26 10:57:30

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1157&r2=1.1158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.278&r2=1.279

--- LVM2/VERSION	2009/05/22 15:23:10	1.196
+++ LVM2/VERSION	2009/06/26 10:57:30	1.197
@@ -1 +1 @@
-2.02.48-cvs (2009-05-22)
+2.02.48-cvs (2009-06-26)
--- LVM2/VERSION_DM	2009/05/22 15:23:10	1.9
+++ LVM2/VERSION_DM	2009/06/26 10:57:30	1.10
@@ -1 +1 @@
-1.02.33-cvs (2009-05-22)
+1.02.33-cvs (2009-06-26)
--- LVM2/WHATS_NEW	2009/06/26 10:55:57	1.1157
+++ LVM2/WHATS_NEW	2009/06/26 10:57:30	1.1158
@@ -1,5 +1,5 @@
-Version 2.02.48 - 
-===============================
+Version 2.02.48 - 26th June 2009
+================================
   Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
--- LVM2/WHATS_NEW_DM	2009/06/17 20:55:24	1.278
+++ LVM2/WHATS_NEW_DM	2009/06/26 10:57:30	1.279
@@ -1,5 +1,5 @@
-Version 1.02.33 -
-===============================
+Version 1.02.33 - 26th June 2009
+================================
   Do not fallback to default major number, provide new function instead (1.02.31)
   Do not fork daemon when dmeventd cannot be found.
   Add crypt target handling to libdevmapper node.


