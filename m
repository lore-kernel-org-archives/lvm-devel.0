From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 30 Jan 2014 21:10:12 +0000 (UTC)
Subject: master - compilation: Rename tags variables to tagsl.
Message-ID: <20140130211012.4CA4761600@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4aa8a14fc25e088ff49b6960ce99633b1a6978b3
Commit:        4aa8a14fc25e088ff49b6960ce99633b1a6978b3
Parent:        83358d4c039a36d5ef4b42b2213d73bb72ea7c26
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 30 21:09:28 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 30 21:09:28 2014 +0000

compilation: Rename tags variables to tagsl.

---
 lib/format_text/export.c |    6 ++--
 lib/format_text/tags.c   |   10 ++++----
 lib/metadata/metadata.c  |    6 ++--
 lib/metadata/metadata.h  |    2 +-
 lib/metadata/mirror.c    |    8 +++---
 lib/report/report.c      |    4 +-
 python/liblvm.c          |   25 +++++++++++---------
 tools/toollib.c          |   56 +++++++++++++++++++++++-----------------------
 tools/toollib.h          |    4 +-
 9 files changed, 62 insertions(+), 59 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 73030e4..883e076 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -367,12 +367,12 @@ static int _print_flag_config(struct formatter *f, uint64_t status, int type)
 }
 
 
