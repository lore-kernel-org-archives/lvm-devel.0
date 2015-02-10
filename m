From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:52 +0000 (UTC)
Subject: master - toollib: pass struct processing_handle to _select_match_* functions
Message-ID: <20150210151252.DCD3B60F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3180c4a05ea947b379e9e9bc51e50d0ca329980
Commit:        c3180c4a05ea947b379e9e9bc51e50d0ca329980
Parent:        a64b39aef80d790dd4afe4ce8fdaa0ed1b0e2c48
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 28 14:34:56 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:26 2015 +0100

toollib: pass struct processing_handle to _select_match_* functions

The "struct processing_handle" contains handles to drive the selection/matching
so pass it to the _select_match_* functions which are entry points to the
selection mechanism used in process_each_* and related functions.

This is revised and edited version of former Dave Teigland's patch which
provided starting point for all the select support in process_each_* fns.
---
 tools/toollib.c |   32 ++++++++++++++++++++++++--------
 tools/toollib.h |   12 ++++++------
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 759769e..13cb034 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1542,22 +1542,38 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
-int select_match_vg(struct cmd_context *cmd, struct volume_group *vg, int *selected)
+int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, int *selected)
 {
+	if (!handle->internal_report_for_select) {
+		*selected = 1;
+		return 1;
+	}
+
 	*selected = 1;
 	return 1;
 }
 
-int select_match_lv(struct cmd_context *cmd, struct volume_group *vg,
-		    struct logical_volume *lv, int *selected)
+int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, struct logical_volume *lv, int *selected)
 {
+	if (!handle->internal_report_for_select) {
+		*selected = 1;
+		return 1;
+	}
+
 	*selected = 1;
 	return 1;
 }
 
-int select_match_pv(struct cmd_context *cmd, struct volume_group *vg,
-		    struct physical_volume *pv, int *selected)
+int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, struct physical_volume *pv, int *selected)
 {
+	if (!handle->internal_report_for_select) {
+		*selected = 1;
+		return 1;
+	}
+
 	*selected = 1;
 	return 1;
 }
@@ -1609,7 +1625,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		if ((process_all ||
 		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
-		    select_match_vg(cmd, vg, &selected) && selected) {
+		    select_match_vg(cmd, handle, vg, &selected) && selected) {
 			ret = process_single_vg(cmd, vg_name, vg, handle);
 			if (ret != ECMD_PROCESSED)
 				stack;
@@ -1797,7 +1813,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!process_lv && tags_supplied && str_list_match_list(tags_in, &lvl->lv->tags, NULL))
 			process_lv = 1;
 
-		process_lv = process_lv && select_match_lv(cmd, vg, lvl->lv, &selected) && selected;
+		process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv, &selected) && selected;
 
 		if (sigint_caught())
 			return_ECMD_FAILED;
@@ -2307,7 +2323,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		    str_list_match_list(arg_tags, &pv->tags, NULL))
 			process_pv = 1;
 
-		process_pv = process_pv && select_match_pv(cmd, vg, pv, &selected) && selected;
+		process_pv = process_pv && select_match_pv(cmd, handle, vg, pv, &selected) && selected;
 
 		if (process_pv) {
 			if (skip)
diff --git a/tools/toollib.h b/tools/toollib.h
index cc86227..ead36d3 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -137,12 +137,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  int stop_on_error, struct processing_handle *handle,
 			  process_single_lv_fn_t process_single_lv);
 
-int select_match_vg(struct cmd_context *cmd, struct volume_group *vg,
-		    int *selected);
-int select_match_lv(struct cmd_context *cmd, struct volume_group *vg,
-		    struct logical_volume *lv, int *selected);
-int select_match_pv(struct cmd_context *cmd, struct volume_group *vg,
-		    struct physical_volume *pv, int *selected);
+int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, int *selected);
+int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, struct logical_volume *lv, int *selected);
+int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
+		    struct volume_group *vg, struct physical_volume *pv, int *selected);
 
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,


