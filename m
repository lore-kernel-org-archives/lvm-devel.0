From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:15 +0000 (UTC)
Subject: master - polldaemon: refactor polling interfaces
Message-ID: <20150505185415.77F8C60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76a0dffe6f4869de9ca457119c9d7ced837d4e0b
Commit:        76a0dffe6f4869de9ca457119c9d7ced837d4e0b
Parent:        bda26acf70e92232b1ed644dba6b44ecbff2a058
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 10 14:08:19 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:52:07 2015 +0200

polldaemon: refactor polling interfaces

Routines responsible for polling of in-progress pvmove, snapshot merge
or mirror conversion each used custom lookup functions to find vg and
lv involved in polling.

Especially pvmove used pvname to lookup pvmove in-progress. The future
lvmpolld will poll each operation by vg/lv name (internally by lvid).
Also there're plans to make pvmove able to move non-overlaping ranges
of extents instead of single PVs as of now. This would also require
to identify the opertion in different manner.

The poll_operation_id structure together with daemon_parms structure they
identify unambiguously the polling task.
---
 tools/lvconvert.c   |   69 +++++++++++++++++------
 tools/polldaemon.c  |  122 ++++++++++++++++++++++++++++++-----------
 tools/polldaemon.h  |   12 +++-
 tools/pvmove.c      |  153 ++++++++++++++++++++++++++++++++++++++++++++++-----
 tools/pvmove_poll.c |   27 ---------
 tools/pvmove_poll.h |    9 ---
 tools/toollib.c     |    2 +-
 tools/tools.h       |    5 +-
 8 files changed, 291 insertions(+), 108 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 41aaad6..5b2ab65 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -720,37 +720,68 @@ static struct poll_functions _lvconvert_thin_merge_fns = {
 	.finish_copy = lvconvert_merge_finish,
 };
 
+static void _destroy_id(struct cmd_context *cmd, struct poll_operation_id *id)
+{
+	if (!id)
+		return;
+
+	dm_pool_free(cmd->mem, (void *)id);
+}
+
+static struct poll_operation_id *_create_id(struct cmd_context *cmd,
+					    const char *vg_name,
+					    const char *lv_name,
+					    const char *uuid)
+{
+	char lv_full_name[NAME_LEN];
+	struct poll_operation_id *id = dm_pool_alloc(cmd->mem, sizeof(struct poll_operation_id));
+	if (!id) {
+		log_error("Poll operation ID allocation failed.");
+		return NULL;
+	}
+
+	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", vg_name, lv_name) < 0) {
+		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", vg_name, lv_name);
+		_destroy_id(cmd, id);
+		return NULL;
+	}
+
+	id->display_name = dm_pool_strdup(cmd->mem, lv_full_name);
+	id->vg_name = vg_name ? dm_pool_strdup(cmd->mem, vg_name) : NULL;
+	id->lv_name = id->display_name ? strchr(id->display_name, '/') + 1 : NULL;
+	id->uuid = uuid ? dm_pool_strdup(cmd->mem, uuid) : NULL;
+
+	if (!id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
+		log_error("Failed to copy one or more poll operation ID members.");
+		_destroy_id(cmd, id);
+		id = NULL;
+	}
+
+	return id;
+}
+
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
-	/*
-	 * FIXME allocate an "object key" structure with split
-	 * out members (vg_name, lv_name, uuid, etc) and pass that
-	 * around the lvconvert and polldaemon code
-	 * - will avoid needless work, e.g. extract_vgname()
-	 * - unfortunately there are enough overloaded "name" dragons in
-	 *   the polldaemon, lvconvert, pvmove code that a comprehensive
-	 *   audit/rework is needed
-	 */
-	char uuid[sizeof(lv->lvid)];
-	char lv_full_name[NAME_LEN];
 	int is_thin, r;
+	struct poll_operation_id *id = _create_id(cmd, lv->vg->name, lv->name, lv->lvid.s);
 
-	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", lv->vg->name, lv->name) < 0) {
-		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", lv->vg->name, lv->name);
+	if (!id) {
+		log_error("Failed to allocate poll identifier for lvconvert.");
 		return ECMD_FAILED;
 	}
 
