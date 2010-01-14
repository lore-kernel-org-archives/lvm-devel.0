From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Jan 2010 14:02:36 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100114140236.2738.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-14 14:02:34

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1386&r2=1.1387
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.335&r2=1.336

--- LVM2/VERSION	2010/01/12 14:46:59	1.219
+++ LVM2/VERSION	2010/01/14 14:02:34	1.220
@@ -1 +1 @@
-2.02.58(1)-cvs (2010-01-12)
+2.02.58(1)-cvs (2010-01-14)
--- LVM2/VERSION_DM	2010/01/12 14:47:00	1.31
+++ LVM2/VERSION_DM	2010/01/14 14:02:34	1.32
@@ -1 +1 @@
-1.02.42-cvs (2010-01-12)
+1.02.42-cvs (2010-01-14)
--- LVM2/WHATS_NEW	2010/01/14 10:19:43	1.1386
+++ LVM2/WHATS_NEW	2010/01/14 14:02:34	1.1387
@@ -1,9 +1,9 @@
-Version 2.02.58 - 
+Version 2.02.58 - 14th January 2010
 ===================================
-  Cleanup of some minor gcc warnings.
-  Fix clvmd automatic target module loading crash.
-  Fix allocation code not to stop at the first area of a PV that fits.
+  Cleanup some minor gcc warnings.
   Add --merge to lvconvert to merge a snapshot into its origin.
+  Fix clvmd automatic target module loading crash (no reset_locking fn).
+  Fix allocation code not to stop at the first area of a PV that fits.
 
 Version 2.02.57 - 12th January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/01/13 21:48:39	1.335
+++ LVM2/WHATS_NEW_DM	2010/01/14 14:02:34	1.336
@@ -1,7 +1,7 @@
-Version 1.02.42 - 
+Version 1.02.42 - 14th January 2010
 ===================================
-  Add support for the "snapshot-merge" target.
-  Introduce a third activation_proiority level in dm_tree_activate_children.
+  Add support for the "snapshot-merge" kernel target (2.6.33-rc1).
+  Introduce a third activation_priority level in dm_tree_activate_children.
 
 Version 1.02.41 - 12th January 2010
 ===================================