-static int _out_tags(struct formatter *f, struct dm_list *tags)
+static int _out_tags(struct formatter *f, struct dm_list *tagsl)
 {
 	char *tag_buffer;
 
-	if (!dm_list_empty(tags)) {
-		if (!(tag_buffer = alloc_printed_tags(tags)))
+	if (!dm_list_empty(tagsl)) {
+		if (!(tag_buffer = alloc_printed_tags(tagsl)))
 			return_0;
 		if (!out_text(f, "tags = %s", tag_buffer)) {
 			dm_free(tag_buffer);
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index b0f0732..d0bf2b1 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -19,14 +19,14 @@
 #include "str_list.h"
 #include "lvm-string.h"
 
-char *alloc_printed_tags(struct dm_list *tags)
+char *alloc_printed_tags(struct dm_list *tagsl)
 {
 	struct str_list *sl;
 	int first = 1;
 	size_t size = 0;
 	char *buffer, *buf;
 
-	dm_list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tagsl)
 		/* '"' + tag + '"' + ',' + ' ' */
 		size += strlen(sl->str) + 4;
 	/* '[' + ']' + '\0' */
@@ -40,7 +40,7 @@ char *alloc_printed_tags(struct dm_list *tags)
 	if (!emit_to_buffer(&buf, &size, "["))
 		goto_bad;
 
-	dm_list_iterate_items(sl, tags) {
+	dm_list_iterate_items(sl, tagsl) {
 		if (!first) {
 			if (!emit_to_buffer(&buf, &size, ", "))
 				goto_bad;
@@ -61,7 +61,7 @@ bad:
 	return_NULL;
 }
 
-int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_value *cv)
+int read_tags(struct dm_pool *mem, struct dm_list *tagsl, const struct dm_config_value *cv)
 {
 	if (cv->type == DM_CFG_EMPTY_ARRAY)
 		return 1;
@@ -72,7 +72,7 @@ int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_
 			return 0;
 		}
 
-		if (!str_list_add(mem, tags, dm_pool_strdup(mem, cv->v.str)))
+		if (!str_list_add(mem, tagsl, dm_pool_strdup(mem, cv->v.str)))
 			return_0;
 
 		cv = cv->next;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4d4778b..16a5411 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4653,7 +4653,7 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 	return 1;
 }
 
-char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 {
 	struct str_list *sl;
 
@@ -4662,9 +4662,9 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 		return NULL;
 	}
 
-	dm_list_iterate_items(sl, tags) {
+	dm_list_iterate_items(sl, tagsl) {
 		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
-		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
+		    (sl->list.n != tagsl && !dm_pool_grow_object(mem, ",", 1))) {
 			log_error("dm_pool_grow_object failed");
 			return NULL;
 		}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index fef4b3f..83959bb 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -488,6 +488,6 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, struct pvcreate_params *pp);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
-char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 
 #endif
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 18917d3..5d99c50 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -279,7 +279,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
  */
 static int _init_mirror_log(struct cmd_context *cmd,
 			    struct logical_volume *log_lv, int in_sync,
-			    struct dm_list *tags, int remove_on_failure)
+			    struct dm_list *tagsl, int remove_on_failure)
 {
 	struct str_list *sl;
 	uint64_t orig_status = log_lv->status;
@@ -315,7 +315,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	lv_set_visible(log_lv);
 
 	/* Temporary tag mirror log for activation */
-	dm_list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tagsl)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
 			goto activate_lv;
@@ -336,7 +336,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* Remove the temporary tags */
-	dm_list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tagsl)
 		str_list_del(&log_lv->tags, sl->str);
 
 	if (activation()) {
@@ -376,7 +376,7 @@ deactivate_and_revert_new_lv:
 revert_new_lv:
 	log_lv->status = orig_status;
 
-	dm_list_iterate_items(sl, tags)
+	dm_list_iterate_items(sl, tagsl)
 		str_list_del(&log_lv->tags, sl->str);
 
 	if (remove_on_failure && !lv_remove(log_lv)) {
diff --git a/lib/report/report.c b/lib/report/report.c
index 3a5119d..18d7579 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -130,10 +130,10 @@ static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute__((unused)))
 {
-	const struct dm_list *tags = (const struct dm_list *) data;
+	const struct dm_list *tagsl = (const struct dm_list *) data;
 	char *tags_str;
 
-	if (!(tags_str = tags_format_and_copy(mem, tags)))
+	if (!(tags_str = tags_format_and_copy(mem, tagsl)))
 		return_0;
 
 	return _field_set_value(field, tags_str, NULL);
diff --git a/python/liblvm.c b/python/liblvm.c
index 6abd5ff..094aec2 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1043,22 +1043,22 @@ static PyObject *_liblvm_lvm_vg_list_lvs(vgobject *self)
 
 static PyObject *_liblvm_lvm_vg_get_tags(vgobject *self)
 {
-	struct dm_list *tags;
+	struct dm_list *tagsl;
 	struct lvm_str_list *strl;
 	PyObject * pytuple;
 	int i = 0;
 
 	VG_VALID(self);
 
-	if (!(tags = lvm_vg_get_tags(self->vg))) {
+	if (!(tagsl = lvm_vg_get_tags(self->vg))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	if (!(pytuple = PyTuple_New(dm_list_size(tags))))
+	if (!(pytuple = PyTuple_New(dm_list_size(tagsl))))
 		return NULL;
 
-	dm_list_iterate_items(strl, tags) {
+	dm_list_iterate_items(strl, tagsl) {
 		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
 		i++;
 	}
@@ -1163,8 +1163,9 @@ static PyObject *_liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 static void liblvm_lv_dealloc(lvobject *self)
 {
 	/* We can dealloc an object that didn't get fully created */
-	if (self->parent_vgobj)
+	if (self->parent_vgobj) {
 		Py_DECREF(self->parent_vgobj);
+	}
 
 	PyObject_Del(self);
 }
@@ -1291,11 +1292,13 @@ static PyObject *_liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
 
 static void _liblvm_pv_dealloc(pvobject *self)
 {
-	if (self->parent_vgobj)
+	if (self->parent_vgobj) {
 		Py_DECREF(self->parent_vgobj);
+	}
 
-	if (self->parent_pvslistobj)
+	if (self->parent_pvslistobj) {
 		Py_DECREF(self->parent_pvslistobj);
+	}
 
 	self->parent_vgobj = NULL;
 	self->parent_pvslistobj = NULL;
@@ -1474,22 +1477,22 @@ static PyObject *_liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
 
 static PyObject *_liblvm_lvm_lv_get_tags(lvobject *self)
 {
-	struct dm_list *tags;
+	struct dm_list *tagsl;
 	struct lvm_str_list *strl;
 	PyObject * pytuple;
 	int i = 0;
 
 	LV_VALID(self);
 
-	if (!(tags = lvm_lv_get_tags(self->lv))) {
+	if (!(tagsl = lvm_lv_get_tags(self->lv))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	if (!(pytuple = PyTuple_New(dm_list_size(tags))))
+	if (!(pytuple = PyTuple_New(dm_list_size(tagsl))))
 		return NULL;
 
-	dm_list_iterate_items(strl, tags) {
+	dm_list_iterate_items(strl, tagsl) {
 		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
 		i++;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 61c14f1..0662c9e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -184,7 +184,7 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
-			  const struct dm_list *tags,
+			  const struct dm_list *tagsl,
 			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv)
@@ -201,7 +201,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
-	if (tags && !dm_list_empty(tags))
+	if (tagsl && !dm_list_empty(tagsl))
 		tags_supplied = 1;
 
 	if (arg_lvnames && !dm_list_empty(arg_lvnames))
@@ -212,7 +212,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		process_all = 1;
 	/* Or if VG tags match */
 	else if (tags_supplied &&
-		 str_list_match_list(tags, &vg->tags, NULL))
+		 str_list_match_list(tagsl, &vg->tags, NULL))
 		process_all = 1;
 
 	/*
@@ -247,7 +247,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		/* LV tag match?   skip test, when process_all */
 		else if (!process_all &&
 			 (!tags_supplied ||
-			  !str_list_match_list(tags, &lvl->lv->tags, NULL)))
+			  !str_list_match_list(tagsl, &lvl->lv->tags, NULL)))
 			continue;
 
 		if (sigint_caught())
@@ -296,7 +296,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	struct cmd_vg *cvl_vg;
 	struct dm_list cmd_vgs;
 	struct dm_list failed_lvnames;
-	struct dm_list tags, lvnames;
+	struct dm_list tagsl, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	struct dm_list arg_vgnames;
 	char *vglv;
@@ -304,7 +304,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	const char *vgname;
 
-	dm_list_init(&tags);
+	dm_list_init(&tagsl);
 	dm_list_init(&arg_lvnames);
 	dm_list_init(&failed_lvnames);
 
@@ -327,7 +327,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						  vgname);
 					continue;
 				}
-				if (!str_list_add(cmd->mem, &tags,
+				if (!str_list_add(cmd->mem, &tagsl,
 						  dm_pool_strdup(cmd->mem,
 							      vgname + 1))) {
 					log_error("strlist allocation failed");
@@ -395,7 +395,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		vgnames = &arg_vgnames;
 	}
 
-	if (!argc || !dm_list_empty(&tags)) {
+	if (!argc || !dm_list_empty(&tagsl)) {
 		log_verbose("Finding all logical volumes");
 		if (!lvmetad_vg_list_to_lvmcache(cmd))
 			stack;
@@ -420,7 +420,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			continue;
 		}
 
-		tags_arg = &tags;
+		tags_arg = &tagsl;
 		dm_list_init(&lvnames);	/* LVs to be processed in this VG */
 		dm_list_iterate_items(sll, &arg_lvnames) {
 			const char *vg_name = sll->str;
@@ -562,7 +562,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
-			   struct dm_list *tags, struct dm_list *arg_vgnames,
+			   struct dm_list *tagsl, struct dm_list *arg_vgnames,
 			   uint32_t flags, void *handle, int ret_max,
 			   process_single_vg_fn_t process_single_vg)
 {
@@ -591,10 +591,10 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			}
 		}
 
-		if (!dm_list_empty(tags) &&
+		if (!dm_list_empty(tagsl) &&
 		    /* Only process if a tag matches or it's on arg_vgnames */
 		    !str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &cvl_vg->vg->tags, NULL))
+		    !str_list_match_list(tagsl, &cvl_vg->vg->tags, NULL))
 			break;
 
 		ret = process_single_vg(cmd, vg_name, cvl_vg->vg, handle);
@@ -622,11 +622,11 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 	struct str_list *sl;
 	struct dm_list *vgnames, *vgids;
-	struct dm_list arg_vgnames, tags;
+	struct dm_list arg_vgnames, tagsl;
 
 	const char *vg_name, *vgid;
 
-	dm_list_init(&tags);
+	dm_list_init(&tagsl);
 	dm_list_init(&arg_vgnames);
 
 	if (argc) {
@@ -642,7 +642,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 						ret_max = EINVALID_CMD_LINE;
 					continue;
 				}
-				if (!str_list_add(cmd->mem, &tags,
+				if (!str_list_add(cmd->mem, &tagsl,
 						  dm_pool_strdup(cmd->mem,
 							      vg_name + 1))) {
 					log_error("strlist allocation failed");
@@ -669,7 +669,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		vgnames = &arg_vgnames;
 	}
 
-	if (!argc || !dm_list_empty(&tags)) {
+	if (!argc || !dm_list_empty(&tagsl)) {
 		log_verbose("Finding all volume groups");
 		if (!lvmetad_vg_list_to_lvmcache(cmd))
 			stack;
@@ -683,7 +683,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 			vgid = sl->str;
 			if (!(vgid) || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
 				continue;
-			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
+			ret_max = _process_one_vg(cmd, vg_name, vgid, &tagsl,
 						  &arg_vgnames,
 						  flags, handle,
 					  	  ret_max, process_single_vg);
@@ -695,7 +695,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 			vg_name = sl->str;
 			if (is_orphan_vg(vg_name))
 				continue;	/* FIXME Unnecessary? */
-			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
+			ret_max = _process_one_vg(cmd, vg_name, NULL, &tagsl,
 						  &arg_vgnames,
 						  flags, handle,
 					  	  ret_max, process_single_vg);
@@ -706,7 +706,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 }
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tags, void *handle,
+			  const struct dm_list *tagsl, void *handle,
 			  process_single_pv_fn_t process_single_pv)
 {
 	int ret_max = ECMD_PROCESSED;
@@ -716,8 +716,8 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (sigint_caught())
 			return_ECMD_FAILED;
-		if (tags && !dm_list_empty(tags) &&
-		    !str_list_match_list(tags, &pvl->pv->tags, NULL)) {
+		if (tagsl && !dm_list_empty(tagsl) &&
+		    !str_list_match_list(tagsl, &pvl->pv->tags, NULL)) {
 			continue;
 		}
 		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
@@ -801,12 +801,12 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	struct dm_list *pvslist = NULL, *vgnames;
-	struct dm_list tags;
+	struct dm_list tagsl;
 	struct str_list *sll;
 	char *at_sign, *tagname;
 	struct device *dev;
 
-	dm_list_init(&tags);
+	dm_list_init(&tagsl);
 
 	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
@@ -831,7 +831,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 						ret_max = EINVALID_CMD_LINE;
 					continue;
 				}
-				if (!str_list_add(cmd->mem, &tags,
+				if (!str_list_add(cmd->mem, &tagsl,
 						  dm_pool_strdup(cmd->mem,
 							      tagname))) {
 					log_error("strlist allocation failed");
@@ -881,7 +881,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (ret > ret_max)
 				ret_max = ret;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
+		if (!dm_list_empty(&tagsl) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				if (sigint_caught()) {
@@ -895,7 +895,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 					continue;
 				}
 
-				ret = process_each_pv_in_vg(cmd, vg, &tags,
+				ret = process_each_pv_in_vg(cmd, vg, &tagsl,
 							    handle,
 							    process_single_pv);
 				if (ret > ret_max)
@@ -1215,7 +1215,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 {
 	struct dm_list *r;
 	struct pv_list *pvl;
-	struct dm_list tags, arg_pvnames;
+	struct dm_list tagsl, arg_pvnames;
 	char *pvname = NULL;
 	char *colon, *at_sign, *tagname;
 	int i;
@@ -1227,7 +1227,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 	}
 	dm_list_init(r);
 
-	dm_list_init(&tags);
+	dm_list_init(&tagsl);
 	dm_list_init(&arg_pvnames);
 
 	for (i = 0; i < argc; i++) {
diff --git a/tools/toollib.h b/tools/toollib.h
index d809123..54636ab 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -80,14 +80,14 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  const struct dm_list *tags, void *handle,
+			  const struct dm_list *tagsl, void *handle,
 			  process_single_pv_fn_t process_single_pv);
 
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
-			  const struct dm_list *tags,
+			  const struct dm_list *tagsl,
 			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);