-	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
-
 	if (lv_is_merging_origin(lv)) {
 		is_thin = seg_is_thin_volume(find_snapshot(lv));
-		r = poll_daemon(cmd, lv_full_name, uuid, background, 0,
+		r = poll_daemon(cmd, background,
+				(MERGING | (is_thin ? THIN_VOLUME : SNAPSHOT)),
 				is_thin ? &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
-				"Merged");
+				"Merged", id);
 	} else
-		r = poll_daemon(cmd, lv_full_name, uuid, background, 0,
-				&_lvconvert_mirror_fns, "Converted");
+		r = poll_daemon(cmd, background, CONVERTING,
+				&_lvconvert_mirror_fns, "Converted", id);
+
+	_destroy_id(cmd, id);
 
 	return r;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 4a4983a..4c010f5 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -143,7 +143,7 @@ static void _sleep_and_rescan_devices(struct daemon_parms *parms)
 	}
 }
 
-static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const char *uuid,
+static int _wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 			       struct daemon_parms *parms)
 {
 	struct volume_group *vg;
@@ -156,26 +156,26 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 			_sleep_and_rescan_devices(parms);
 
 		/* Locks the (possibly renamed) VG again */
-		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid, READ_FOR_UPDATE);
+		vg = parms->poll_fns->get_copy_vg(cmd, id->vg_name, NULL, READ_FOR_UPDATE);
 		if (vg_read_error(vg)) {
 			release_vg(vg);
-			log_error("ABORTING: Can't reread VG for %s", name);
+			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
 			/* What more could we do here? */
 			return 0;
 		}
 
