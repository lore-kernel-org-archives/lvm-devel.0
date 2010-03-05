From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 5 Mar 2010 17:59:40 -0600
Subject: [PATCH 10 of 10] LVM: rework lvconvert_mirrors
Message-ID: <201003052359.o25Nxeg5012728@hydrogen.msp.redhat.com>
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

This last patch still needs a little bit of clean-up and
testing.  Please test and comment.

 brassow

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -696,8 +696,7 @@ static int _lv_update_log_type(struct cm
 
 	/* Remove an existing log completely */
 	if (!log_count) {
-		if (!remove_mirror_log(cmd, original_lv,
-				       lp->pv_count ? lp->pvh : NULL))
+		if (!remove_mirror_log(cmd, original_lv, lp->pvh))
 			return_0;
 		return 1;
 	}
@@ -753,9 +752,488 @@ static void _remove_missing_empty_pv(str
 	}
 }
 
-static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
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
+{
+	int repair = arg_count(cmd, repair_ARG);
+	const char *mirrorlog;
+	*old_mimage_count = lv_mirror_count(lv);
+	*old_log_count = _get_log_count(lv);
+
+	/*
+	 * Collapsing a stack of mirrors:
+	 *
+	 * If called with no argument, try collapsing the resync layers
+	 */
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
+	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
+	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
+		*new_mimage_count = *old_mimage_count;
+		*new_log_count = *old_log_count;
+
+		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
+			lp->need_polling = 1;
+		return 1;
+	}
+
+	if ((arg_count(cmd, mirrors_ARG) && repair) ||
+	    (arg_count(cmd, mirrorlog_ARG) && repair) ||
+	    (arg_count(cmd, corelog_ARG) && repair)) {
+		log_error("--repair cannot be used with --mirrors, --mirrorlog,"
+			  " or --corelog");
+		return 0;
+	}
+
+	/*
+	 * Adjusting mimage count?
+	 */
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
+		lp->mirrors = *old_mimage_count;
+	else if (lp->mirrors_sign == SIGN_PLUS)
+		lp->mirrors = *old_mimage_count + lp->mirrors;
+	else if (lp->mirrors_sign == SIGN_MINUS)
+		lp->mirrors = *old_mimage_count - lp->mirrors;
+	else
+		lp->mirrors += 1;
+
+	*new_mimage_count = lp->mirrors;
+
+	/* Too many mimages? */
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
+	/* Did the user try to subtract more legs than available? */
+	if (lp->mirrors < 1) {
+		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+			  lv->name, *old_mimage_count);
+		return 0;
+	}
+
+	/*
+	 * FIXME: It would be nice to say what we are adjusting to, but
+	 * I really don't know whether to specify the # of copies or mimages.
+	 */
+	if (*old_mimage_count != *new_mimage_count)
+		log_verbose("Adjusting mirror image count of %s", lv->name);
+
+	/*
+	 * Adjust log type
+	 */
+	*new_log_count = *old_log_count;
+	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
+		return 1;
+
+	if (arg_count(cmd, corelog_ARG))
+		*new_log_count = 0;
+
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+				  !*new_log_count ? "core" : DEFAULT_MIRRORLOG);
+
+	if (strcmp("core", mirrorlog) && !*new_log_count) {
+		log_error("--mirrorlog and --corelog are incompatible");
+		return 0;
+	}
+
+	if (!strcmp("mirrored", mirrorlog))
+		*new_log_count = 2;
+	else if (!strcmp("disk", mirrorlog))
+		*new_log_count = 1;
+	else if (!strcmp("core", mirrorlog))
+		*new_log_count = 0;
+	else {
+		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		return 0;
+	}
+
+	log_verbose("Setting logging type to %s", mirrorlog);
+
+	/*
+	 * Region size must not change on existing mirrors
+	 */
+	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
+	    (lp->region_size != first_seg(lv)->region_size)) {
+		log_error("Mirror log region size cannot be changed on "
+			  "an existing mirror.");
+		return 0;
+	}
+
+	/*
+	 * For the most part, we cannot handle multi-segment mirrors. Bail out
+	 * early if we have encountered one.
+	 */
+	if ((lv->status & MIRRORED) && dm_list_size(&lv->segments) != 1) {
+		log_error("Logical volume %s has multiple "
+			  "mirror segments.", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
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
+	}
+
+	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+						  lv->le_count,
+						  lp->region_size);
+
+	if (!operable_pvs)
+		operable_pvs = lp->pvh;
+
+	/*
+	 * Up-convert from linear to mirror
+	 */
+	if (!(lv->status & MIRRORED)) {
+		/* FIXME Share code with lvcreate */
+
+		/* FIXME Why is this restriction here?  Fix it! */
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (seg_is_striped(seg) && seg->area_count > 1) {
+				log_error("Mirrors of striped volumes are not yet supported.");
+				return 0;
+			}
+		}
+
+		/*
+		 * FIXME should we give not only lp->pvh, but also all PVs
+		 * currently taken by the mirror? Would make more sense from
+		 * user perspective.
+		 */
+		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, 1,
+				    region_size, new_log_count, operable_pvs,
+				    lp->alloc, MIRROR_BY_LV)) {
+			stack;
+			return failure_code;
+		}
+		if (lp->wait_completion)
+			lp->need_polling = 1;
+
+		goto out;
+	}
+
+	/*
+	 * Up-convert m-way mirror to n-way mirror
+	 */
+	if (new_mimage_count > old_mimage_count) {
+		if (lv->status & MIRROR_NOTSYNCED) {
+			log_error("Can't add mirror to out-of-sync mirrored "
+				  "LV: use lvchange --resync first.");
+			return 0;
+		}
+
+		/*
+		 * We allow snapshots of mirrors, but for now, we
+		 * do not allow up converting mirrors that are under
+		 * snapshots.  The layering logic is somewhat complex,
+		 * and preliminary test show that the conversion can't
+		 * seem to get the correct %'age of completion.
+		 */
+		if (lv_is_origin(lv)) {
+			log_error("Can't add additional mirror images to "
+				  "mirrors that are under snapshots");
+			return failure_code;
+		}
+
+		/*
+		 * Log addition/removal should be done before the layer
+		 * insertion to make the end result consistent with
+		 * linear-to-mirror conversion.
+		 */
+		if (!_lv_update_log_type(cmd, lp, lv, new_log_count)) {
+			stack;
+			return failure_code;
+		}
+
+		/* Insert a temporary layer for syncing,
+		 * only if the original lv is using disk log. */
+		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
+			log_error("Failed to insert resync layer");
+			return 0;
+		}
+
+		/* FIXME: can't have multiple mlogs. force corelog. */
+		if (!lv_add_mirrors(cmd, lv,
+				    new_mimage_count - old_mimage_count, 1,
+				    region_size, 0U, operable_pvs, lp->alloc,
+				    MIRROR_BY_LV)) {
+			layer_lv = seg_lv(first_seg(lv), 0);
+			if (!remove_layer_from_lv(lv, layer_lv) ||
+			    !deactivate_lv(cmd, layer_lv) ||
+			    !lv_remove(layer_lv) || !vg_write(lv->vg) ||
+			    !vg_commit(lv->vg)) {
+				log_error("ABORTING: Failed to remove "
+					  "temporary mirror layer %s.",
+					  layer_lv->name);
+				log_error("Manual cleanup with vgcfgrestore "
+					  "and dmsetup may be required.");
+				return 0;
+			}
+			stack;
+			return failure_code;
+		}
+		if (seg->log_lv)
+			lv->status |= CONVERTING;
+		lp->need_polling = 1;
+
+		goto out;
+	}
+
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
+		if (!_lv_update_log_type(cmd, lp, lv, new_log_count)) {
+			stack;
+			return failure_code;
+		}
+	}
+
+	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to lock %s", lv->name);
+		vg_revert(lv->vg);
+		goto out;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, lv))
+			stack;
+		goto_out;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", lv->name);
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		goto out;
+	}
+
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
+	if (replace_log && (old_log_count != new_log_count))
+		if (!_lvconvert_mirrors_aux(cmd, log_lv, lp, NULL,
+					    old_log_count, 0, 1))
+			return 0;
+
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
 			      struct lvconvert_params *lp)
 {
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
+	if (!lp->need_polling)
+		log_print("Logical volume %s converted.", lv->name);
+
+	backup(lv->vg);
+	return 1;
+}
+
+
+static int _lvconvert_mirrors_orig(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct lvconvert_params *lp)
+{
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
 	const char *mirrorlog;


