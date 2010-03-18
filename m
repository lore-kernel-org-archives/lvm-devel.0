From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Mar 2010 15:54:38 -0500
Subject: [PATCH 11 of 12] LVM: rework lvconvert_mirrors
Message-ID: <201003182054.o2IKscoD025116@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-rework-lvconvert_mirrors.patch

This patch breaks up the _lvconvert_mirrors function - making
it easier to handle the various different cases (collapse,
convert, and repair).

The goal is to handle failures more easily and be able to
have the repair function pass the log LV to the convert
function when repairing mirrored logs.  This allows us
to obey the imposed restriction of passing only top-level
LVs to lvconvert.

I've taken Taka's comments into account, but I am still
working through the tests (mostly trying to debug allocation
changes and mirrored log changes).  These patches are
ready for serious inclusion consideration, but I can't be
sure there are no issues yet.  Please comment and test.

 brassow

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -670,6 +670,7 @@ static int _get_log_count(struct logical
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
+			       struct dm_list *operable_pvs,
 			       int log_count)
 {
 	uint32_t region_size;
@@ -689,15 +690,14 @@ static int _lv_update_log_type(struct cm
 	/* Add a log where there is none */
 	if (!old_log_count) {
 		if (!add_mirror_log(cmd, original_lv, log_count,
-				    region_size, lp->pvh, lp->alloc))
+				    region_size, operable_pvs, lp->alloc))
 			return_0;
 		return 1;
 	}
 
 	/* Remove an existing log completely */
 	if (!log_count) {
-		if (!remove_mirror_log(cmd, original_lv,
-				       lp->pv_count ? lp->pvh : NULL))
+		if (!remove_mirror_log(cmd, original_lv, operable_pvs))
 			return_0;
 		return 1;
 	}
@@ -712,7 +712,7 @@ static int _lv_update_log_type(struct cm
 	}
 
 	/* Reducing redundancy of the log */
-	return remove_mirror_images(log_lv, log_count, lp->pvh, 1U);
+	return remove_mirror_images(log_lv, log_count, operable_pvs, 1U);
 }
 
 /*
@@ -753,148 +753,134 @@ static void _remove_missing_empty_pv(str
 	}
 }
 
-static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
+/*
+ * _lvconvert_mirrors_parse_params
+ *
+ * This function performs the following:
+ *  1) Gets the old values of mimage and log counts
+ *  2) Parses the CLI args to find the new desired values
+ *  3) Adjusts 'lp->mirrors' to the appropriate absolute value.
+ *     (Remember, 'lp->mirrors' is specified in terms of the number of "copies"
+ *      vs. the number of mimages.  It can also be a relative value.)
+ *  4) Sets 'lp->need_polling' if collapsing
+ *  5) Validates other mirror params
+ *
+ * Returns: 1 on success, 0 on error
+ */
+static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
+					   struct logical_volume *lv,
+					   struct lvconvert_params *lp,
+					   uint32_t *old_mimage_count,
+					   uint32_t *old_log_count,
+					   uint32_t *new_mimage_count,
+					   uint32_t *new_log_count)
 {
-	struct lv_segment *seg;
-	uint32_t existing_mirrors;
-	const char *mirrorlog;
-	unsigned log_count = _get_log_count(lv);
-	int r = 0;
-	struct logical_volume *log_lv, *layer_lv;
-	int failed_mirrors = 0, failed_log = 0;
-	struct dm_list *old_pvh = NULL, *remove_pvs = NULL, *failed_pvs = NULL;
-
 	int repair = arg_count(cmd, repair_ARG);
-	int replace_log = 1, replace_mirrors = 1;
-	int failure_code = 0;
-
-	seg = first_seg(lv);
-	existing_mirrors = lv_mirror_count(lv);
+	const char *mirrorlog;
+	*old_mimage_count = lv_mirror_count(lv);
+	*old_log_count = _get_log_count(lv);
 
-	/* If called with no argument, try collapsing the resync layers */
+	/*
+	 * Collapsing a stack of mirrors:
+	 *
+	 * If called with no argument, try collapsing the resync layers
+	 */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
 	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
+		*new_mimage_count = *old_mimage_count;
+		*new_log_count = *old_log_count;
+
 		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
 			lp->need_polling = 1;
 		return 1;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) && repair) {
-		log_error("You may only use one of --mirrors and --repair.");
+	if ((arg_count(cmd, mirrors_ARG) && repair) ||
+	    (arg_count(cmd, mirrorlog_ARG) && repair) ||
+	    (arg_count(cmd, corelog_ARG) && repair)) {
+		log_error("--repair cannot be used with --mirrors, --mirrorlog,"
+			  " or --corelog");
+		return 0;
+	}
+
+	if (arg_count(cmd, mirrorlog_ARG) && arg_count(cmd, corelog_ARG)) {
+		log_error("--mirrorlog and --corelog are incompatible");
 		return 0;
 	}
 
 	/*
-	 * Adjust required number of mirrors
-	 *
-	 * We check mirrors_ARG again to see if it
-	 * was supplied.  If not, they want the mirror
-	 * count to remain the same.  They may be changing
-	 * the logging type.
+	 * Adjusting mimage count?
 	 */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
-		lp->mirrors = existing_mirrors;
+		lp->mirrors = *old_mimage_count;
 	else if (lp->mirrors_sign == SIGN_PLUS)
-		lp->mirrors = existing_mirrors + lp->mirrors;
+		lp->mirrors = *old_mimage_count + lp->mirrors;
 	else if (lp->mirrors_sign == SIGN_MINUS)
-		lp->mirrors = existing_mirrors - lp->mirrors;
+		lp->mirrors = *old_mimage_count - lp->mirrors;
 	else
 		lp->mirrors += 1;
 
+	*new_mimage_count = lp->mirrors;
+
+	/* Too many mimages? */
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
 			  DEFAULT_MIRROR_MAX_IMAGES);
 		return 0;
 	}
 
