From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Oct 2006 21:33:31 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20061013213331.32322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-13 21:33:31

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Retain activation state after changing LV minor number with --force.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.468&r2=1.469
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2006/10/13 13:22:44	1.468
+++ LVM2/WHATS_NEW	2006/10/13 21:33:31	1.469
@@ -1,6 +1,7 @@
 Version 2.02.12 -
 ===================================
-  Propogate clustered flag in vgsplit and require resizeable flag.
+  Retain activation state after changing LV minor number with --force.
+  Propagate clustered flag in vgsplit and require resizeable flag.
 
 Version 2.02.11 - 12th October 2006
 ===================================
--- LVM2/tools/lvchange.c	2006/07/10 19:39:14	1.68
+++ LVM2/tools/lvchange.c	2006/10/13 21:33:31	1.69
@@ -294,16 +294,15 @@
 			log_error("Major number must be specified with -My");
 			return 0;
 		}
-		if (lv_info(cmd, lv, &info, 0) && info.exists &&
-		    !arg_count(cmd, force_ARG)) {
-			if (yes_no_prompt("Logical volume %s will be "
-					  "deactivated temporarily. "
-					  "Continue? [y/n]: ", lv->name) == 'n') {
-				log_print("%s device number not changed.",
-					  lv->name);
-				return 0;
-			}
+		if (lv_info(cmd, lv, &info, 0) && info.exists)
 			active = 1;
+		if (active && !arg_count(cmd, force_ARG) &&
+		    yes_no_prompt("Logical volume %s will be "
+				  "deactivated temporarily. "
+				  "Continue? [y/n]: ", lv->name) == 'n') {
+			log_print("%s device number not changed.",
+				  lv->name);
+			return 0;
 		}
 		log_verbose("Ensuring %s is inactive.", lv->name);
 		if (!deactivate_lv(cmd, lv)) {


