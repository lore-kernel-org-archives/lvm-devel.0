From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Mar 2012 14:30:35 +0200
Subject: [PATCH 1/2] Proposal to speedup pvs ver.1
In-Reply-To: <cover.1332764920.git.zkabelac@redhat.com>
References: <cover.1332764920.git.zkabelac@redhat.com>
Message-ID: <69aff68b8c6f3b0e9d25cd9b0f6554c2997b4a6d.1332764920.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

First version of acceleration of pvs command.
Introduce 'smarter' scan_pvs() function which is able to
run process_pv_fn_t for each pv (essentially similar to
process_single_pv used in toollib - maybe we move typedef
into lib/metadata/metadata-exported.h  and use the same type?)

For _process_all_pvs - it's not maintaining hashtable of used PVs.

For _process_all_devs - maintains used PVs hash table.

NOTICE: moving lvmcache_seed_infos_from_lvmetad() used only
in _process_all_devs() to  _get_pvs - IMHO it's bug - but I'm
not so sure about the logic.

NOTICE2: currently patch DOES NOT accelerate pvs if devices are given on
command line - this will be added if we will consider this is the way
we want to go.

To give the illusion of speed increase:

300PVs creating one 1VG:

without patch & lvmetad   28 minutes.
with patch & lvmetad      5 seconds
with patch & without lvmetad   1second

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    5 ++
 lib/metadata/metadata.c          |   30 ++++++---
 tools/toollib.c                  |  128 ++++++++++++++++++++++++++++----------
 3 files changed, 121 insertions(+), 42 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8ebf487..10cd910 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -413,6 +413,11 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				int warnings,
 				int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
+typedef int (*process_pv_fn_t) (struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				void *handle);
+int scan_pvs(struct cmd_context *cmd, process_pv_fn_t fn, void *handle);
 
 /*
  * Add/remove LV to/from volume group
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bd13a23..7d65d8b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3693,7 +3693,8 @@ struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 	return lvmcache_get_vgids(cmd, include_internal);
 }
 
-static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvslist)
+static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvslist,
+		    process_pv_fn_t process_pv, void *handle)
 {
 	struct str_list *strl;
 	struct dm_list * uninitialized_var(results);
@@ -3705,6 +3706,7 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 	int old_pvmove;
 
 	lvmcache_label_scan(cmd, 0);
+	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (pvslist) {
 		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
@@ -3727,8 +3729,6 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 	init_pvmove(1);
 	dm_list_iterate_items(strl, vgids) {
 		vgid = strl->str;
-		if (!vgid)
-			continue;	/* FIXME Unnecessary? */
 		consistent = 0;
 		if (!(vgname = lvmcache_vgname_from_vgid(NULL, vgid))) {
 			stack;
@@ -3741,9 +3741,14 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 		if (!consistent)
 			log_warn("WARNING: Volume Group %s is not consistent",
 				 vgname);
-
-		/* Move PVs onto results list */
-		if (pvslist)
+		if (process_pv) {
+			dm_list_iterate_items(pvl, &vg->pvs)
+				if (!process_pv(cmd, vg, pvl->pv, handle)) {
+					release_vg(vg);
+					return_0;
+				}
+		} else if (pvslist)
+			/* Copy PVs onto results list */
 			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
 					log_error("PV list allocation failed");
@@ -3764,11 +3769,20 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 	return 1;
 }
 
+int scan_pvs(struct cmd_context *cmd, process_pv_fn_t process_pv, void *handle)
+{
+	if (!_get_pvs(cmd, 1, NULL, process_pv, handle))
+		return_0;
+
+	return 1;
+}
+
+/* FIXME: Convert users to use more efficient scan_pvs() if possible */
 struct dm_list *get_pvs(struct cmd_context *cmd)
 {
 	struct dm_list *results;
 
-	if (!_get_pvs(cmd, 1, &results))
+	if (!_get_pvs(cmd, 1, &results, NULL, NULL))
 		return NULL;
 
 	return results;
@@ -3776,7 +3790,7 @@ struct dm_list *get_pvs(struct cmd_context *cmd)
 
 int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings)
 {
-	return _get_pvs(cmd, warnings, NULL);
+	return _get_pvs(cmd, warnings, NULL, NULL, NULL);
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
diff --git a/tools/toollib.c b/tools/toollib.c
index d5ad805..e621917 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -647,6 +647,65 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	return ret_max;
 }
 
