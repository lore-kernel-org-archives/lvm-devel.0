From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jun 2009 14:31:21 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090609143121.7557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-09 14:31:21

Modified files:
	tools          : vgsplit.c 

Log message:
	Update vgsplit to use new vg_reserve_newname() function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/tools/vgsplit.c	2009/05/21 03:04:54	1.74
+++ LVM2/tools/vgsplit.c	2009/06/09 14:31:20	1.75
@@ -285,6 +285,7 @@
 	int consistent;
 	int r = ECMD_FAILED;
 	const char *lv_name;
+	uint32_t rc;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -321,15 +322,29 @@
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE)) {
+	/*
+	 * Try to lock the name of the new VG.  If we cannot reserve it,
+	 * then we assume it exists, and we will not be holding a lock.
+	 * We then try to read it - the vgsplit will be into an existing VG.
+	 *
+	 * Otherwise, if the lock was successful, it must be the case that
+	 * we obtained a WRITE lock and could not find the vgname in the
+	 * system.  Thus, the split will be into a new VG.
+	 */
+	rc = vg_lock_newname(cmd, vg_name_to);
+	if (rc == FAILED_LOCKING) {
 		log_error("Can't get lock for %s", vg_name_to);
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
-
-	consistent = 0;
-	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
+	if (rc == FAILED_EXIST) {
 		existing_vg = 1;
+		if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
+					       LCK_VG_WRITE,
+					       CLUSTERED | EXPORTED_VG |
+					       RESIZEABLE_VG | LVM_WRITE,
+					       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+			return ECMD_FAILED;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -337,7 +352,7 @@
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
-	} else {
+	} else if (rc == SUCCESS) {
 		existing_vg = 0;
 
 		/* Set metadata format of original VG */


