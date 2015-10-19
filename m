From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 19 Oct 2015 21:27:17 +0000 (UTC)
Subject: master - pvscan: use process_each_pv
Message-ID: <20151019212717.487CB60EAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83d475626a4d9ecaa2084f349cb2cee4f0f3a719
Commit:        83d475626a4d9ecaa2084f349cb2cee4f0f3a719
Parent:        1ea7e2634d67a7628508a677668a00f748aee0b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 19 13:58:43 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 19 16:15:51 2015 -0500

pvscan: use process_each_pv

The old code made two loops through the PVs: in the first
loop it found the max PV and VG name lengths, and in the
second loop it printed each PV using the name lengths as
field widths for aligning columns.

The new code uses process_each_pv() which makes one loop
through the PVs.  In the *first* call to pvscan_single(),
the max name lengths are found by looping through the
lvmcache entries which have been populated by the generic
process_each code prior to calling any _single functions.
Subsequent calls to pvscan_single() reuse the max lengths
that were found by the first call.
---
 lib/cache/lvmcache.c |   24 +++++++
 lib/cache/lvmcache.h |    4 +
 tools/pvscan.c       |  178 ++++++++++++++++++++++----------------------------
 3 files changed, 107 insertions(+), 99 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c495fa7..1bc4241 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2358,3 +2358,27 @@ int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd)
 	return 0;
 }
 
+void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
+				   unsigned *pv_max_name_len,
+				   unsigned *vg_max_name_len)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+	unsigned len;
+
+	*vg_max_name_len = 0;
+	*pv_max_name_len = 0;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		len = strlen(vginfo->vgname);
+		if (*vg_max_name_len < len)
+			*vg_max_name_len = len;
+
+		dm_list_iterate_items(info, &vginfo->infos) {
+			len = strlen(dev_name(info->dev));
+			if (*pv_max_name_len < len)
+				*pv_max_name_len = len;
+		}
+	}
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 76b9b10..ccf3eb4 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -190,4 +190,8 @@ void lvmcache_set_preferred_duplicates(const char *vgid);
 
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 
+void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
+			unsigned *pv_max_name_len, unsigned *vg_max_name_len);
+
+
 #endif
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3adb91c..460b74d 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -18,56 +18,66 @@
 #include "lvmetad.h"
 #include "lvmcache.h"
 
-unsigned pv_max_name_len = 0;
-unsigned vg_max_name_len = 0;
-
-static void _pvscan_display_single(struct cmd_context *cmd,
-				   struct physical_volume *pv,
-				   void *handle __attribute__((unused)))
+struct pvscan_params {
+	int new_pvs_found;
+	int pvs_found;
+	uint64_t size_total;
+	uint64_t size_new;
+	unsigned pv_max_name_len;
+	unsigned vg_max_name_len;
+	unsigned pv_tmp_namelen;
+	char *pv_tmp_name;
+};
+
+static int _pvscan_display_single(struct cmd_context *cmd,
+				  struct physical_volume *pv,
+				  struct pvscan_params *params)
 {
 	/* XXXXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXXXX */
 	char uuid[40] __attribute__((aligned(8)));
-	const unsigned suffix = sizeof(uuid) + 10;
-	char pv_tmp_name[pv_max_name_len + suffix];
-	unsigned pv_len = pv_max_name_len;
+	const unsigned suffix_len = sizeof(uuid) + 10;
+	unsigned pv_len;
 	const char *pvdevname = pv_dev_name(pv);
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
 		log_print_unless_silent("%s", pvdevname);
-		return;
+		return ECMD_PROCESSED;
 	}
 
