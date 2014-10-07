From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Oct 2014 00:16:16 +0000 (UTC)
Subject: master - toollib: Rewrite process_each_pv.
Message-ID: <20141007001616.350046006D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1a000a477558e157532d5f2cd2f9c9139d4f87c
Commit:        f1a000a477558e157532d5f2cd2f9c9139d4f87c
Parent:        aeb4d3b740434ed04993e9e7ef74f6e3462efb50
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 7 00:34:04 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 7 01:15:43 2014 +0100

toollib: Rewrite process_each_pv.

Process PVs by iterating through VGs, then iterating through
devices if the command needs to process non-PV devices.
The process_single function can always use the VG and PV args.

[Committed by agk with cosmetic changes and tweaks.]
---
 lib/metadata/pv_manip.c |   22 --
 lib/report/report.c     |    8 +-
 tools/pvdisplay.c       |   59 +++----
 tools/pvresize.c        |    2 +-
 tools/reporter.c        |   83 +++------
 tools/toollib.c         |  505 ++++++++++++++++++++++++++++++-----------------
 tools/toollib.h         |    6 +-
 tools/vgdisplay.c       |    2 +-
 tools/vgreduce.c        |    2 +-
 9 files changed, 379 insertions(+), 310 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 2cc7892..9a0f287 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -615,31 +615,12 @@ int pv_resize_single(struct cmd_context *cmd,
 		     struct physical_volume *pv,
 		     const uint64_t new_size)
 {
-	struct pv_list *pvl;
 	uint64_t size = 0;
 	int r = 0;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = pv->vg_name;
-	struct volume_group *old_vg = vg;
 	int vg_needs_pv_write = 0;
 
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		log_error("Unable to read volume group \"%s\".",
-			  vg_name);
-		return 0;
-	}
-
-	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-		log_error("Unable to find \"%s\" in volume group \"%s\"",
-			  pv_name, vg->name);
-		goto out;
-	}
-
-	pv = pvl->pv;
-
 	if (!archive(vg))
 		goto out;
 
@@ -698,9 +679,6 @@ out:
 	if (!r && vg_needs_pv_write)
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
-	unlock_vg(cmd, vg_name);
-	if (!old_vg)
-		release_vg(vg);
 	return r;
 }
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 69f75ed..3f63e1c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -272,7 +272,7 @@ static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 
-	if (vg->fid)
+	if (vg->fid && vg->fid->fmt)
 		return _string_disp(rh, mem, field, &vg->fid->fmt->name, private);
 
 	return _field_set_value(field, "", NULL);
@@ -1880,8 +1880,12 @@ int report_object(void *handle, struct volume_group *vg,
 		obj.label = &dummy_label;
 	}
 
+	/* Never report orphan VGs. */
+	if (vg && is_orphan_vg(vg->name))
+		obj.vg = NULL;
+
 	/* The two format fields might as well match. */
-	if (!vg && pv)
+	if (!obj.vg && pv)
 		_dummy_fid.fmt = pv->fmt;
 
 	return dm_report_object(handle, &obj);
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 773d9a9..d4cb516 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -19,36 +19,9 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     struct physical_volume *pv, void *handle)
 {
-	struct pv_list *pvl;
+	const char *pv_name = pv_dev_name(pv);
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
-	struct volume_group *old_vg = vg;
-
-	const char *pv_name = pv_dev_name(pv);
-	const char *vg_name = NULL;
-
-	if (!is_orphan(pv) && !vg) {
-		vg_name = pv_vg_name(pv);
-		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (ignore_vg(vg, vg_name, 0, &ret)) {
-			release_vg(vg);
-			stack;
-			return ret;
-		}
-
-		/*
-		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read_internal() path.
-		 */
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			ret = ECMD_FAILED;
-			goto out;
-		}
-
-		pv = pvl->pv;
-	}
 
 	if (is_orphan(pv))
 		size = pv_size(pv);
