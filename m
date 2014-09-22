From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:03 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: rewrite process_each_pv
Message-ID: <20140922154003.5AB0B60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c88ae037e5e1e860cd58e873a90dc3e3cd0bbe1
Commit:        7c88ae037e5e1e860cd58e873a90dc3e3cd0bbe1
Parent:        84b51035909394ad52010a4f7aaa5f9da22b0faa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 29 16:32:46 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: rewrite process_each_pv

Process pvs by iterating through vgs, then iterating through
devs if the command wants to process non-pv devices.  The
process_single function can always use the vg and pv args.
---
 lib/metadata/pv_manip.c |   22 --
 lib/metadata/vg.c       |    1 +
 lib/report/columns.h    |    4 +-
 lib/report/report.c     |   37 +++-
 tools/pvdisplay.c       |   59 ++---
 tools/pvresize.c        |    2 +-
 tools/reporter.c        |   83 ++-----
 tools/toollib.c         |  614 ++++++++++++++++++++++++++++-------------------
 tools/toollib.h         |    8 +-
 tools/vgdisplay.c       |    2 +-
 tools/vgreduce.c        |    2 +-
 11 files changed, 460 insertions(+), 374 deletions(-)

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
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 7b6cb85..1d2491d 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -44,6 +44,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	vg->cmd = cmd;
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
+	vg->system_id = (char *) "";
 
 	if (!(vg->hostnames = dm_hash_create(16))) {
 		log_error("Failed to allocate VG hostname hashtable.");
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 796ac4e..4035758 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -120,7 +120,7 @@ FIELD(PVS, pv, SIZ, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootl
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
-FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
+FIELD(VGS, vg, STR, "VG", cmd, 4, vgname, vg_name, "Name.", 0)
 FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
 FIELD(VGS, vg, STR, "VPerms", cmd, 10, vgpermissions, vg_permissions, "VG permissions.", 0)
 FIELD(VGS, vg, BIN, "Extendable", cmd, 10, vgextendable, vg_extendable, "Set if VG is extendable.", 0)
@@ -130,7 +130,7 @@ FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_polic
 FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
-FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
+FIELD(VGS, vg, STR, "SYS ID", cmd, 6, vgsysid, vg_sysid, "System ID indicating when and where it was created.", 0)
 FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
 FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index c34aa5e..c0e0b47 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -386,6 +386,36 @@ static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	return _field_set_value(field, "", NULL);
 }
 
+static int _vgname_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+
+	if (!is_orphan_vg(vg->name))
+		return dm_report_field_string(rh, field, &vg->name);
+
+	return _field_set_value(field, "", NULL);
+}
+
+static int _vgsysid_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	const char *sysid;
+
+	if (!vg->system_id)
+		return _field_set_value(field, "", NULL);
+
+	if (!(sysid = dm_pool_strdup(mem, vg->system_id))) {
+		log_error("dm_pool_strdup failed");
+		return 0;
+	}
+
+	return dm_report_field_string(rh, field, &sysid);
+}
+
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
@@ -1695,7 +1725,10 @@ static void *_obj_get_vg(void *obj)
 {
 	struct volume_group *vg = ((struct lvm_report_object *)obj)->vg;
 
-	return vg ? vg : &_dummy_vg;
+	if (!vg || is_orphan_vg(vg->name))
+		return &_dummy_vg;
+
+	return vg;
 }
 
 static void *_obj_get_lv(void *obj)
@@ -1863,7 +1896,7 @@ int report_object(void *handle, struct volume_group *vg,
 	}
 
 	/* The two format fields might as well match. */
-	if (!vg && pv)
+	if ((!vg || is_orphan_vg(vg->name)) && pv)
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
index 462ca8a..32a0b05 100644
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
@@ -333,6 +283,19 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (args_are_pvs && argc)
 		cmd->filter->wipe(cmd->filter);
 
