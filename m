From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Sep 2009 00:42:48 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090926004248.5817.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-26 00:42:47

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.210&r2=1.211
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1272&r2=1.1273
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.303&r2=1.304

--- LVM2/VERSION	2009/09/25 18:32:22	1.210
+++ LVM2/VERSION	2009/09/26 00:42:47	1.211
@@ -1 +1 @@
-2.02.53(1)-cvs (2009-09-25)
+2.02.54(1)-cvs (2009-09-26)
--- LVM2/VERSION_DM	2009/09/25 18:32:22	1.22
+++ LVM2/VERSION_DM	2009/09/26 00:42:47	1.23
@@ -1 +1 @@
-1.02.38-cvs (2009-09-25)
+1.02.39-cvs (2009-09-26)
--- LVM2/WHATS_NEW	2009/09/25 18:32:22	1.1272
+++ LVM2/WHATS_NEW	2009/09/26 00:42:47	1.1273
@@ -1,3 +1,6 @@
+Version 2.02.54 -
+=====================================
+
 Version 2.02.53 - 25th September 2009
 =====================================
   Create any directories in /dev with DM_DEV_DIR_UMASK (022).
--- LVM2/WHATS_NEW_DM	2009/09/25 18:32:22	1.303
+++ LVM2/WHATS_NEW_DM	2009/09/26 00:42:47	1.304
@@ -1,3 +1,6 @@
+Version 1.02.39 - 
+=====================================
+
 Version 1.02.38 - 25th September 2009
 =====================================
   Export DM_DEV_DIR_UMASK, the default umask for /dev directories created.


