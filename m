From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:34 +0000 (UTC)
Subject: master - toolib: fix ignore_vg
Message-ID: <20141114171734.D7ED760DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8923457b82456ebee3e333b3fcc26087483cd01
Commit:        d8923457b82456ebee3e333b3fcc26087483cd01
Parent:        06e3f1757eee0005267bbe1e088dd95638540849
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 10:50:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:10:45 2014 +0100

toolib: fix ignore_vg

Rework ignore_vg() API so it properly handles
multiple kind of vg_read_error() states.

Skip processing only otherwise valid VG.

Always return ECMD_FAILED when break is detected.

Check sigint_caught() in front of dm iterator loop.

Add stack for _process failing ret codes.
---
 WHATS_NEW        |    1 +
 tools/reporter.c |   22 +++---
 tools/toollib.c  |  201 ++++++++++++++++++++++++++----------------------------
 tools/toollib.h  |    2 +-
 4 files changed, 112 insertions(+), 114 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b526fa..33546ac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Fix ignore_vg() to properly react on various vg_read errors (2.02.112).
   Failed recovery returns FAILED_RECOVERY status flag for vg_read().
   Exit with non-zero status code when pvck encounters a problem.
   Fix clean_tree after activation/resume for cache target (2.02.112).
diff --git a/tools/reporter.c b/tools/reporter.c
index 8399395..eec9948 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -361,12 +361,13 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
 		      void *handle)
 {
-	int ret = ECMD_PROCESSED;
+	int skip;
 
-	if (ignore_vg(vg, vg_name, 0, &ret)) {
-		stack;
-		return ret;
-	}
+	if (ignore_vg(vg, vg_name, 0, &skip))
+		return_ECMD_FAILED;
+
+	if (skip)
+		return ECMD_PROCESSED;
 
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvs_single);
 }
@@ -375,12 +376,13 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle)
 {
-	int ret = ECMD_PROCESSED;
+	int skip;
 
-	if (ignore_vg(vg, vg_name, 0, &ret)) {
-		stack;
-		return ret;
-	}
+	if (ignore_vg(vg, vg_name, 0, &skip))
+		return_ECMD_FAILED;
+
+	if (skip)
+		return ECMD_PROCESSED;
 
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index e47213d..c3d6852 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -159,26 +159,26 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 /*
  * Returns 1 if VG should be ignored.
  */
-int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *ret)
+int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip)
 {
 	uint32_t read_error = vg_read_error(vg);
+	*skip = 0;
 
-	if (!read_error)
-		return 0;
-
-	if ((read_error == FAILED_INCONSISTENT) && allow_inconsistent)
-		return 0;
+	if ((read_error & FAILED_INCONSISTENT) && allow_inconsistent)
+		read_error &= ~FAILED_INCONSISTENT; /* Check for other errors */
 
-	if (read_error == FAILED_NOTFOUND)
-		*ret = ECMD_FAILED;
-	else if (read_error == FAILED_CLUSTERED && vg->cmd->ignore_clustered_vgs)
+	if ((read_error & FAILED_CLUSTERED) && vg->cmd->ignore_clustered_vgs) {
+		read_error &= ~FAILED_CLUSTERED; /* Check for other errors */
 		log_verbose("Skipping volume group %s", vg_name);
-	else {
-		log_error("Skipping volume group %s", vg_name);
-		*ret = ECMD_FAILED;
+		*skip = 1;
 	}
 
-	return 1;
+	if (read_error != SUCCESS) {
+		log_error("Cannot process volume group %s", vg_name);
+		return 1;
+	}
+
+	return 0;
 }
 
 /*
@@ -195,22 +195,17 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	int ret;
 	struct pv_segment _free_pv_segment = { .pv = pv };
 
-	if (dm_list_empty(&pv->segments)) {
-		ret = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle);
-		if (ret > ret_max)
-			ret_max = ret;
-	} else {
+	if (!dm_list_empty(&pv->segments)) {
 		dm_list_iterate_items(pvseg, &pv->segments) {
-			if (sigint_caught()) {
-				ret_max = ECMD_FAILED;
+			if (sigint_caught())
+				return_ECMD_FAILED;
+			if ((ret = process_single_pvseg(cmd, vg, pvseg, handle)) != ECMD_PROCESSED)
 				stack;
-				break;
-			}
-			ret = process_single_pvseg(cmd, vg, pvseg, handle);
 			if (ret > ret_max)
 				ret_max = ret;
 		}
-	}
+	} else if ((ret_max = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle)) != ECMD_PROCESSED)
+			stack;
 
 	return ret_max;
 }
@@ -225,9 +220,13 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	int ret;
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
-		ret = process_single_seg(cmd, seg, handle);
+		if (sigint_caught()) {
+			stack;
+			ret_max = ECMD_FAILED;
+			break;
+		}
+		if ((ret = process_single_seg(cmd, seg, handle)) != ECMD_PROCESSED)
+			stack;
 		if (ret > ret_max)
 			ret_max = ret;
 	}
@@ -1459,7 +1458,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	const char *vg_name;
 	const char *vg_uuid;
 	int ret_max = ECMD_PROCESSED;
-	int ret;
+	int ret, skip;
 	int process_all = 0;
 
 	/*
@@ -1469,34 +1468,32 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		process_all = 1;
 
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
-		ret = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
-			if (ret > ret_max)
-				ret_max = ret;
-			release_vg(vg);
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
-			continue;
-		}
-
-		/* Process this VG? */
-		if (process_all ||
-		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
-		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL)))
-			ret = process_single_vg(cmd, vg_name, vg, handle);
-
-		if (vg_read_error(vg))
+			ret = ECMD_FAILED;
 			release_vg(vg);