-		lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid, parms->lv_type);
+		lv = parms->poll_fns->get_copy_lv(cmd, vg, id->lv_name, id->uuid, parms->lv_type);
 
 		if (!lv && parms->lv_type == PVMOVE) {
 			log_print_unless_silent("%s: no pvmove in progress - already finished or aborted.",
-						name);
+						id->display_name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 1;
 		}
 
 		if (!lv) {
-			log_error("ABORTING: Can't find LV in %s for %s",
-				  vg->name, name);
+			log_error("ABORTING: Can't find LV in %s for %s.",
+				  vg->name, id->display_name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
@@ -185,12 +185,12 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 		 * queried for its status.  We must exit in this case.
 		 */
 		if (!lv_is_active_locally(lv)) {
-			log_print_unless_silent("%s: Interrupted: No longer active.", name);
+			log_print_unless_silent("%s: Interrupted: No longer active.", id->display_name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 1;
 		}
 
-		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
+		if (!_check_lv_status(cmd, vg, lv, id->display_name, parms, &finished)) {
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return_0;
 		}
@@ -216,15 +216,65 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 	return 1;
 }
 
+struct poll_id_list {
+	struct dm_list list;
+	struct poll_operation_id *id;
+};
+
+static struct poll_operation_id *copy_poll_operation_id(struct dm_pool *mem,
+							const struct poll_operation_id *id)
+{
+	struct poll_operation_id *copy;
+
+	if (!id)
+		return_NULL;
+
+	copy = (struct poll_operation_id *) dm_pool_alloc(mem, sizeof(struct poll_operation_id));
+	if (!copy) {
+		log_error("Poll operation ID allocation failed.");
+		return NULL;
+	}
+
+	copy->display_name = id->display_name ? dm_pool_strdup(mem, id->display_name) : NULL;
+	copy->lv_name = id->lv_name ? dm_pool_strdup(mem, id->lv_name) : NULL;
+	copy->vg_name = id->vg_name ? dm_pool_strdup(mem, id->vg_name) : NULL;
+	copy->uuid = id->uuid ? dm_pool_strdup(mem, id->uuid) : NULL;
+
+	if (!copy->display_name || !copy->lv_name || !copy->vg_name || !copy->uuid) {
+		log_error("Failed to copy one or more poll_operation_id members.");
+		return NULL;
+	}
+
+	return copy;
+}
+
+static struct poll_id_list* poll_id_list_create(struct dm_pool *mem,
+						const struct poll_operation_id *id)
+{
+	struct poll_id_list *idl = (struct poll_id_list *) dm_pool_alloc(mem, sizeof(struct poll_id_list));
+
+	if (!idl) {
+		log_error("Poll ID list allocation failed.");
+		return NULL;
+	}
+
+	if (!(idl->id = copy_poll_operation_id(mem, id))) {
+		dm_pool_free(mem, idl);
+		return NULL;
+	}
+
+	return idl;
+}
+
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct daemon_parms *parms;
 	struct lv_list *lvl;
-	struct dm_list *sls;
-	struct dm_str_list *sl;
+	struct dm_list idls;
+	struct poll_id_list *idl;
+	struct poll_operation_id id;
 	struct logical_volume *lv;
-	const char *name;
 	int finished;
 
 	if (!handle || !(parms = (struct daemon_parms *) handle->custom_handle)) {
@@ -232,8 +282,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		return ECMD_FAILED;
 	}
 
-	if (!(sls = str_list_create(cmd->mem)))
-		return ECMD_FAILED;
+	dm_list_init(&idls);
 
 	/*
 	 * first iterate all LVs in a VG and collect LVs suitable
@@ -243,11 +292,11 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;
-		name = parms->poll_fns->get_copy_name_from_lv(lv);
-		if (!name && !parms->aborting)
+		id.display_name = parms->poll_fns->get_copy_name_from_lv(lv);
+		if (!id.display_name && !parms->aborting)
 			continue;
 
-		if (!name) {
+		if (!id.display_name) {
 			log_error("Device name for LV %s not found in metadata. "
 				  "(unfinished pvmove mirror removal?)", display_lvname(lv));
 			goto err;
@@ -256,25 +305,33 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting. */
 		if (!lv_is_active(lv)) {
-			log_print_unless_silent("%s: Skipping inactive LV. Try lvchange or vgchange.", name);
+			log_print_unless_silent("%s: Skipping inactive LV. Try lvchange or vgchange.", id.display_name);
 			continue;
 		}
 
-		if (!str_list_add(cmd->mem, sls, dm_pool_strdup(cmd->mem, name))) {
-			log_error("Failed to clone pvname");
+		id.lv_name = lv->name;
+		id.vg_name = vg->name;
+		id.uuid = lv->lvid.s;
+
+		idl = poll_id_list_create(cmd->mem, &id);
+		if (!idl) {
+			log_error("Failed to create poll_id_list.");
 			goto err;
 		}
+
+		dm_list_add(&idls, &idl->list);
 	}
 
 	/* perform the poll operation on LVs collected in previous cycle */
-	dm_list_iterate_items(sl, sls) {
-		lv = parms->poll_fns->get_copy_lv(cmd, vg, sl->str, NULL, parms->lv_type);
-		if (lv && _check_lv_status(cmd, vg, lv, sl->str, parms, &finished) && !finished)
+	dm_list_iterate_items(idl, &idls) {
+		lv = parms->poll_fns->get_copy_lv(cmd, vg, idl->id->lv_name, idl->id->uuid, parms->lv_type);
+		if (lv && _check_lv_status(cmd, vg, lv, idl->id->display_name, parms, &finished) && !finished)
 			parms->outstanding_count++;
 	}
 
 err:
-	dm_pool_free(cmd->mem, sls);
+	if (!dm_list_empty(&idls))
+		dm_pool_free(cmd->mem, dm_list_item(dm_list_first(&idls), struct poll_id_list));
 
 	return ECMD_PROCESSED;
 }
@@ -299,8 +356,8 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
  * - 'background' is advisory so a child polldaemon may not be used even
  *   if it was requested.
  */
-static int _poll_daemon(struct cmd_context *cmd, const char *name,
-			const char *uuid, struct daemon_parms *parms)
+static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
+			struct daemon_parms *parms)
 {
 	struct processing_handle *handle = NULL;
 	int daemon_mode = 0;
@@ -319,8 +376,8 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 	/*
 	 * Process one specific task or all incomplete tasks?
 	 */
-	if (name) {
-		if (!_wait_for_single_lv(cmd, name, uuid, parms)) {
+	if (id) {
+		if (!_wait_for_single_lv(cmd, id, parms)) {
 			stack;
 			ret = ECMD_FAILED;
 		}
@@ -382,15 +439,16 @@ static int _daemon_parms_init(struct cmd_context *cmd, struct daemon_parms *parm
 	return 1;
 }
 
-int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
-		unsigned background,
+int poll_daemon(struct cmd_context *cmd, unsigned background,
 		uint64_t lv_type, struct poll_functions *poll_fns,
-		const char *progress_title)
+		const char *progress_title, struct poll_operation_id *id)
 {
 	struct daemon_parms parms;
 
 	if (!_daemon_parms_init(cmd, &parms, background, poll_fns, progress_title, lv_type))
 		return_EINVALID_CMD_LINE;
 
-	return _poll_daemon(cmd, name, uuid, &parms);
+	/* classical polling allows only PMVOVE or 0 values */
+	parms.lv_type &= PVMOVE;
+	return _poll_daemon(cmd, id, &parms);
 }
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index 1779007..9c33250 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -52,6 +52,13 @@ struct poll_functions {
 			    struct dm_list *lvs_changed);
 };
 
+struct poll_operation_id {
+	const char *vg_name;
+	const char *lv_name;
+	const char *display_name;
+	const char *uuid;
+};
+
 struct daemon_parms {
 	unsigned interval;
 	unsigned wait_before_testing;
@@ -64,10 +71,9 @@ struct daemon_parms {
 	struct poll_functions *poll_fns;
 };
 
-int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
-		unsigned background,
+int poll_daemon(struct cmd_context *cmd, unsigned background,
 		uint64_t lv_type, struct poll_functions *poll_fns,
-		const char *progress_title);
+		const char *progress_title, struct poll_operation_id *id);
 
 progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 90cf5fe..70fba99 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -569,8 +569,24 @@ out:
 	return r;
 }
 
+static int _copy_id_components(struct cmd_context *cmd,
+			       const struct logical_volume *lv, char **vg_name,
+			       char **lv_name, union lvid *lvid)
+{
+	if (!(*vg_name = dm_pool_strdup(cmd->mem, lv->vg->name)) ||
+	    !(*lv_name = dm_pool_strdup(cmd->mem, lv->name))) {
+		log_error("Failed to clone VG or LV name.");
+		return 0;
+	}
+
+	*lvid = lv->lvid;
+
+	return 1;
+}
+
 static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
-			  int argc, char **argv)
+			  int argc, char **argv, union lvid *lvid, char **vg_name,
+			  char **lv_mirr_name)
 {
 	const char *lv_name = NULL;
 	char *pv_name_arg;
@@ -613,7 +629,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	vg = get_vg(cmd, pv_vg_name(pv));
+	vg = poll_get_copy_vg(cmd, pv_vg_name(pv), NULL, READ_FOR_UPDATE);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
@@ -674,6 +690,9 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		if (!_update_metadata(cmd, vg, lv_mirr, lvs_changed, exclusive))
 			goto_out;
 
+	if (!_copy_id_components(cmd, lv_mirr, vg_name, lv_mirr_name, lvid))
+		goto out;
+
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:
@@ -682,30 +701,122 @@ out:
 	return r;
 }
 
