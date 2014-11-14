From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 14 Nov 2014 23:10:57 +0000 (UTC)
Subject: master - toollib: fixes and cleanup of recent changes
Message-ID: <20141114231057.570E2615AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b622a7fe3ffa89e763577c3176a2cc2f1b1e2cdd
Commit:        b622a7fe3ffa89e763577c3176a2cc2f1b1e2cdd
Parent:        513105c6aca5f8159b8345e3c252bf1ced40b92f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 14 15:00:35 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 14 16:58:09 2014 -0600

toollib: fixes and cleanup of recent changes

- Fix problems with recent changes related to skipping in:
  . _process_vgnameid_list
  . _process_pvs_in_vgs

- Undo unnecessary changes to the code structure and readability.

- Preserve valid but minor changes:
  . testing FAILED bit values in ignore_vg
  . using "skip" value from ignore_vg instead of "ret" value
  . applying the sigint check to the start of all loops
  . setting stack backtrace when ECMD_PROCESSED is not returned,
    i.e. apply the following pattern:

	ret = process_foo();
	if (ret != ECMD_PROCESSED)
		stack;
	if (ret > ret_max)
		ret_max = ret;
---
 tools/toollib.c |  174 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 107 insertions(+), 67 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 2b08249..8eb434d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -157,7 +157,17 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 }
 
 /*
- * Returns 1 if VG should be ignored.
+ * Three possible results:
+ * a) return 0, skip 0: take the VG, and cmd will end in success
+ * b) return 0, skip 1: skip the VG, and cmd will end in success
+ * c) return 1, skip *: skip the VG, and cmd will end in failure
+ *
+ * Case b is the special case, and includes the following:
+ * . The VG is inconsistent, and the command allows for inconsistent VGs.
+ * . The VG is clustered, the host cannot access clustered VG's,
+ *   and the command option has been used to ignore clustered vgs.
+ *
+ * Case c covers the other errors returned when reading the VG.
  */
 int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip)
 {
@@ -195,17 +205,24 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	int ret;
 	struct pv_segment _free_pv_segment = { .pv = pv };
 
-	if (!dm_list_empty(&pv->segments)) {
+	if (dm_list_empty(&pv->segments)) {
+		ret = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle);
+		if (ret != ECMD_PROCESSED)
+			stack;
+		if (ret > ret_max)
+			ret_max = ret;
+	} else {
 		dm_list_iterate_items(pvseg, &pv->segments) {
 			if (sigint_caught())
 				return_ECMD_FAILED;
-			if ((ret = process_single_pvseg(cmd, vg, pvseg, handle)) != ECMD_PROCESSED)
+
+			ret = process_single_pvseg(cmd, vg, pvseg, handle);
+			if (ret != ECMD_PROCESSED)
 				stack;
 			if (ret > ret_max)
 				ret_max = ret;
 		}
-	} else if ((ret_max = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle)) != ECMD_PROCESSED)
-			stack;
+	}
 
 	return ret_max;
 }
@@ -220,12 +237,11 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	int ret;
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (sigint_caught()) {
-			stack;
-			ret_max = ECMD_FAILED;
-			break;
-		}
-		if ((ret = process_single_seg(cmd, seg, handle)) != ECMD_PROCESSED)
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
+		ret = process_single_seg(cmd, seg, handle);
+		if (ret != ECMD_PROCESSED)
 			stack;
 		if (ret > ret_max)
 			ret_max = ret;
@@ -1458,7 +1474,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	const char *vg_name;
 	const char *vg_uuid;
 	int ret_max = ECMD_PROCESSED;
-	int ret, skip;
+	int ret;
+	int skip;
 	int process_all = 0;
 
 	/*
@@ -1473,28 +1490,35 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
+		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
-			ret = ECMD_FAILED;
-		} else if (skip)
-			ret = ECMD_PROCESSED;
-		else {
-			/* Process this VG? */
-			if (process_all ||
-			    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
-			    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) {
-				if ((ret = process_single_vg(cmd, vg_name, vg, handle)) != ECMD_PROCESSED)
-					stack;
-			} else
-				ret = ECMD_PROCESSED;
-			unlock_vg(cmd, vg_name);
+			ret_max = ECMD_FAILED;
+			release_vg(vg);
+			continue;
+		}
+		if (skip) {
+			release_vg(vg);
+			continue;
 		}
-		release_vg(vg);
 
-		if (ret > ret_max)
-			ret_max = ret;
+		/* Process this VG? */
+		if (process_all ||
+		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
+		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) {
+			ret = process_single_vg(cmd, vg_name, vg, handle);
+			if (ret != ECMD_PROCESSED)
+				stack;
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+
+		if (vg_read_error(vg))
+			release_vg(vg);
+		else
+			unlock_and_release_vg(cmd, vg, vg_name);
 	}
 
 	return ret_max;
