From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:13:10 -0000
Subject: LVM2/lib activate/activate.c metadata/thin_manip.c
Message-ID: <20120125091310.30682.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:13:10

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : thin_manip.c 

Log message:
	Thin use origin_only for thin pools as well
	
	Extend the usage of origin_only flag to allow resume of thin pool LV
	(when it's active) to pass only the messages.
	
	origin_only flag will skip detection of already resumed tree for thin_pool,
	so we do not need to suspend the tree and we just send messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/activate/activate.c	2012/01/25 09:10:13	1.237
+++ LVM2/lib/activate/activate.c	2012/01/25 09:13:10	1.238
@@ -1508,6 +1508,7 @@
 	struct logical_volume *lv;
 	struct lvinfo info;
 	int r = 0;
+	int messages_only = 0;
 
 	if (!activation())
 		return 1;
@@ -1515,6 +1516,9 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
+	if (lv_is_thin_pool(lv) && laopts->origin_only)
+		messages_only = 1;
+
 	if (!lv_is_origin(lv))
 		laopts->origin_only = 0;
 
@@ -1533,7 +1537,7 @@
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
-	if (!info.exists || !info.suspended) {
+	if (!info.exists || !(info.suspended || messages_only)) {
 		if (error_if_not_active)
 			goto_out;
 		r = 1;
--- LVM2/lib/metadata/thin_manip.c	2012/01/25 08:55:19	1.30
+++ LVM2/lib/metadata/thin_manip.c	2012/01/25 09:13:10	1.31
@@ -379,15 +379,11 @@
 			if (!deactivate_lv(lv->vg->cmd, lv))
 				return_0;
 		}
-		/* If already active, do suspend resume
-		 *
-		 * TODO: Support pool resume without suspend,
-		 * since the real suspend is not needed here
+		/*
+		 * Resume active pool to send thin messages.
+		 * origin_only is used to skip check for resumed state
 		 */
-		else if (!suspend_lv(lv->vg->cmd, lv)) {
-			log_error("Failed to suspend %s.", lv->name);
-			return 0;
-		} else if (!resume_lv(lv->vg->cmd, lv)) {
+		else if (!resume_lv_origin(lv->vg->cmd, lv)) {
 			log_error("Failed to resume %s.", lv->name);
 			return 0;
 		}


