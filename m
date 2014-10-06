From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  6 Oct 2014 21:02:24 +0000 (UTC)
Subject: master - toollib: Shuffle PV functions.
Message-ID: <20141006210224.6D62460249@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97b16ec26f10f98b7febf661ba33bcd2882c7e6c
Commit:        97b16ec26f10f98b7febf661ba33bcd2882c7e6c
Parent:        b7c81769e72fe6ad4569c10de86090e75fe914ba
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 6 22:02:00 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 6 22:02:00 2014 +0100

toollib: Shuffle PV functions.

---
 tools/toollib.c |  495 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 248 insertions(+), 247 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 195f47a..4b0ba22 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -266,249 +266,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
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
 static const char *_extract_vgname(struct cmd_context *cmd, const char *lv_name,
 				   const char **after)
 {
@@ -540,6 +297,7 @@ static const char *_extract_vgname(struct cmd_context *cmd, const char *lv_name,
 
 	return vg_name;
 }
+
 /*
  * Extract default volume group name from environment
  */
@@ -1999,7 +1757,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 				     process_single_lv_fn_t process_single_lv)
 {
 	struct volume_group *vg;
-	struct vgnameid_list *nl;
+	struct vgnameid_list *vgnl;
 	struct dm_str_list *sl;
 	struct dm_list *tags_arg;
 	struct dm_list lvnames;
@@ -2010,9 +1768,9 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
-	dm_list_iterate_items(nl, vgnameids_to_process) {
-		vg_name = nl->vg_name;
-		vg_uuid = nl->vgid;
+	dm_list_iterate_items(vgnl, vgnameids_to_process) {
+		vg_name = vgnl->vg_name;
+		vg_uuid = vgnl->vgid;
 		ret = 0;
 
 		/*
@@ -2128,3 +1886,246 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	return _process_lv_vgnameid_list(cmd, flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
 					 &arg_tags, handle, process_single_lv);
 }
+
+int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			  const struct dm_list *tagsl, void *handle,
+			  process_single_pv_fn_t process_single_pv)
+{
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+		if (tagsl && !dm_list_empty(tagsl) &&
+		    !str_list_match_list(tagsl, &pvl->pv->tags, NULL)) {
+			continue;
+		}
+		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
+			ret_max = ret;
+	}
+
+	return ret_max;
+}
+
+static int _process_all_devs(struct cmd_context *cmd, void *handle,
+			     process_single_pv_fn_t process_single_pv)
+{
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
+	struct physical_volume *pv;
+	struct physical_volume pv_dummy;
+	struct dev_iter *iter;
+	struct device *dev;
+
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!(pvslist = get_pvs(cmd)))
+		return_ECMD_FAILED;
+
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+		log_error("dev_iter creation failed");
+		return ECMD_FAILED;
+	}
+
+	while ((dev = dev_iter_get(iter)))
+	{
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			stack;
+			break;
+		}
+
+		memset(&pv_dummy, 0, sizeof(pv_dummy));
+		dm_list_init(&pv_dummy.tags);
+		dm_list_init(&pv_dummy.segments);
+		pv_dummy.dev = dev;
+		pv = &pv_dummy;
+
+		/* TODO use a device-indexed hash here */
+		dm_list_iterate_items(pvl, pvslist)
+			if (pvl->pv->dev == dev)
+				pv = pvl->pv;
+
+		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+
+		free_pv_fid(pv);
+	}
+
+	dev_iter_destroy(iter);
+	dm_list_iterate_items(pvl, pvslist)
+		free_pv_fid(pvl->pv);
+
+	return ret_max;
+}
+
+/*
+ * If the lock_type is LCK_VG_READ (used only in reporting commands),
+ * we lock VG_GLOBAL to enable use of metadata cache.
+ * This can pause alongide pvscan or vgscan process for a while.
+ */
+int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
+		    struct volume_group *vg, uint32_t flags,
+		    int scan_label_only, void *handle,
+		    process_single_pv_fn_t process_single_pv)
+{
+	int opt = 0;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE) && !lvmetad_active();
+
+	struct pv_list *pvl;
+	struct physical_volume *pv;
+	struct dm_list *pvslist = NULL, *vgnames;
+	struct dm_list tagsl;
+	struct dm_str_list *sll;
+	char *at_sign, *tagname;
+	struct device *dev;
+
+	dm_list_init(&tagsl);
+
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
+	if (argc) {
+		log_verbose("Using physical volume(s) on command line");
+		for (; opt < argc; opt++) {
+			if (sigint_caught()) {
+				ret_max = ECMD_FAILED;
+				goto_out;
+			}
+			dm_unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
+			if (at_sign && (at_sign == argv[opt])) {
+				tagname = at_sign + 1;
+
+				if (!validate_tag(tagname)) {
+					log_error("Skipping invalid tag %s",
+						  tagname);
+					if (ret_max < EINVALID_CMD_LINE)
+						ret_max = EINVALID_CMD_LINE;
+					continue;
+				}
+				if (!str_list_add(cmd->mem, &tagsl,
+						  dm_pool_strdup(cmd->mem,
+							      tagname))) {
+					log_error("strlist allocation failed");
+					goto bad;
+				}
+				continue;
+			}
+			if (vg) {
+				if (!(pvl = find_pv_in_vg(vg, argv[opt]))) {
+					log_error("Physical Volume \"%s\" not "
+						  "found in Volume Group "
+						  "\"%s\"", argv[opt],
+						  vg->name);
+					ret_max = ECMD_FAILED;
+					continue;
+				}
+				pv = pvl->pv;
+			} else {
+				if (!pvslist) {
+					lvmcache_seed_infos_from_lvmetad(cmd);
+					if (!(pvslist = get_pvs(cmd)))
+						goto bad;
+				}
+
+				if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
+					log_error("Failed to find device "
+						  "\"%s\"", argv[opt]);
+					ret_max = ECMD_FAILED;
+					continue;
+				}
+
+				pv = NULL;
+				dm_list_iterate_items(pvl, pvslist)
+					if (pvl->pv->dev == dev)
+						pv = pvl->pv;
+
+				if (!pv) {
+					log_error("Failed to find physical volume "
+						  "\"%s\"", argv[opt]);
+					ret_max = ECMD_FAILED;
+					continue;
+				}
+			}
+
+			ret = process_single_pv(cmd, vg, pv, handle);
+
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+		if (!dm_list_empty(&tagsl) && (vgnames = get_vgnames(cmd, 1)) &&
+			   !dm_list_empty(vgnames)) {
+			dm_list_iterate_items(sll, vgnames) {
+				if (sigint_caught()) {
+					ret_max = ECMD_FAILED;
+					goto_out;
+				}
+				vg = vg_read(cmd, sll->str, NULL, flags);
+				if (ignore_vg(vg, sll->str, 0, &ret_max)) {
+					release_vg(vg);
+					stack;
+					continue;
+				}
+
+				ret = process_each_pv_in_vg(cmd, vg, &tagsl,
+							    handle,
+							    process_single_pv);
+				if (ret > ret_max)
+					ret_max = ret;
+
+				unlock_and_release_vg(cmd, vg, sll->str);
+			}
+		}
+	} else {
+		if (vg) {
+			log_verbose("Using all physical volume(s) in "
+				    "volume group");
+			ret_max = process_each_pv_in_vg(cmd, vg, NULL, handle,
+							process_single_pv);
+		} else if (arg_count(cmd, all_ARG)) {
+			ret_max = _process_all_devs(cmd, handle, process_single_pv);
+		} else {
+			log_verbose("Scanning for physical volume names");
+
+			lvmcache_seed_infos_from_lvmetad(cmd);
+			if (!(pvslist = get_pvs(cmd)))
+				goto bad;
+
+			dm_list_iterate_items(pvl, pvslist) {
+				if (sigint_caught()) {
+					ret_max = ECMD_FAILED;
+					goto_out;
+				}
+				ret = process_single_pv(cmd, NULL, pvl->pv,
+						     handle);
+				if (ret > ret_max)
+					ret_max = ret;
+
+				free_pv_fid(pvl->pv);
+			}
+		}
+	}
+out:
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+	return ret_max;
+bad:
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
+	return ECMD_FAILED;
+}