@@ -1659,9 +1683,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
-		if ((ret = process_single_lv(cmd, lvl->lv, handle)) != ECMD_PROCESSED)
+		ret = process_single_lv(cmd, lvl->lv, handle);
+		if (ret != ECMD_PROCESSED)
 			stack;
-
 		if (ret > ret_max)
 			ret_max = ret;
 
@@ -1816,6 +1840,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
+		skip = 0;
 
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
@@ -1850,19 +1875,24 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
-			ret = ECMD_FAILED;
-		} else if (skip)
-			ret = ECMD_PROCESSED;
-		else {
-			if ((ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
-							 handle, process_single_lv)) != ECMD_PROCESSED)
-				stack;
-			unlock_vg(cmd, vg_name);
+			ret_max = ECMD_FAILED;
+			release_vg(vg);
+			continue;
+
+		}
+		if (skip) {
+			release_vg(vg);
+			continue;
 		}
-		release_vg(vg);
 
+		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
+					    handle, process_single_lv);
+		if (ret != ECMD_PROCESSED)
+			stack;
 		if (ret > ret_max)
 			ret_max = ret;
+
+		unlock_and_release_vg(cmd, vg, vg_name);
 	}
 
 	return ret_max;
@@ -2111,9 +2141,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			}
 
 			if (!skip) {
-				if ((ret = process_single_pv(cmd, vg, pv, handle)) != ECMD_PROCESSED)
+				ret = process_single_pv(cmd, vg, pv, handle);
+				if (ret != ECMD_PROCESSED)
 					stack;
-
 				if (ret > ret_max)
 					ret_max = ret;
 			}
@@ -2155,9 +2185,9 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 	struct dm_str_list *sl;
 	const char *vg_name;
 	const char *vg_uuid;
-	int skip;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
+	int skip;
 
 	dm_list_iterate_items(vgnl, all_vgnameids) {
 		if (sigint_caught())
@@ -2165,24 +2195,31 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
+		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret = ECMD_FAILED;
-		} else {
-			if ((ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
-						      process_all, skip, handle,
-						      process_single_pv)) != ECMD_PROCESSED)
-				stack;
-			if (!skip)
-				unlock_vg(cmd, vg->name);
-		}
-		release_vg(vg);
+			skip = 1;
 
-		if (ret > ret_max)
+			/* Only continue if no vg was returned. */
+			if (!vg)
+				continue;
+		}
+		
+		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
+					 process_all, skip, handle, process_single_pv);
+		if (ret != ECMD_PROCESSED)
+			stack;
+		 if (ret > ret_max)
 			ret_max = ret;
 
+		 if (skip)
+			 release_vg(vg);
+		 else
+			 unlock_and_release_vg(cmd, vg, vg->name);
+
 		/* Quit early when possible. */
 		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
 			return ret_max;
@@ -2210,7 +2247,7 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list all_devices;	/* device_list */
 	int process_all_pvs;
 	int process_all_devices;
-	int ret_max;
+	int ret_max = ECMD_PROCESSED;
 	int ret;
 
 	dm_list_init(&arg_tags);
@@ -2247,21 +2284,23 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
-	/* Here 'ret' could be only ECMD_PROCESSED */
-	if ((ret_max = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
-					   &arg_pvnames, &arg_tags, process_all_pvs,
-					   handle, process_single_pv)) != ECMD_PROCESSED)
+	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
+				  &arg_pvnames, &arg_tags, process_all_pvs,
+				  handle, process_single_pv);
+	if (ret != ECMD_PROCESSED)
 		stack;
+	if (ret > ret_max)
+		ret_max = ret;
 
-	if (process_all_devices) {
-		if ((ret = _process_device_list(cmd, &all_devices, handle,
-						process_single_pv)) != ECMD_PROCESSED)
-			stack;
-
-		if (ret > ret_max)
-			ret_max = ret;
-	}
+	if (!process_all_devices)
+		goto out;
 
+	ret = _process_device_list(cmd, &all_devices, handle, process_single_pv);
+	if (ret != ECMD_PROCESSED)
+		stack;
+	if (ret > ret_max)
+		ret_max = ret;
+out:
 	return ret_max;
 }
 
@@ -2275,9 +2314,10 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (sigint_caught())
 			return_ECMD_FAILED;
-		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) != ECMD_PROCESSED)
-                        stack;
 
+		ret = process_single_pv(cmd, vg, pvl->pv, handle);
+		if (ret != ECMD_PROCESSED)
+			stack;
 		if (ret > ret_max)
 			ret_max = ret;
 	}


