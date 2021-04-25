From: Leo Yan <leo.yan@linaro.org>
Date: Sun, 25 Apr 2021 10:22:40 +0800
Subject: [LVM2 RFCv1 4/5] lib: locking: Parse PV list for IDM locking
In-Reply-To: <20210425022241.5055-1-leo.yan@linaro.org>
References: <20210425022241.5055-1-leo.yan@linaro.org>
Message-ID: <20210425022241.5055-5-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For shared VG or LV locking, IDM locking scheme needs to use the PV
list assocated with VG or LV for sending SCSI commands, thus it requires
to use some places to generate PV list.

In reviewing the flow for LVM commands, the best place to generate PV
list is in the locking lib.  So this is why this patch parses PV list as
shown.  It iterates over all the PV nodes one by one, and compare with
the VG name or LV prefix string.  If any PV matches, then the PV is
added into the PV list.  Finally the PV list is sent to lvmlockd daemon.

Here as mentioned, it compares LV prefix string with the format
"lv_name_", the reason is it needs to find out all relevant PVs, e.g.
for the thin pool, it has LVs for metadata, pool, error, and raw LV, so
we can use the prefix string to find out all PVs belonging to the thin
pool.

For the global lock, it's not covered in this patch.  To avoid the egg
and chicken issue, we need to prepare the global lock ahead before any
locking can be used.  So the global lock's PV list is established in
lvmlockd daemon by iterating all drives with partition labelled with
"propeller".

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 lib/locking/lvmlockd.c | 284 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 273 insertions(+), 11 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 268f9fc2f..ca3ebfec3 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -25,6 +25,11 @@ static int _use_lvmlockd = 0;         /* is 1 if command is configured to use lv
 static int _lvmlockd_connected = 0;   /* is 1 if command is connected to lvmlockd */
 static int _lvmlockd_init_failed = 0; /* used to suppress further warnings */
 
+struct lvmlockd_pvs {
+	char **path;
+	int num;
+};
+
 void lvmlockd_set_socket(const char *sock)
 {
 	_lvmlockd_socket = sock;
@@ -178,18 +183,34 @@ static int _lockd_result(daemon_reply reply, int *result, uint32_t *lockd_flags)
 	return 1;
 }
 
-static daemon_reply _lockd_send(const char *req_name, ...)
+static daemon_reply _lockd_send_with_pvs(const char *req_name,
+				const struct lvmlockd_pvs *lock_pvs, ...)
 {
-	va_list ap;
 	daemon_reply repl;
 	daemon_request req;
+	int i;
+	char key[32];
+	const char *val;
+	va_list ap;
 
 	req = daemon_request_make(req_name);
 
-	va_start(ap, req_name);
+	va_start(ap, lock_pvs);
 	daemon_request_extend_v(req, ap);
 	va_end(ap);
 
+	/* Pass PV list */
+	if (lock_pvs) {
+		daemon_request_extend(req, "path_num = " FMTd64,
+				      (int64_t)(lock_pvs)->num, NULL);
+
+		for (i = 0; i < lock_pvs->num; i++) {
+			snprintf(key, sizeof(key), "path[%d] = %%s", i);
+			val = lock_pvs->path[i] ? lock_pvs->path[i] : "none";
+			daemon_request_extend(req, key, val, NULL);
+		}
+	}
+
 	repl = daemon_send(_lvmlockd, req);
 
 	daemon_request_destroy(req);
@@ -197,6 +218,218 @@ static daemon_reply _lockd_send(const char *req_name, ...)
 	return repl;
 }
 
