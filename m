From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:04:22 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090701170422.28170.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:04:22

Modified files:
	tools          : vgsplit.c 

Log message:
	Convert vgsplit to use vg_read_for_update.
	
	Sun May  3 13:12:28 CEST 2009  Petr Rockai <me@mornfall.net>
	* Convert vgsplit to use vg_read_for_update.
	
	Author: Petr Rockai <prockai@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/tools/vgsplit.c	2009/06/10 11:21:10	1.76
+++ LVM2/tools/vgsplit.c	2009/07/01 17:04:21	1.77
@@ -282,7 +282,6 @@
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg = 0;
-	int consistent;
 	int r = ECMD_FAILED;
 	const char *lv_name;
 	uint32_t rc;
@@ -315,11 +314,11 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG |
-				       RESIZEABLE_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return ECMD_FAILED;
+
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+				     READ_REQUIRE_RESIZEABLE);
+	if (vg_read_error(vg_from))
+		return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
@@ -339,12 +338,14 @@
 	}
 	if (rc == FAILED_EXIST) {
 		existing_vg = 1;
-		if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
-					       LCK_VG_WRITE,
-					       CLUSTERED | EXPORTED_VG |
-					       RESIZEABLE_VG | LVM_WRITE,
-					       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-			return ECMD_FAILED;
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   READ_REQUIRE_RESIZEABLE |
+					   LOCK_NONBLOCKING | LOCK_KEEP |
+					   READ_CHECK_EXISTENCE);
+
+		if (vg_read_error(vg_to))
+			goto_bad;
+
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -456,13 +457,12 @@
 	/*
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
-	consistent = 1;
 	if (!test_mode()) {
-		vg_release(vg_to);
-		if (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
-		    !consistent) {
-			log_error("Volume group \"%s\" became inconsistent: please "
-				  "fix manually", vg_name_to);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   READ_ALLOW_EXPORTED);
+		if (vg_read_error(vg_to)) {
+			log_error("Volume group \"%s\" became inconsistent: "
+				  "please fix manually", vg_name_to);
 			goto_bad;
 		}
 	}