-	/*
-	 * If we are converting from one type of mirror to another, and
-	 * the type of log wasn't specified, then let's keep the log type
-	 * the same.
-	 */
-	if ((existing_mirrors > 1) && (lp->mirrors > 1) &&
-	    (lp->mirrors != existing_mirrors) && !(lv->status & CONVERTING) &&
-	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
-		log_count = _get_log_count(lv);
+	/* Did the user try to subtract more legs than available? */
+	if (lp->mirrors < 1) {
+		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+			  lv->name, *old_mimage_count);
+		return 0;
 	}
 
-	if (repair) {
-		cmd->handles_missing_pvs = 1;
-		cmd->partial_activation = 1;
-		lp->need_polling = 0;
-		if (!(lv->status & PARTIAL_LV)) {
-			log_error("The mirror is consistent. Nothing to repair.");
-			return 1;
-		}
-		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
-			return_0;
-		lp->mirrors -= failed_mirrors;
-		log_error("Mirror status: %d of %d images failed.",
-			  failed_mirrors, existing_mirrors);
-		old_pvh = lp->pvh;
-		if (!(failed_pvs = _failed_pv_list(lv->vg)))
-			return_0;
-		lp->pvh = lp->failed_pvs = failed_pvs;
-		log_lv = first_seg(lv)->log_lv;
-		if (!log_lv) {
-			failed_log = 1;
-			log_count = 0;
-		} else {
-			log_count = lv_mirror_count(log_lv);
-			if (log_lv->status & PARTIAL_LV) {
-				failed_log = 1;
-				if (log_lv->status & MIRRORED)
-					log_count -= _failed_mirrors_count(log_lv);
-				else
-					log_count = 0;
-			}
-		}
-	} else {
-		/*
-		 * Did the user try to subtract more legs than available?
-		 */
-		if (lp->mirrors < 1) {
-			log_error("Logical volume %s only has %" PRIu32 " mirrors.",
-				  lv->name, existing_mirrors);
-			return 0;
-		}
-
-		/*
-		 * Adjust log type
-		 */
-		if (arg_count(cmd, corelog_ARG))
-			log_count = 0;
+	/*
+	 * FIXME: It would be nice to say what we are adjusting to, but
+	 * I really don't know whether to specify the # of copies or mimages.
+	 */
+	if (*old_mimage_count != *new_mimage_count)
+		log_verbose("Adjusting mirror image count of %s", lv->name);
 
-		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-					  !log_count ? "core" : DEFAULT_MIRRORLOG);
+	/*
+	 * Adjust log type
+	 *
+	 * If we are converting from a mirror to another mirror or simply
+	 * changing the log type, we start by assuming they want the log
+	 * type the same and then parse the given args.  OTOH, If we are
+	 * converting from linear to mirror, then we start from the default
+	 * position that the user would like a 'disk' log.
+	 */
+	*new_log_count = (*old_mimage_count > 1) ? *old_log_count : 1;
+	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
+		return 1;
 
