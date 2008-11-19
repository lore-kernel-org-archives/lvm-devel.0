From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2008 14:14:54 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20081119141454.15572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-19 14:14:52

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release (retrospective)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.996&r2=1.997
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.256&r2=1.257

--- LVM2/VERSION	2008/11/10 12:39:50	1.187
+++ LVM2/VERSION	2008/11/19 14:14:51	1.188
@@ -1 +1 @@
-2.02.43-cvs (2008-11-10)
+2.02.44-cvs (2008-11-19)
--- LVM2/VERSION_DM	2008/11/10 12:39:50	1.2
+++ LVM2/VERSION_DM	2008/11/19 14:14:52	1.3
@@ -1 +1 @@
-1.02.29-cvs (2008-11-10)
+1.02.30-cvs (2008-11-19)
--- LVM2/WHATS_NEW	2008/11/17 18:20:13	1.996
+++ LVM2/WHATS_NEW	2008/11/19 14:14:52	1.997
@@ -1,7 +1,11 @@
-Version 2.02.43 - 10th November 2008
+Version 2.02.44 - 
 ====================================
+  Fix clvmd & dmeventd builds after tree restructuring.
   Cope with snapshot dependencies when removing a whole VG with lvremove.
   Make man pages consistent with either-or options (use "|" everywhere).
+
+Version 2.02.43 - 10th November 2008
+====================================
   Merge device-mapper into the lvm2 tree.
   Correct prototype for --permission on lvchange and lvcreate man pages.
   Exit with non-zero status from vgdisplay if couldn't show any requested VG.
--- LVM2/WHATS_NEW_DM	2008/11/10 12:39:50	1.256
+++ LVM2/WHATS_NEW_DM	2008/11/19 14:14:52	1.257
@@ -1,3 +1,6 @@
+Version 1.02.30 -
+====================================
+
 Version 1.02.29 - 10th November 2008
 ====================================
   Merge device-mapper into the LVM2 tree.


