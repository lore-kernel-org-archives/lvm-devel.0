From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:35 +0000 (UTC)
Subject: master - thin: initial --repair support for pools
Message-ID: <20130731133635.28CB360319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de0cba0e2d588a327867f17015cecba516364591
Commit:        de0cba0e2d588a327867f17015cecba516364591
Parent:        22fc80982aa08ef8a907fc858a29a30c2d9293a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 24 15:25:34 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:32:36 2013 +0200

thin: initial --repair support for pools

Initial basic support for repair.
It currently takes pool metadata spare volume, which
is used for recovery.  New spare is created if the volume
is successfuly repaired.

After the operation the previous _tmeta volume is moved
into  _tmeta%d volume and if everything is ok, this volume
could be removed.
New _tmeta needs to be pvmoved to proper place and also
converted to i.e. mirror if it should be mirrored.

Later version will try to automate some steps here.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |  196 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 197 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6d59265..69a8275 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Add initial support thin pool lvconvert --repair.
   Add --with-thin-repair and --with-thin-dump configure options.
   Add lvm.conf thin_repair/dump_executable and thin_repair_options.
   Require 1.9 thin pool target version for online thin pool metadata resize.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index bd07497..88e0119 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1948,6 +1948,199 @@ out:
 	return r;
 }
 