-		if (strcmp("core", mirrorlog) && !log_count) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
+	if (arg_count(cmd, corelog_ARG))
+		*new_log_count = 0;
 
-		if (!strcmp("mirrored", mirrorlog))
-			log_count = 2;
-		else if (!strcmp("disk", mirrorlog))
-			log_count = 1;
-		else if (!strcmp("core", mirrorlog))
-			log_count = 0;
-		else {
-			log_error("Unknown mirrorlog type: %s", mirrorlog);
-			return 0;
-		}
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+				  !*new_log_count ? "core" : DEFAULT_MIRRORLOG);
 
-		log_verbose("Setting logging type to %s", mirrorlog);
+	if (!strcmp("mirrored", mirrorlog))
+		*new_log_count = 2;
+	else if (!strcmp("disk", mirrorlog))
+		*new_log_count = 1;
+	else if (!strcmp("core", mirrorlog))
+		*new_log_count = 0;
+	else {
+		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		return 0;
 	}
 
+	log_verbose("Setting logging type to %s", mirrorlog);
+
 	/*
 	 * Region size must not change on existing mirrors
 	 */
 	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
-	    (lp->region_size != seg->region_size)) {
+	    (lp->region_size != first_seg(lv)->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
 			  "an existing mirror.");
 		return 0;
@@ -910,48 +896,54 @@ static int _lvconvert_mirrors(struct cmd
 		return 0;
 	}
 
-	if (repair)
-		_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
-					      &replace_log, &replace_mirrors);
+	return 1;
+}
 
- restart:
-	/*
-	 * Converting from mirror to linear
-	 */
-	if ((lp->mirrors == 1)) {
-		if (!(lv->status & MIRRORED)) {
-			log_error("Logical volume %s is already not mirrored.",
-				  lv->name);
-			return 1;
-		}
+/*
+ * _lvconvert_mirrors_aux
+ *
+ * Add/remove mirror images and adjust log type.  'operable_pvs'
+ * are the set of PVs open to removal or allocation - depending
+ * on the operation being performed.
+ *
+ * If 'allocation_failures_ok' is set, and there is a failure to
+ * convert due to space, success will be returned.
+ */
+static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
+				  struct logical_volume *lv,
+				  struct lvconvert_params *lp,
+				  struct dm_list *operable_pvs,
+				  uint32_t new_mimage_count,
+				  uint32_t new_log_count,
+				  int allocation_failures_ok)
+{
+	uint32_t region_size;
+	struct dm_list *tmp;
+	struct lv_segment *seg;
+	struct logical_volume *layer_lv;
+	uint32_t old_mimage_count = lv_mirror_count(lv);
+	uint32_t old_log_count = _get_log_count(lv);
+	int failure_code = (allocation_failures_ok) ? 1 : 0;
+
+	if ((lp->mirrors == 1) && !(lv->status & MIRRORED)) {
+		log_error("Logical volume %s is already not mirrored.",
+			  lv->name);
+		return 1;
 	}
 
-	/*
-	 * Downconversion.
-	 */
-	if (lp->mirrors < existing_mirrors) {
-		/* Reduce number of mirrors */
-		if (repair || lp->pv_count)
-			remove_pvs = lp->pvh;
+	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+						  lv->le_count,
+						  lp->region_size);
 
-		if (lp->keep_mimages) {
-			if (!lv_split_mirror_images(lv, lp->lv_split_name,
-						    existing_mirrors - lp->mirrors,
-						    remove_pvs))
-				return 0;
-		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
-					      remove_pvs, 0))
-			return_0;
+	if (!operable_pvs)
+		operable_pvs = lp->pvh;
 
