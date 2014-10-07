From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Oct 2014 00:16:18 +0000 (UTC)
Subject: master - vgreduce: Use process_each_pv.
Message-ID: <20141007001618.553056006D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e458fc9a6a3a82231367450b5f54f3c12700cd20
Commit:        e458fc9a6a3a82231367450b5f54f3c12700cd20
Parent:        f1a000a477558e157532d5f2cd2f9c9139d4f87c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 7 00:53:56 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 7 01:15:43 2014 +0100

vgreduce: Use process_each_pv.

Adapt process_each_pv for use by vgreduce in the non-repair case.

[Committed by agk with cosmetic changes and tweaks.]
---
 tools/toollib.c  |   51 +++++++++++-------------
 tools/toollib.h  |    2 +-
 tools/vgreduce.c |  116 +++++++++++++++++++++++++----------------------------
 3 files changed, 79 insertions(+), 90 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b65351e..16aeaa2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1373,13 +1373,27 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
  */
 static int _get_vgnameids_on_system(struct cmd_context *cmd,
 				    struct dm_list *vgnameids_on_system,
-				    int include_internal)
+				    const char *only_this_vgname, int include_internal)
 {
 	struct vgnameid_list *vgnl;
 	struct dm_list *vgids;
 	struct dm_str_list *sl;
 	const char *vgid;
 
+	if (only_this_vgname) {
+		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
+		if (!vgnl) {
+			log_error("name_id_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		vgnl->vg_name = dm_pool_strdup(cmd->mem, only_this_vgname);
+		vgnl->vgid = NULL;
+
+		dm_list_add(vgnameids_on_system, &vgnl->list);
+		return ECMD_PROCESSED;
+	}
+
 	log_verbose("Finding all volume groups");
 
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
@@ -1530,7 +1544,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, 0)) != ECMD_PROCESSED)) {
+	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}
@@ -1864,7 +1878,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	 *   no VG names were given and the command defaults to processing all VGs.
 	*/
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, 0) != ECMD_PROCESSED)) {
+	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}
@@ -2159,16 +2173,15 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 
 int process_each_pv(struct cmd_context *cmd,
 		    int argc, char **argv,
-		    struct volume_group *vg,
+		    const char *only_this_vgname,
 		    uint32_t flags,
 		    void *handle,
 		    process_single_pv_fn_t process_single_pv)
 {
-	struct dm_list arg_tags;    /* str_list */
-	struct dm_list arg_pvnames; /* str_list */
-	struct dm_list all_vgnameids; /* vgnameid_list */
-	struct dm_list all_devices;    /* device_list */
-	struct dm_str_list *sl;
+	struct dm_list arg_tags;	/* str_list */
+	struct dm_list arg_pvnames;	/* str_list */
+	struct dm_list all_vgnameids;	/* vgnameid_list */
+	struct dm_list all_devices;	/* device_list */
 	int process_all_pvs;
 	int process_all_devices;
 	int ret_max = ECMD_PROCESSED;
@@ -2194,24 +2207,6 @@ int process_each_pv(struct cmd_context *cmd,
 			   arg_count(cmd, all_ARG);
 
 	/*
-	 * If vg is set, the caller already selected, locked, and read one
-	 * VG.  This code is unused.
-	 */
-	if (vg) {
-		ret = _process_pvs_in_vg(cmd, vg, NULL,
-					 &arg_pvnames, &arg_tags, process_all_pvs, 0,
-					 handle, process_single_pv);
-
-		dm_list_iterate_items(sl, &arg_pvnames) {
-			log_error("Physical Volume \"%s\" not found in Volume Group \"%s\"",
-				  sl->str, vg->name);
-			ret = ECMD_FAILED;
-		}
-
-		return ret;
-	}
-
-	/*
 	 * If the caller wants to process all devices (not just PVs), then all PVs
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
@@ -2221,7 +2216,7 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
-	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, 1) != ECMD_PROCESSED)) {
+	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 483ac68..5b42f28 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -49,7 +49,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type,
+		    const char *vg_name, uint32_t lock_type,
 		    void *handle, process_single_pv_fn_t process_single_pv);
 
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 493a084..7af5a76 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -125,16 +125,18 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
 {
-	int r = vgreduce_single(cmd, vg, pv, 1);
+	int r;
 
+	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
+		return ECMD_FAILED;
+
+	r = vgreduce_single(cmd, vg, pv, 1);
 	if (!r)
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
 
-
-
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
@@ -181,12 +183,17 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 	argc--;
 
+	if (!repairing)
+		/* FIXME: Pass private struct through to all these functions */
+		/* and update in batch afterwards? */
+		return process_each_pv(cmd, argc, argv, vg_name,
+				       READ_FOR_UPDATE, NULL,
+				      _vgreduce_single);
+
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	if (repairing) {
-		init_ignore_suspended_devices(1);
-		cmd->handles_missing_pvs = 1;
-	}
+	init_ignore_suspended_devices(1);
+	cmd->handles_missing_pvs = 1;
 
 	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg) == FAILED_ALLOCATION ||
@@ -194,65 +201,54 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 
 	/* FIXME We want to allow read-only VGs to be changed here? */
-	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
-	    && !arg_count(cmd, removemissing_ARG))
+	if (vg_read_error(vg) &&
+	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
+	    !arg_count(cmd, removemissing_ARG))
 		goto_out;
 
 	locked = !vg_read_error(vg);
 
