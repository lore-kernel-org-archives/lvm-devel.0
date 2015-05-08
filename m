From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 May 2015 16:49:56 +0000 (UTC)
Subject: master - toollib: avoid repeated lvmetad vg_lookup
Message-ID: <20150508164956.0207A60F07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e509b5dd50bff30e5017f572e54f4f384830a58
Commit:        8e509b5dd50bff30e5017f572e54f4f384830a58
Parent:        f25132b354b110994b9da8dc3edf39cf4db37657
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 5 16:24:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 8 11:44:55 2015 -0500

toollib: avoid repeated lvmetad vg_lookup

In process_each_{vg,lv,pv} when no vgname args are given,
the first step is to get a list of all vgid/vgname on the
system.  This is exactly what lvmetad returns from a
vg_list request.  The current code is doing a vg_lookup
on each VG after the vg_list and populating lvmcache with
the info for each VG.  These preliminary vg_lookup's are
unnecessary, because they will be done again when the
processing functions call vg_read.  This patch eliminates
the initial round of vg_lookup's, which can roughly cut in
half the number of lvmetad requests and save a lot of extra work.
---
 lib/cache/lvmcache.c             |   31 +++++++++++++
 lib/cache/lvmcache.h             |    3 +
 lib/cache/lvmetad.c              |   50 +++++++++++++++++++++
 lib/cache/lvmetad.h              |    6 +++
 lib/metadata/metadata-exported.h |    8 +++
 lib/metadata/metadata.c          |   48 ++++++++++++++++++++
 tools/toollib.c                  |   91 +++++++-------------------------------
 7 files changed, 162 insertions(+), 75 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1586f30..d44f9d4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -905,6 +905,37 @@ int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo
 }
 // #endif
 
+int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
+			   struct dm_list *vgnameids)
+{
+	struct vgnameid_list *vgnl;
+	struct lvmcache_vginfo *vginfo;
+
+	lvmcache_label_scan(cmd, 0);
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (!include_internal && is_orphan_vg(vginfo->vgname))
+			continue;
+
+		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+			log_error("vgnameid_list allocation failed.");
+			return 0;
+		}
+
+		vgnl->vgid = dm_pool_strdup(cmd->mem, vginfo->vgid);
+		vgnl->vg_name = dm_pool_strdup(cmd->mem, vginfo->vgname);
+
+		if (!vgnl->vgid || !vgnl->vg_name) {
+			log_error("vgnameid_list member allocation failed.");
+			return 0;
+		}
+
+		dm_list_add(vgnameids, &vgnl->list);
+	}
+
+	return 1;
+}
+
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 6a43204..780325a 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -107,6 +107,9 @@ struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal);
 
+int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
+                          struct dm_list *vgnameids);
+
 /* Returns list of struct dm_str_list containing pool-allocated copy of pvids */
 struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index fd0630f..0a79c50 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -673,6 +673,56 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	return 1;
 }
 
+int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids)
+{
+	struct vgnameid_list *vgnl;
+	struct id vgid;
+	const char *vgid_txt;
+	const char *vg_name;
+	daemon_reply reply;
+	struct dm_config_node *cn;
+
+	log_debug_lvmetad("Asking lvmetad for complete list of known VG ids/names");
+	reply = _lvmetad_send("vg_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
+		daemon_reply_destroy(reply);
+		return_0;
+	}
+
+	if ((cn = dm_config_find_node(reply.cft->root, "volume_groups"))) {
+		for (cn = cn->child; cn; cn = cn->sib) {
+			vgid_txt = cn->key;
+			if (!id_read_format(&vgid, vgid_txt)) {
+				stack;
+				continue;
+			}
+
+			if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+				log_error("vgnameid_list allocation failed.");
+				return 0;
+			}
+
+			if (!(vg_name = dm_config_find_str(cn->child, "name", NULL))) {
+				log_error("vg_list no name found.");
+				return 0;
+			}
+
+			vgnl->vgid = dm_pool_strdup(cmd->mem, (char *)&vgid);
+			vgnl->vg_name = dm_pool_strdup(cmd->mem, vg_name);
+
+			if (!vgnl->vgid || !vgnl->vg_name) {
+				log_error("vgnameid_list member allocation failed.");
+				return 0;
+			}
+
+			dm_list_add(vgnameids, &vgnl->list);
+		}
+	}
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
 int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 {
 	struct volume_group *tmp;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index b5bac69..4ee07bb 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -143,6 +143,12 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd);
 
 /*
+ * Request a list of vgid/vgname pairs for all VGs known to lvmetad.
+ * Does not do vg_lookup's on each VG, and does not populate lvmcache.
+ */
+int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids);
+
+/*
  * Find a VG by its ID or its name in the lvmetad cache. Gives NULL if the VG is
  * not found.
  */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 47fb9ae..0e52153 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -494,6 +494,12 @@ struct vg_list {
 	struct volume_group *vg;
 };
 
+struct vgnameid_list {
+	struct dm_list list;
+	const char *vg_name;
+	const char *vgid;
+};
+
 #define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
 
 struct pvcreate_restorable_params {
@@ -606,6 +612,8 @@ void lv_set_hidden(struct logical_volume *lv);
 
 struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
+int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
+		  const char *only_this_vgname, int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd, uint32_t warn_flags);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv, int allow_non_orphan);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2a5be7d..19741ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4017,6 +4017,54 @@ struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 	return lvmcache_get_vgids(cmd, include_internal);
 }
 
