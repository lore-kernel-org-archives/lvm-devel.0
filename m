From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2007 02:53:50 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20071115025350.29930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-15 02:53:50

Modified files:
	tools          : vgsplit.c 

Log message:
	another vg_lock_and_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/tools/vgsplit.c	2007/11/15 02:20:03	1.39
+++ LVM2/tools/vgsplit.c	2007/11/15 02:53:49	1.40
@@ -216,7 +216,6 @@
 	struct volume_group *vg_to, *vg_from;
 	int opt;
 	int active;
-	int consistent = 1;
 
 	if (argc < 3) {
 		log_error("Existing VG, new VG and physical volumes required.");
@@ -240,27 +239,15 @@
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vg_name_to);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (!validate_new_vg_name(cmd, vg_name_to)) {
-		log_error("New volume group name \"%s\" is invalid",
-			   vg_name_to);
+	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
+	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
+				      LCK_VG_WRITE | LCK_NONBLOCK,
+				      0, 0))) {
+		log_error("Volume group \"%s\" already exists", vg_name_to);
 		unlock_vg(cmd, vg_name_from);
 		return ECMD_FAILED;
 	}
 
-	consistent = 0;
-	if ((vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))) {
-		/* FIXME Remove this restriction */
-		log_error("Volume group \"%s\" already exists", vg_name_to);
-		goto error;
-	}
-
 	if ((active = lvs_in_vg_activated(vg_from))) {
 		/* FIXME Remove this restriction */
 		log_error("Logical volumes in \"%s\" must be inactive",
@@ -336,8 +323,8 @@
 	}
 
 	/* Remove EXPORTED flag from new VG */
-	consistent = 1;
-	if (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent)) || !consistent) {
+	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_NONE, 0,
+				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);
 		goto error;