+static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_name,
+				     union lvid *lvid, char **vg_name, char **lv_name,
+				     unsigned *in_progress)
+{
+	int ret = 0;
+	struct logical_volume *lv;
+	struct physical_volume *pv;
+	struct volume_group *vg;
+
+	if (!pv_name) {
+		log_error(INTERNAL_ERROR "Invalid PV name parameter.");
+		return 0;
+	}
+
+	if (!(pv = find_pv_by_name(cmd, pv_name, 0, 0)))
+		return_0;
+
+	/* need read-only access */
+	vg = poll_get_copy_vg(cmd, pv_vg_name(pv), NULL, 0);
+	if (vg_read_error(vg)) {
+		log_error("ABORTING: Can't read VG for %s.", pv_name);
+		release_vg(vg);
+		free_pv_fid(pv);
+		return 0;
+	}
+
+	if (!(lv = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
+		log_print_unless_silent("%s: no pvmove in progress - already finished or aborted.",
+					pv_name);
+		ret = 1;
+		*in_progress = 0;
+	} else if (_copy_id_components(cmd, lv, vg_name, lv_name, lvid)) {
+		ret = 1;
+		*in_progress = 1;
+	}
+
+	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
+	free_pv_fid(pv);
+	return ret;
+}
+
 static struct poll_functions _pvmove_fns = {
 	.get_copy_name_from_lv = get_pvmove_pvname_from_lv_mirr,
-	.get_copy_vg = pvmove_get_copy_vg,
-	.get_copy_lv = find_pvmove_lv_from_pvname,
+	.get_copy_vg = poll_get_copy_vg,
+	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
 	.update_metadata = pvmove_update_metadata,
 	.finish_copy = pvmove_finish,
 };
 
+static void _destroy_id(struct cmd_context *cmd, struct poll_operation_id *id)
+{
+	if (!id)
+		return;
+
+	dm_pool_free(cmd->mem, id);
+}
+
+static struct poll_operation_id *_create_id(struct cmd_context *cmd,
+					    const char *pv_name,
+					    const char *vg_name,
+					    const char *lv_name,
+					    const char *uuid)
+{
+	struct poll_operation_id *id = dm_pool_alloc(cmd->mem, sizeof(struct poll_operation_id));
+	if (!id) {
+		log_error("Poll operation ID allocation failed.");
+		return NULL;
+	}
+
+	id->vg_name = vg_name ? dm_pool_strdup(cmd->mem, vg_name) : NULL;
+	id->lv_name = lv_name ? dm_pool_strdup(cmd->mem, lv_name) : NULL;
+	id->display_name = pv_name ? dm_pool_strdup(cmd->mem, pv_name) : NULL;
+	id->uuid = uuid ? dm_pool_strdup(cmd->mem, uuid) : NULL;
+
+	if (!id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
+		log_error("Failed to copy one or more poll operation ID members.");
+		_destroy_id(cmd, id);
+		id = NULL;
+	}
+
+	return id;
+}
+
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
-		unsigned background)
+		const char *uuid, const char *vg_name,
+		const char *lv_name, unsigned background)
 {
+	int r;
+	struct poll_operation_id *id = NULL;
+
 	if (test_mode())
 		return ECMD_PROCESSED;
 
-	return poll_daemon(cmd, pv_name, NULL, background, PVMOVE, &_pvmove_fns,
-			   "Moved");
+	if (uuid) {
+		id = _create_id(cmd, pv_name, vg_name, lv_name, uuid);
+		if (!id) {
+			log_error("Failed to allocate poll identifier for pvmove.");
+			return ECMD_FAILED;
+		}
+	}
+
+	r = poll_daemon(cmd, background, PVMOVE, &_pvmove_fns, "Moved", id);
+
+	_destroy_id(cmd, id);
+
+	return r;
 }
 
 int pvmove(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *pv_name = NULL;
 	char *colon;
 	int ret;
+	unsigned in_progress = 1;
+	union lvid *lvid = NULL;
+	char *pv_name = NULL, *vg_name = NULL, *lv_name = NULL;
 
 	/* dm raid1 target must be present in every case */
 	if (!_pvmove_target_present(cmd, 0)) {
@@ -715,8 +826,13 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (argc) {
+		if (!(lvid = dm_pool_alloc(cmd->mem, sizeof(*lvid)))) {
+			log_error("Failed to allocate lvid.");
+			return ECMD_FAILED;
+		}
+
 		if (!(pv_name = dm_pool_strdup(cmd->mem, argv[0]))) {
-			log_error("Failed to clone PV name");
+			log_error("Failed to clone PV name.");
 			return ECMD_FAILED;
 		}
 
@@ -726,13 +842,20 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		if (colon)
 			*colon = '\0';
 
-		if (!arg_count(cmd, abort_ARG) &&
-		    (ret = _set_up_pvmove(cmd, pv_name, argc, argv)) !=
-		    ECMD_PROCESSED) {
-			stack;
-			return ret;
+		if (!arg_count(cmd, abort_ARG)) {
+			if ((ret = _set_up_pvmove(cmd, pv_name, argc, argv, lvid, &vg_name, &lv_name)) != ECMD_PROCESSED) {
+				stack;
+				return ret;
+			}
+		} else {
+			if (!_read_poll_id_from_pvname(cmd, pv_name, lvid, &vg_name, &lv_name, &in_progress))
+				return_ECMD_FAILED;
+
+			if (!in_progress)
+				return ECMD_PROCESSED;
 		}
 	}
 
-	return pvmove_poll(cmd, pv_name, arg_is_set(cmd, background_ARG));
+	return pvmove_poll(cmd, pv_name, lvid ? lvid->s : NULL, vg_name, lv_name,
+			   arg_is_set(cmd, background_ARG));
 }
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index eeaf390..61ebd23 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -16,13 +16,6 @@
 #include "pvmove_poll.h"
 #include "tools.h"
 
-struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname)
-{
-	dev_close_all();
-
-	return vg_read_for_update(cmd, vgname, NULL, 0);
-}
-
 static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 				      void *baton)
 {
@@ -201,23 +194,3 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 
 	return r;
 }
