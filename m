From: David Teigland <teigland@redhat.com>
Date: Tue, 26 Mar 2013 16:09:27 -0500
Subject: [PATCH 7/8] toollib: rework process_each_pv
Message-ID: <1364332168-24676-8-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Split up process_each_pv, matching the previous
renovation to process_each_vg,lv.

The VG_GLOBAL lock is now taken by the two callers
that had wanted it.

Two new flags passed to process_each_pv control
which pvs should be processed when command args
contain no pv names or tags:

ENABLE_ALL_VGNAMES
Scan for all vgs, including orphan vgs, and process each pv in them.

ENABLE_ALL_DEVS
Scan for all devices, including non-pvs, and process each.

process_single_pv is always passed the vg
when the pv is not an orphan.  If the pv is
an orphan (or has no mda and is not otherwise
identified as belonging to a vg), vg is NULL.

Previously, process_single_pv would not receive
the vg in what was the ENABLE_ALL_DEVS case,
and had to read the vg itself.  This case is now
removed from instances of process_single_pv.
---
 lib/metadata/metadata-exported.h |   1 +
 tools/pvdisplay.c                |  74 ++--
 tools/pvresize.c                 |  37 +-
 tools/reporter.c                 |  94 ++---
 tools/toollib.c                  | 855 ++++++++++++++++++++++++++++-----------
 tools/toollib.h                  |   3 +-
 tools/vgdisplay.c                |   2 +-
 7 files changed, 697 insertions(+), 369 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 61f18d0..2089d61 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -122,6 +122,7 @@
 /* meta-flags, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE		0x00100000U
 #define ENABLE_ALL_VGNAMES	0x00200000U	/* run cmd on all vg names if none are named */
+#define ENABLE_ALL_DEVS		0x00400000U	/* run cmd on all devs if none are named */
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index c6cd412..1b10993 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -15,41 +15,18 @@
 
 #include "tools.h"
 
+/*
+ * An orphan pv may be passed in with vg set to the orphan vg,
+ * or with null vg.  vg will be NULL for a non-pv device.
+ */
+
 static int _pvdisplay_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     struct physical_volume *pv, void *handle)
 {
-	struct pv_list *pvl;
-	int ret = ECMD_PROCESSED;
-	uint64_t size;
-	struct volume_group *old_vg = vg;
-
 	const char *pv_name = pv_dev_name(pv);
-	const char *vg_name = NULL;
-
-	if (!is_orphan(pv) && !vg) {
-		vg_name = pv_vg_name(pv);
-		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
-		if (vg_read_error(vg)) {
-			log_error("Skipping volume group %s", vg_name);
-			release_vg(vg);
-			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
-			return ECMD_FAILED;
-		}
-
-	 	/*
-		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read_internal() path.
-		 */
-		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			 log_error("Unable to find \"%s\" in volume group \"%s\"",
-				   pv_name, vg->name);
-			 ret = ECMD_FAILED;
-			 goto out;
-		 }
-
-		 pv = pvl->pv;
-	}
+	uint64_t size;
+	int ret = ECMD_PROCESSED;
 
 	if (is_orphan(pv))
 		size = pv_size(pv);
@@ -80,18 +57,16 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 
 	if (arg_count(cmd, maps_ARG))
 		pvdisplay_segments(pv);