+	/*
+	 * This moved here as part of factoring it out of process_each_pv.
+	 * We lock VG_GLOBAL to enable use of metadata cache.
+	 * This can pause alongide pvscan or vgscan process for a while.
+	 */
+	if ((report_type == PVS || report_type == PVSEGS) && !lvmetad_active()) {
+		lock_global = 1;
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
 	switch (report_type) {
 	case DEVTYPES:
 		keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
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
index d222da9..b1ec7c5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -264,249 +264,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	return ret_max;
 }
 
-int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tagsl, void *handle,
-			  process_single_pv_fn_t process_single_pv)
-{
-	int ret_max = ECMD_PROCESSED;
-	int ret;
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
-		if (tagsl && !dm_list_empty(tagsl) &&
-		    !str_list_match_list(tagsl, &pvl->pv->tags, NULL)) {
-			continue;
-		}
-		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
-			ret_max = ret;
-	}
-
-	return ret_max;
-}
-
-static int _process_all_devs(struct cmd_context *cmd, void *handle,
-			     process_single_pv_fn_t process_single_pv)
-{
-	struct pv_list *pvl;
-	struct dm_list *pvslist;
-	struct physical_volume *pv;
-	struct physical_volume pv_dummy;
-	struct dev_iter *iter;
-	struct device *dev;
-
-	int ret_max = ECMD_PROCESSED;
-	int ret;
-
-	lvmcache_seed_infos_from_lvmetad(cmd);
-	if (!(pvslist = get_pvs(cmd)))
-		return_ECMD_FAILED;
-
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
-		return ECMD_FAILED;
-	}
-
-	while ((dev = dev_iter_get(iter)))
-	{
-		if (sigint_caught()) {
-			ret_max = ECMD_FAILED;
-			stack;
-			break;
-		}
-
-		memset(&pv_dummy, 0, sizeof(pv_dummy));
-		dm_list_init(&pv_dummy.tags);
-		dm_list_init(&pv_dummy.segments);
-		pv_dummy.dev = dev;
-		pv = &pv_dummy;
-
-		/* TODO use a device-indexed hash here */
-		dm_list_iterate_items(pvl, pvslist)
-			if (pvl->pv->dev == dev)
-				pv = pvl->pv;
-
-		ret = process_single_pv(cmd, NULL, pv, handle);
-
-		if (ret > ret_max)
-			ret_max = ret;
-
-		free_pv_fid(pv);
-	}
-
-	dev_iter_destroy(iter);
-	dm_list_iterate_items(pvl, pvslist)
-		free_pv_fid(pvl->pv);
-
-	return ret_max;
-}
-
-/*
- * If the lock_type is LCK_VG_READ (used only in reporting commands),
- * we lock VG_GLOBAL to enable use of metadata cache.
- * This can pause alongide pvscan or vgscan process for a while.
- */
-int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t flags,
-		    int scan_label_only, void *handle,
-		    process_single_pv_fn_t process_single_pv)
-{
-	int opt = 0;
-	int ret_max = ECMD_PROCESSED;
-	int ret;
-	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
-
-	struct pv_list *pvl;
-	struct physical_volume *pv;
-	struct dm_list *pvslist = NULL, *vgnames;
-	struct dm_list tagsl;
-	struct dm_str_list *sll;
-	char *at_sign, *tagname;
-	struct device *dev;
-
-	dm_list_init(&tagsl);
-
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
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
-
-				if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
-					log_error("Failed to find device "
-						  "\"%s\"", argv[opt]);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-
-				pv = NULL;
-				dm_list_iterate_items(pvl, pvslist)
-					if (pvl->pv->dev == dev)
-						pv = pvl->pv;
-
-				if (!pv) {
-					log_error("Failed to find physical volume "
-						  "\"%s\"", argv[opt]);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-			}
-
-			ret = process_single_pv(cmd, vg, pv, handle);
-
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
-
-				ret = process_each_pv_in_vg(cmd, vg, &tagsl,
-							    handle,
-							    process_single_pv);
-				if (ret > ret_max)
-					ret_max = ret;
-
-				unlock_and_release_vg(cmd, vg, sll->str);
-			}
-		}
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
-
-			lvmcache_seed_infos_from_lvmetad(cmd);
-			if (!(pvslist = get_pvs(cmd)))
-				goto bad;
-
-			dm_list_iterate_items(pvl, pvslist) {
-				if (sigint_caught()) {
-					ret_max = ECMD_FAILED;
-					goto_out;
-				}
-				ret = process_single_pv(cmd, NULL, pvl->pv,
-						     handle);
-				if (ret > ret_max)
-					ret_max = ret;
-
-				free_pv_fid(pvl->pv);
-			}
-		}
-	}
-out:
-	if (pvslist)
-		dm_list_iterate_items(pvl, pvslist)
-			free_pv_fid(pvl->pv);
-
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
-	return ret_max;
-bad:
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
-
-	return ECMD_FAILED;
-}
-
 /*
  * Determine volume group name from a logical volume name
  */
@@ -1511,7 +1268,8 @@ static int get_arg_vgnames(struct cmd_context *cmd,
  * duplicate vg names.)
  */
 
