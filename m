From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:44 +0000 (UTC)
Subject: master - toollib: prepare select_match_{pv, vg, lv} hooks
Message-ID: <20150210151244.5F3276108E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=455ef6f2f58e5af11a75eb4b369c1a48780b068d
Commit:        455ef6f2f58e5af11a75eb4b369c1a48780b068d
Parent:        123a3383a021df737852892ff400f047b5ff609e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 24 11:08:41 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:04:41 2015 +0100

toollib: prepare select_match_{pv,vg,lv} hooks

These hooks will check currently processed PV/VG/LV with current selection
criteria and the processing continues only if there's a match.
---
 tools/toollib.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 tools/toollib.h |    7 ++++++
 2 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 17a9c71..c634b17 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1541,6 +1541,26 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
+int select_match_vg(struct cmd_context *cmd, struct volume_group *vg, int *selected)
+{
+	*selected = 1;
+	return 1;
+}
+
+int select_match_lv(struct cmd_context *cmd, struct volume_group *vg,
+		    struct logical_volume *lv, int *selected)
+{
+	*selected = 1;
+	return 1;
+}
+
+int select_match_pv(struct cmd_context *cmd, struct volume_group *vg,
+		    struct physical_volume *pv, int *selected)
+{
+	*selected = 1;
+	return 1;
+}
+
 static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 				  struct dm_list *vgnameids_to_process,
 				  struct dm_list *arg_vgnames,
@@ -1551,6 +1571,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
+	int selected;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
@@ -1583,9 +1604,10 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		/* Process this VG? */
-		if (process_all ||
+		if ((process_all ||
 		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
-		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) {
+		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
+		    select_match_vg(cmd, vg, &selected) && selected) {
 			ret = process_single_vg(cmd, vg_name, vg, handle);
 			if (ret != ECMD_PROCESSED)
 				stack;
@@ -1698,6 +1720,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
+	int selected;
+	unsigned process_lv;
 	unsigned process_all = 0;
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
@@ -1751,12 +1775,31 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
-		/* Only process the LV if the name matches or process_all is set or if an LV tag matches */
-		if (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name))
+		/*
+		 * process the LV if one of the following:
+		 * - process_all is set
+		 * - LV name matches a supplied LV name
+		 * - LV tag matches a supplied LV tag
+		 * - LV matches the selection
+		 */
+
+		process_lv = process_all;
+
+		if (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name)) {
 			/* Remove LV from list of unprocessed LV names */
 			str_list_del(arg_lvnames, lvl->lv->name);
-		else if (!process_all &&
-			 (!tags_supplied || !str_list_match_list(tags_in, &lvl->lv->tags, NULL)))
+			process_lv = 1;
+		}
+
+		if (!process_lv && tags_supplied && str_list_match_list(tags_in, &lvl->lv->tags, NULL))
+			process_lv = 1;
+
+		process_lv = process_lv && select_match_lv(cmd, vg, lvl->lv, &selected) && selected;
+
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
+		if (!process_lv)
 			continue;
 
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
@@ -2225,6 +2268,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct device_id_list *dil;
 	struct device *dev_orig;
 	const char *pv_name;
+	int selected;
 	int process_pv;
 	int dev_found;
 	int ret_max = ECMD_PROCESSED;
@@ -2259,6 +2303,8 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		    str_list_match_list(arg_tags, &pv->tags, NULL))
 			process_pv = 1;
 
+		process_pv = process_pv && select_match_pv(cmd, vg, pv, &selected) && selected;
+
 		if (process_pv) {
 			if (skip)
 				log_verbose("Skipping PV %s in VG %s.", pv_name, vg->name);
diff --git a/tools/toollib.h b/tools/toollib.h
index 715f65e..56259fb 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -79,6 +79,13 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  int stop_on_error, void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
+int select_match_vg(struct cmd_context *cmd, struct volume_group *vg,
+		    int *selected);
+int select_match_lv(struct cmd_context *cmd, struct volume_group *vg,
+		    struct logical_volume *lv, int *selected);
+int select_match_pv(struct cmd_context *cmd, struct volume_group *vg,
+		    struct physical_volume *pv, int *selected);
+
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found);