-	if (arg_count(cmd, verbose_ARG) > 1) {
-		/* FIXME As per pv_display! Drop through for now. */
-		/* pv_show(pv); */
+	if (!params->pv_max_name_len) {
+		lvmcache_get_max_name_lengths(cmd, &params->pv_max_name_len, &params->vg_max_name_len);
 
-		/* FIXME - Moved to Volume Group structure */
-		/* log_print("system ID             %s", pv->vg->system_id); */
+		params->pv_max_name_len += 2;
+		params->vg_max_name_len += 2;
+		params->pv_tmp_namelen = params->pv_max_name_len + suffix_len;
 
-		/* log_print(" "); */
-		/* return; */
+		if (!(params->pv_tmp_name = dm_pool_alloc(cmd->mem, params->pv_tmp_namelen)))
+			return ECMD_FAILED;
 	}
 
+	pv_len = params->pv_max_name_len;
+	memset(params->pv_tmp_name, 0, params->pv_tmp_namelen);
+
 	if (arg_count(cmd, uuid_ARG)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 			stack;
-			return;
+			return ECMD_FAILED;
 		}
 
-		if (dm_snprintf(pv_tmp_name, sizeof(pv_tmp_name), "%-*s with UUID %s",
-				pv_max_name_len - 2, pvdevname, uuid) < 0) {
+		if (dm_snprintf(params->pv_tmp_name, params->pv_tmp_namelen, "%-*s with UUID %s",
+				params->pv_max_name_len - 2, pvdevname, uuid) < 0) {
 			log_error("Invalid PV name with uuid.");
-			return;
+			return ECMD_FAILED;
 		}
-		pvdevname = pv_tmp_name;
-		pv_len += suffix;
+		pvdevname = params->pv_tmp_name;
+		pv_len += suffix_len;
 	}
 
 	if (is_orphan(pv))
 		log_print_unless_silent("PV %-*s    %-*s %s [%s]",
 					pv_len, pvdevname,
-					vg_max_name_len, " ",
+					params->vg_max_name_len, " ",
 					pv->fmt ? pv->fmt->name : "    ",
 					display_size(cmd, pv_size(pv)));
 	else if (pv_status(pv) & EXPORTED_VG)
@@ -78,10 +88,36 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 	else
 		log_print_unless_silent("PV %-*s VG %-*s %s [%s / %s free]",
 					pv_len, pvdevname,
-					vg_max_name_len, pv_vg_name(pv),
+					params->vg_max_name_len, pv_vg_name(pv),
 					pv->fmt ? pv->fmt->name : "    ",
 					display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
 					display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
+	return ECMD_PROCESSED;
+}
+
+static int _pvscan_single(struct cmd_context *cmd, struct volume_group *vg,
+			  struct physical_volume *pv, struct processing_handle *handle)
+{
+	struct pvscan_params *params = (struct pvscan_params *)handle->custom_handle;
+
+	if ((arg_count(cmd, exported_ARG) && !(pv_status(pv) & EXPORTED_VG)) ||
+	    (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
+		return ECMD_PROCESSED;
+
+	}
+
+	params->pvs_found++;
+
+	if (is_orphan(pv)) {
+		params->new_pvs_found++;
+		params->size_new += pv_size(pv);
+		params->size_total += pv_size(pv);
+	} else {
+		params->size_total += (uint64_t) pv_pe_count(pv) * pv_pe_size(pv);
+	}
+
+	_pvscan_display_single(cmd, pv, params);
+	return ECMD_PROCESSED;
 }
 
 #define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5
@@ -327,16 +363,9 @@ out:
 
 int pvscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	int new_pvs_found = 0;
-	int pvs_found = 0;
-
-	struct dm_list *pvslist;
-	struct pv_list *pvl;
-	struct physical_volume *pv;
-
-	uint64_t size_total = 0;
-	uint64_t size_new = 0;
-	unsigned len;
+	struct pvscan_params params = { 0 };
+	struct processing_handle *handle = NULL;
+	int ret;
 
 	if (arg_count(cmd, cache_long_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
@@ -377,80 +406,31 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	if (cmd->full_filter->wipe)
 		cmd->full_filter->wipe(cmd->full_filter);
-	lvmcache_destroy(cmd, 1, 0);
 
-	/* populate lvmcache */
-	if (!lvmetad_vg_list_to_lvmcache(cmd))
-		stack;
-
-	log_verbose("Walking through all physical volumes");
-	if (!(pvslist = get_pvs(cmd))) {
-		unlock_vg(cmd, VG_GLOBAL);
-		return_ECMD_FAILED;
-	}
-
-	/* eliminate exported/new if required */
-	dm_list_iterate_items(pvl, pvslist) {
-		pv = pvl->pv;
-
-		if ((arg_count(cmd, exported_ARG)
-		     && !(pv_status(pv) & EXPORTED_VG)) ||
-		    (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
-			dm_list_del(&pvl->list);
-			free_pv_fid(pv);
-			continue;
-		}
+	lvmcache_destroy(cmd, 1, 0);
 
-		/* Also check for MD use? */
-/*******
-		if (MAJOR(pv_create_kdev_t(pv[p]->pv_name)) != MD_MAJOR) {
-			log_warn
-			    ("WARNING: physical volume \"%s\" belongs to a meta device",
-			     pv[p]->pv_name);
-		}
-		if (MAJOR(pv[p]->pv_dev) != MD_MAJOR)
-			continue;
-********/
-		pvs_found++;
-
-		if (is_orphan(pv)) {
-			new_pvs_found++;
-			size_new += pv_size(pv);
-			size_total += pv_size(pv);
-		} else
-			size_total += (uint64_t) pv_pe_count(pv) * pv_pe_size(pv);
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		ret = ECMD_FAILED;
+		goto out;
 	}
 
-	/* find maximum pv name length */
-	pv_max_name_len = vg_max_name_len = 0;
-	dm_list_iterate_items(pvl, pvslist) {
-		pv = pvl->pv;
-		len = strlen(pv_dev_name(pv));
-		if (pv_max_name_len < len)
-			pv_max_name_len = len;
-		len = strlen(pv_vg_name(pv));
-		if (vg_max_name_len < len)
-			vg_max_name_len = len;
-	}
-	pv_max_name_len += 2;
-	vg_max_name_len += 2;
+	handle->custom_handle = &params;
 
-	dm_list_iterate_items(pvl, pvslist) {
-		_pvscan_display_single(cmd, pvl->pv, NULL);
-		free_pv_fid(pvl->pv);
-	}
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, handle, _pvscan_single);
 
-	if (!pvs_found)
+	if (!params.pvs_found)
 		log_print_unless_silent("No matching physical volumes found");
 	else
 		log_print_unless_silent("Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]",
-					pvs_found,
-					display_size(cmd, size_total),
-					pvs_found - new_pvs_found,
-					display_size(cmd, (size_total - size_new)),
-					new_pvs_found, display_size(cmd, size_new));
+					params.pvs_found,
+					display_size(cmd, params.size_total),
+					params.pvs_found - params.new_pvs_found,
+					display_size(cmd, (params.size_total - params.size_new)),
+					params.new_pvs_found, display_size(cmd, params.size_new));
 
+out:
 	unlock_vg(cmd, VG_GLOBAL);
 
-	return ECMD_PROCESSED;
+	return ret;
 }