-static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
+static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames,
+			   int include_orphan)
 {
 	int ret_max = ECMD_PROCESSED;
 	struct name_id_list *nl;
@@ -1524,7 +1282,7 @@ static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
 		stack;
 
-	vgids = get_vgids(cmd, 0);
+	vgids = get_vgids(cmd, include_orphan);
 
 	if (!vgids || dm_list_empty(vgids))
 		goto out;
@@ -1660,7 +1418,7 @@ int process_each_vg(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames);
+		ret = get_all_vgnames(cmd, &all_vgnames, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -1998,7 +1756,7 @@ int process_each_lv(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames);
+		ret = get_all_vgnames(cmd, &all_vgnames, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -2022,3 +1780,365 @@ int process_each_lv(struct cmd_context *cmd,
 	return ret;
 }
 
+static int get_arg_pvnames(struct cmd_context *cmd,
+			   int argc, char **argv,
+			   struct dm_list *arg_pvnames,
+			   struct dm_list *arg_tags)
+{
+	int opt = 0;
+	char *at_sign, *tagname;
+	char *arg_name;
+	int ret_max = ECMD_PROCESSED;
+
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
+			continue;
+		}
+
+		if (!str_list_add(cmd->mem, arg_pvnames,
+				  dm_pool_strdup(cmd->mem, arg_name))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
+	}
+
+	return ret_max;
+}
+
+static int get_all_devs(struct cmd_context *cmd, struct dm_list *all_devs)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	struct device_list *devl;
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+		log_error("dev_iter creation failed");
+		return ECMD_FAILED;
+	}
+
+	while ((dev = dev_iter_get(iter))) {
+		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
+			log_error("device_list alloc failed");
+			return ECMD_FAILED;
+		}
+
+		devl->dev = dev;
+		dm_list_add(all_devs, &devl->list);
+	}
+
+	dev_iter_destroy(iter);
+
+	return ECMD_PROCESSED;
+}
+
+static void device_list_remove(struct dm_list *all_devs, struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, all_devs) {
+		if (devl->dev == dev) {
+			dm_list_del(&devl->list);
+			return;
+		}
+	}
+	log_error(INTERNAL_ERROR "device_list_remove %s not found", dev_name(dev));
+}
+
+static int process_dev_list(struct cmd_context *cmd, struct dm_list *all_devs,
+			    void *handle, process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume pv_dummy;
+	struct physical_volume *pv;
+	struct device_list *devl;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	dm_list_iterate_items(devl, all_devs) {
+		memset(&pv_dummy, 0, sizeof(pv_dummy));
+		dm_list_init(&pv_dummy.tags);
+		dm_list_init(&pv_dummy.segments);
+		pv_dummy.dev = devl->dev;
+		pv = &pv_dummy;
+
+		log_very_verbose("Processing device %s", dev_name(devl->dev));
+
+		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+		if (sigint_caught())
+			break;
+	}
+
+	return ECMD_PROCESSED;
+}
+
+static int process_pvs_in_vg(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     struct dm_list *all_devs,
+			     struct dm_list *arg_pvnames,
+			     struct dm_list *arg_tags,
+			     int process_all,
+			     int skip,
+			     void *handle,
+			     process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	const char *pv_name;
+	int process_pv;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		pv_name = pv_dev_name(pv);
+
+		process_pv = 0;
+
+		/*
+		 * We cannot check for empty arg_tags and empty
+		 * arg_pvnames to determine process_all here because we
+		 * remove items from arg_pvnames as they are completed.
+		 */
+		if (process_all)
+			process_pv = 1;
+
+		if (!process_pv && !dm_list_empty(arg_pvnames) &&
+		    str_list_match_item(arg_pvnames, pv_name)) {
+			process_pv = 1;
+			str_list_del(arg_pvnames, pv_name);
+		}
+
+		if (!process_pv && !dm_list_empty(arg_tags) &&
+		    str_list_match_list(arg_tags, &pv->tags, NULL)) {
+			process_pv = 1;
+		}
+
+		if (process_pv) {
+			if (skip)
+				log_verbose("Skipping PV %s in VG %s", pv_name, vg->name);
+			else
+				log_very_verbose("Processing PV %s in VG %s", pv_name, vg->name);
+
+			if (all_devs)
+				device_list_remove(all_devs, pv->dev);
+
+			if (!skip)
+				ret = process_single_pv(cmd, vg, pv, handle);
+
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+
+		if (sigint_caught())
+			break;
+
+		/*
+		 * When processing only specific pv names, we can quit
+		 * once they've all been found.
+	 	 */
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+			break;
+	}
+
+	return ret_max;
+}
+
+/*
+ * Iterate through all pvs in each listed vg.  Process a pv if
+ * the name or tag matches arg_pvnames or arg_tags.  If both
+ * arg_pvnames and arg_tags are empty, then process all pvs.
+ *
+ * This removes items from arg_pvnames and all_devs when a pv
+ * is found.  Any names remaining in arg_pvnames were not found, and
+ * should produce an error.  Any devs remaining in all_devs were
+ * not found and should be processed by process_all_devs().
+ */
+
+static int process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
+			      struct dm_list *all_vgnames,
+			      struct dm_list *all_devs,
+			      struct dm_list *arg_pvnames,
+			      struct dm_list *arg_tags,
+			      int process_all,
+			      void *handle,
+			      process_single_pv_fn_t process_single_pv)
+{
+	struct volume_group *vg;
+	struct name_id_list *nl;
+	struct dm_str_list *sl;
+	const char *vg_name;
+	const char *vg_uuid;
+	int skip;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_iterate_items(nl, all_vgnames) {
+		vg_name = nl->name;
+		vg_uuid = nl->uuid;
+		ret = 0;
+		skip = 0;
+
+		vg = vg_read(cmd, vg_name, vg_uuid, flags);
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
+			if (ret > ret_max)
+				ret_max = ret;
+			skip = 1;
+		}
+
+		ret = process_pvs_in_vg(cmd, vg, all_devs, arg_pvnames, arg_tags,
+					process_all, skip, handle, process_single_pv);
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
+			return ret_max;
+
+		/* quit early when possible */
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+			return ret_max;
+	}
+
+	/* command should return an error if a pvname arg was not found */
+
+	dm_list_iterate_items(sl, arg_pvnames) {
+		log_error("Failed to find physical volume \"%s\"", sl->str);
+		ret_max = ECMD_FAILED;
+	}
+
+	return ret_max;
+}
+
+int process_each_pv(struct cmd_context *cmd,
+		    int argc, char **argv,
+		    struct volume_group *vg,
+		    uint32_t flags,
+		    void *handle,
+		    process_single_pv_fn_t process_single_pv)
+{
+	struct dm_list arg_tags;    /* str_list */
+	struct dm_list arg_pvnames; /* str_list */
+	struct dm_list all_vgnames; /* name_id_list */
+	struct dm_list all_devs;    /* device_list */
+	struct dm_str_list *sl;
+	int process_all_pvs;
+	int process_all_devs;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_pvnames);
+	dm_list_init(&all_vgnames);
+	dm_list_init(&all_devs);
+
+	/*
+	 * Create two lists from argv:
+	 * arg_pvnames: pvs explicitly named in argv
+	 * arg_tags: tags explicitly named in argv
+	 */
+	ret = get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags);
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
+
+	process_all_devs = process_all_pvs &&
+			   (cmd->command->flags & ENABLE_ALL_DEVS) &&
+			   arg_count(cmd, all_ARG);
+
+	/*
+	 * Caller has already selected, locked, and read one vg in which to
+	 * process pvs (all pvs, or named pvs, or pvs with matching tags).
+	 */
+	if (vg) {
+		ret = process_pvs_in_vg(cmd, vg, NULL,
+					&arg_pvnames, &arg_tags, process_all_pvs,
+					handle, process_single_pv);
+
+		dm_list_iterate_items(sl, &arg_pvnames) {
+			log_error("Physical Volume \"%s\" not found in Volume Group \"%s\"",
+				  sl->str, vg->name);
+			ret = ECMD_FAILED;
+		}
+		return ret;
+	}
+
+	/*
+	 * If the caller wants to process all devs (not only pvs), then all pvs
+	 * from all vgs are processed first, removing each from all_devs.  Then
+	 * any devs remaining in all_devs are processed.
+	 */
+	if (process_all_devs) {
+		ret = get_all_devs(cmd, &all_devs);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	ret = get_all_vgnames(cmd, &all_vgnames, 1);
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	ret = process_pvs_in_vgs(cmd, flags, &all_vgnames,
+				 process_all_devs ? &all_devs : NULL,
+				 &arg_pvnames, &arg_tags, process_all_pvs,
+				 handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	if (sigint_caught())
+		goto out;
+
+	if (dm_list_empty(&all_devs))
+		goto out;
+
+	ret = process_dev_list(cmd, &all_devs, handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+out:
+	return ret_max;
+}
+
+int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			  void *handle, process_single_pv_fn_t process_single_pv)
+{
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
+			ret_max = ret;
+	}
+
+	return ret_max;
+}
+
diff --git a/tools/toollib.h b/tools/toollib.h
index 3f21470..4327f84 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -58,8 +58,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
-		    int scan_label_only, void *handle,
-		    process_single_pv_fn_t process_single_pv);
+		    void *handle, process_single_pv_fn_t process_single_pv);
 
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		       void *handle, process_single_label_fn_t process_single_label);
@@ -80,13 +79,12 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tagsl, void *handle,
-			  process_single_pv_fn_t process_single_pv);
+			  void *handle, process_single_pv_fn_t process_single_pv);
 
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
-			  const struct dm_list *arg_lvnames,
+			  struct dm_list *arg_lvnames,
 			  const struct dm_list *tagsl,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
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


