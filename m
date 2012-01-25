From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:14:26 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120125091426.31531.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:14:25

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin use  suspend/resume_lv_origin
	
	Use origin_only support for thin volume when thin snapshot is created.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.350&r2=1.351

--- LVM2/lib/metadata/lv_manip.c	2012/01/25 09:02:35	1.350
+++ LVM2/lib/metadata/lv_manip.c	2012/01/25 09:14:25	1.351
@@ -4354,16 +4354,17 @@
 					  "the autoextend threshold (%d%%).", percent);
 				goto revert_new_lv;
 			}
-			if (!suspend_lv(cmd, org)) {
-				log_error("Failed to suspend thin origin %s.",
+			if (!suspend_lv_origin(cmd, org)) {
+				log_error("Failed to suspend thin snapshot origin %s.",
 					  org->name);
 				goto revert_new_lv;
-			} else if (!resume_lv(cmd, org)) {
-				log_error("Failed to resume thin origin %s.",
+			}
+			if (!resume_lv_origin(cmd, org)) { /* deptree updates thin-pool */
+				log_error("Failed to resume thin snapshot origin %s.",
 					  org->name);
 				goto revert_new_lv;
 			}
-			/* At this point snapshot is active in kernel thin mda */
+			/* At this point remove pool messages, snapshot is active */
 			if (!update_pool_lv(first_seg(org)->pool_lv, 0)) {
 				stack;
 				goto deactivate_and_revert_new_lv;