-	if (repairing) {
-		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
-			log_error("Volume group \"%s\" is already consistent",
-				  vg_name);
-			ret = ECMD_PROCESSED;
-			goto out;
-		}
+	if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
+		log_error("Volume group \"%s\" is already consistent", vg_name);
+		ret = ECMD_PROCESSED;
+		goto out;
+	}
 
-		release_vg(vg);
-		log_verbose("Trying to open VG %s for recovery...", vg_name);
+	release_vg(vg);
+	log_verbose("Trying to open VG %s for recovery...", vg_name);
 
-		vg = vg_read_for_update(cmd, vg_name, NULL,
-					READ_ALLOW_INCONSISTENT
-					| READ_ALLOW_EXPORTED);
+	vg = vg_read_for_update(cmd, vg_name, NULL,
+				READ_ALLOW_INCONSISTENT | READ_ALLOW_EXPORTED);
 
-		locked |= !vg_read_error(vg);
-		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
-		    && vg_read_error(vg) != FAILED_INCONSISTENT)
-			goto_out;
+	locked |= !vg_read_error(vg);
 
-		if (!archive(vg))
-			goto_out;
+	if (vg_read_error(vg) &&
+	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
+	    (vg_read_error(vg) != FAILED_INCONSISTENT))
+		goto_out;
 
-		if (arg_count(cmd, force_ARG)) {
-			if (!_make_vg_consistent(cmd, vg))
-				goto_out;
-		} else
-			fixed = _consolidate_vg(cmd, vg);
+	if (!archive(vg))
+		goto_out;
 
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to write out a consistent VG for %s",
-				  vg_name);
-			goto out;
-		}
-		backup(vg);
+	if (arg_count(cmd, force_ARG)) {
+		if (!_make_vg_consistent(cmd, vg))
+			goto_out;
+	} else
+		fixed = _consolidate_vg(cmd, vg);
 
-		if (fixed) {
-			log_print_unless_silent("Wrote out consistent volume group %s",
-						vg_name);
-			ret = ECMD_PROCESSED;
-		} else
-			ret = ECMD_FAILED;
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to write out a consistent VG for %s", vg_name);
+		goto out;
+	}
 
-	} else {
-		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
-			goto_out;
+	backup(vg);
 
-		/* FIXME: Pass private struct through to all these functions */
-		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, READ_FOR_UPDATE, NULL,
-				      _vgreduce_single);
+	if (fixed) {
+		log_print_unless_silent("Wrote out consistent volume group %s", vg_name);
+		ret = ECMD_PROCESSED;
+	} else
+		ret = ECMD_FAILED;
 
-	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	if (locked)
@@ -265,16 +261,14 @@ out:
 /******* FIXME
 	log_error ("no empty physical volumes found in volume group \"%s\"", vg_name);
 
-	log_verbose
-	    ("volume group \"%s\" will be reduced by %d physical volume%s",
-	     vg_name, np, np > 1 ? "s" : "");
-	log_verbose ("reducing volume group \"%s\" by physical volume \"%s\"",
-		     vg_name, pv_names[p]);
+	log_verbose("volume group \"%s\" will be reduced by %d physical volume%s",
+		    vg_name, np, np > 1 ? "s" : "");
+	log_verbose("reducing volume group \"%s\" by physical volume \"%s\"",
+		    vg_name, pv_names[p]);
 
-	log_print
-	    ("volume group \"%s\" %ssuccessfully reduced by physical volume%s:",
-	     vg_name, error > 0 ? "NOT " : "", p > 1 ? "s" : "");
-		log_print("%s", pv_this[p]->pv_name);
+	log_print("volume group \"%s\" %ssuccessfully reduced by physical volume%s:",
+		  vg_name, error > 0 ? "NOT " : "", p > 1 ? "s" : "");
+	log_print("%s", pv_this[p]->pv_name);
 ********/
 
 }


