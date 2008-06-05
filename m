From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jun 2008 12:45:56 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20080605124556.9782.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-05 12:45:55

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	When removing LV symlinks, skip any where the VG name is not determined.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.880&r2=1.881
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/WHATS_NEW	2008/06/03 17:56:54	1.880
+++ LVM2/WHATS_NEW	2008/06/05 12:45:53	1.881
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  When removing LV symlinks, skip any where the VG name is not determined.
   Drop metadata cache if update fails in vg_revert or vg_commit.
   Avoid spurious duplicate VG messages referring to VGs that are gone.
   Drop dev_name_confirmed error message to debug level.
--- LVM2/lib/activate/dev_manager.c	2008/04/10 17:09:30	1.136
+++ LVM2/lib/activate/dev_manager.c	2008/06/05 12:45:55	1.137
@@ -995,6 +995,9 @@
 			continue;
 		}
 
+		if (!*vgname)
+			continue;
+
 		/* only top level layer has symlinks */
 		if (*layer)
 			continue;