@@ -81,16 +54,14 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		pvdisplay_segments(pv);
 
 out:
-	if (vg_name)
-		unlock_vg(cmd, vg_name);
-	if (!old_vg)
-		release_vg(vg);
-
 	return ret;
 }
 
 int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
+	int lock_global = 0;
+	int ret;
+
 	if (arg_count(cmd, columns_ARG)) {
 		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG) ||
 		    arg_count(cmd, short_ARG)) {
@@ -122,6 +93,24 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, 0, 0, NULL,
-			       _pvdisplay_single);
+	/*
+	 * If the lock_type is LCK_VG_READ (used only in reporting commands),
+	 * we lock VG_GLOBAL to enable use of metadata cache.
+	 * This can pause alongide pvscan or vgscan process for a while.
+	 */
+	if (!lvmetad_active()) {
+		lock_global = 1;
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, NULL,
+			      _pvdisplay_single);
+
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
+	return ret;
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 1bb8a15..70b564d 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -61,7 +61,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, 0, &params,
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, &params,
 			      _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
diff --git a/tools/reporter.c b/tools/reporter.c
index 462ca8a..c55d653 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -209,61 +209,10 @@ static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	struct pv_list *pvl;
-	int ret = ECMD_PROCESSED;
-	const char *vg_name = NULL;
-	struct volume_group *old_vg = vg;
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (is_pv(pv) && !is_orphan(pv) && !vg) {
-		vg_name = pv_vg_name(pv);
-
-		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (ignore_vg(vg, vg_name, 0, &ret)) {
-			release_vg(vg);
-			stack;
-			return ret;
-		}
-
-		/*
-		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read.
-		*/
-		if (!is_missing_pv(pv)) {
-			if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
-				log_error("Unable to find \"%s\" in volume group \"%s\"",
-					  pv_dev_name(pv), vg->name);
-				ret = ECMD_FAILED;
-				goto out;
-			}
-		} else if (!(pvl = find_pv_in_vg_by_uuid(vg, &pv->id))) {
-			if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-				stack;
-				uuid[0] = '\0';
-			}
-
-			log_error("Unable to find missing PV %s in volume group %s",
-				  uuid, vg->name);
-			ret = ECMD_FAILED;
-			goto out;
-		}
-
-		pv = pvl->pv;
-	}
-
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL)) {
-		stack;
-		ret = ECMD_FAILED;
-	}
-
-out:
-	if (vg_name)
-		unlock_vg(cmd, vg_name);
-
-	if (!old_vg)
-		release_vg(vg);
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
+		return_ECMD_FAILED;
 
-	return ret;
+	return ECMD_PROCESSED;
 }
 
 static int _label_single(struct cmd_context *cmd, struct label *label,
@@ -286,7 +235,7 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		return ret;
 	}
 
-	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
+	return process_each_pv_in_vg(cmd, vg, handle, &_pvs_single);
 }
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
@@ -300,7 +249,7 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		return ret;
 	}
 
-	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
+	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
 
 static int _report(struct cmd_context *cmd, int argc, char **argv,
@@ -314,6 +263,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
 	unsigned args_are_pvs, lv_info_needed;
+	int lock_global = 0;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
@@ -460,6 +410,19 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	else if (report_type & LVS)
 		report_type = LVS;
 
+	/*
+	 * We lock VG_GLOBAL to enable use of metadata cache.
+	 * This can pause alongide pvscan or vgscan process for a while.
+	 */
+	if (args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
+	    !lvmetad_active()) {
+		lock_global = 1;
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
 	switch (report_type) {
 	case DEVTYPES:
 		r = _process_each_devtype(cmd, argc, report_handle);
@@ -483,7 +446,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case PVS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    0, report_handle, &_pvs_single);
+					    report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvs_in_vg);
@@ -496,7 +459,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case PVSEGS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    0, report_handle,
+					    report_handle,
 					    lv_info_needed ? &_pvsegs_with_lv_info_single
 							   : &_pvsegs_single);
 		else