-		else
+		} else {
+			/* Process this VG? */
+			if (!skip &&
+			    (process_all ||
+			     (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
+			     (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL)))) {
+				if ((ret = process_single_vg(cmd, vg_name, vg, handle)) != ECMD_PROCESSED)
+					stack;
+			} else
+				ret = ECMD_PROCESSED;
 			unlock_and_release_vg(cmd, vg, vg_name);
+		}
 
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
-			break;
 	}
 
 	return ret_max;
@@ -1624,6 +1621,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 * but it works since entries are allocated from vg mem pool.
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
@@ -1656,12 +1656,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			 (!tags_supplied || !str_list_match_list(tags_in, &lvl->lv->tags, NULL)))
 			continue;
 
-		if (sigint_caught())
-			return_ECMD_FAILED;
-
 		log_very_verbose("Processing LV %s in VG %s", lvl->lv->name, vg->name);
 
-		ret = process_single_lv(cmd, lvl->lv, handle);
+		if ((ret = process_single_lv(cmd, lvl->lv, handle)) != ECMD_PROCESSED)
+			stack;
 
 		if (ret > ret_max)
 			ret_max = ret;
@@ -1809,11 +1807,14 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	const char *lvn;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
+	int skip;
 
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
-		ret = 0;
 
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
@@ -1846,23 +1847,21 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
-			if (ret > ret_max)
-				ret_max = ret;
-			release_vg(vg);
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
-			continue;
+			ret = ECMD_FAILED;
+			release_vg(vg);
+		} else {
+			if (skip)
+				ret = ECMD_PROCESSED;
+			else if ((ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
+							      handle, process_single_lv)) != ECMD_PROCESSED)
+				stack;
+			unlock_and_release_vg(cmd, vg, vg_name);
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
-					    handle, process_single_lv);
-		unlock_and_release_vg(cmd, vg, vg_name);
-
 		if (ret > ret_max)
 			ret_max = ret;
-
-		if (sigint_caught())
-			break;
 	}
 
 	return ret_max;
@@ -2030,6 +2029,9 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 	 * FIXME Formalise this extension or find an alternative.
 	 */
 	dm_list_iterate_items(devl, all_devices) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		memset(&pv_dummy, 0, sizeof(pv_dummy));
 		dm_list_init(&pv_dummy.tags);
 		dm_list_init(&pv_dummy.segments);
@@ -2042,9 +2044,6 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 
 		if (ret > ret_max)
 			ret_max = ret;
-
-		if (sigint_caught())
-			return_ECMD_FAILED;
 	}
 
 	return ECMD_PROCESSED;
@@ -2069,6 +2068,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	int ret = 0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		pv = pvl->pv;
 		pv_name = pv_dev_name(pv);
 
@@ -2107,16 +2109,15 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 				continue;
 			}
 
-			if (!skip)
-				ret = process_single_pv(cmd, vg, pv, handle);
+			if (!skip) {
+				if ((ret = process_single_pv(cmd, vg, pv, handle)) != ECMD_PROCESSED)
+					stack;
 
-			if (ret > ret_max)
-				ret_max = ret;
+				if (ret > ret_max)
+					ret_max = ret;
+			}
 		}
 
-		if (sigint_caught())
-			return_ECMD_FAILED;
-
 		/*
 		 * When processing only specific PV names, we can quit
 		 * once they've all been found.
@@ -2158,32 +2159,28 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 	int ret;
 
 	dm_list_iterate_items(vgnl, all_vgnameids) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
-		ret = 0;
-		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
-			if (ret > ret_max)
-				ret_max = ret;
-			skip = 1;
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+			stack;
+			ret = ECMD_FAILED;
+			release_vg(vg);
+		} else {
+			if ((ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
+						      process_all, skip, handle,
+						      process_single_pv)) != ECMD_PROCESSED)
+				stack;
+			unlock_and_release_vg(cmd, vg, vg->name);
 		}
 
-		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
-					 process_all, skip, handle, process_single_pv);
-
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (skip)
-			release_vg(vg);
-		else
-			unlock_and_release_vg(cmd, vg, vg->name);
-
-		if (sigint_caught())
-			return_ECMD_FAILED;
-
 		/* Quit early when possible. */
 		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
 			return ret_max;
@@ -2248,21 +2245,19 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
-	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
-				  &arg_pvnames, &arg_tags, process_all_pvs,
-				  handle, process_single_pv);
-	if (ret > ret_max)
-		ret_max = ret;
-
-	if (sigint_caught())
-		return_ECMD_FAILED;
+	if ((ret_max = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
+					   &arg_pvnames, &arg_tags, process_all_pvs,
+					   handle, process_single_pv)) != ECMD_PROCESSED)
+		stack;
 
-	if (!process_all_devices)
-		goto_out;
+	if (process_all_devices) {
+		if ((ret = _process_device_list(cmd, &all_devices, handle,
+						process_single_pv)) != ECMD_PROCESSED)
+			stack;
 
-	ret = _process_device_list(cmd, &all_devices, handle, process_single_pv);
-	if (ret > ret_max)
-		ret_max = ret;
+		if (ret > ret_max)
+			ret_max = ret;
+	}
 
 out:
 	return ret_max;
diff --git a/tools/toollib.h b/tools/toollib.h
index e0e1e66..9040387 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -20,7 +20,7 @@
 
 int become_daemon(struct cmd_context *cmd, int skip_lvm);
 
-int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *ret);
+int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip);
 
 typedef int (*process_single_vg_fn_t) (struct cmd_context * cmd,
 				       const char *vg_name,


