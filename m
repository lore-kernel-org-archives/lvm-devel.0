From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Dec 2010 21:08:55 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20101221210855.15086.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-21 21:08:52

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1849&r2=1.1850
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.433&r2=1.434
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.265&r2=1.266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2010/12/21 01:08:29	1.1849
+++ LVM2/WHATS_NEW	2010/12/21 21:08:51	1.1850
@@ -1,8 +1,11 @@
+Version 2.02.80 - 
+====================================
+
 Version 2.02.79 - 20th December 2010
 ====================================
   Remove some unused variables.
   Add missing test for reallocation error in _find_parallel_space().
-  Add checks for allocation errors in config node clonning.
+  Add checks for allocation errors in config node cloning.
   Fix error path if regex engine cannot be created in _build_matcher().
   Use char* arithmetic in target_version(), _process_all() & _targets().
   Fixing const cast gcc warnings in the code.
--- LVM2/WHATS_NEW_DM	2010/12/21 01:08:29	1.433
+++ LVM2/WHATS_NEW_DM	2010/12/21 21:08:52	1.434
@@ -1,3 +1,6 @@
+Version 1.02.61 - 
+====================================
+
 Version 1.02.60 - 20th December 2010
 ====================================
   Check for unlink failure in remove_lockfile() in dmeventd.
--- LVM2/VERSION	2010/12/21 01:08:29	1.265
+++ LVM2/VERSION	2010/12/21 21:08:52	1.266
@@ -1 +1 @@
-2.02.79(2)-cvs (2010-12-20)
+2.02.80(2)-cvs (2010-12-21)
--- LVM2/VERSION_DM	2010/12/21 01:08:29	1.74
+++ LVM2/VERSION_DM	2010/12/21 21:08:52	1.75
@@ -1 +1 @@
-1.02.60-cvs (2010-12-20)
+1.02.61-cvs (2010-12-21)


