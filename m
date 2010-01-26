From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Jan 2010 08:01:19 -0000
Subject: LVM2 ./WHATS_NEW tools/pvmove.c
Message-ID: <20100126080119.29405.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-26 08:01:18

Modified files:
	.              : WHATS_NEW 
	tools          : pvmove.c 

Log message:
	Add some missing vg_revrts calls when pvmove aborts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1409&r2=1.1410
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2010/01/26 08:00:02	1.1409
+++ LVM2/WHATS_NEW	2010/01/26 08:01:18	1.1410
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Add missing metadata reverts in pvmove error path.
   Unlock shared lock in clvmd if activation calls failed.
   Fix return code of info call for query by uuid.
   Extend cmirrord man page.
--- LVM2/tools/pvmove.c	2010/01/05 21:08:34	1.72
+++ LVM2/tools/pvmove.c	2010/01/26 08:01:18	1.73
@@ -303,8 +303,10 @@
 	}
 
 	/* Suspend lvs_changed */
-	if (!suspend_lvs(cmd, lvs_changed))
+	if (!suspend_lvs(cmd, lvs_changed)) {
+		vg_revert(vg);
 		goto_out;
+	}
 
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
@@ -324,6 +326,7 @@
 				stack;
 		if (!resume_lvs(cmd, lvs_changed))
 			stack;
+		vg_revert(vg);
 		goto out;
 	}
 