-		if (lp->mirrors > 1 &&
-		    !_lv_update_log_type(cmd, lp, lv, log_count))
-			return_0;
-	} else if (!(lv->status & MIRRORED)) {
-		/*
-		 * Converting from linear to mirror
-		 */
+	seg = first_seg(lv);
 
+	/*
+	 * Up-convert from linear to mirror
+	 */
+	if (!(lv->status & MIRRORED)) {
 		/* FIXME Share code with lvcreate */
 
 		/* FIXME Why is this restriction here?  Fix it! */
@@ -967,19 +959,22 @@ static int _lvconvert_mirrors(struct cmd
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.
 		 */
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, 1,
-				    adjusted_mirror_region_size(
-						lv->vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    log_count, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV)) {
+		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, 1,
+				    region_size, new_log_count, operable_pvs,
+				    lp->alloc, MIRROR_BY_LV)) {
 			stack;
 			return failure_code;
 		}
 		if (lp->wait_completion)
 			lp->need_polling = 1;
-	} else if (lp->mirrors > existing_mirrors || failed_mirrors) {
+
+		goto out;
+	}
+
+	/*
+	 * Up-convert m-way mirror to n-way mirror
+	 */
+	if (new_mimage_count > old_mimage_count) {
 		if (lv->status & MIRROR_NOTSYNCED) {
 			log_error("Can't add mirror to out-of-sync mirrored "
 				  "LV: use lvchange --resync first.");
@@ -1004,23 +999,23 @@ static int _lvconvert_mirrors(struct cmd
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
+		if (!_lv_update_log_type(cmd, lp, lv,
+					 operable_pvs, new_log_count)) {
 			stack;
 			return failure_code;
 		}
+
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
 			log_error("Failed to insert resync layer");
 			return 0;
 		}
+
 		/* FIXME: can't have multiple mlogs. force corelog. */
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - existing_mirrors, 1,
-				    adjusted_mirror_region_size(
-						lv->vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    0U, lp->pvh, lp->alloc,
+		if (!lv_add_mirrors(cmd, lv,
+				    new_mimage_count - old_mimage_count, 1,
+				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
@@ -1040,24 +1035,45 @@ static int _lvconvert_mirrors(struct cmd
 		if (seg->log_lv)
 			lv->status |= CONVERTING;
 		lp->need_polling = 1;
+
+		goto out_skip_log_convert;
 	}
 
-	if (lp->mirrors == existing_mirrors) {
-		if (_get_log_count(lv) != log_count) {
-			if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
-				stack;
-				return failure_code;
-			}
-		} else {
-			log_error("Logical volume %s already has %"
-				  PRIu32 " mirror(s).", lv->name,
-				  lp->mirrors - 1);
-			if (lv->status & CONVERTING)
-				lp->need_polling = 1;
-			return 1;
+	/*
+	 * Down-convert (reduce # of mimages).
+	 */
+	if (new_mimage_count < old_mimage_count) {
+		uint32_t nmc = old_mimage_count - new_mimage_count;
+		uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
+
+		/* FIXME: We did nlc used to be calculated that way? */
+
+		/* Reduce number of mirrors */
+		if (lp->keep_mimages) {
+			if (!lv_split_mirror_images(lv, lp->lv_split_name,
+						    nmc, operable_pvs))
+				return 0;
+		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
+					      operable_pvs, 0))
+			return_0;
+
+		goto out; /* Just in case someone puts code between */
+	}
+
+out:
+	/*
+	 * Converting the log type
+	 */
+	if (old_log_count != new_log_count) {
+		if (!_lv_update_log_type(cmd, lp, lv,
+					 operable_pvs, new_log_count)) {
+			stack;
+			return failure_code;
 		}
 	}
 
+out_skip_log_convert:
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
 	if (!vg_write(lv->vg))
@@ -1082,35 +1098,165 @@ static int _lvconvert_mirrors(struct cmd
 		goto out;
 	}
 
-	if (failed_log || failed_mirrors) {
-		lp->pvh = old_pvh;
-		if (failed_log && replace_log) {
-			failed_log = 0;
-			log_count = 1;
-		}
-		if (replace_mirrors)
-			lp->mirrors += failed_mirrors;
-		failed_mirrors = 0;
-		existing_mirrors = lv_mirror_count(lv);
+	return 1;
+}
+
+/*
+ * _lvconvert_mirrors_repair
+ *
+ * This function operates in two phases.  First, all of the bad
+ * devices are removed from the mirror.  Then, if desired by the
+ * user, the devices are replaced.
+ *
+ * 'old_mimage_count' and 'old_log_count' are there so we know
+ * what to convert to after the removal of devices.
+ */
+static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct lvconvert_params *lp,
+				     uint32_t old_mimage_count,
+				     uint32_t old_log_count)
+{
+	int failed_log = 0;
+	int failed_mirrors = 0;
+	int replace_log = 0;
+	int replace_mirrors = 0;
+	uint32_t new_log_count;
+	struct dm_list *failed_pvs = NULL;
+	struct logical_volume *log_lv;
+
+	cmd->handles_missing_pvs = 1;
+	cmd->partial_activation = 1;
+	lp->need_polling = 0;
+
+	if (!(lv->status & PARTIAL_LV)) {
+		log_error("%s is consistent. Nothing to repair.", lv->name);
+		return 1;
+	}
+
+	/*
+	 * Count the failed mimages - negative if 'lv' is not a mirror
+	 */
+	if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
+		return_0;
+
+	lp->mirrors = old_mimage_count - failed_mirrors;
+
+	if (lp->mirrors != old_mimage_count)
+		log_error("Mirror status: %d of %d images failed.",
+			  failed_mirrors, old_mimage_count);
+
+	/*
+	 * Count the failed log devices
+	 */
+	new_log_count = old_log_count;
+	log_lv = first_seg(lv)->log_lv;
+	if (log_lv) {
+		new_log_count = lv_mirror_count(log_lv);
+		if (log_lv->status & PARTIAL_LV) {
+			failed_log = 1;
+			if (log_lv->status & MIRRORED)
+				new_log_count -= _failed_mirrors_count(log_lv);
+			else
+				new_log_count = 0;
+		}
+	}
+	if (old_log_count != new_log_count)
+		log_error("Mirror log status: %d of %d images failed%s",
+			  old_log_count - new_log_count, old_log_count,
+			  (!new_log_count) ? " - switching to core" : "");
+
+	/*
+	 * Find out our policies
+	 */
+	_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
+				      &replace_log, &replace_mirrors);
+
+	/*
+	 * First phase - remove faulty devices
+	 */
+	if (!(failed_pvs = _failed_pv_list(lv->vg)))
+		return_0;
+
+	/*
+	 * We must adjust the log first, or the entire mirror
+	 * will get stuck during a suspend.
+	 */
+	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
+		return 0;
+
+	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
+				    lp->mirrors, new_log_count, 0))
+		return 0;
+
+	/*
+	 * Second phase - replace faulty devices
+	 *
+	 * FIXME: It would be nice to do this all in one step, but
+	 *        for simplicity, we replace mimages first and then
+	 *        work on the log.
+	 */
+	if (replace_mirrors && (old_mimage_count != lp->mirrors)) {
+		lp->mirrors = old_mimage_count;
+		if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+					    old_mimage_count, new_log_count, 1))
+			return 0;
+	}
+
+	log_lv = first_seg(lv)->log_lv;
+	if (replace_log && (old_log_count != new_log_count)) {
 		/*
-		 * Ignore failure in upconversion if this is a policy-driven
-		 * action. If we got this far, only unexpected failures are
-		 * reported.
+		 * If we are up-converting the log from linear to
+		 * mirrored, then we must use '_lvconvert_mirrors_aux'
 		 */
-		if (arg_count(cmd, use_policies_ARG))
-			failure_code = 1;
-		/* Now replace missing devices. */
-		if (replace_log || replace_mirrors)
-			goto restart;
+		if ((new_log_count == 1) && (old_log_count > 1)) {
+			if (!_lvconvert_mirrors_aux(cmd, log_lv, lp, NULL,
+						    old_log_count, 0, 1))
+				return 0;
+		} else if (!_lv_update_log_type(cmd, lp, lv,
+						lp->pvh, new_log_count))
+			return 0;
 	}
 
