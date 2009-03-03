From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2009 18:25:06 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090303182506.5216.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-03-03 18:25:05

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1060&r2=1.1061
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.264&r2=1.265

--- LVM2/VERSION	2009/03/03 13:03:03	1.192
+++ LVM2/VERSION	2009/03/03 18:25:05	1.193
@@ -1 +1 @@
-2.02.45-cvs (2009-03-03)
+2.02.46-cvs (2009-03-03)
--- LVM2/VERSION_DM	2009/03/03 13:03:03	1.6
+++ LVM2/VERSION_DM	2009/03/03 18:25:05	1.7
@@ -1 +1 @@
-1.02.31-cvs (2009-03-03)
+1.02.32-cvs (2009-03-03)
--- LVM2/WHATS_NEW	2009/03/03 16:35:32	1.1060
+++ LVM2/WHATS_NEW	2009/03/03 18:25:05	1.1061
@@ -1,3 +1,6 @@
+Version 2.02.46 - 
+================================
+
 Version 2.02.45 - 3rd March 2009
 ================================
   Avoid scanning empty metadata areas for VG names.
--- LVM2/WHATS_NEW_DM	2009/03/03 13:03:03	1.264
+++ LVM2/WHATS_NEW_DM	2009/03/03 18:25:05	1.265
@@ -1,3 +1,6 @@
+Version 1.02.32 - 
+================================
+
 Version 1.02.31 - 3rd March 2009
 ================================
   If kernel supports only one dm major number, use in place of any supplied.