+#define _lockd_send(req_name, args...)	\
+	_lockd_send_with_pvs(req_name, NULL, ##args)
+
+static int _lockd_retrive_vg_pv_num(struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	int num = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs)
+		num++;
+
+	return num;
+}
+
+static void _lockd_retrive_vg_pv_list(struct volume_group *vg,
+				      struct lvmlockd_pvs *lock_pvs)
+{
+	struct pv_list *pvl;
+	int pv_num, i;
+	char **path;
+
+	memset(lock_pvs, 0x0, sizeof(*lock_pvs));
+
+	pv_num = _lockd_retrive_vg_pv_num(vg);
+	if (!pv_num) {
+		log_error("Fail to any PVs for VG %s", vg->name);
+		return;
+	}
+
+	/* Allocate buffer for PV list */
+	path = malloc(sizeof(lock_pvs->path) * pv_num);
+	if (!path) {
+		log_error("Fail to allocate PV list for VG %s", vg->name);
+		return;
+	}
+	lock_pvs->path = path;
+
+	i = 0;
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		lock_pvs->path[i] = strdup(pv_dev_name(pvl->pv));
+		if (!lock_pvs->path[i]) {
+			log_error("Fail to allocate PV path for VG %s", vg->name);
+			goto fail;
+		}
+
+		log_debug("VG %s find PV device %s", vg->name, lock_pvs->path[i]);
+		i++;
+	}
+
+	lock_pvs->num = pv_num;
+	return;
+
+fail:
+	for (i = 0; i < pv_num; i++) {
+		if (!lock_pvs->path[i])
+			continue;
+		free(lock_pvs->path[i]);
+		lock_pvs->path[i] = NULL;
+	}
+	free(lock_pvs->path);
+	lock_pvs->path = NULL;
+	lock_pvs->num = 0;
+	return;
+}
+
+static int _lockd_retrive_lv_pv_num(struct volume_group *vg,
+				    const char *lv_name)
+{
+	struct pv_list *pvl;
+	struct physical_volume *pv;
+	const struct pv_segment *pvseg;
+	char *lv_name_prefix;
+	int pv_num = 0;
+
+	/* Allocate buffer for 'lv_name' + '_' + '\0' */
+	lv_name_prefix = malloc(strlen(lv_name) + 1 + 1);
+	snprintf(lv_name_prefix, strlen(lv_name) + 1 + 1, "%s_", lv_name);
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		dm_list_iterate_items(pvseg, &pv->segments) {
+
+			if (!pvseg || !pvseg->lvseg ||
+			    !pvseg->lvseg->lv || !pvseg->lvseg->lv->name)
+				continue;
+
+			if (!strcmp(lv_name, pvseg->lvseg->lv->name)) {
+				pv_num++;
+				break;
+			}
+
+			/* Find out corresponding PVs with lv name prefix */
+			if (strstr(pvseg->lvseg->lv->name, lv_name_prefix)) {
+				pv_num++;
+				break;
+			}
+		}
+	}
+
+	return pv_num;
+}
+
+static void _lockd_retrive_lv_pv_list(struct volume_group *vg,
+				      const char *lv_name,
+				      struct lvmlockd_pvs *lock_pvs)
+{
+	struct pv_list *pvl;
+	struct physical_volume *pv;
+	const struct pv_segment *pvseg;
+	char *lv_name_prefix;
+	char **path;
+	int found, pv_num, i = 0;
+
+	memset(lock_pvs, 0x0, sizeof(*lock_pvs));
+
+	pv_num = _lockd_retrive_lv_pv_num(vg, lv_name);
+	if (!pv_num) {
+		/*
+		 * Fixup for 'lvcreate --type error -L1 -n $lv1 $vg', in this
+		 * case, the drive path list is empty since it doesn't establish
+		 * the structure 'pvseg->lvseg->lv->name'.
+		 *
+		 * So create drive path list with all drives in the VG.
+		 */
+		log_error("Fail to find any PVs for %s/%s", vg->name, lv_name);
+		log_error("Try to find PVs from VG %s instead", vg->name);
+		_lockd_retrive_vg_pv_list(vg, lock_pvs);
+		return;
+	}
+
+	/* Allocate buffer for PV list */
+	path = malloc(sizeof(lock_pvs->path) * pv_num);
+	if (!path) {
+		log_error("Fail to allocate PV list for %s/%s", vg->name, lv_name);
+		return;
+	}
+	lock_pvs->path = path;
+
+	/* Allocate buffer for 'lv_name' + '_' + '\0' */
+	lv_name_prefix = malloc(strlen(lv_name) + 1 + 1);
+	snprintf(lv_name_prefix, strlen(lv_name) + 1 + 1, "%s_", lv_name);
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		found = 0;
+		pv = pvl->pv;
+		dm_list_iterate_items(pvseg, &pv->segments) {
+
+			if (!pvseg || !pvseg->lvseg ||
+			    !pvseg->lvseg->lv || !pvseg->lvseg->lv->name)
+				continue;
+
+			log_debug("%s pvseg->lvseg->name=%s", __func__,
+				  pvseg->lvseg->lv->name);
+
+			if (!strcmp(lv_name, pvseg->lvseg->lv->name)) {
+				found = 1;
+				break;
+			}
+
+			/* Find out corresponding PVs with lv name prefix */
+			if (strstr(pvseg->lvseg->lv->name, lv_name_prefix)) {
+				found = 1;
+				break;
+			}
+		}
+
+		if (found) {
+			lock_pvs->path[i] = strdup(pv_dev_name(pv));
+			if (!lock_pvs->path[i]) {
+				log_error("Fail to allocate PV path for LV %s/%s",
+					  vg->name, lv_name);
+				goto fail;
+			}
+
+			log_debug("Find PV device %s for LV %s/%s",
+				  lock_pvs->path[i], vg->name, lv_name);
+			i++;
+		}
+	}
+
+	lock_pvs->num = pv_num;
+	free(lv_name_prefix);
+	return;
+
+fail:
+	for (i = 0; i < pv_num; i++) {
+		if (!lock_pvs->path[i])
+			continue;
+		free(lock_pvs->path[i]);
+		lock_pvs->path[i] = NULL;
+	}
+	free(lock_pvs->path);
+	lock_pvs->path = NULL;
+	lock_pvs->num = 0;
+	free(lv_name_prefix);
+	return;
+}
+
+static void _lockd_free_pv_list(struct lvmlockd_pvs *lock_pvs)
+{
+	int i;
+
+	for (i = 0; i < lock_pvs->num; i++) {
+		free(lock_pvs->path[i]);
+		lock_pvs->path[i] = NULL;
+	}
+
+	free(lock_pvs->path);
+	lock_pvs->path = NULL;
+	lock_pvs->num = 0;
+}
+
 /*
  * result/lockd_flags are values returned from lvmlockd.
  *
@@ -227,6 +460,7 @@ static int _lockd_request(struct cmd_context *cmd,
 		          const char *lv_lock_args,
 		          const char *mode,
 		          const char *opts,
+			  const struct lvmlockd_pvs *lock_pvs,
 		          int *result,
 		          uint32_t *lockd_flags)
 {
@@ -251,7 +485,16 @@ static int _lockd_request(struct cmd_context *cmd,
 		cmd_name = "none";
 
 	if (vg_name && lv_name) {
-		reply = _lockd_send(req_name,
+		/*
+		 * For LV operation, the PV list must be passed for idm,
+		 * otherwise, IDM lock manager has no idea to send locking
+		 * request to which drives, so return failure.
+		 */
+		if (!lock_pvs)
+			return 1;
+
+		reply = _lockd_send_with_pvs(req_name,
+					lock_pvs,
 					"cmd = %s", cmd_name,
 					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
@@ -271,7 +514,8 @@ static int _lockd_request(struct cmd_context *cmd,
 			  req_name, mode, vg_name, lv_name, *result, *lockd_flags);
 
 	} else if (vg_name) {
-		reply = _lockd_send(req_name,
+		reply = _lockd_send_with_pvs(req_name,
+					lock_pvs,
 					"cmd = %s", cmd_name,
 					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
@@ -288,7 +532,8 @@ static int _lockd_request(struct cmd_context *cmd,
 			  req_name, mode, vg_name, *result, *lockd_flags);
 
 	} else {
-		reply = _lockd_send(req_name,
+		reply = _lockd_send_with_pvs(req_name,
+					lock_pvs,
 					"cmd = %s", cmd_name,
 					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
@@ -1134,6 +1379,7 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 	int host_id = 0;
 	int result;
 	int ret;
+	struct lvmlockd_pvs lock_pvs;
 
 	memset(uuid, 0, sizeof(uuid));
 
@@ -1169,7 +1415,15 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 		host_id = find_config_tree_int(cmd, local_host_id_CFG, NULL);
 	}
 
-	reply = _lockd_send("start_vg",
+	/*
+	 * Create the VG's PV list when start the VG, the PV list
+	 * is passed to lvmlockd, and the the PVs path will be used
+	 * to send SCSI commands for idm locking scheme.
+	 */
+	_lockd_retrive_vg_pv_list(vg, &lock_pvs);
+
+	reply = _lockd_send_with_pvs("start_vg",
+				&lock_pvs,
 				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
@@ -1180,6 +1434,8 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 				"opts = %s", start_init ? "start_init" : "none",
 				NULL);
 
+	_lockd_free_pv_list(&lock_pvs);
+
 	if (!_lockd_result(reply, &result, &lockd_flags)) {
 		ret = 0;
 		result = -ELOCKD;
@@ -1406,7 +1662,7 @@ int lockd_global_create(struct cmd_context *cmd, const char *def_mode, const cha
  req:
 	if (!_lockd_request(cmd, "lock_gl",
 			      NULL, vg_lock_type, NULL, NULL, NULL, NULL, mode, NULL,
-			      &result, &lockd_flags)) {
+			      NULL, &result, &lockd_flags)) {
 		/* No result from lvmlockd, it is probably not running. */
 		log_error("Global lock failed: check that lvmlockd is running.");
 		return 0;
@@ -1642,7 +1898,7 @@ int lockd_global(struct cmd_context *cmd, const char *def_mode)
 
 	if (!_lockd_request(cmd, "lock_gl",
 			    NULL, NULL, NULL, NULL, NULL, NULL, mode, opts,
-			    &result, &lockd_flags)) {
+			    NULL, &result, &lockd_flags)) {
 		/* No result from lvmlockd, it is probably not running. */
 
 		/* We don't care if an unlock fails. */
@@ -1910,7 +2166,7 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 
 	if (!_lockd_request(cmd, "lock_vg",
 			      vg_name, NULL, NULL, NULL, NULL, NULL, mode, NULL,
-			      &result, &lockd_flags)) {
+			      NULL, &result, &lockd_flags)) {
 		/*
 		 * No result from lvmlockd, it is probably not running.
 		 * Decide if it is ok to continue without a lock in
@@ -2170,6 +2426,7 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t lockd_flags;
 	int refreshed = 0;
 	int result;
+	struct lvmlockd_pvs lock_pvs;
 
 	/*
 	 * Verify that when --readonly is used, no LVs should be activated or used.
@@ -2235,15 +2492,20 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
  retry:
 	log_debug("lockd LV %s/%s mode %s uuid %s", vg->name, lv_name, mode, lv_uuid);
 
+	_lockd_retrive_lv_pv_list(vg, lv_name, &lock_pvs);
+
 	if (!_lockd_request(cmd, "lock_lv",
 			       vg->name, vg->lock_type, vg->lock_args,
 			       lv_name, lv_uuid, lock_args, mode, opts,
-			       &result, &lockd_flags)) {
+			       &lock_pvs, &result, &lockd_flags)) {
+		_lockd_free_pv_list(&lock_pvs);
 		/* No result from lvmlockd, it is probably not running. */
 		log_error("Locking failed for LV %s/%s", vg->name, lv_name);
 		return 0;
 	}
 
+	_lockd_free_pv_list(&lock_pvs);
+
 	/* The lv was not active/locked. */
 	if (result == -ENOENT && !strcmp(mode, "un"))
 		return 1;
-- 
2.25.1