+static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
+				      struct logical_volume *pool_lv,
+				      struct lvconvert_params *lp)
+{
+	const char *dmdir = dm_dir();
+	const char *thin_dump =
+		find_config_tree_str_allow_empty(cmd, global_thin_dump_executable_CFG, NULL);
+	const char *thin_repair =
+		find_config_tree_str_allow_empty(cmd, global_thin_repair_executable_CFG, NULL);
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	int ret = 0, status;
+	int args = 0;
+	const char *argv[19]; /* Max supported 10 args */
+	char *split, *dm_name, *trans_id_str;
+	char meta_path[PATH_MAX];
+	char pms_path[PATH_MAX];
+	uint64_t trans_id;
+	struct logical_volume *pmslv;
+	struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
+	FILE *f;
+
+	if (!thin_repair[0]) {
+		log_error("Thin repair commnand is not configured. Repair is disabled.");
+		return 0; /* Checking disabled */
+	}
+
+	/* Check we have pool metadata spare LV */
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
+		return_0;
+
+	pmslv = pool_lv->vg->pool_metadata_spare_lv;
+
+	if (!(dm_name = dm_build_dm_name(cmd->mem, mlv->vg->name,
+					 mlv->name, NULL)) ||
+	    (dm_snprintf(meta_path, sizeof(meta_path), "%s/%s", dmdir, dm_name) < 0)) {
+		log_error("Failed to build thin metadata path.");
+		return 0;
+	}
+
+	if (!(dm_name = dm_build_dm_name(cmd->mem, pmslv->vg->name,
+					 pmslv->name, NULL)) ||
+	    (dm_snprintf(pms_path, sizeof(pms_path), "%s/%s", dmdir, dm_name) < 0)) {
+		log_error("Failed to build pool metadata spare path.");
+		return 0;
+	}
+
+	if ((cn = find_config_tree_node(cmd, global_thin_repair_options_CFG, NULL))) {
+		for (cv = cn->v; cv && args < 16; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING) {
+				log_error("Invalid string in config file: "
+					  "global/thin_repair_options");
+				return 0;
+			}
+			argv[++args] = cv->v.str;
+		}
+	} else {
+		/* Use default options (no support for options with spaces) */
+		if (!(split = dm_pool_strdup(cmd->mem, DEFAULT_THIN_REPAIR_OPTIONS))) {
+			log_error("Failed to duplicate thin repair string.");
+			return 0;
+		}
+		args = dm_split_words(split, 16, 0, (char**) argv + 1);
+	}
+
+	if (args == 10) {
+		log_error("Too many options for thin repair command.");
+		return 0;
+	}
+
+	argv[0] = thin_repair;
+	argv[++args] = "-i";
+	argv[++args] = meta_path;
+	argv[++args] = "-o";
+	argv[++args] = pms_path;
+	argv[++args] = NULL;
+
+	if (pool_is_active(pool_lv)) {
+		log_error("Only inactive pool can be repaired.");
+		return 0;
+	}
+
+	if (!activate_lv_local(cmd, pmslv)) {
+		log_error("Cannot activate pool metadata spare volume %s.",
+			  pmslv->name);
+		return 0;
+	}
+
+	if (!activate_lv_local(cmd, mlv)) {
+		log_error("Cannot activate thin pool metadata volume %s.",
+			  mlv->name);
+		goto deactivate_pmslv;
+	}
+
+	if (!(ret = exec_cmd(cmd, (const char * const *)argv, &status, 1))) {
+		log_error("Repair of thin metadata volume of thin pool %s/%s failed (status:%d). "
+			  "Manual repair required!",
+			  pool_lv->vg->name, pool_lv->name, status);
+		goto deactivate_mlv;
+	}
+
+	if (thin_dump[0]) {
+		if (dm_snprintf(meta_path, sizeof(meta_path), "%s %s", thin_dump, pms_path) < 0) {
+			log_error("Command cannot fit into buffer.");
+			goto deactivate_mlv;
+		}
+
+		if (!(f = popen(meta_path, "r")))
+			log_warn("WARNING: Cannot read output from %s.", meta_path);
+		else {
+			/*
+			 * Scan only the 1st. line for transation id.
+			 * Watch out, if the thin_dump format changes
+			 */
+			if ((fgets(meta_path, sizeof(meta_path), f) > 0) &&
+			    (trans_id_str = strstr(meta_path, "transaction=\"")) &&
+			    (sscanf(trans_id_str + 13, "%" PRIu64, &trans_id) == 1) &&
+			    (trans_id != first_seg(pool_lv)->transaction_id) &&
+			    ((trans_id - 1) != first_seg(pool_lv)->transaction_id))
+				log_error("Transaction id %" PRIu64 " from pool \"%s/%s\" "
+					  "does not match repaired transaction id "
+					  "%" PRIu64 " from %s.",
+					  first_seg(pool_lv)->transaction_id,
+					  pool_lv->vg->name, pool_lv->name, trans_id,
+					  pms_path);
+			if (pclose(f))
+				log_sys_error("popen", thin_dump);
+		}
+	}
+
+deactivate_mlv:
+	if (!deactivate_lv(cmd, mlv)) {
+		log_error("Cannot deactivate thin pool metadata volume %s.",
+			  mlv->name);
+		return 0;
+	}
+
+deactivate_pmslv:
+	if (!deactivate_lv(cmd, pmslv)) {
+		log_error("Cannot deactivate thin pool metadata volume %s.",
+			  mlv->name);
+		return 0;
+	}
+
+	if (!ret)
+		return 0;
+
+	if (pmslv == pool_lv->vg->pool_metadata_spare_lv) {
+		pool_lv->vg->pool_metadata_spare_lv = NULL;
+		pmslv->status &= ~POOL_METADATA_SPARE;
+		lv_set_visible(pmslv);
+	}
+
+	/* Try to allocate new pool metadata spare LV */
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
+		stack;
+
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s%%d", mlv->name) < 0) {
+		log_error("Can't prepare new name for %s.", mlv->name);
+		return 0;
+	}
+
+	if (!generate_lv_name(pool_lv->vg, meta_path, pms_path, sizeof(pms_path))) {
+		log_error("Can't generate new name for %s.", meta_path);
+		return 0;
+	}
+
+	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
+		return_0;
+
+	if (!_swap_lv_identifiers(cmd, mlv, pmslv))
+		return_0;
+
+	/* Used _pmspare will become _tmeta */
+	if (!attach_pool_metadata_lv(first_seg(pool_lv), pmslv))
+		return_0;
+
+	/* Used _tmeta will become visible  _tmeta%d */
+	if (!lv_rename_update(cmd, mlv, pms_path, 0))
+		return_0;
+
+	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+		return_0;
+
+	log_warn("WARNING: If everything works, remove \"%s/%s\".",
+		 mlv->vg->name, mlv->name);
+
+	log_warn("WARNING: Use pvmove command to move \"%s/%s\" on the best fitting PV.",
+		 mlv->vg->name, first_seg(pool_lv)->metadata_lv->name);
+
+	return 1;
+}
+
 static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 					struct logical_volume *pool_lv,
 					struct logical_volume *external_lv,
@@ -2326,6 +2519,9 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, repair_ARG) && lv_is_thin_pool(lv))
+		return _lvconvert_thinpool_repair(cmd, lv, lp);
+
 	if (arg_count(cmd, repair_ARG) &&
 	    !(lv->status & MIRRORED) && !(lv->status & RAID)) {
 		if (arg_count(cmd, use_policies_ARG))


