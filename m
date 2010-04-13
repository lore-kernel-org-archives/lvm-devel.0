From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Apr 2010 01:54:36 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c man/lvc ...
Message-ID: <20100413015436.31643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-13 01:54:34

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	man            : lvconvert.8.in 
	tools          : args.h commands.h lvconvert.c lvcreate.c 
	                 toollib.c toollib.h 

Log message:
	Add --stripes to lvconvert too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1511&r2=1.1512
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2010/04/13 01:43:56	1.1511
+++ LVM2/WHATS_NEW	2010/04/13 01:54:32	1.1512
@@ -7,7 +7,7 @@
   Add --enable-write_install options to install user writable files.
   Use INSTALL_PROGRAM/DATA/WDATA target.
   Switch from using VPATH  to vpath in Makefiles.
-  Permit mimage LVs to be striped in lvcreate and lvresize.
+  Permit mimage LVs to be striped in lvcreate, lvresize and lvconvert.
   Fix pvmove allocation to take existing parallel stripes into account.
   Add pvmove_source_seg to struct lv_segment.
   Fix incorrect removal of symlinks after LV deactivation fails.
--- LVM2/lib/locking/locking.c	2010/04/12 11:52:53	1.78
+++ LVM2/lib/locking/locking.c	2010/04/13 01:54:33	1.79
@@ -387,7 +387,8 @@
 		}
 
 		_update_vg_lock_count(resource, flags);
-	}
+	} else
+		stack;
 
 	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
--- LVM2/man/lvconvert.8.in	2010/03/26 22:15:43	1.15
+++ LVM2/man/lvconvert.8.in	2010/04/13 01:54:33	1.16
@@ -7,6 +7,7 @@
 [\-A|\-\-alloc AllocationPolicy]
 [\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
+[\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 [\-\-noudevsync]
 [\-v|\-\-verbose] [\-y|\-\-yes]
 [\-\-version]
--- LVM2/tools/args.h	2010/01/13 01:45:15	1.72
+++ LVM2/tools/args.h	2010/04/13 01:54:33	1.73
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -14,8 +14,7 @@
  */
 
 /*
- * Put all long args that don't have a
- * corresponding short option first ...
+ * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
 arg(version_ARG, '\0', "version", NULL, 0)
@@ -66,6 +65,7 @@
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/03/26 22:15:44	1.143
+++ LVM2/tools/commands.h	2010/04/13 01:54:34	1.144
@@ -105,6 +105,7 @@
    "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t[--noudevsync]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
@@ -137,7 +138,8 @@
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, test_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG,
+   stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
--- LVM2/tools/lvconvert.c	2010/04/09 01:00:11	1.125
+++ LVM2/tools/lvconvert.c	2010/04/13 01:54:34	1.126
@@ -35,6 +35,8 @@
 	uint32_t mirrors;
 	sign_t mirrors_sign;
 	uint32_t keep_mimages;
+	uint32_t stripes;
+	uint32_t stripe_size;
 
 	struct segment_type *segtype;
 
@@ -194,9 +196,11 @@
 
 	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	if (lp->merge) {
+	/* There are three types of lvconvert. */
+	if (lp->merge) {	/* Snapshot merge */
 		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
-		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG)) {
+		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
+		    arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) {
 			log_error("Only --background and --interval are valid "
 				  "arguments for snapshot merge");
 			return 0;
@@ -205,12 +209,17 @@
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
 
-	} else if (lp->snapshot) {
+	} else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
 		if (arg_count(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
 		}
 
+		if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
+			log_error("--stripes and --stripesize are only available with striped mirrors");
+			return 0;
+		}
+
 		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative chunk size is invalid");
 			return 0;
@@ -287,6 +296,12 @@
 			return 0;
 		}
 
+		/* Default is never striped, regardless of existing LV configuration. */
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size)) {
+			stack;
+			return 0;
+		}
+
 		if (!(lp->segtype = get_segtype_from_string(cmd, "mirror")))
 			return_0;
 	}
@@ -950,8 +965,8 @@
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.
 		 */