+struct process_devs {
+	void *handle;
+	process_single_pv_fn_t process_single_pv;
+	int ret_max;
+	struct dm_hash_table *pvh;
+};
+
+static int _process_pv_dev(struct cmd_context *cmd, struct volume_group *vg,
+			   struct physical_volume *pv, void *handle)
+{
+	struct process_devs *h = handle;
+	int r;
+
+	if (sigint_caught()) {
+		log_error("Break...");
+		return 0;
+	}
+
+	if (is_missing_pv(pv)) {
+		log_very_verbose("Missing PV."); /* Missing uuid is reported via vg_read() */
+		h->ret_max = ECMD_FAILED;
+		return 1;
+	}
+
+	log_debug("Process PV:%s from VG:%s (%d)",
+		  pv_dev_name(pv), vg->name,
+		  h->pvh ? (int)dm_hash_lookup(h->pvh, pv_dev_name(pv)) : 0);
+
+	if (h->pvh && !dm_hash_insert(h->pvh, pv_dev_name(pv), pv)) {
+		log_error("Failed to hash device name.");
+		return 0;
+	}
+
+	if ((r = h->process_single_pv(cmd, vg, pv, h->handle)) > h->ret_max)
+		h->ret_max = r;
+
+	return 1;
+}
+
+static int _process_all_pvs(struct cmd_context *cmd, void *handle,
+			     process_single_pv_fn_t process_single_pv)
+{
+	/* Does not need to create hash table */
+	struct process_devs devsh = {
+		.handle = handle,
+		.process_single_pv = process_single_pv,
+		.ret_max = ECMD_PROCESSED
+	};
+
+	// moved to _getpvs()
+	//lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!scan_pvs(cmd, _process_pv_dev, &devsh)) {
+		stack;
+		devsh.ret_max = ECMD_FAILED;
+	}
+
+	return devsh.ret_max;
+}
+
 static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			     process_single_pv_fn_t process_single_pv)
 {
@@ -654,21 +713,35 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	struct physical_volume pv_dummy;
 	struct dev_iter *iter;
 	struct device *dev;
-
-	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
-
-	if (!scan_vgs_for_pvs(cmd, 1)) {
-		stack;
+	int ret;
+	struct process_devs devsh = {
+		.handle = handle,
+		.process_single_pv = process_single_pv,
+		.ret_max = ECMD_PROCESSED
+	};
+
+	if (!(devsh.pvh = dm_hash_create(128))) {
+		log_error("Failed to allocate hash table for devices.");
 		return ECMD_FAILED;
 	}
 
+	if (!scan_pvs(cmd, _process_pv_dev, &devsh)) {
+		devsh.ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");
-		return ECMD_FAILED;
+		devsh.ret_max = ECMD_FAILED;
+		goto out;
 	}
 
 	while ((dev = dev_iter_get(iter))) {
+		if (dm_hash_lookup(devsh.pvh, dev_name(dev))) {
+			log_debug("Skipping already scanned device: %s", dev_name(dev));
+			continue;
+		}
+
 		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
 			dm_list_init(&pv_dummy.tags);
@@ -681,15 +754,19 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 
 		free_pv_fid(pv);
 
-		if (ret > ret_max)
-			ret_max = ret;
-		if (sigint_caught())
+		if (ret > devsh.ret_max)
+			devsh.ret_max = ret;
+		if (sigint_caught()) {
+			devsh.ret_max = ECMD_FAILED;
 			break;
+		}
 	}
 
 	dev_iter_destroy(iter);
+out:
+	dm_hash_destroy(devsh.pvh);
 
-	return ret_max;
+	return devsh.ret_max;
 }
 
 /*
@@ -709,7 +786,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	struct dm_list *pvslist, *vgnames;
+	struct dm_list *vgnames;
 	struct dm_list tags;
 	struct str_list *sll;
 	char *at_sign, *tagname;
@@ -836,33 +913,16 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				    "volume group");
 			ret = process_each_pv_in_vg(cmd, vg, NULL, handle,
 						    process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
 		} else if (arg_count(cmd, all_ARG)) {
 			ret = _process_all_devs(cmd, handle, process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
 		} else {
 			log_verbose("Scanning for physical volume names");
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
+			ret = _process_all_pvs(cmd, handle, process_single_pv);
 		}
+		if (ret > ret_max)
+			ret_max = ret;
+		if (sigint_caught())
+			goto out;
 	}
 out:
 	if (lock_global)
-- 
1.7.9.3