+	return 1;
+}
+
+/*
+ * _lvconvert_mirrors
+ *
+ * Determine what is being done.  Are we doing a conversion, repair, or
+ * collapsing a stack?  Once determined, call helper functions.
+ */
+static int _lvconvert_mirrors(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	int repair = arg_count(cmd, repair_ARG);
+	uint32_t omc; /* old_mimage_count */
+	uint32_t olc; /* old_log_count */
+	uint32_t nmc; /* new_mimage_count */
+	uint32_t nlc; /* new_log_count */
+
+	/* Adjust mimage and/or log count */
+	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
+					     &omc, &olc, &nmc, &nlc))
+		return 0;
+
+	/* Nothing to do?  (Probably finishing collapse.) */
+	if ((omc == nmc) && (olc == nlc) && !repair)
+		return 1;
+
+	if (repair)
+		return _lvconvert_mirrors_repair(cmd, lv, lp, omc, olc);
+
+	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL, nmc, nlc, 0))
+		return 0;
+
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
-	r = 1;
-out:
 	backup(lv->vg);
-	return r;
+	return 1;
 }
 
 static int lvconvert_snapshot(struct cmd_context *cmd,
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -709,8 +709,8 @@ static int _split_mirror_images(struct l
  *
  * Arguments:
  *   num_removed:   the requested (maximum) number of mirrors to be removed
- *   removable_pvs: if not NULL, only mirrors using PVs in this list
- *                  will be removed
+ *   removable_pvs: if not NULL and list not empty, only mirrors using PVs
+ *                  in this list will be removed
  *   remove_log:    if non-zero, log_lv will be removed
  *                  (even if it's 0, log_lv will be removed if there is no
  *                   mirror remaining after the removal)
@@ -737,6 +737,7 @@ static int _remove_mirror_images(struct 
 {
 	uint32_t m;
 	uint32_t s;
+	int removable_pvs_specified;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *temp_layer_lv = NULL;
@@ -746,6 +747,9 @@ static int _remove_mirror_images(struct 
 	struct lv_list *lvl;
 	struct dm_list tmp_orphan_lvs;
 
+	removable_pvs_specified = (removable_pvs &&
+				   !dm_list_empty(removable_pvs)) ? 1 : 0;
+
 	if (removed)
 		*removed = 0;
 
@@ -755,13 +759,13 @@ static int _remove_mirror_images(struct 
 			 remove_log ? " and no log volume" : "");
 
 	if (collapse &&
-	    (removable_pvs || (old_area_count - num_removed != 1))) {
+	    (removable_pvs_specified || (old_area_count - num_removed != 1))) {
 		log_error("Incompatible parameters to _remove_mirror_images");
 		return 0;
 	}
 
 	/* Move removable_pvs to end of array */
-	if (removable_pvs) {
+	if (removable_pvs_specified) {
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);


