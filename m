From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 18:34:25 +0000 (UTC)
Subject: master - toollib: ignore_vg() with skip is not locked
Message-ID: <20141114183425.63F0A60F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=513105c6aca5f8159b8345e3c252bf1ced40b92f
Commit:        513105c6aca5f8159b8345e3c252bf1ced40b92f
Parent:        27182e1ddb21d3a90559b7a848c422eb2a443cfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 19:32:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 19:32:03 2014 +0100

toollib: ignore_vg() with skip is not locked

Extend/fix d8923457b82456ebee3e333b3fcc26087483cd01 commit.

'skip'-ed VG is not holding any lock - so don't unlock such VG.

At the same time simplify the code around and relase VG at a single
place and unlock only not skiped and not ignored VGs.
---
 tools/toollib.c |   43 ++++++++++++++++++++++++-------------------
 1 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 5a17b5d..2b08249 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1478,19 +1478,20 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret = ECMD_FAILED;
-			release_vg(vg);
-		} else {
+		} else if (skip)
+			ret = ECMD_PROCESSED;
+		else {
 			/* Process this VG? */
-			if (!skip &&
-			    (process_all ||
-			     (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
-			     (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL)))) {
+			if (process_all ||
+			    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
+			    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) {
 				if ((ret = process_single_vg(cmd, vg_name, vg, handle)) != ECMD_PROCESSED)
 					stack;
 			} else
 				ret = ECMD_PROCESSED;
-			unlock_and_release_vg(cmd, vg, vg_name);
+			unlock_vg(cmd, vg_name);
 		}
+		release_vg(vg);
 
 		if (ret > ret_max)
 			ret_max = ret;
@@ -1850,15 +1851,15 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret = ECMD_FAILED;
-			release_vg(vg);
-		} else {
-			if (skip)
-				ret = ECMD_PROCESSED;
-			else if ((ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
-							      handle, process_single_lv)) != ECMD_PROCESSED)
+		} else if (skip)
+			ret = ECMD_PROCESSED;
+		else {
+			if ((ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
+							 handle, process_single_lv)) != ECMD_PROCESSED)
 				stack;
-			unlock_and_release_vg(cmd, vg, vg_name);
+			unlock_vg(cmd, vg_name);
 		}
+		release_vg(vg);
 
 		if (ret > ret_max)
 			ret_max = ret;
@@ -2169,14 +2170,15 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret = ECMD_FAILED;
-			release_vg(vg);
 		} else {
 			if ((ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
 						      process_all, skip, handle,
 						      process_single_pv)) != ECMD_PROCESSED)
 				stack;
-			unlock_and_release_vg(cmd, vg, vg->name);
+			if (!skip)
+				unlock_vg(cmd, vg->name);
 		}
+		release_vg(vg);
 
 		if (ret > ret_max)
 			ret_max = ret;
@@ -2208,7 +2210,7 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list all_devices;	/* device_list */
 	int process_all_pvs;
 	int process_all_devices;
-	int ret_max = ECMD_PROCESSED;
+	int ret_max;
 	int ret;
 
 	dm_list_init(&arg_tags);
@@ -2245,6 +2247,7 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
+	/* Here 'ret' could be only ECMD_PROCESSED */
 	if ((ret_max = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
 					   &arg_pvnames, &arg_tags, process_all_pvs,
 					   handle, process_single_pv)) != ECMD_PROCESSED)
@@ -2259,7 +2262,6 @@ int process_each_pv(struct cmd_context *cmd,
 			ret_max = ret;
 	}
 
-out:
 	return ret_max;
 }
 
@@ -2273,7 +2275,10 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (sigint_caught())
 			return_ECMD_FAILED;
-		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
+		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) != ECMD_PROCESSED)
+                        stack;
+
+		if (ret > ret_max)
 			ret_max = ret;
 	}
 


