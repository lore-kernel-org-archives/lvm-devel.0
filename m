From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Apr 2008 19:30:13 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20080402193013.8962.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-02 19:30:13

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit locking and remove unneeded error messages when split into new VG.
	
	When vg_lock_and_read() calls were added, they were done so incorrectly for
	the destination VG (vg_to).  This resulted in the VG lock not obtained when
	a new VG was the destination (vg_lock_and_read() would fail in the vg_read()
	clause, which would then release the lock before returning NULL), and could
	result in corrupted destination VG.
	
	The fix was to put back the original lock_vol() and vg_read() calls for 'vg_to'.
	The failure of vg_read() indicates "vg does not exist", and we key off that
	to determine whether we are dealing with a new or existing VG as the
	destination.
	
	The first two error messages were also the result of the incorrect
	vg_lock_and_read() calls:
	Volume group "new" not found
	cluster request failed: Invalid argument
	New volume group "new" successfully split from "vg"
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=438249

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.816&r2=1.817
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2008/04/02 13:08:49	1.816
+++ LVM2/WHATS_NEW	2008/04/02 19:30:12	1.817
@@ -1,6 +1,6 @@
 Version 2.02.34 -
 ===================================
-  Suppress excess messages when vgsplit into a new vg.
+  Fix vgsplit locking, remove unneeded error messages when split into new VG.
   Suppress duplicate message when lvresize fails because of invalid vgname.
   Cache VG metadata internally while VG lock is held.
   Fix redundant lvresize message if vg doesn't exist.
--- LVM2/tools/vgsplit.c	2008/04/02 13:08:49	1.53
+++ LVM2/tools/vgsplit.c	2008/04/02 19:30:12	1.54
@@ -222,6 +222,7 @@
 	int existing_vg;
 	int old_suppress;
 	struct pv_list *pvl;
+	int consistent;
 
 	if (argc < 3) {
 		log_error("Existing VG, new VG and physical volumes required.");
@@ -254,11 +255,14 @@
 	}
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	old_suppress = log_suppress(2);
-	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
-				      LCK_VG_WRITE | LCK_NONBLOCK,
-				      0, 0))) {
-		log_suppress(old_suppress);
+	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
+		log_error("Can't get lock for %s", vg_name_to);
+		unlock_vg(cmd, vg_name_from);
+		return ECMD_FAILED;
+	}
+
+	consistent = 0;
+	if ((vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -341,7 +345,13 @@
 	/* store it on disks */
 	log_verbose("Writing out updated volume groups");
 
-	/* Write out new VG as EXPORTED */
+	/*
+	 * First, write out the new VG as EXPORTED.  We do this first in case
+	 * there is a crash - we will still have the new VG information, in an
+	 * exported state.  Recovery after this point would be removal of the
+	 * new VG and redoing the vgsplit.
+	 * FIXME: recover automatically or instruct the user?
+	 */
 	vg_to->status |= EXPORTED_VG;
 
 	if (!archive(vg_to))
@@ -352,7 +362,11 @@
 
 	backup(vg_to);
 
-	/* Write out updated old VG */
+	/*
+	 * Next, write out the updated old VG.  If we crash after this point,
+	 * recovery is a vgimport on the new VG.
+	 * FIXME: recover automatically or instruct the user the user?
+	 */
 	if (vg_from->pv_count) {
 		if (!vg_write(vg_from) || !vg_commit(vg_from))
 			goto error;
@@ -360,10 +374,13 @@
 		backup(vg_from);
 	}
 
-	/* Remove EXPORTED flag from new VG */
+	/*
+	 * Finally, remove the EXPORTED flag from the new VG and write it out.
+	 */
+	consistent = 1;
 	if (!test_mode() &&
-	    !(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_NONE, 0,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+	    (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))
+	     || !consistent)) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);
 		goto error;