-		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, 1,
-				    0, region_size, new_log_count, operable_pvs,
+		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, lp->stripes,
+				    lp->stripe_size, region_size, new_log_count, operable_pvs,
 				    lp->alloc, MIRROR_BY_LV)) {
 			stack;
 			return failure_code;
@@ -1005,7 +1020,7 @@
 
 		/* FIXME: can't have multiple mlogs. force corelog. */
 		if (!lv_add_mirrors(cmd, lv,
-				    new_mimage_count - old_mimage_count, 1, 0,
+				    new_mimage_count - old_mimage_count, lp->stripes, lp->stripe_size,
 				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
--- LVM2/tools/lvcreate.c	2010/04/09 01:00:11	1.219
+++ LVM2/tools/lvcreate.c	2010/04/13 01:54:34	1.220
@@ -233,71 +233,6 @@
 }
 
 /*
- * Generic stripe parameter checks.
- * FIXME: Should eventually be moved into lvm library.
- */
-static int _validate_stripe_params(struct cmd_context *cmd,
-				   struct lvcreate_params *lp)
-{
-	if (lp->stripes == 1 && lp->stripe_size) {
-		log_print("Ignoring stripesize argument with single stripe");
-		lp->stripe_size = 0;
-	}
-
-	if (lp->stripes > 1 && !lp->stripe_size) {
-		lp->stripe_size = find_config_tree_int(cmd,
-						  "metadata/stripesize",
-						  DEFAULT_STRIPESIZE) * 2;
-		log_print("Using default stripesize %s",
-			  display_size(cmd, (uint64_t) lp->stripe_size));
-	}
-
-	if (lp->stripes < 1 || lp->stripes > MAX_STRIPES) {
-		log_error("Number of stripes (%d) must be between %d and %d",
-			  lp->stripes, 1, MAX_STRIPES);
-		return 0;
-	}
-
-	/* MAX size check is in _lvcreate */
-	if (lp->stripes > 1 && (lp->stripe_size < STRIPE_SIZE_MIN ||
-				lp->stripe_size & (lp->stripe_size - 1))) {
-		log_error("Invalid stripe size %s",
-			  display_size(cmd, (uint64_t) lp->stripe_size));
-		return 0;
-	}
-
-	return 1;
-}
-
-/* The stripe size is limited by the size of a uint32_t, but since the
- * value given by the user is doubled, and the final result must be a
- * power of 2, we must divide UINT_MAX by four and add 1 (to round it
- * up to the power of 2) */
-static int _read_stripe_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd)
-{
-	if (arg_count(cmd, stripesize_ARG)) {
-		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative stripesize is invalid");
-			return 0;
-		}
-		/* Check to make sure we won't overflow lp->stripe_size */
-		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-			log_error("Stripe size cannot be larger than %s",
-				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
-			return 0;
-		}
-		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
-	}
-
-
-	if (!_validate_stripe_params(cmd, lp))
-		return 0;
-
-	return 1;
-}
-
-/*
  * Generic mirror parameter checks.
  * FIXME: Should eventually be moved into lvm library.
  */
@@ -399,10 +334,6 @@
 	    arg_ptr_value(cmd, type_ARG,
 			  get_segtype_from_string(cmd, "striped"));
 
-	lp->stripes = arg_uint_value(cmd, stripes_ARG, 1);
-	if (arg_count(cmd, stripes_ARG) && lp->stripes == 1)
-		log_print("Redundant stripes argument: default is 1");
-
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    arg_count(cmd, virtualsize_ARG))
 		lp->snapshot = 1;
@@ -484,7 +415,7 @@
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
-	    !_read_stripe_params(lp, cmd) ||
+	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
 
--- LVM2/tools/toollib.c	2010/03/29 16:09:41	1.191
+++ LVM2/tools/toollib.c	2010/04/13 01:54:34	1.192
@@ -1455,3 +1455,65 @@
 	
 	return 1;
 }
+
+/*
+ * Generic stripe parameter checks.
+ */
+static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
+				   uint32_t *stripe_size)
+{
+	if (*stripes == 1 && *stripe_size) {
+		log_print("Ignoring stripesize argument with single stripe");
+		*stripe_size = 0;
+	}
+
+	if (*stripes > 1 && !*stripe_size) {
+		*stripe_size = find_config_tree_int(cmd, "metadata/stripesize", DEFAULT_STRIPESIZE) * 2;
+		log_print("Using default stripesize %s",
+			  display_size(cmd, (uint64_t) *stripe_size));
+	}
+
+	if (*stripes < 1 || *stripes > MAX_STRIPES) {
+		log_error("Number of stripes (%d) must be between %d and %d",
+			  *stripes, 1, MAX_STRIPES);
+		return 0;
+	}
+
+	if (*stripes > 1 && (*stripe_size < STRIPE_SIZE_MIN ||
+			     *stripe_size & (*stripe_size - 1))) {
+		log_error("Invalid stripe size %s",
+			  display_size(cmd, (uint64_t) *stripe_size));
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * The stripe size is limited by the size of a uint32_t, but since the
+ * value given by the user is doubled, and the final result must be a
+ * power of 2, we must divide UINT_MAX by four and add 1 (to round it
+ * up to the power of 2)
+ */
+int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stripe_size)
+{
+	/* stripes_long_ARG takes precedence (for lvconvert) */
+        *stripes = arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
+
+	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
+	if (*stripe_size) {
+		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative stripesize is invalid");
+			return 0;
+		}
+
+		if(*stripe_size > STRIPE_SIZE_LIMIT * 2) {
+			log_error("Stripe size cannot be larger than %s",
+				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+			return 0;
+		}
+	}
+
+	return _validate_stripe_params(cmd, stripes, stripe_size);
+}
+
--- LVM2/tools/toollib.h	2010/03/29 16:09:41	1.71
+++ LVM2/tools/toollib.h	2010/04/13 01:54:34	1.72
@@ -115,5 +115,8 @@
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   int *monitoring_mode);
+int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
+		      uint32_t *stripe_size);
+
 
 #endif


