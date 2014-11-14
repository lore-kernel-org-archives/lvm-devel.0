From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:39 +0000 (UTC)
Subject: master - cleanup: add '.' to log messages
Message-ID: <20141114171739.10D4160DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38200c2000e5499a6421f477305464f9772b8d57
Commit:        38200c2000e5499a6421f477305464f9772b8d57
Parent:        f36080a05d987d359e1c09e64d1222636dcd96ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 16:08:27 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:12:35 2014 +0100

cleanup: add '.' to log messages

---
 lib/metadata/metadata.c |    2 +-
 tools/toollib.c         |  146 +++++++++++++++++++++++-----------------------
 2 files changed, 74 insertions(+), 74 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0c5b0d6..26e43b4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3677,7 +3677,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 
 out:
 	if (!*consistent && (warn_flags & WARN_INCONSISTENT))
-		log_warn("WARNING: Volume Group %s is not consistent", vgname);
+		log_warn("WARNING: Volume Group %s is not consistent.", vgname);
 
 	return vg;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index c3d6852..02a1bbf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -137,7 +137,7 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 
 			if (!dm_split_lvm_name(cmd->mem, vg_name, &vgname, &lvname, &layer) ||
 			    *layer) {
-				log_error("skip_dev_dir: Couldn't split up device name %s",
+				log_error("skip_dev_dir: Couldn't split up device name %s.",
 					  vg_name);
 				return vg_name;
 			}
@@ -146,7 +146,7 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			    dm_snprintf(vglv, vglv_sz, "%s%s%s", vgname,
 					*lvname ? "/" : "",
 					lvname) < 0) {
-				log_error("vg/lv string alloc failed");
+				log_error("vg/lv string alloc failed.");
 				return vg_name;
 			}
 			return vglv;
@@ -250,7 +250,7 @@ static const char *_extract_vgname(struct cmd_context *cmd, const char *lv_name,
 			st++;
 
 	if (!st || strchr(st, '/')) {
-		log_error("\"%s\": Invalid path for Logical Volume",
+		log_error("\"%s\": Invalid path for Logical Volume.",
 			  lv_name);
 		return 0;
 	}
@@ -281,8 +281,8 @@ static const char *_default_vgname(struct cmd_context *cmd)
 	vg_path = skip_dev_dir(cmd, vg_path, NULL);
 
 	if (strchr(vg_path, '/')) {
-		log_error("Environment Volume Group in LVM_VG_NAME invalid: "
-			  "\"%s\"", vg_path);
+		log_error("\"%s\": Invalid environment var LVM_VG_NAME set for Volume Group.",
+			  vg_path);
 		return 0;
 	}
 
@@ -306,7 +306,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 
 	if (!(vg_name = _default_vgname(cmd))) {
 		if (lv_name)
-			log_error("Path required for Logical Volume \"%s\"",
+			log_error("Path required for Logical Volume \"%s\".",
 				  lv_name);
 		return NULL;
 	}
@@ -323,7 +323,7 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 	struct pe_range *per;
 
 	log_debug("Adding PE range: start PE %" PRIu32 " length %" PRIu32
-		  " on %s", start, count, pvname);
+		  " on %s.", start, count, pvname);
 
 	/* Ensure no overlap with existing areas */
 	dm_list_iterate_items(per, pe_ranges) {
@@ -332,7 +332,7 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 			(per->start + per->count - 1) >= start)) {
 			log_error("Overlapping PE ranges specified (%" PRIu32
 				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")"
-				  " on %s",
+				  " on %s.",
 				  start, start + count - 1, per->start,
 				  per->start + per->count - 1, pvname);
 			return 0;
@@ -340,7 +340,7 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 	}
 
 	if (!(per = dm_pool_alloc(mem, sizeof(*per)))) {
-		log_error("Allocation of list failed");
+		log_error("Allocation of list failed.");
 		return 0;
 	}
 
@@ -425,7 +425,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 
 		if ((start > end) || (end > size - 1)) {
 			log_error("PE range error: start extent %" PRIu32 " to "
-				  "end extent %" PRIu32, start, end);
+				  "end extent %" PRIu32 ".", start, end);
 			return 0;
 		}
 
@@ -437,7 +437,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 	return 1;
 
       error:
-	log_error("Physical extent parsing error at %s", c);
+	log_error("Physical extent parsing error at %s.", c);
 	return 0;
 }
 
@@ -480,7 +480,7 @@ static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 		memcpy(new_pvl, pvl, sizeof(*new_pvl));
 
 		if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
-			log_error("Allocation of pe_ranges list failed");
+			log_error("Allocation of pe_ranges list failed.");
 			return 0;
 		}
 		dm_list_init(pe_ranges);
@@ -522,7 +522,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 		if (at_sign && (at_sign == argv[i])) {
 			tagname = at_sign + 1;
 			if (!validate_tag(tagname)) {
-				log_error("Skipping invalid tag %s", tagname);
+				log_error("Skipping invalid tag %s.", tagname);
 				continue;
 			}
 			dm_list_iterate_items(pvl, &vg->pvs) {
@@ -541,13 +541,13 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 
 		if (colon && !(pvname = dm_pool_strndup(mem, pvname,
 					(unsigned) (colon - pvname)))) {
-			log_error("Failed to clone PV name");
+			log_error("Failed to clone PV name.");
 			return NULL;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pvname))) {
 			log_error("Physical Volume \"%s\" not found in "
-				  "Volume Group \"%s\"", pvname, vg->name);
+				  "Volume Group \"%s\".", pvname, vg->name);
 			return NULL;
 		}
 		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r))
@@ -555,7 +555,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 	}
 
 	if (dm_list_empty(r))
-		log_error("No specified PVs have space available");
+		log_error("No specified PVs have space available.");
 
 	return dm_list_empty(r) ? NULL : r;
 }
@@ -567,7 +567,7 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 
 	/* Build up list of PVs */
 	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed");
+		log_error("Allocation of list failed.");
 		return NULL;
 	}
 	dm_list_init(r);
@@ -585,7 +585,7 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 	return r;
 }
 
-const char _pe_size_may_not_be_negative_msg[] = "Physical extent size may not be negative";
+const char _pe_size_may_not_be_negative_msg[] = "Physical extent size may not be negative.";
 
 int vgcreate_params_set_defaults(struct cmd_context *cmd,
 				 struct vgcreate_params *vp_def,
@@ -653,18 +653,18 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	}
 
 	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
-		log_error("Physical extent size cannot be larger than %s",
+		log_error("Physical extent size cannot be larger than %s.",
 				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
 		return 0;
 	}
 
 	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Max Logical Volumes may not be negative");
+		log_error("Max Logical Volumes may not be negative.");
 		return 0;
 	}
 
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Max Physical Volumes may not be negative");
+		log_error("Max Physical Volumes may not be negative.");
 		return 0;
 	}
 