-
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
+	uint32_t flags = 0;
+	int lock_global = 0;
+	int ret;
+
 	if (arg_count(cmd, columns_ARG)) {
 		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG) ||
 		    arg_count(cmd, short_ARG)) {
@@ -114,6 +89,29 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
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
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (!argc && arg_count(cmd, all_ARG))
+		flags = ENABLE_ALL_DEVS;
+	else
+		flags = ENABLE_ALL_VGNAMES;
+
+	ret = process_each_pv(cmd, argc, argv, NULL, flags,
+			      0, NULL, _pvdisplay_single);
+
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
+	return ret;
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 2f0693a..b72f773 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -29,12 +29,10 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			     struct physical_volume *pv,
 			     const uint64_t new_size)
 {
-	struct pv_list *pvl;
 	uint64_t size = 0;
 	int r = 0;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = pv_vg_name(pv);
-	struct volume_group *old_vg = vg;
 	int vg_needs_pv_write = 0;
 
 	if (is_orphan_vg(vg_name)) {
@@ -48,26 +46,19 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
 		}
-	} else {
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-
-		if (vg_read_error(vg)) {
-			release_vg(vg);
-			log_error("Unable to read volume group \"%s\".",
-				  vg_name);
-			return 0;
-		}
-
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			goto out;
-		}
-
-		pv = pvl->pv;
+	} else if (vg) {
+		/*
+		 * READ_FOR_UPDATE is passed to process_each_pv below,
+		 * and process_each_pv uses that flag in vg_read, so
+		 * reading the vg again here appears to be unnecessary.
+		 */
 
 		if (!archive(vg))
 			goto out;
+	} else {
+		/* should not happen */
+		log_error("pv is not orphan or in a vg");
+		return ECMD_FAILED;
 	}
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
@@ -125,11 +116,11 @@ out:
 	if (!r && vg_needs_pv_write)
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
-	unlock_vg(cmd, vg_name);
-	if (is_orphan_vg(vg_name))
+
+	if (is_orphan_vg(vg_name)) {
+		unlock_vg(cmd, vg_name);
 		free_pv_fid(pv);
-	if (!old_vg)
-		release_vg(vg);
+	}
 	return r;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 0e6cbe4..a276684 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -130,61 +130,12 @@ static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
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
-		if (vg_read_error(vg)) {
-			log_error("Skipping volume group %s", vg_name);
-			release_vg(vg);
-			return ECMD_FAILED;
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
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
 		stack;
-		ret = ECMD_FAILED;
+		return ECMD_FAILED;
 	}
 
-out:
-	if (vg_name)
-		unlock_vg(cmd, vg_name);
-
-	if (!old_vg)
-		release_vg(vg);
-
-	return ret;
+	return ECMD_PROCESSED;
 }
 
 static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
@@ -207,7 +158,7 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
+	return process_each_pv_in_vg(cmd, vg, handle, &_pvs_single);
 }
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
@@ -219,7 +170,7 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
+	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
 
 static int _report(struct cmd_context *cmd, int argc, char **argv,
@@ -233,6 +184,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
 	unsigned args_are_pvs;
+	int lock_global = 0;
+	uint32_t flags = 0;
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG);
@@ -364,6 +317,24 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	else if (report_type & LVS)
 		report_type = LVS;
 
+	/*
+	 * This moved here as part of factoring it out of process_each_pv.
+	 * We lock VG_GLOBAL to enable use of metadata cache.
+	 * This can pause alongide pvscan or vgscan process for a while.
+	 */
+	if ((report_type == PVS || report_type == PVSEGS) && !lvmetad_active()) {
+		lock_global = 1;
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (!argc && arg_count(cmd, all_ARG))
+		flags = ENABLE_ALL_DEVS;
+	else
+		flags = ENABLE_ALL_VGNAMES;
+
 	switch (report_type) {
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, ENABLE_ALL_VGNAMES,
@@ -374,13 +345,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
-		r = process_each_pv(cmd, argc, argv, NULL, READ_WITHOUT_LOCK,
-				    1, report_handle, &_label_single);
+		r = process_each_pv(cmd, argc, argv, NULL,
+				    flags | READ_WITHOUT_LOCK, 1,
+				    report_handle, &_label_single);
 		break;
 	case PVS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    0, report_handle, &_pvs_single);
+			r = process_each_pv(cmd, argc, argv, NULL, flags, 0,
+					    report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
 					    report_handle, &_pvs_in_vg);
@@ -391,8 +363,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    0, report_handle, &_pvsegs_single);
+			r = process_each_pv(cmd, argc, argv, NULL, flags, 0,
+					    report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
 					    report_handle, &_pvsegs_in_vg);
@@ -402,6 +374,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	dm_report_output(report_handle);
 
 	dm_report_free(report_handle);
