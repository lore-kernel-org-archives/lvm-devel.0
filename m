From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:05 +0000 (UTC)
Subject: dev-dct-process-latest - vgreduce: use normal process_each_pv
Message-ID: <20140922154005.76C7B60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6351dabe95a7c0f4837567953466c4910c858fa9
Commit:        6351dabe95a7c0f4837567953466c4910c858fa9
Parent:        7c88ae037e5e1e860cd58e873a90dc3e3cd0bbe1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 22 15:50:44 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

vgreduce: use normal process_each_pv

In the non-repair case.
---
 tools/toollib.c  |   42 +++++++++-----------
 tools/toollib.h  |    2 +-
 tools/vgreduce.c |  115 ++++++++++++++++++++++++++---------------------------
 3 files changed, 76 insertions(+), 83 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b1ec7c5..0a0cb6f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1269,7 +1269,7 @@ static int get_arg_vgnames(struct cmd_context *cmd,
  */
 
 static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames,
-			   int include_orphan)
+			   const char *one_vgname, int include_orphan)
 {
 	int ret_max = ECMD_PROCESSED;
 	struct name_id_list *nl;
@@ -1277,6 +1277,20 @@ static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames,
 	struct dm_str_list *sl;
 	const char *vgid;
 
+	if (one_vgname) {
+		nl = dm_pool_alloc(cmd->mem, sizeof(struct name_id_list));
+		if (!nl) {
+			log_error("name_id_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		nl->name = dm_pool_strdup(cmd->mem, one_vgname);
+		nl->uuid = NULL;
+
+		dm_list_add(all_vgnames, &nl->list);
+		return ret_max;
+	}
+
 	log_verbose("Finding all volume groups");
 
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
@@ -1418,7 +1432,7 @@ int process_each_vg(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames, 0);
+		ret = get_all_vgnames(cmd, &all_vgnames, NULL, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -1756,7 +1770,7 @@ int process_each_lv(struct cmd_context *cmd,
 
 	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) ||
 	    !dm_list_empty(&arg_tags)) {
-		ret = get_all_vgnames(cmd, &all_vgnames, 0);
+		ret = get_all_vgnames(cmd, &all_vgnames, NULL, 0);
 		if (ret != ECMD_PROCESSED)
 			return ret;
 	}
@@ -2038,7 +2052,7 @@ static int process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 
 int process_each_pv(struct cmd_context *cmd,
 		    int argc, char **argv,
-		    struct volume_group *vg,
+		    const char *vg_name,
 		    uint32_t flags,
 		    void *handle,
 		    process_single_pv_fn_t process_single_pv)
@@ -2047,7 +2061,6 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list arg_pvnames; /* str_list */
 	struct dm_list all_vgnames; /* name_id_list */
 	struct dm_list all_devs;    /* device_list */
-	struct dm_str_list *sl;
 	int process_all_pvs;
 	int process_all_devs;
 	int ret_max = ECMD_PROCESSED;
@@ -2074,23 +2087,6 @@ int process_each_pv(struct cmd_context *cmd,
 			   arg_count(cmd, all_ARG);
 
 	/*
-	 * Caller has already selected, locked, and read one vg in which to
-	 * process pvs (all pvs, or named pvs, or pvs with matching tags).
-	 */
-	if (vg) {
-		ret = process_pvs_in_vg(cmd, vg, NULL,
-					&arg_pvnames, &arg_tags, process_all_pvs,
-					handle, process_single_pv);
-
-		dm_list_iterate_items(sl, &arg_pvnames) {
-			log_error("Physical Volume \"%s\" not found in Volume Group \"%s\"",
-				  sl->str, vg->name);
-			ret = ECMD_FAILED;
-		}
-		return ret;
-	}
-
-	/*
 	 * If the caller wants to process all devs (not only pvs), then all pvs
 	 * from all vgs are processed first, removing each from all_devs.  Then
 	 * any devs remaining in all_devs are processed.
@@ -2101,7 +2097,7 @@ int process_each_pv(struct cmd_context *cmd,
 			return ret;
 	}
 
-	ret = get_all_vgnames(cmd, &all_vgnames, 1);
+	ret = get_all_vgnames(cmd, &all_vgnames, vg_name, 1);
 	if (ret != ECMD_PROCESSED)
 		return ret;
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 4327f84..1eba5bb 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -57,7 +57,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type,
+		    const char *vg_name, uint32_t lock_type,
 		    void *handle, process_single_pv_fn_t process_single_pv);
 
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 493a084..7296b54 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -125,8 +125,12 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
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
 
@@ -181,12 +185,16 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 	argc--;
 
+	if (!repairing) {
+		return process_each_pv(cmd, argc, argv, vg_name,
+				       READ_FOR_UPDATE, NULL,
+				      _vgreduce_single);
+	}
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
@@ -194,64 +202,55 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 
 	/* FIXME We want to allow read-only VGs to be changed here? */
-	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
-	    && !arg_count(cmd, removemissing_ARG))
+	if (vg_read_error(vg) &&
+	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
+	    !arg_count(cmd, removemissing_ARG)) {
 		goto_out;
+	}
 
 	locked = !vg_read_error(vg);
 
-	if (repairing) {
-		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
-			log_error("Volume group \"%s\" is already consistent",
-				  vg_name);
-			ret = ECMD_PROCESSED;
-			goto out;
-		}
-
-		release_vg(vg);
-		log_verbose("Trying to open VG %s for recovery...", vg_name);
-
-		vg = vg_read_for_update(cmd, vg_name, NULL,
-					READ_ALLOW_INCONSISTENT
-					| READ_ALLOW_EXPORTED);
+	if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
+		log_error("Volume group \"%s\" is already consistent", vg_name);
+		ret = ECMD_PROCESSED;
+		goto out;
+	}
 
-		locked |= !vg_read_error(vg);
-		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
-		    && vg_read_error(vg) != FAILED_INCONSISTENT)
-			goto_out;
+	release_vg(vg);
+	log_verbose("Trying to open VG %s for recovery...", vg_name);
 
-		if (!archive(vg))
-			goto_out;
+	vg = vg_read_for_update(cmd, vg_name, NULL,
+				READ_ALLOW_INCONSISTENT | READ_ALLOW_EXPORTED);
 
-		if (arg_count(cmd, force_ARG)) {
-			if (!_make_vg_consistent(cmd, vg))
-				goto_out;
-		} else
-			fixed = _consolidate_vg(cmd, vg);
+	locked |= !vg_read_error(vg);
 
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to write out a consistent VG for %s",
-				  vg_name);
-			goto out;
-		}
-		backup(vg);
+	if (vg_read_error(vg) &&
+	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
+	    (vg_read_error(vg) != FAILED_INCONSISTENT)) {
+		goto_out;
+	}
 
-		if (fixed) {
-			log_print_unless_silent("Wrote out consistent volume group %s",
-						vg_name);
-			ret = ECMD_PROCESSED;
-		} else
-			ret = ECMD_FAILED;
+	if (!archive(vg))
+		goto_out;
 
-	} else {
-		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
+	if (arg_count(cmd, force_ARG)) {
+		if (!_make_vg_consistent(cmd, vg))
 			goto_out;
+	} else {
+		fixed = _consolidate_vg(cmd, vg);
+	}
 
-		/* FIXME: Pass private struct through to all these functions */
-		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, READ_FOR_UPDATE, NULL,
-				      _vgreduce_single);
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to write out a consistent VG for %s", vg_name);
+		goto out;
+	}
+	backup(vg);
 
+	if (fixed) {
+		log_print_unless_silent("Wrote out consistent volume group %s", vg_name);
+		ret = ECMD_PROCESSED;
+	} else {
+		ret = ECMD_FAILED;
 	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
@@ -265,16 +264,14 @@ out:
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


