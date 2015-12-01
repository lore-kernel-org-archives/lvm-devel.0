From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  1 Dec 2015 15:12:08 +0000 (UTC)
Subject: master - process_each: always use list of vgnames on system
Message-ID: <20151201151208.D365060E9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ff2583dc5ffb87ad4265d7f0d9063c482cbc3a7
Commit:        4ff2583dc5ffb87ad4265d7f0d9063c482cbc3a7
Parent:        68e2ea11a35b3c204aede9dce23ab99cdedcba32
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 12:51:44 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:09:49 2015 -0600

process_each: always use list of vgnames on system

This makes process_each_vg/lv always use the list of
vgnames on the system.  When specific VGs are named on
the command line, the corresponding entries from
vgnameids_on_system are moved to vgnameids_to_process.

Previously, when specific VGs were named on the command
line, the vgnameids_on_system list was not created, and
vgnameids_to_process was created from the arg_vgnames
list (which is only names, without vgids).

Now, vgnameids_on_system is always created, and entries
are moved from that list to vgnameids_to_process -- either
some (when arg_vgnames specifies only some), or all (when
the command is processing all VGs, or needs to look at
all VGs for checking tags/selection).

This change adds one new lvmetad lookup (vg_list) to a
command that specifies VG names.  It adds no new work
for other commands, e.g. non-lvmetad commands, or
commands that look at all VGs.

When using lvmetad, 'lvs foo' previously sent one
request to lvmetad: 'vg_lookup foo'.
Now, 'lvs foo' sends two requests to lvmetad:
'vg_list' and 'vg_lookup foo <uuid>'.

(The lookup can now always include the uuid in the request
because the initial vg_list contains name/vgid pairs.)
---
 tools/toollib.c |  219 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 169 insertions(+), 50 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index a52252e..889bbb0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1916,6 +1916,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				  struct processing_handle *handle,
 				  process_single_vg_fn_t process_single_vg)
 {
+	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
@@ -1947,6 +1948,11 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		skip = 0;
 		notfound = 0;
 
+		if (vg_uuid)
+			id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid));
+
+		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
+
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
 			continue;
@@ -1966,6 +1972,9 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
 		    select_match_vg(cmd, handle, vg, &selected) && selected) {
+
+			log_very_verbose("Process single VG %s", vg_name);
+
 			ret = process_single_vg(cmd, vg_name, vg, handle);
 			_update_selection_result(handle, &whole_selected);
 			if (ret != ECMD_PROCESSED)
@@ -2017,6 +2026,57 @@ static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *s
 }
 
 /*
+ * For each arg_vgname, move the corresponding entry from
+ * vgnameids_on_system to vgnameids_to_process.  If an
+ * item in arg_vgnames doesn't exist in vgnameids_on_system,
+ * then add a new entry for it to vgnameids_to_process.
+ */
+static void _choose_vgs_to_process(struct cmd_context *cmd,
+				   struct dm_list *arg_vgnames,
+				   struct dm_list *vgnameids_on_system,
+				   struct dm_list *vgnameids_to_process)
+{
+	struct dm_str_list *sl, *sl2;
+	struct vgnameid_list *vgnl, *vgnl2;
+	int found;
+
+	dm_list_iterate_items_safe(sl, sl2, arg_vgnames) {
+		found = 0;
+		dm_list_iterate_items_safe(vgnl, vgnl2, vgnameids_on_system) {
+			if (strcmp(sl->str, vgnl->vg_name))
+				continue;
+
+			dm_list_del(&vgnl->list);
+			dm_list_add(vgnameids_to_process, &vgnl->list);
+			found = 1;
+			break;
+		}
+		
+		/*
+		 * If the name arg was not found in the list of all VGs, then
+		 * it probably doesn't exist, but we want the "VG not found"
+		 * failure to be handled by the existing vg_read() code for
+		 * that error.  So, create an entry with just the VG name so
+		 * that the processing loop will attempt to process it and use
+		 * the vg_read() error path.
+		 */
+		if (!found) {
+			log_verbose("VG name on command line not found in list of VGs: %s", sl->str);
+
+			if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl))))
+				continue;
+
+			vgnl->vgid = NULL;
+
+			if (!(vgnl->vg_name = dm_pool_strdup(cmd->mem, sl->str)))
+				continue;
+
+			dm_list_add(vgnameids_to_process, &vgnl->list);
+		}
+	}
+}
+
+/*
  * Call process_single_vg() for each VG selected by the command line arguments.
  */
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
@@ -2028,9 +2088,10 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list arg_vgnames;		/* str_list */
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
-
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
 	int one_vgname_arg = (cmd->command->flags & ONE_VGNAME_ARG);