+
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
 	return r;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 65501e8..2e5dc49 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -268,251 +268,21 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 }
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tags, void *handle,
-			  process_single_pv_fn_t process_single_pv)
+			  void *handle, process_single_pv_fn_t process_single_pv)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (tags && !dm_list_empty(tags) &&
-		    !str_list_match_list(tags, &pvl->pv->tags, NULL)) {
-			continue;
-		}
-		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
-			ret_max = ret;
-		if (sigint_caught())
-			return ret_max;
-	}
-
-	return ret_max;
-}
-
-static int _process_all_devs(struct cmd_context *cmd, void *handle,
-			     process_single_pv_fn_t process_single_pv)
-{
-	struct physical_volume *pv;
-	struct physical_volume pv_dummy;
-	struct dev_iter *iter;
-	struct device *dev;
-
-	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
-
-	if (!scan_vgs_for_pvs(cmd, 1)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
-		return ECMD_FAILED;
-	}
-
-	while ((dev = dev_iter_get(iter))) {
-		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
-			memset(&pv_dummy, 0, sizeof(pv_dummy));
-			dm_list_init(&pv_dummy.tags);
-			dm_list_init(&pv_dummy.segments);
-			pv_dummy.dev = dev;
-			pv = &pv_dummy;
-		}
-		ret = process_single_pv(cmd, NULL, pv, handle);
-
-		free_pv_fid(pv);
-
+		ret = process_single_pv(cmd, vg, pvl->pv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
 			break;
 	}
 
-	dev_iter_destroy(iter);
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
-	int ret = 0;
-	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
-
-	struct pv_list *pvl;
-	struct physical_volume *pv;
-	struct dm_list *pvslist, *vgnames;
-	struct dm_list tags;
-	struct str_list *sll;
-	char *at_sign, *tagname;
-	int scanned = 0;
-
-	dm_list_init(&tags);
-
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
-	if (argc) {
-		log_verbose("Using physical volume(s) on command line");
-		for (; opt < argc; opt++) {
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
-				if (!str_list_add(cmd->mem, &tags,
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
-				if (!(pv = pv_read(cmd, argv[opt],
-						   1, scan_label_only))) {
-					log_error("Failed to read physical "
-						  "volume \"%s\"", argv[opt]);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-
-				/*
-				 * If a PV has no MDAs it may appear to be an
-				 * orphan until the metadata is read off
-				 * another PV in the same VG.  Detecting this
-				 * means checking every VG by scanning every
-				 * PV on the system.
-				 */
-				if (!scanned && is_orphan(pv) &&
-				    !dm_list_size(&pv->fid->metadata_areas_in_use)) {
-					if (!scan_label_only &&
-					    !scan_vgs_for_pvs(cmd, 1)) {
-						stack;
-						ret_max = ECMD_FAILED;
-						continue;
-					}
-					scanned = 1;
-					free_pv_fid(pv);
-					if (!(pv = pv_read(cmd, argv[opt],
-							   1,
-							   scan_label_only))) {
-						log_error("Failed to read "
-							  "physical volume "
-							  "\"%s\"", argv[opt]);
-						ret_max = ECMD_FAILED;
-						continue;
-					}
-				}
-			}
-
-			ret = process_single_pv(cmd, vg, pv, handle);
-
-			/*
-			 * Free PV only if we called pv_read before,
-			 * otherwise the PV structure is part of the VG.
-			 */
-			if (!vg)
-				free_pv_fid(pv);
-
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
-		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
-			   !dm_list_empty(vgnames)) {
-			dm_list_iterate_items(sll, vgnames) {
-				vg = vg_read(cmd, sll->str, NULL, flags);
-				if (vg_read_error(vg)) {
-					ret_max = ECMD_FAILED;
-					release_vg(vg);
-					stack;
-					continue;
-				}
-
-				ret = process_each_pv_in_vg(cmd, vg, &tags,
-							    handle,
-							    process_single_pv);
-
-				unlock_and_release_vg(cmd, vg, sll->str);
-
-				if (ret > ret_max)
-					ret_max = ret;
-				if (sigint_caught())
-					goto out;
-			}
-		}
-	} else {
-		if (vg) {
-			log_verbose("Using all physical volume(s) in "
-				    "volume group");
-			ret = process_each_pv_in_vg(cmd, vg, NULL, handle,
-						    process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
-		} else if (arg_count(cmd, all_ARG)) {
-			ret = _process_all_devs(cmd, handle, process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
-		} else {
-			log_verbose("Scanning for physical volume names");
-
-			lvmcache_seed_infos_from_lvmetad(cmd);
-			if (!(pvslist = get_pvs(cmd)))
-				goto bad;
-
-			dm_list_iterate_items(pvl, pvslist) {
-				ret = process_single_pv(cmd, NULL, pvl->pv,
-						     handle);
-				free_pv_fid(pvl->pv);
-				if (ret > ret_max)
-					ret_max = ret;
-				if (sigint_caught())
-					goto out;
-			}
-		}
-	}
-out:
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
 	return ret_max;
-bad:
-	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
-
-	return ECMD_FAILED;
 }
 
 /*
@@ -1434,19 +1204,26 @@ static int get_arg_vgnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
+static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames,
+			   int include_orphan)
 {
-	int ret_max = ECMD_PROCESSED;
+	struct dm_list orphan_vgnames;
 	struct dm_list *vgnames;
+	struct dm_list *tmp, *safe;
 	struct str_list *sl;
 	const char *vg_name;
+	const char *dup_str;
+	int ret_max = ECMD_PROCESSED;
+	int rv;
+
+	dm_list_init(&orphan_vgnames);
 
 	log_verbose("Finding all volume groups");
 
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
 		stack;
 
-	if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames))
+	if (!(vgnames = get_vgnames(cmd, include_orphan)) || dm_list_empty(vgnames))
 		goto out;
 
 	dm_list_iterate_items(sl, vgnames) {
@@ -1454,12 +1231,33 @@ static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
 		if (!vg_name)
 			continue;
 
-		if (!str_list_add_order(cmd->mem, all_vgnames,
-					dm_pool_strdup(cmd->mem, vg_name))) {
+		dup_str = dm_pool_strdup(cmd->mem, vg_name);
+		if (!dup_str) {
+			log_error("strdup allocation failed");
+			return ECMD_FAILED;
+		}
+
+		if (include_orphan && is_orphan_vg(vg_name))
+			rv = str_list_add(cmd->mem, &orphan_vgnames, dup_str);
+		else
+			rv = str_list_add_order(cmd->mem, all_vgnames, dup_str);
+
+		if (!rv) {
 			log_error("strlist allocation failed");
 			return ECMD_FAILED;
 		}
 	}
+
+	/*
+	 * vg list processing/locking requires the orphan vgs to be at the end,
+	 * so we save all the orphan vgs on the tmp list and then add them to
+	 * to the end of the real list here.
+	 */
+	dm_list_iterate_safe(tmp, safe, &orphan_vgnames) {
+		dm_list_del(tmp);
+		dm_list_add(all_vgnames, tmp);
+	}
+
 out:
 	return ret_max;
 }
@@ -1480,7 +1278,9 @@ static void release_vg_list(struct cmd_context *cmd, struct dm_list *vgl_list)
 	struct vg_list *vgl;
 
 	dm_list_iterate_items(vgl, vgl_list) {
-		if (vg_read_error(vgl->vg))
+		if (is_orphan_vg(vgl->vg->name))
+			release_vg(vgl->vg);
+		else if (vg_read_error(vgl->vg))
 			release_vg(vgl->vg);
 		else
 			unlock_and_release_vg(cmd, vgl->vg, vgl->vg->name);
@@ -1495,6 +1295,7 @@ static int read_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 	struct vg_list *vgl;
 	struct str_list *sl;
 	const char *vg_name;
+	int consistent;
 	int ret_max = ECMD_PROCESSED;
 
 	dm_list_iterate_items(sl, vg_name_list) {
@@ -1506,15 +1307,27 @@ static int read_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 			return ECMD_FAILED;
 		}
 
-		vg = vg_read(cmd, vg_name, NULL, flags);
-		if (vg_read_error(vg)) {
-			if (!((flags & READ_ALLOW_INCONSISTENT) &&
-			     (vg_read_error(vg) == FAILED_INCONSISTENT))) {
-				ret_max = ECMD_FAILED;
-				release_vg(vg);
+		if (is_orphan_vg(vg_name)) {
+			consistent = 0;
+
+			if (!(vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
 				stack;
 				continue;
 			}
+
+			if (!consistent)
+				log_warn("WARNING: Volume Group %s is not consistent", vg_name);
+		} else {
+			vg = vg_read(cmd, vg_name, NULL, flags);
+			if (vg_read_error(vg)) {
+				if (!((flags & READ_ALLOW_INCONSISTENT) &&
+			     	     (vg_read_error(vg) == FAILED_INCONSISTENT))) {
+					ret_max = ECMD_FAILED;
+					release_vg(vg);
+					stack;
+					continue;
+				}
+			}
 		}
 
 		vgl->vg = vg;
@@ -1605,7 +1418,7 @@ int process_each_vg(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && (flags & ENABLE_ALL_VGNAMES)) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames);
+		ret = get_all_vgnames(cmd, &all_vgnames, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -1843,7 +1656,7 @@ int process_each_lv(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && (flags & ENABLE_ALL_VGNAMES)) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames);
+		ret = get_all_vgnames(cmd, &all_vgnames, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -1882,3 +1695,553 @@ out:
 	return ret_max;
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
+static int get_all_devs(struct cmd_context *cmd,
+			struct dm_list *all_pvnames,
+			struct dm_list *dummy_pvnames)
+{
+	struct physical_volume *pv;
+	struct dev_iter *iter;
+	struct device *dev;
+	const char *pv_name;
+
+	if (!scan_vgs_for_pvs(cmd, 1)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+		log_error("dev_iter creation failed");
+		return ECMD_FAILED;
+	}
+
+	while ((dev = dev_iter_get(iter))) {
+		pv_name = dev_name(dev);
+
+		if (!(pv = pv_read(cmd, pv_name, 0, 0))) {
+			if (!str_list_add(cmd->mem, dummy_pvnames,
+					  dm_pool_strdup(cmd->mem, pv_name))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+                } else {
+			if (!str_list_add(cmd->mem, all_pvnames,
+					  dm_pool_strdup(cmd->mem, pv_name))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+			free_pv_fid(pv);
+		}
+
+		if (sigint_caught())
+			break;
+	}
+
+	dev_iter_destroy(iter);
+
+	return ECMD_PROCESSED;
+}
+
+/*
+ * If the vg for the pv is known, add that vg name to vg_name_list.
+ * If the pv is known to be an orphan, duplicate that pv name onto orphan_pvnames.
+ * If the pv has no mda's, it may be an orphan, or it may not be (if other pvs
+ * with mdas from its vg are missing), so put a duplicate that pv name onto
+ * nomda_pvnames.
+ */
+
+static int get_vgnames_for_pvnames(struct cmd_context *cmd, uint32_t flags,
+				   int scan_label_only,
+				   struct dm_list *arg_pvnames,
+				   struct dm_list *vg_name_list,
+				   struct dm_list *orphan_pvnames,
+				   struct dm_list *nomda_pvnames)
+{
+	struct physical_volume *pv;
+	struct str_list *sl;
+	const char *vg_name;
+	const char *pv_name;
+	int ret_max = ECMD_PROCESSED;
+
+	dm_list_iterate_items(sl, arg_pvnames) {
+		pv_name = sl->str;
+
+		if (!(pv = pv_read(cmd, pv_name, 1, scan_label_only))) {
+			log_error("Failed to read physical volume \"%s\"",
+				  pv_name);
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+			if (!str_list_add(cmd->mem, nomda_pvnames,
+					  dm_pool_strdup(cmd->mem, pv_name))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+		} else if (is_orphan(pv)) {
+			if (!str_list_add(cmd->mem, orphan_pvnames,
+					  dm_pool_strdup(cmd->mem, pv_name))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+		} else {
+			vg_name = pv_vg_name(pv);
+
+			if (!str_list_add_order(cmd->mem, vg_name_list,
+						dm_pool_strdup(cmd->mem, vg_name))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+		}
+
+		/* FIXME: why is this done after pv_read's? */
+		free_pv_fid(pv);
+	}
+
+	return ret_max;
+}
+
+/*
+ * If a PV has no MDAs it may appear to be an
+ * orphan until the metadata is read off
+ * another PV in the same VG.  Detecting this
+ * means checking every VG by scanning every
+ * PV on the system.
+ */
+
+static int verify_nomda_pvnames(struct cmd_context *cmd,
+				struct dm_list *nomda_pvnames,
+				struct dm_list *vg_name_list)
+{
+	struct physical_volume *pv;
+	struct str_list *sl, *safe;
+	const char *vg_name;
+	const char *pv_name;
+	int ret_max = ECMD_PROCESSED;
+
+	if (!scan_vgs_for_pvs(cmd, 1)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	dm_list_iterate_items_safe(sl, safe, nomda_pvnames) {
+		pv_name = sl->str;
+
+		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
+			str_list_del(nomda_pvnames, pv_name);
+			log_error("Failed to read physical volume \"%s\"", pv_name);
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		if (!is_orphan(pv)) {
+			str_list_del(nomda_pvnames, pv_name);
+
+			vg_name = pv_vg_name(pv);
+			if (!str_list_add_order(cmd->mem, vg_name_list,
+						dm_pool_strdup(cmd->mem, vg_name))) {
+				log_error("strlist allocation failed");
+				ret_max = ECMD_FAILED;
+			}
+		}
+
+		free_pv_fid(pv);
+	}
+
+	return ret_max;
+}
+
+static int process_pv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
+				   struct dm_list *vg_name_list,
+				   struct dm_list *pv_name_list,
+				   struct dm_list *arg_tags,
+				   struct dm_list *vgl_list,
+				   void *handle,
+				   process_single_pv_fn_t process_single_pv)
+{
+	struct volume_group *vg, *vg_arg;
+	struct physical_volume *pv;
+	struct vg_list *vgl;
+	struct pv_list *pvl;
+	struct str_list *sl;
+	const char *vg_name;
+	const char *pv_name;
+	int process_all = 0;
+	int process_pv;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	if (dm_list_empty(pv_name_list) && dm_list_empty(arg_tags))
+		process_all = 1;
+
+	dm_list_iterate_items(sl, vg_name_list) {
+		vg_name = sl->str;
+
+		vgl = find_vgl(vgl_list, vg_name);
+		if (!vgl)
+			continue;
+
+		vg = vgl->vg;
+
+		/*
+		 * Be consistent with process_orphan_name_list which does
+		 * not pass the orphan vg to process_single_pv.
+		 */
+		if (is_orphan_vg(vg_name))
+			vg_arg = NULL;
+		else
+			vg_arg = vg;
+
+		dm_list_iterate_items(pvl, &vg->pvs) {
+
+			pv = pvl->pv;
+
+			pv_name = pv_dev_name(pv);
+
+			process_pv = 0;
+
+			if (process_all)
+				process_pv = 1;
+
+			if (!process_pv && !dm_list_empty(pv_name_list) &&
+			    str_list_match_item(pv_name_list, pv_name))
+				process_pv = 1;
+
+			if (!process_pv && !dm_list_empty(arg_tags) &&
+			    str_list_match_list(arg_tags, &pv->tags, NULL))
+				process_pv = 1;
+
+			if (process_pv)
+				ret = process_single_pv(cmd, vg_arg, pv, handle);
+
+			if (ret > ret_max)
+				ret_max = ret;
+			if (sigint_caught())
+				break;
+		}
+	}
+
+	return ret_max;
+}
+
+static int process_orphan_name_list(struct cmd_context *cmd,
+				    int scan_label_only,
+				    struct dm_list *orphan_pvnames,
+				    void *handle,
+				    process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume *pv;
+	struct str_list *sl;
+	const char *pv_name;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_iterate_items(sl, orphan_pvnames) {
+		pv_name = sl->str;
+
+		if (!(pv = pv_read(cmd, pv_name, 1, scan_label_only))) {
+			log_error("Failed to read physical volume \"%s\"",
+				  pv_name);
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+		if (sigint_caught())
+			break;
+
+		free_pv_fid(pv);
+	}
+
+	return ret_max;
+}
+
+static int process_dummy_name_list(struct cmd_context *cmd,
+				   struct dm_list *dummy_pvnames,
+				   void *handle,
+				   process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume *pv;
+	struct physical_volume pv_dummy;
+	struct str_list *sl;
+	struct device *dev;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_iterate_items(sl, dummy_pvnames) {
+		dev = dev_cache_get(sl->str, NULL);
+		if (!dev) {
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		memset(&pv_dummy, 0, sizeof(pv_dummy));
+		dm_list_init(&pv_dummy.tags);
+		dm_list_init(&pv_dummy.segments);
+		pv_dummy.dev = dev;
+		pv = &pv_dummy;
+
+		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+		if (sigint_caught())
+			break;
+	}
+
+	return ret_max;
+}
+
+int process_each_pv(struct cmd_context *cmd,
+		    int argc, char **argv,
+		    struct volume_group *vg,
+		    uint32_t flags,
+		    int scan_label_only,
+		    void *handle,
+		    process_single_pv_fn_t process_single_pv)
+{
+	struct dm_list arg_tags;        /* named in argv */
+	struct dm_list arg_pvnames;     /* named in argv */
+	struct dm_list all_pvnames;     /* real pvs from scanning all devs */
+	struct dm_list dummy_pvnames;   /* non-pvs from scanning all devs */
+	struct dm_list nomda_pvnames;   /* dup from arg_ or all_ */
+	struct dm_list orphan_pvnames;  /* dup from arg_ or all_ */
+	struct dm_list *pv_name_list;   /* set to arg_ or all_ */
+	struct dm_list vg_name_list;    /* vgs to process pvs in */
+	struct dm_list vgl_list;        /* result of reading vg_name_list */
+	struct vg_list *vgl;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_pvnames);
+	dm_list_init(&all_pvnames);
+	dm_list_init(&dummy_pvnames);
+	dm_list_init(&nomda_pvnames);
+	dm_list_init(&orphan_pvnames);
+	dm_list_init(&vg_name_list);
+	dm_list_init(&vgl_list);
+
+	/*
+	 * Create two lists from argv:
+	 * arg_pvnames: pvs explicitly named in argv
+	 * arg_tags: tags explicitly named in argv
+	 */
+
+	ret = get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags);
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	/*
+	 * Caller has already selected and read one vg in which to
+	 * process pvs. Empty arg_pvnames and empty arg_tags means
+	 * all pvs in this vg, empty arg_pvnames and non-empty arg_tags
+	 * means all pvs in this vg with a matching tag.
+	 */
+
+	if (vg) {
+		if (!str_list_add(cmd->mem, &vg_name_list,
+				  dm_pool_strdup(cmd->mem, vg->name))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
+		if (!(vgl = dm_pool_alloc(cmd->mem, sizeof(*vgl)))) {
+			log_error("vg_list alloc failed");
+			return ECMD_FAILED;
+		}
+		vgl->vg = vg;
+		dm_list_add(&vgl_list, &vgl->list);
+		goto process;
+	}
+
+	/*
+	 * Caller wants to process all devs; all devs are split into two lists:
+	 * all_pvnames: pv names (pv_read does not return error)
+	 * dummy_pvnames: non-pv devs (pv_read returns error)
+	 */
+
+	if (dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags) &&
+	    (flags & ENABLE_ALL_DEVS)) {
+		ret = get_all_devs(cmd, &all_pvnames, &dummy_pvnames);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	/*
+	 * Create list of vg names for all the pvs we want to process
+	 * so those pvs can be processed in the context of their vg.
+	 *
+	 * For the pvs that are orphans, dup their name into orphan_pvnames.
+	 * For the pvs that have no mda, dup their name into nomda_pvnames.
+	 *
+	 * (One or both of arg_pvnames or all_pvnames will be empty.)
+	 */
+
+	ret = get_vgnames_for_pvnames(cmd, flags, scan_label_only,
+				      &arg_pvnames, &vg_name_list,
+				      &orphan_pvnames, &nomda_pvnames);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	ret = get_vgnames_for_pvnames(cmd, flags, scan_label_only,
+				      &all_pvnames, &vg_name_list,
+				      &orphan_pvnames, &nomda_pvnames);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	/*
+	 * We now have the following lists:
+	 * arg_tags: tags named in argv
+	 * arg_pvnames: pvs named in argv (may be orphan or not)
+	 * all_pvnames: pvs found from full scan (may be orphan or not)
+	 * dummy_pvnames: devs found from full scan that are not pvs
+	 * orphan_pvnames: pvs that are orphans (also exist in arg_ or all_)
+	 * nomda_pvnames: pvs that have no mda (also exist in arg_ or all_)
+	 * vg_name_list: vg names for pvs in arg_ or all_
+	 *
+	 * Next decide if we need to go through all vg names.
+	 */
+
+	if (dm_list_empty(&arg_pvnames) &&
+	    dm_list_empty(&all_pvnames) &&
+	    dm_list_empty(&vg_name_list) &&
+	    (flags & ENABLE_ALL_VGNAMES) &&
+	    !(flags & ENABLE_ALL_DEVS) && !argc) {
+
+		/*
+		 * Process all pvs in all vgs (including orphan vgs).
+		 * This option is implied by nothing being specified,
+		 * which means all of the conditions above should pass.
+		 * (testing some of them is redundant but makes the point).
+		 * In this case, orphan pvs are handled by
+		 * process_pv_vg_name_list, and not by process_orphan_name_list
+		 * which is used when arg_pvnames or all_pvnames include orphans.
+		 * The "1" arg here means include orphan vgs.
+		 */
+
+		ret = get_all_vgnames(cmd, &vg_name_list, 1);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+
+	} else if (!dm_list_empty(&arg_tags)) {
+
+		/*
+		 * We need to look at all pvs in all vgs (not including
+		 * orphan vgs) to see if any have matching tags.  There
+		 * may already be entries in arg_pvnames and vg_name_list,
+		 * but all_pvnames is not used when tags are used
+		 * (checked above).
+		 */
+
+		ret = get_all_vgnames(cmd, &vg_name_list, 0);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	/*
+	 * We should be able to remove this once pv's with no mda's can
+	 * be directly identified as member of a vg or not.
+	 */
+
+	if (!dm_list_empty(&nomda_pvnames) && !scan_label_only) {
+		ret = verify_nomda_pvnames(cmd, &nomda_pvnames, &vg_name_list);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	ret = read_vg_name_list(cmd, flags, &vg_name_list, &vgl_list);
+	if (ret > ret_max)
+		ret_max = ret;
+	if (sigint_caught())
+		goto out;
+
+	if (dm_list_empty(&vgl_list)) {
+		stack;
+		goto novg;
+	}
+
+process:
+	/* one or both of arg_pvnames/all_pvnames will be empty */
+
+	pv_name_list = &arg_pvnames;
+	if (!dm_list_empty(&all_pvnames))
+		pv_name_list = &all_pvnames;
+
+	/* will process all pvs when both pv_name_list and arg_tags are empty */
+
+	ret = process_pv_vg_name_list(cmd, flags, &vg_name_list,
+				      pv_name_list, &arg_tags, &vgl_list,
+				      handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+	if (sigint_caught())
+		goto out;
+
+	if (!vg)
+		release_vg_list(cmd, &vgl_list);
+
+novg:
+	ret = process_orphan_name_list(cmd, scan_label_only, &orphan_pvnames,
+				       handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	ret = process_orphan_name_list(cmd, scan_label_only, &nomda_pvnames,
+				       handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+
+	ret = process_dummy_name_list(cmd, &dummy_pvnames,
+				      handle, process_single_pv);
+	if (ret > ret_max)
+		ret_max = ret;
+out:
+	return ret_max;
+}
+
diff --git a/tools/toollib.h b/tools/toollib.h
index e71b08a..cddf034 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -70,8 +70,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tags, void *handle,
-			  process_single_pv_fn_t process_single_pv);
+			  void *handle, process_single_pv_fn_t process_single_pv);
 
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index e03118a..41b6e9b 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -41,7 +41,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
-		process_each_pv_in_vg(cmd, vg, NULL, NULL,
+		process_each_pv_in_vg(cmd, vg, NULL,
 				      (process_single_pv_fn_t)pvdisplay_short);
 	}
 
-- 
1.8.1.rc1.5.g7e0651a