-
-struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd, const char *name,
-					const char *uuid __attribute__((unused)),
-					uint32_t flags __attribute__((unused)))
-{
-	struct physical_volume *pv;
-	struct volume_group *vg;
-
-	/* Reread all metadata in case it got changed */
-	if (!(pv = find_pv_by_name(cmd, name, 0, 0))) {
-		log_error("ABORTING: Can't reread PV %s", name);
-		/* What more could we do here? */
-		return NULL;
-	}
-
-	vg = get_vg(cmd, pv_vg_name(pv));
-	free_pv_fid(pv);
-
-	return vg;
-}
diff --git a/tools/pvmove_poll.h b/tools/pvmove_poll.h
index ae7505a..b12458f 100644
--- a/tools/pvmove_poll.h
+++ b/tools/pvmove_poll.h
@@ -15,16 +15,11 @@
 #ifndef _LVM_PVMOVE_H
 #define _LVM_PVMOVE_H
 
-/* FIXME: remove it after refactoring completes */
-#include <stdint.h>
-
 struct cmd_context;
 struct dm_list;
 struct logical_volume;
 struct volume_group;
 
-struct volume_group *get_vg(struct cmd_context *cmd, const char *vgname);
-
 int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct logical_volume *lv_mirr,
 			   struct dm_list *lvs_changed, unsigned flags);
@@ -32,8 +27,4 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed);
 
-struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd,
-					const char *name, const char *uuid,
-					uint32_t flags);
-
 #endif  /* _LVM_PVMOVE_H */
diff --git a/tools/toollib.c b/tools/toollib.c
index d29bebf..e6c3cdb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -921,7 +921,7 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 	    (pvname = get_pvmove_pvname_from_lv_mirr(lv_mirr))) {
 		log_verbose("Spawning background pvmove process for %s.",
 			    pvname);
-		pvmove_poll(cmd, pvname, 1);
+		pvmove_poll(cmd, pvname, lv_mirr->lvid.s, lv_mirr->vg->name, lv_mirr->name, 1);
 	}
 
 	if (lv_is_converting(lv) || lv_is_merging(lv)) {
diff --git a/tools/tools.h b/tools/tools.h
index 1f344b0..e959d80 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -176,7 +176,8 @@ int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t
 
 const char *command_name(struct cmd_context *cmd);
 
-int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
+int pvmove_poll(struct cmd_context *cmd, const char *pv_name, const char *uuid,
+		const char *vg_name, const char *lv_name, unsigned background);
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned background);
 
 int mirror_remove_missing(struct cmd_context *cmd,