+	int process_all_vgs_on_system = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	/* Disable error in vg_read so we can print it from ignore_vg. */
@@ -2044,29 +2105,46 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname_arg, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED)
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname_arg, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
+		ret_max = ret;
 		goto_out;
+	}
 
 	/*
-	 * Obtain the complete list of VGs present on the system if it is needed because:
-	 *   any tags were supplied and need resolving; or
-	 *   no VG names were given and the command defaults to processing all VGs.
+	 * Process all VGs on the system when:
+	 * . tags are specified and all VGs need to be read to
+	 *   look for matching tags.
+	 * . no VG names are specified and the command defaults
+	 *   to processing all VGs when none are specified.
 	 */
-	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) {
-		/* Needed for a current listing of the global VG namespace. */
-		if (!lockd_gl(cmd, "sh", 0)) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
+	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags))
+		process_all_vgs_on_system = 1;
 
-		if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
-			goto_out;
+	/*
+	 * Needed for a current listing of the global VG namespace.
+	 */
+	if (process_all_vgs_on_system && !lockd_gl(cmd, "sh", 0)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
+	/*
+	 * A list of all VGs on the system is needed when:
+	 * . processing all VGs on the system
+	 * . A VG name is specified which may refer to one
+	 *   of multiple VGs on the system with that name.
+	 */
+	log_very_verbose("Get list of VGs on system");
+
+	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
 	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");
-		ret = ECMD_PROCESSED;
+		ret_max = ECMD_PROCESSED;
 		goto out;
 	}
 
@@ -2074,28 +2152,37 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		read_flags |= READ_OK_NOTFOUND;
 
 	/*
-	 * If we obtained a full list of VGs on the system, we need to work through them all;
-	 * otherwise we can merely work through the VG names provided.
+	 * When processing all VGs, vgnameids_on_system simply becomes
+	 * vgnameids_to_process.
+	 * When processing only specified VGs, then for each item in
+	 * arg_vgnames, move the corresponding entry from
+	 * vgnameids_on_system to vgnameids_to_process.
 	 */
-	if (!dm_list_empty(&vgnameids_on_system))
+	if (process_all_vgs_on_system)
 		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
-	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED)
-		goto_out;
+	else
+		_choose_vgs_to_process(cmd, &arg_vgnames, &vgnameids_on_system, &vgnameids_to_process);
 
-	if (!handle && !(handle = init_processing_handle(cmd)))
+	if (!handle && !(handle = init_processing_handle(cmd))) {
+		ret_max = ECMD_FAILED;
 		goto_out;
+	}
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle, VGS))
+	    !init_selection_handle(cmd, handle, VGS)) {
+		ret_max = ECMD_FAILED;
 		goto_out;
+	}
 
 	ret = _process_vgnameid_list(cmd, read_flags, &vgnameids_to_process,
 				     &arg_vgnames, &arg_tags, handle, process_single_vg);
+	if (ret > ret_max)
+		ret_max = ret;
 out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
 
-	return ret;
+	return ret_max;
 }
 
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
@@ -2386,6 +2473,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 				     struct processing_handle *handle,
 				     process_single_lv_fn_t process_single_lv)
 {
+	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
 	struct dm_str_list *sl;
@@ -2440,6 +2528,11 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			}
 		}
 