+int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
+		  const char *only_this_vgname, int include_internal)
+{
+	struct vgnameid_list *vgnl;
+	struct format_type *fmt;
+
+	if (only_this_vgname) {
+		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+			log_error("vgnameid_list allocation failed.");
+			return 0;
+		}
+
+		vgnl->vg_name = dm_pool_strdup(cmd->mem, only_this_vgname);
+		vgnl->vgid = NULL;
+		dm_list_add(vgnameids, &vgnl->list);
+		return 1;
+	}
+
+	if (lvmetad_active()) {
+		/*
+		 * This just gets the list of names/ids from lvmetad
+		 * and does not populate lvmcache.
+		 */
+		lvmetad_get_vgnameids(cmd, vgnameids);
+
+		if (include_internal) {
+			dm_list_iterate_items(fmt, &cmd->formats) {
+				if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+					log_error("vgnameid_list allocation failed.");
+					return 0;
+				}
+
+				vgnl->vg_name = dm_pool_strdup(cmd->mem, fmt->orphan_vg_name);
+				vgnl->vgid = NULL;
+				dm_list_add(vgnameids, &vgnl->list);
+			}
+		}
+	} else {
+		/*
+		 * The non-lvmetad case. This function begins by calling
+		 * lvmcache_label_scan() to populate lvmcache.
+		 */
+		lvmcache_get_vgnameids(cmd, include_internal, vgnameids);
+	}
+
+	return 1;
+}
+
 static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
diff --git a/tools/toollib.c b/tools/toollib.c
index e6c3cdb..ae48e7b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1515,12 +1515,6 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
 	return -1;
 }
 
-struct vgnameid_list {
-	struct dm_list list;
-	const char *vg_name;
-	const char *vgid;
-};
-
 /*
  * Extract list of VG names and list of tags from command line arguments.
  */
@@ -1584,67 +1578,6 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
-/*
- * FIXME Add arg to include (or not) entries with duplicate vg names?
- *
- * Obtain complete list of VG name/vgid pairs known on the system.
- */
-static int _get_vgnameids_on_system(struct cmd_context *cmd,
-				    struct dm_list *vgnameids_on_system,
-				    const char *only_this_vgname, int include_internal)
-{
-	struct vgnameid_list *vgnl;
-	struct dm_list *vgids;
-	struct dm_str_list *sl;
-	const char *vgid;
-
-	if (only_this_vgname) {
-		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
-		if (!vgnl) {
-			log_error("name_id_list allocation failed.");
-			return ECMD_FAILED;
-		}
-
-		vgnl->vg_name = dm_pool_strdup(cmd->mem, only_this_vgname);
-		vgnl->vgid = NULL;
-
-		dm_list_add(vgnameids_on_system, &vgnl->list);
-		return ECMD_PROCESSED;
-	}
-
-	log_verbose("Finding all volume groups.");
-
-	if (!lvmetad_vg_list_to_lvmcache(cmd))
-		stack;
-
-	/*
-	 * Start with complete vgid list because multiple VGs might have same name.
-	 */
-	vgids = get_vgids(cmd, include_internal);
-	if (!vgids || dm_list_empty(vgids)) {
-		stack;
-		return ECMD_PROCESSED;
-	}
-
-	/* FIXME get_vgids() should provide these pairings directly */
-	dm_list_iterate_items(sl, vgids) {
-		if (!(vgid = sl->str))
-			continue;
-
-		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
-			log_error("vgnameid_list allocation failed.");
-			return ECMD_FAILED;
-		}
-
-		vgnl->vgid = dm_pool_strdup(cmd->mem, vgid);
-		vgnl->vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid);
-
-		dm_list_add(vgnameids_on_system, &vgnl->list);
-	}
-
-	return ECMD_PROCESSED;
-}
-
 struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 {
 	struct processing_handle *handle;
@@ -1903,7 +1836,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED))
+	    !get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
 		goto_out;
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
@@ -2304,6 +2237,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
 
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int need_vgnameids = 0;
 	int ret;
 
 	cmd->error_foreign_vgs = 0;
@@ -2330,11 +2264,17 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	/*
 	 * Obtain the complete list of VGs present on the system if it is needed because:
 	 *   any tags were supplied and need resolving; or
+	 *   no VG names were given and the select option needs resolving; or
 	 *   no VG names were given and the command defaults to processing all VGs.
 	*/
-	if (((dm_list_empty(&arg_vgnames) && (enable_all_vgs ||
-	      handle->internal_report_for_select)) || !dm_list_empty(&arg_tags)) &&
-	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0) != ECMD_PROCESSED))
+	if (!dm_list_empty(&arg_tags))
+		need_vgnameids = 1;
+	else if (dm_list_empty(&arg_vgnames) && enable_all_vgs)
+		need_vgnameids = 1;
+	else if (dm_list_empty(&arg_vgnames) && handle->internal_report_for_select)
+		need_vgnameids = 1;
+
+	if (need_vgnameids && !get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
 		goto_out;
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
@@ -2822,11 +2762,12 @@ int process_each_pv(struct cmd_context *cmd,
 			      arg_count(cmd, all_ARG);
 
 	/*
-	 * Read all the vgs here because this has the effect of initializing
-	 * device/lvmcache info so that dev->pvid is available when creating
-	 * a list of devices.
+	 * Need pvid's set on all PVs before processing so that pvid's
+	 * can be compared to find duplicates while processing.
 	 */
-	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
 		stack;
 		return ret;
 	}