@@ -508,6 +471,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	dm_report_output(report_handle);
 
 	dm_report_free(report_handle);
+
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
 	return r;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 4b0ba22..b65351e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -359,8 +359,8 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 
 	/* Ensure no overlap with existing areas */
 	dm_list_iterate_items(per, pe_ranges) {
-		if (((start < per->start) && (start + count - 1 >= per->start))
-		    || ((start >= per->start) &&
+		if (((start < per->start) && (start + count - 1 >= per->start)) ||
+		    ((start >= per->start) &&
 			(per->start + per->count - 1) >= start)) {
 			log_error("Overlapping PE ranges specified (%" PRIu32
 				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")"
@@ -383,14 +383,16 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 	return 1;
 }
 
-static int xstrtouint32(const char *s, char **p, int base, uint32_t *result)
+static int _xstrtouint32(const char *s, char **p, int base, uint32_t *result)
 {
 	unsigned long ul;
 
 	errno = 0;
 	ul = strtoul(s, p, base);
+
 	if (errno || *p == s || ul > UINT32_MAX)
 		return 0;
+
 	*result = ul;
 
 	return 1;
@@ -425,7 +427,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 
 		/* Start extent given? */
 		if (isdigit(*c)) {
-			if (!xstrtouint32(c, &endptr, 10, &start))
+			if (!_xstrtouint32(c, &endptr, 10, &start))
 				goto error;
 			c = endptr;
 			/* Just one number given? */
@@ -436,14 +438,14 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 		if (*c == '-') {
 			c++;
 			if (isdigit(*c)) {
-				if (!xstrtouint32(c, &endptr, 10, &end))
+				if (!_xstrtouint32(c, &endptr, 10, &end))
 					goto error;
 				c = endptr;
 			}
 		} else if (*c == '+') {	/* Length? */
 			c++;
 			if (isdigit(*c)) {
-				if (!xstrtouint32(c, &endptr, 10, &len))
+				if (!_xstrtouint32(c, &endptr, 10, &len))
 					goto error;
 				c = endptr;
 				end = start + (len ? (len - 1) : 0);
@@ -1370,7 +1372,8 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
  * Obtain complete list of VG name/vgid pairs known on the system.
  */
 static int _get_vgnameids_on_system(struct cmd_context *cmd,
-				    struct dm_list *vgnameids_on_system)
+				    struct dm_list *vgnameids_on_system,
+				    int include_internal)
 {
 	struct vgnameid_list *vgnl;
 	struct dm_list *vgids;
@@ -1385,7 +1388,7 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 	/*
 	 * Start with complete vgid list because multiple VGs might have same name.
 	 */
-	vgids = get_vgids(cmd, 0);
+	vgids = get_vgids(cmd, include_internal);
 	if (!vgids || dm_list_empty(vgids)) {
 		stack;
 		return ECMD_PROCESSED;
@@ -1527,7 +1530,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system)) != ECMD_PROCESSED)) {
+	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, 0)) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}
@@ -1861,7 +1864,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	 *   no VG names were given and the command defaults to processing all VGs.
 	*/
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system) != ECMD_PROCESSED)) {
+	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, 0) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}
@@ -1887,245 +1890,375 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 					 &arg_tags, handle, process_single_lv);
 }
 
