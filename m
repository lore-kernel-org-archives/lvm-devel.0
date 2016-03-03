From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:55 +0000 (UTC)
Subject: master - toollib: honour '-H|--history' switch while executing process_each_lv_in_vg
Message-ID: <20160303131955.0973E60232@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e7a1210622e25a5a3d813b9a069767eaad3b4ac
Commit:        2e7a1210622e25a5a3d813b9a069767eaad3b4ac
Parent:        f7e0a4cc1809c371a4aee2a3da8a3545379fcfbf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:23:05 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:14 2016 +0100

toollib: honour '-H|--history' switch while executing process_each_lv_in_vg

When processing LVs in a VG and when the -H|--history switch is used,
make process_each_lv_in_vg to iterate over historical volumes too.

For each historical LV, we use dummy struct logical_volume instance with
the "this_glv" reference set to a wrapper over proper struct
historical_logical_volume representation. This makes it possible to process
historical LVs just like normal live LVs (though a dummy one without any
segments and all the other fields zeroed and blank) and it also allows
for using all historical LV related information via lv->this_glv->historical
reference.

One can use a simple call to lv_is_historical to make a difference between
live and historical LV in all the code that is called by process_each_* fns.
---
 tools/toollib.c |   85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3833581..9e866d6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2180,6 +2180,48 @@ out:
 	return ret_max;
 }
 
+static struct dm_str_list *_str_list_match_item_with_prefix(const struct dm_list *sll, const char *prefix, const char *str)
+{
+	struct dm_str_list *sl;
+	size_t prefix_len = strlen(prefix);
+
+	dm_list_iterate_items(sl, sll) {
+		if (!strncmp(prefix, sl->str, prefix_len) &&
+		    !strcmp(sl->str + prefix_len, str))
+			return sl;
+	}
+
+	return NULL;
+}
+
+/*
+ * Dummy LV, segment type and segment to represent all historical LVs.
+ */
+static struct logical_volume _historical_lv = {
+	.name = "",
+	.major = -1,
+	.minor = -1,
+	.snapshot_segs = DM_LIST_HEAD_INIT(_historical_lv.snapshot_segs),
+	.segments = DM_LIST_HEAD_INIT(_historical_lv.segments),
+	.tags = DM_LIST_HEAD_INIT(_historical_lv.tags),
+	.segs_using_this_lv = DM_LIST_HEAD_INIT(_historical_lv.segs_using_this_lv),
+	.indirect_glvs = DM_LIST_HEAD_INIT(_historical_lv.indirect_glvs),
+	.hostname = "",
+};
+
+static struct segment_type _historical_segment_type = {
+	.name = "historical",
+	.flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED,
+};
+
+static struct lv_segment _historical_lv_segment = {
+	.lv = &_historical_lv,
+	.segtype = &_historical_segment_type,
+	.len = 0,
+	.tags = DM_LIST_HEAD_INIT(_historical_lv_segment.tags),
+	.origin_list = DM_LIST_HEAD_INIT(_historical_lv_segment.origin_list),
+};
+
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
 			  int stop_on_error,
@@ -2199,6 +2241,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct dm_str_list *sl;
 	struct dm_list final_lvs;
 	struct lv_list *final_lvl;
+	struct glv_list *glvl, *tglvl;
 
 	dm_list_init(&final_lvs);
 
@@ -2340,6 +2383,48 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			goto_out;
 	}
 
+	if (handle->include_historical_lvs && !tags_supplied) {
+		if (!dm_list_size(&_historical_lv.segments))
+			dm_list_add(&_historical_lv.segments, &_historical_lv_segment.list);
+		_historical_lv.vg = vg;
+
+		dm_list_iterate_items_safe(glvl, tglvl, &vg->historical_lvs) {
+			process_lv = process_all;
+
+			if (lvargs_supplied &&
+			    (sl = _str_list_match_item_with_prefix(arg_lvnames, HISTORICAL_LV_PREFIX, glvl->glv->historical->name))) {
+				str_list_del(arg_lvnames, glvl->glv->historical->name);
+				dm_list_del(&sl->list);
+				process_lv = 1;
+			}
+
+			process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv, &selected) && selected;
+
+			if (sigint_caught()) {
+				ret_max = ECMD_FAILED;
+				goto_out;
+			}
+
+			if (!process_lv)
+				continue;
+
+			_historical_lv.this_glv = glvl->glv;
+			_historical_lv.name = glvl->glv->historical->name;
+			log_very_verbose("Processing historical LV %s in VG %s.", glvl->glv->historical->name, vg->name);
+
+			ret = process_single_lv(cmd, &_historical_lv, handle);
+			if (handle_supplied)
+				_update_selection_result(handle, &whole_selected);
+			if (ret != ECMD_PROCESSED)
+				stack;
+			if (ret > ret_max)
+				ret_max = ret;
+
+			if (stop_on_error && ret != ECMD_PROCESSED)
+				goto_out;
+		}
+	}
+
 	if (lvargs_supplied) {
 		/*
 		 * FIXME: lvm supports removal of LV with all its dependencies