@@ -806,18 +806,18 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 
 	if (lv_is_pvmove(lv) &&
 	    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
-		log_verbose("Spawning background pvmove process for %s",
+		log_verbose("Spawning background pvmove process for %s.",
 			    pvname);
 		pvmove_poll(cmd, pvname, 1);
 	} else if (lv_is_locked(lv) &&
 		   (pvname = get_pvmove_pvname_from_lv(lv))) {
-		log_verbose("Spawning background pvmove process for %s",
+		log_verbose("Spawning background pvmove process for %s.",
 			    pvname);
 		pvmove_poll(cmd, pvname, 1);
 	}
 
 	if (lv_is_converting(lv) || lv_is_merging(lv)) {
-		log_verbose("Spawning background lvconvert process for %s",
+		log_verbose("Spawning background lvconvert process for %s.",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
 	}
@@ -834,7 +834,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 			     struct pvcreate_params *pp)
 {
 	if (!argc) {
-		log_error("Please enter a physical volume path");
+		log_error("Please enter a physical volume path.");
 		return 0;
 	}
 
@@ -842,7 +842,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 	pp->force = (force_t) arg_count(cmd, force_ARG);
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu",
+		log_error("labelsector must be less than %lu.",
 			  LABEL_SCAN_SECTORS);
 		return 0;
 	} else {
@@ -883,7 +883,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 	pp->zero = arg_int_value(cmd, zero_ARG, 1);
 
 	if (arg_sign_value(cmd, dataalignment_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical volume data alignment may not be negative");
+		log_error("Physical volume data alignment may not be negative.");
 		return 0;
 	}
 	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
@@ -917,12 +917,12 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 	}
 
 	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative");
+		log_error("Metadata size may not be negative.");
 		return 0;
 	}
 
 	if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Bootloader area size may not be negative");
+		log_error("Bootloader area size may not be negative.");
 		return 0;
 	}
 
@@ -947,7 +947,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	if (arg_count(cmd, monitor_ARG) &&
 	    (arg_count(cmd, ignoremonitoring_ARG) ||
 	     arg_count(cmd, sysinit_ARG))) {
-		log_error("--ignoremonitoring or --sysinit option not allowed with --monitor option");
+		log_error("--ignoremonitoring or --sysinit option not allowed with --monitor option.");
 		return 0;
 	}
 
@@ -985,7 +985,7 @@ int get_pool_params(struct cmd_context *cmd,
 		if (arg_is_set(cmd, discards_ARG)) {
 			*passed_args |= PASS_ARG_DISCARDS;
 			*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
-			log_very_verbose("Setting pool discards: %s",
+			log_very_verbose("Setting pool discards to %s.",
 					 get_pool_discards_name(*discards));
 		}
 	}
@@ -1011,7 +1011,7 @@ int get_pool_params(struct cmd_context *cmd,
 		if (!validate_pool_chunk_size(cmd, segtype, *chunk_size))
 			return_0;
 
-		log_very_verbose("Setting pool chunk size: %s",
+		log_very_verbose("Setting pool chunk size to %s.",
 				 display_size(cmd, *chunk_size));
 	}
 
@@ -1046,25 +1046,25 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 				   uint32_t *stripe_size)
 {
 	if (*stripes == 1 && *stripe_size) {
-		log_print_unless_silent("Ignoring stripesize argument with single stripe");
+		log_print_unless_silent("Ignoring stripesize argument with single stripe.");
 		*stripe_size = 0;
 	}
 
 	if (*stripes > 1 && !*stripe_size) {
 		*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-		log_print_unless_silent("Using default stripesize %s",
+		log_print_unless_silent("Using default stripesize %s.",
 			  display_size(cmd, (uint64_t) *stripe_size));
 	}
 
 	if (*stripes < 1 || *stripes > MAX_STRIPES) {
-		log_error("Number of stripes (%d) must be between %d and %d",
+		log_error("Number of stripes (%d) must be between %d and %d.",
 			  *stripes, 1, MAX_STRIPES);
 		return 0;
 	}
 
 	if (*stripes > 1 && (*stripe_size < STRIPE_SIZE_MIN ||
 			     *stripe_size & (*stripe_size - 1))) {
-		log_error("Invalid stripe size %s",
+		log_error("Invalid stripe size %s.",
 			  display_size(cmd, (uint64_t) *stripe_size));
 		return 0;
 	}
@@ -1086,12 +1086,12 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 	if (*stripe_size) {
 		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative stripesize is invalid");
+			log_error("Negative stripesize is invalid.");
 			return 0;
 		}
 
 		if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-			log_error("Stripe size cannot be larger than %s",
+			log_error("Stripe size cannot be larger than %s.",
 				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 			return 0;
 		}
@@ -1105,7 +1105,7 @@ static int _pv_change_tag(struct physical_volume *pv, const char *tag, int addta
 {
 	if (addtag) {
 		if (!str_list_add(pv->fmt->cmd->mem, &pv->tags, tag)) {
-			log_error("Failed to add tag %s to physical volume %s",
+			log_error("Failed to add tag %s to physical volume %s.",
 				  tag, pv_dev_name(pv));
 			return 0;
 		}
@@ -1127,7 +1127,7 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 
 		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
-			log_error("Failed to get tag");
+			log_error("Failed to get tag.");
 			return 0;
 		}
 
@@ -1157,13 +1157,13 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 		for (; opt < argc; opt++) {
 			if (!(dev = dev_cache_get(argv[opt], cmd->full_filter))) {
 				log_error("Failed to find device "
-					  "\"%s\"", argv[opt]);
+					  "\"%s\".", argv[opt]);
 				ret_max = ECMD_FAILED;
 				continue;
 			}
 
 			if (!label_read(dev, &label, 0)) {
-				log_error("No physical volume label read from %s",
+				log_error("No physical volume label read from %s.",
 					  argv[opt]);
 				ret_max = ECMD_FAILED;
 				continue;
@@ -1182,7 +1182,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 	}
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
-		log_error("dev_iter creation failed");
+		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}
 
@@ -1297,7 +1297,7 @@ int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 			*vg_name = vgname;
 		else if (strcmp(vgname, *vg_name)) {
 			log_error("Please use a single volume group name "
-				  "(\"%s\" or \"%s\")", vgname, *vg_name);
+				  "(\"%s\" or \"%s\").", vgname, *vg_name);
 			return 0;
 		}
 
@@ -1350,7 +1350,7 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	const char *vg_name;
 
-	log_verbose("Using volume group(s) on command line");
+	log_verbose("Using volume group(s) on command line.");
 
 	for (; opt < argc; opt++) {
 		vg_name = argv[opt];
@@ -1363,7 +1363,7 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 			}
 			if (!str_list_add(cmd->mem, arg_tags,
 					  dm_pool_strdup(cmd->mem, vg_name + 1))) {
-				log_error("strlist allocation failed");
+				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
 			continue;
@@ -1371,14 +1371,14 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 
 		vg_name = skip_dev_dir(cmd, vg_name, NULL);
 		if (strchr(vg_name, '/')) {
-			log_error("Invalid volume group name: %s", vg_name);
+			log_error("Invalid volume group name %s.", vg_name);
 			if (ret_max < EINVALID_CMD_LINE)
 				ret_max = EINVALID_CMD_LINE;
 			continue;
 		}
 		if (!str_list_add(cmd->mem, arg_vgnames,
 				  dm_pool_strdup(cmd->mem, vg_name))) {
-			log_error("strlist allocation failed");
+			log_error("strlist allocation failed.");
 			return ECMD_FAILED;
 		}
 	}
@@ -1403,7 +1403,7 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 	if (only_this_vgname) {
 		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
 		if (!vgnl) {
-			log_error("name_id_list allocation failed");
+			log_error("name_id_list allocation failed.");
 			return ECMD_FAILED;
 		}
 
@@ -1414,7 +1414,7 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 		return ECMD_PROCESSED;
 	}
 
-	log_verbose("Finding all volume groups");
+	log_verbose("Finding all volume groups.");
 
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
 		stack;
@@ -1434,7 +1434,7 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 			continue;
 
 		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
-			log_error("vgnameid_list allocation failed");
+			log_error("vgnameid_list allocation failed.");
 			return ECMD_FAILED;
 		}
 
@@ -1515,7 +1515,7 @@ static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *s
 
 		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
 		if (!vgnl) {
-			log_error("vgnameid_list allocation failed");
+			log_error("vgnameid_list allocation failed.");
 			return ECMD_FAILED;
 		}
 
@@ -1656,7 +1656,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			 (!tags_supplied || !str_list_match_list(tags_in, &lvl->lv->tags, NULL)))
 			continue;
 
-		log_very_verbose("Processing LV %s in VG %s", lvl->lv->name, vg->name);
+		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
 		if ((ret = process_single_lv(cmd, lvl->lv, handle)) != ECMD_PROCESSED)
 			stack;
@@ -1708,7 +1708,7 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	const char *vgname_def;
 	unsigned dev_dir_found;
 
-	log_verbose("Using logical volume(s) on command line");
+	log_verbose("Using logical volume(s) on command line.");
 
 	for (; opt < argc; opt++) {
 		lv_name = argv[opt];
@@ -1719,12 +1719,12 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 
 		if (*vgname == '@') {
 			if (!validate_tag(vgname + 1)) {
-				log_error("Skipping invalid tag %s", vgname);
+				log_error("Skipping invalid tag %s.", vgname);
 				continue;
 			}
 			if (!str_list_add(cmd->mem, arg_tags,
 					  dm_pool_strdup(cmd->mem, vgname + 1))) {
-				log_error("strlist allocation failed");
+				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
 			continue;
@@ -1734,7 +1734,7 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 		vgname = skip_dev_dir(cmd, vgname, &dev_dir_found);
 
 		if (*vgname == '/') {
-			log_error("\"%s\": Invalid path for Logical Volume",
+			log_error("\"%s\": Invalid path for Logical Volume.",
 				  argv[opt]);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
@@ -1761,25 +1761,25 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 
 		if (!str_list_add(cmd->mem, arg_vgnames,
 				  dm_pool_strdup(cmd->mem, vgname))) {
-			log_error("strlist allocation failed");
+			log_error("strlist allocation failed.");
 			return ECMD_FAILED;
 		}
 
 		if (!lv_name) {
 			if (!str_list_add(cmd->mem, arg_lvnames,
 					  dm_pool_strdup(cmd->mem, vgname))) {
-				log_error("strlist allocation failed");
+				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
 		} else {
 			vglv_sz = strlen(vgname) + strlen(lv_name) + 2;
 			if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
 			    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lv_name) < 0) {
-				log_error("vg/lv string alloc failed");
+				log_error("vg/lv string alloc failed.");
 				return ECMD_FAILED;
 			}
 			if (!str_list_add(cmd->mem, arg_lvnames, vglv)) {
-				log_error("strlist allocation failed");
+				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
 		}
@@ -1840,7 +1840,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			    strlen(vg_name) == (size_t) (lvn - vgn)) {
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem, lvn + 1))) {
-					log_error("strlist allocation failed");
+					log_error("strlist allocation failed.");
 					return ECMD_FAILED;
 				}
 			}
@@ -1938,7 +1938,7 @@ static int _get_arg_pvnames(struct cmd_context *cmd,
 	char *arg_name;
 	int ret_max = ECMD_PROCESSED;
 
-	log_verbose("Using physical volume(s) on command line");
+	log_verbose("Using physical volume(s) on command line.");
 
 	for (; opt < argc; opt++) {
 		arg_name = argv[opt];
@@ -1948,14 +1948,14 @@ static int _get_arg_pvnames(struct cmd_context *cmd,
 			tagname = at_sign + 1;
 
 			if (!validate_tag(tagname)) {
-				log_error("Skipping invalid tag %s", tagname);
+				log_error("Skipping invalid tag %s.", tagname);
 				if (ret_max < EINVALID_CMD_LINE)
 					ret_max = EINVALID_CMD_LINE;
 				continue;
 			}
 			if (!str_list_add(cmd->mem, arg_tags,
 					  dm_pool_strdup(cmd->mem, tagname))) {
-				log_error("strlist allocation failed");
+				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
 			continue;
@@ -1963,7 +1963,7 @@ static int _get_arg_pvnames(struct cmd_context *cmd,
 
 		if (!str_list_add(cmd->mem, arg_pvnames,
 				  dm_pool_strdup(cmd->mem, arg_name))) {
-			log_error("strlist allocation failed");
+			log_error("strlist allocation failed.");
 			return ECMD_FAILED;
 		}
 	}
@@ -1981,13 +1981,13 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
+		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}
 
 	while ((dev = dev_iter_get(iter))) {
 		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
-			log_error("device_list alloc failed");
+			log_error("device_list alloc failed.");
 			goto out;
 		}
 
@@ -2038,7 +2038,7 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 		pv_dummy.dev = devl->dev;
 		pv = &pv_dummy;
 
-		log_very_verbose("Processing device %s", dev_name(devl->dev));
+		log_very_verbose("Processing device %s.", dev_name(devl->dev));
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
 
@@ -2089,9 +2089,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 
 		if (process_pv) {
 			if (skip)
-				log_verbose("Skipping PV %s in VG %s", pv_name, vg->name);
+				log_verbose("Skipping PV %s in VG %s.", pv_name, vg->name);
 			else
-				log_very_verbose("Processing PV %s in VG %s", pv_name, vg->name);
+				log_very_verbose("Processing PV %s in VG %s.", pv_name, vg->name);
 
 			dev_found = _device_list_remove(all_devices, pv->dev);
 
@@ -2105,7 +2105,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			 * not present in all_devices.
 			 */
 			if (!dev_found && !is_missing_pv(pv)) {
-				log_verbose("Skipping PV %s in VG %s: not in device list", pv_name, vg->name);
+				log_verbose("Skipping PV %s in VG %s: not in device list.", pv_name, vg->name);
 				continue;
 			}
 
@@ -2188,7 +2188,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 
 	/* Return an error if a pvname arg was not found. */
 	dm_list_iterate_items(sl, arg_pvnames) {
-		log_error("Failed to find physical volume \"%s\"", sl->str);
+		log_error("Failed to find physical volume \"%s\".", sl->str);
 		ret_max = ECMD_FAILED;
 	}
 