-int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tagsl, void *handle,
-			  process_single_pv_fn_t process_single_pv)
+static int _get_arg_pvnames(struct cmd_context *cmd,
+			    int argc, char **argv,
+			    struct dm_list *arg_pvnames,
+			    struct dm_list *arg_tags)
 {
+	int opt = 0;
+	char *at_sign, *tagname;
+	char *arg_name;
 	int ret_max = ECMD_PROCESSED;
-	int ret;
-	struct pv_list *pvl;
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
-		if (tagsl && !dm_list_empty(tagsl) &&
-		    !str_list_match_list(tagsl, &pvl->pv->tags, NULL)) {
+	log_verbose("Using physical volume(s) on command line");
+
+	for (; opt < argc; opt++) {
+		arg_name = argv[opt];
+
+		dm_unescape_colons_and_at_signs(arg_name, NULL, &at_sign);
+		if (at_sign && (at_sign == arg_name)) {
+			tagname = at_sign + 1;
+
+			if (!validate_tag(tagname)) {
+				log_error("Skipping invalid tag %s", tagname);
+				if (ret_max < EINVALID_CMD_LINE)
+					ret_max = EINVALID_CMD_LINE;
+				continue;
+			}
+			if (!str_list_add(cmd->mem, arg_tags,
+					  dm_pool_strdup(cmd->mem, tagname))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
 			continue;
 		}
-		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
-			ret_max = ret;
+
+		if (!str_list_add(cmd->mem, arg_pvnames,
+				  dm_pool_strdup(cmd->mem, arg_name))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
 	}
 
 	return ret_max;
 }
 
-static int _process_all_devs(struct cmd_context *cmd, void *handle,
-			     process_single_pv_fn_t process_single_pv)
+static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
 {
-	struct pv_list *pvl;
-	struct dm_list *pvslist;
-	struct physical_volume *pv;
-	struct physical_volume pv_dummy;
 	struct dev_iter *iter;
 	struct device *dev;
-
-	int ret_max = ECMD_PROCESSED;
-	int ret;
+	struct device_list *devl;
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
-	if (!(pvslist = get_pvs(cmd)))
-		return_ECMD_FAILED;
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");
 		return ECMD_FAILED;
 	}
 
-	while ((dev = dev_iter_get(iter)))
-	{
-		if (sigint_caught()) {
-			ret_max = ECMD_FAILED;
-			stack;
-			break;
+	while ((dev = dev_iter_get(iter))) {
+		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
+			log_error("device_list alloc failed");
+			return ECMD_FAILED;
 		}
 
+		devl->dev = dev;
+		dm_list_add(all_devices, &devl->list);
+	}
+
+	dev_iter_destroy(iter);
+
+	return ECMD_PROCESSED;
+}
+
+static int _device_list_remove(struct dm_list *all_devices, struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, all_devices) {
+		if (devl->dev == dev) {
+			dm_list_del(&devl->list);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
+				void *handle, process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume pv_dummy;
+	struct physical_volume *pv;
+	struct device_list *devl;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	/*
+	 * Pretend that each device is a PV with dummy values.
+	 * FIXME Formalise this extension or find an alternative.
+	 */
+	dm_list_iterate_items(devl, all_devices) {
 		memset(&pv_dummy, 0, sizeof(pv_dummy));
 		dm_list_init(&pv_dummy.tags);
 		dm_list_init(&pv_dummy.segments);
-		pv_dummy.dev = dev;
+		pv_dummy.dev = devl->dev;
 		pv = &pv_dummy;
 
-		/* TODO use a device-indexed hash here */
-		dm_list_iterate_items(pvl, pvslist)
-			if (pvl->pv->dev == dev)
-				pv = pvl->pv;
+		log_very_verbose("Processing device %s", dev_name(devl->dev));
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
 
 		if (ret > ret_max)
 			ret_max = ret;
 
-		free_pv_fid(pv);
+		if (sigint_caught())
+			return_ECMD_FAILED;
 	}
 
-	dev_iter_destroy(iter);
-	dm_list_iterate_items(pvl, pvslist)
-		free_pv_fid(pvl->pv);
+	return ECMD_PROCESSED;
+}
+
+static int _process_pvs_in_vg(struct cmd_context *cmd,
+			      struct volume_group *vg,
+			      struct dm_list *all_devices,
+			      struct dm_list *arg_pvnames,
+			      struct dm_list *arg_tags,
+			      int process_all,
+			      int skip,
+			      void *handle,
+			      process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	const char *pv_name;
+	int process_pv;
+	int dev_found;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		pv_name = pv_dev_name(pv);
+
+		process_pv = process_all;
+
+		/* Remove each pvname as it is processed. */
+		if (!process_pv && !dm_list_empty(arg_pvnames) &&
+		    str_list_match_item(arg_pvnames, pv_name)) {
+			process_pv = 1;
+			str_list_del(arg_pvnames, pv_name);
+		}
+
+		if (!process_pv && !dm_list_empty(arg_tags) &&
+		    str_list_match_list(arg_tags, &pv->tags, NULL))
+			process_pv = 1;
+
+		if (process_pv) {
+			if (skip)
+				log_verbose("Skipping PV %s in VG %s", pv_name, vg->name);
+			else
+				log_very_verbose("Processing PV %s in VG %s", pv_name, vg->name);
+
+			dev_found = _device_list_remove(all_devices, pv->dev);
+
+			/*
+			 * FIXME PVs with no mdas may turn up in an orphan VG when
+			 * not using lvmetad as well as their correct VG.  They
+			 * will be missing from all_devices the second time
+			 * around but must not be processed twice or trigger a message.
+			 *
+			 * Missing PVs will also need processing even though they are
+			 * not present in all_devices.
+			 */
+			if (!dev_found && !is_missing_pv(pv)) {
+				log_verbose("Skipping PV %s in VG %s: not in device list", pv_name, vg->name);
+				continue;
+			}
+
+			if (!skip)
+				ret = process_single_pv(cmd, vg, pv, handle);
+
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
+		/*
+		 * When processing only specific PV names, we can quit
+		 * once they've all been found.
+	 	 */
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+			break;
+	}
 
 	return ret_max;
 }
 
 /*
- * If the lock_type is LCK_VG_READ (used only in reporting commands),
- * we lock VG_GLOBAL to enable use of metadata cache.
- * This can pause alongide pvscan or vgscan process for a while.
+ * Iterate through all PVs in each listed VG.  Process a PV if
+ * the name or tag matches arg_pvnames or arg_tags.  If both
+ * arg_pvnames and arg_tags are empty, then process all PVs.
+ * No PV should be processed more than once.
+ *
+ * Each PV is removed from arg_pvnames and all_devices when it is
+ * processed.  Any names remaining in arg_pvnames were not found, and
+ * should produce an error.  Any devices remaining in all_devices were
+ * not found and should be processed by process_all_devices().
  */
-int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t flags,
-		    int scan_label_only, void *handle,
-		    process_single_pv_fn_t process_single_pv)
+static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
+			       struct dm_list *all_vgnameids,
+			       struct dm_list *all_devices,
+			       struct dm_list *arg_pvnames,
+			       struct dm_list *arg_tags,
+			       int process_all,
+			       void *handle,
+			       process_single_pv_fn_t process_single_pv)
 {
-	int opt = 0;
+	struct volume_group *vg;
+	struct vgnameid_list *vgnl;
+	struct dm_str_list *sl;
+	const char *vg_name;
+	const char *vg_uuid;
+	int skip;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
-	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
 
-	struct pv_list *pvl;
-	struct physical_volume *pv;
-	struct dm_list *pvslist = NULL, *vgnames;
-	struct dm_list tagsl;
-	struct dm_str_list *sll;
-	char *at_sign, *tagname;
-	struct device *dev;
+	dm_list_iterate_items(vgnl, all_vgnameids) {
+		vg_name = vgnl->vg_name;
+		vg_uuid = vgnl->vgid;
+		ret = 0;
+		skip = 0;
 
-	dm_list_init(&tagsl);
+		vg = vg_read(cmd, vg_name, vg_uuid, flags);
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
+			if (ret > ret_max)
+				ret_max = ret;
+			skip = 1;
+		}
 
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
+		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
+					 process_all, skip, handle, process_single_pv);
+
+		if (ret > ret_max)
+			ret_max = ret;
+
+		if (skip)
+			release_vg(vg);
+		else
+			unlock_and_release_vg(cmd, vg, vg->name);
+
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
+		/* Quit early when possible. */
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+			return ret_max;
 	}
 
-	if (argc) {
-		log_verbose("Using physical volume(s) on command line");
-		for (; opt < argc; opt++) {
-			if (sigint_caught()) {
-				ret_max = ECMD_FAILED;
-				goto_out;
-			}
-			dm_unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
-			if (at_sign && (at_sign == argv[opt])) {
-				tagname = at_sign + 1;
-
-				if (!validate_tag(tagname)) {
-					log_error("Skipping invalid tag %s",
-						  tagname);
-					if (ret_max < EINVALID_CMD_LINE)
-						ret_max = EINVALID_CMD_LINE;
-					continue;
-				}
-				if (!str_list_add(cmd->mem, &tagsl,
-						  dm_pool_strdup(cmd->mem,
-							      tagname))) {
-					log_error("strlist allocation failed");
-					goto bad;
-				}
-				continue;
-			}
-			if (vg) {
-				if (!(pvl = find_pv_in_vg(vg, argv[opt]))) {
-					log_error("Physical Volume \"%s\" not "
-						  "found in Volume Group "
-						  "\"%s\"", argv[opt],
-						  vg->name);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-				pv = pvl->pv;
-			} else {
-				if (!pvslist) {
-					lvmcache_seed_infos_from_lvmetad(cmd);
-					if (!(pvslist = get_pvs(cmd)))
-						goto bad;
-				}
+	/* Return an error if a pvname arg was not found. */
+	dm_list_iterate_items(sl, arg_pvnames) {
+		log_error("Failed to find physical volume \"%s\"", sl->str);
+		ret_max = ECMD_FAILED;
+	}
 
-				if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
-					log_error("Failed to find device "
-						  "\"%s\"", argv[opt]);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
+	return ret_max;
+}
 
-				pv = NULL;
-				dm_list_iterate_items(pvl, pvslist)
-					if (pvl->pv->dev == dev)
-						pv = pvl->pv;
+int process_each_pv(struct cmd_context *cmd,
+		    int argc, char **argv,
+		    struct volume_group *vg,
+		    uint32_t flags,
+		    void *handle,
+		    process_single_pv_fn_t process_single_pv)
+{
+	struct dm_list arg_tags;    /* str_list */
+	struct dm_list arg_pvnames; /* str_list */
+	struct dm_list all_vgnameids; /* vgnameid_list */
+	struct dm_list all_devices;    /* device_list */
+	struct dm_str_list *sl;
+	int process_all_pvs;
+	int process_all_devices;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
 
-				if (!pv) {
-					log_error("Failed to find physical volume "
-						  "\"%s\"", argv[opt]);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-			}
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_pvnames);
+	dm_list_init(&all_vgnameids);
+	dm_list_init(&all_devices);
 
-			ret = process_single_pv(cmd, vg, pv, handle);
+	/*
+	 * Create two lists from argv:
+	 * arg_pvnames: pvs explicitly named in argv
+	 * arg_tags: tags explicitly named in argv
+	 */
+	if ((ret = _get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags)) != ECMD_PROCESSED)
+		return ret;
 
-			if (ret > ret_max)
-				ret_max = ret;
-		}
-		if (!dm_list_empty(&tagsl) && (vgnames = get_vgnames(cmd, 1)) &&
-			   !dm_list_empty(vgnames)) {
-			dm_list_iterate_items(sll, vgnames) {
-				if (sigint_caught()) {
-					ret_max = ECMD_FAILED;
-					goto_out;
-				}
-				vg = vg_read(cmd, sll->str, NULL, flags);
-				if (ignore_vg(vg, sll->str, 0, &ret_max)) {
-					release_vg(vg);
-					stack;
-					continue;
-				}
+	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
-				ret = process_each_pv_in_vg(cmd, vg, &tagsl,
-							    handle,
-							    process_single_pv);
-				if (ret > ret_max)
-					ret_max = ret;
+	process_all_devices = process_all_pvs &&
+			   (cmd->command->flags & ENABLE_ALL_DEVS) &&
+			   arg_count(cmd, all_ARG);
 
-				unlock_and_release_vg(cmd, vg, sll->str);
-			}
+	/*
+	 * If vg is set, the caller already selected, locked, and read one
+	 * VG.  This code is unused.
+	 */
+	if (vg) {
+		ret = _process_pvs_in_vg(cmd, vg, NULL,
+					 &arg_pvnames, &arg_tags, process_all_pvs, 0,
+					 handle, process_single_pv);
+
+		dm_list_iterate_items(sl, &arg_pvnames) {
+			log_error("Physical Volume \"%s\" not found in Volume Group \"%s\"",
+				  sl->str, vg->name);
+			ret = ECMD_FAILED;
 		}
-	} else {
-		if (vg) {
-			log_verbose("Using all physical volume(s) in "
-				    "volume group");
-			ret_max = process_each_pv_in_vg(cmd, vg, NULL, handle,
-							process_single_pv);
-		} else if (arg_count(cmd, all_ARG)) {
-			ret_max = _process_all_devs(cmd, handle, process_single_pv);
-		} else {
-			log_verbose("Scanning for physical volume names");
 
-			lvmcache_seed_infos_from_lvmetad(cmd);
-			if (!(pvslist = get_pvs(cmd)))
-				goto bad;
+		return ret;
+	}
 
-			dm_list_iterate_items(pvl, pvslist) {
-				if (sigint_caught()) {
-					ret_max = ECMD_FAILED;
-					goto_out;
-				}
-				ret = process_single_pv(cmd, NULL, pvl->pv,
-						     handle);
-				if (ret > ret_max)
-					ret_max = ret;
+	/*
+	 * If the caller wants to process all devices (not just PVs), then all PVs
+	 * from all VGs are processed first, removing them from all_devices.  Then
+	 * any devs remaining in all_devices are processed.
+	 */
+	if ((ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
 
-				free_pv_fid(pvl->pv);
-			}
-		}
+	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, 1) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
 	}
-out:
-	if (pvslist)
-		dm_list_iterate_items(pvl, pvslist)
-			free_pv_fid(pvl->pv);
 
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
+	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
+				  &arg_pvnames, &arg_tags, process_all_pvs,
+				  handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	if (sigint_caught())
+		return_ECMD_FAILED;
+
+	if (!process_all_devices)
+		goto_out;
+
+	ret = _process_device_list(cmd, &all_devices, handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+
+out:
 	return ret_max;
-bad:
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
+}
+
+int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			  void *handle, process_single_pv_fn_t process_single_pv)
+{
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+	struct pv_list *pvl;
 
-	return ECMD_FAILED;
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
+			ret_max = ret;
+	}
+
+	return ret_max;
 }
diff --git a/tools/toollib.h b/tools/toollib.h
index ae4b21e..483ac68 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -50,8 +50,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
-		    int scan_label_only, void *handle,
-		    process_single_pv_fn_t process_single_pv);
+		    void *handle, process_single_pv_fn_t process_single_pv);
 
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		       void *handle, process_single_label_fn_t process_single_label);
@@ -72,8 +71,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tagsl, void *handle,
-			  process_single_pv_fn_t process_single_pv);
+			  void *handle, process_single_pv_fn_t process_single_pv);
 
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 39cdaf3..95a5ebd 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -43,7 +43,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
-		process_each_pv_in_vg(cmd, vg, NULL, NULL,
+		process_each_pv_in_vg(cmd, vg, NULL,
 				      (process_single_pv_fn_t)pvdisplay_short);
 	}
 
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 970f61c..493a084 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -249,7 +249,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, READ_FOR_UPDATE, 0, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, READ_FOR_UPDATE, NULL,
 				      _vgreduce_single);
 
 	}


