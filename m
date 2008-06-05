From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jun 2008 13:38:31 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20080605133831.14217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-05 13:38:31

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Add missing deactivation after activation failure in lvcreate -Zy.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.882&r2=1.883
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/WHATS_NEW	2008/06/05 13:06:39	1.882
+++ LVM2/WHATS_NEW	2008/06/05 13:38:30	1.883
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  Add missing deactivation after activation failure in lvcreate -Zy.
   When activating, if precommitted metadata is still cached, assume it's live.
   When removing LV symlinks, skip any where the VG name is not determined.
   Drop metadata cache if update fails in vg_revert or vg_commit.
--- LVM2/tools/lvcreate.c	2008/04/10 17:09:32	1.174
+++ LVM2/tools/lvcreate.c	2008/06/05 13:38:30	1.175
@@ -801,7 +801,7 @@
 		if (lp->zero) {
 			log_error("Aborting. Failed to activate new LV to wipe "
 				  "the start of it.");
-			goto revert_new_lv;
+			goto deactivate_and_revert_new_lv;
 		}
 		log_error("Failed to activate new LV.");
 		return 0;


