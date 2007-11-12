From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Nov 2007 13:34:15 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20071112133415.32045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-12 13:34:14

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Attempt to remove incomplete LVs with lvcreate zeroing/activation problems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.731&r2=1.732
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW	2007/11/09 16:51:53	1.731
+++ LVM2/WHATS_NEW	2007/11/12 13:34:14	1.732
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Attempt to remove incomplete LVs with lvcreate zeroing/activation problems.
   Add activation/readahead configuration option and FMT_RESTRICTED_READAHEAD.
   Extend readahead arg to accept "auto" and "none".
   Add lv_read_ahead and lv_kernel_read_ahead fields to reports.
--- LVM2/tools/lvcreate.c	2007/11/09 16:51:54	1.154
+++ LVM2/tools/lvcreate.c	2007/11/12 13:34:14	1.155
@@ -249,7 +249,7 @@
  * Generic mirror parameter checks.
  * FIXME: Should eventually be moved into lvm library.
  */
-static int _validate_mirror_params(const struct cmd_context *cmd,
+static int _validate_mirror_params(const struct cmd_context *cmd __attribute((unused)),
 				   const struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
@@ -638,6 +638,12 @@
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
+	if (lp->zero && !activation) {
+		log_error("Can't wipe start of new LV without using "
+			  "device-mapper kernel driver");
+		return 0;
+	}
+
 	if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "
@@ -811,45 +817,41 @@
 		alloc_destroy(ah);
 		ah = NULL;
 	} else if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       lp->mirrors, lp->extents, NULL, 0u, 0u, pvh, lp->alloc)) {
-		stack;
-		return 0;
-	}
+		       lp->mirrors, lp->extents, NULL, 0u, 0u, pvh, lp->alloc))
+		return_0;
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(vg))
+		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_commit(vg))
+		return_0;
 
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
-				  "exception store. Remove new LV and retry.");
-			return 0;
+				  "exception store.");
+			goto revert_new_lv;
 		}
 	} else if (!activate_lv(cmd, lv)) {
+		if (lp->zero) {
+			log_error("Aborting. Failed to activate new LV to wipe "
+				  "the start of it.");
+			goto revert_new_lv;
+		}
 		log_error("Failed to activate new LV.");
 		return 0;
 	}
 
-	if ((lp->zero || lp->snapshot) && activation()) {
-		if (!set_lv(cmd, lv, UINT64_C(0), 0) && lp->snapshot) {
-			/* FIXME Remove the failed lv we just added */
-			log_error("Aborting. Failed to wipe snapshot "
-				  "exception store. Remove new LV and retry.");
-			return 0;
-		}
-	} else {
+	if (!lp->zero && !lp->snapshot)
 		log_error("WARNING: \"%s\" not zeroed", lv->name);
-		/* FIXME Remove the failed lv we just added */
+	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
+		log_error("Aborting. Failed to wipe %s.",
+			  lp->snapshot ? "snapshot exception store" :
+					 "start of new LV");
+		goto deactivate_and_revert_new_lv;
 	}
 
 	if (lp->snapshot) {
@@ -860,7 +862,7 @@
 		/* COW area must be deactivated if origin is not active */
 		if (!origin_active && !deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot "
-				  "COW area.");
+				  "COW area. Manual intervention required.");
 			return 0;
 		}
 
@@ -868,13 +870,13 @@
 
 		if (!vg_add_snapshot(NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
-			log_err("Couldn't create snapshot.");
+			log_error("Couldn't create snapshot.");
 			return 0;
 		}
 
 		/* store vg on disk(s) */
 		if (!vg_write(vg))
-			return 0;
+			return_0;
 
 		if (!suspend_lv(cmd, org)) {
 			log_error("Failed to suspend origin %s", org->name);
@@ -883,7 +885,7 @@
 		}
 
 		if (!vg_commit(vg))
-			return 0;
+			return_0;
 
 		if (!resume_lv(cmd, org)) {
 			log_error("Problem reactivating origin %s", org->name);
@@ -906,6 +908,20 @@
 	if (ah)
 		alloc_destroy(ah);
 	return 0;
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate failed new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+revert_new_lv:
+	/* FIXME Better to revert to backup of metadata? */
+	if (!lv_remove(lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned LV(s) before retrying.");
+	return 0;
 }
 
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)