+		if (vg_uuid)
+			id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid));
+
+		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
+
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
 			continue;
@@ -2483,9 +2576,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 	struct dm_list arg_lvnames;		/* str_list */
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
-
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
-	int need_vgnameids = 0;
+	int process_all_vgs_on_system = 0;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	/* Disable error in vg_read so we can print it from ignore_vg. */
@@ -2500,44 +2593,63 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 	/*
 	 * Find any LVs, VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED))
+	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
+		ret_max = ret;
 		goto_out;
+	}
 
-	if (!handle && !(handle = init_processing_handle(cmd)))
+	if (!handle && !(handle = init_processing_handle(cmd))) {
+		ret_max = ECMD_FAILED;
 		goto_out;
+	}
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle, LVS))
+	    !init_selection_handle(cmd, handle, LVS)) {
+		ret_max = ECMD_FAILED;
 		goto_out;
+	}
 
 	/*
-	 * Obtain the complete list of VGs present on the system if it is needed because:
-	 *   any tags were supplied and need resolving; or
-	 *   no VG names were given and the select option needs resolving; or
-	 *   no VG names were given and the command defaults to processing all VGs.
-	*/
+	 * Process all VGs on the system when:
+	 * . tags are specified and all VGs need to be read to
+	 *   look for matching tags.
+	 * . no VG names are specified and the command defaults
+	 *   to processing all VGs when none are specified.
+	 * . no VG names are specified and the select option needs
+	 *   resolving.
+	 */
 	if (!dm_list_empty(&arg_tags))
-		need_vgnameids = 1;
+		process_all_vgs_on_system = 1;
 	else if (dm_list_empty(&arg_vgnames) && enable_all_vgs)
-		need_vgnameids = 1;
+		process_all_vgs_on_system = 1;
 	else if (dm_list_empty(&arg_vgnames) && handle->internal_report_for_select)
-		need_vgnameids = 1;
+		process_all_vgs_on_system = 1;
 
-	if (need_vgnameids) {
-		/* Needed for a current listing of the global VG namespace. */
-		if (!lockd_gl(cmd, "sh", 0)) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
+	/*
+	 * Needed for a current listing of the global VG namespace.
+	 */
+	if (process_all_vgs_on_system && !lockd_gl(cmd, "sh", 0)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
 
-		if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
-			goto_out;
+	/*
+	 * A list of all VGs on the system is needed when:
+	 * . processing all VGs on the system
+	 * . A VG name is specified which may refer to one
+	 *   of multiple VGs on the system with that name.
+	 */
+	log_very_verbose("Get list of VGs on system");
+
+	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
 	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");
-		ret = ECMD_PROCESSED;
+		ret_max = ECMD_PROCESSED;
 		goto out;
 	}
 
@@ -2545,20 +2657,27 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 		read_flags |= READ_OK_NOTFOUND;
 
 	/*
-	 * If we obtained a full list of VGs on the system, we need to work through them all;
-	 * otherwise we can merely work through the VG names provided.
+	 * When processing all VGs, vgnameids_on_system simply becomes
+	 * vgnameids_to_process.
+	 * When processing only specified VGs, then for each item in
+	 * arg_vgnames, move the corresponding entry from
+	 * vgnameids_on_system to vgnameids_to_process.
 	 */
-	if (!dm_list_empty(&vgnameids_on_system))
+	if (process_all_vgs_on_system)
 		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
-	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED)
-		goto_out;
+	else
+		_choose_vgs_to_process(cmd, &arg_vgnames, &vgnameids_on_system, &vgnameids_to_process);
 
 	ret = _process_lv_vgnameid_list(cmd, read_flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
 					&arg_tags, handle, process_single_lv);
+
+	if (ret > ret_max)
+		ret_max = ret;
 out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
-	return ret;
+
+	return ret_max;
 }
 
 static int _get_arg_pvnames(struct cmd_context *cmd,


