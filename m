From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:10 +0000 (UTC)
Subject: master - libdm: report: introduce dm_report_group
Message-ID: <20160620094010.ACFE460F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c8f912ea79d9b836c814b3d12cc331de634617e
Commit:        9c8f912ea79d9b836c814b3d12cc331de634617e
Parent:        029f51e1a853297ca7246b75ac80cde9de23a2a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 2 14:21:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 09:26:51 2016 +0200

libdm: report: introduce dm_report_group

This patch introduces DM report group (represented by dm_report_group
structure) that is used to group several reports to make a whole. As a
whole, all the reports in the group follow the same settings and/or
formatting used on output and it controls that the output is properly
ordered (e.g. the output from different reports is not interleaved
which would break readability and/or syntax of target output format
used for the whole group).

To support this feature, there are 4 new functions:
  - dm_report_group_create
  - dm_report_group_push
  - dm_report_group_pop
  - dm_report_group_destroy

>From the naming used (dm_report_group_push/pop), it's clear the reports
are pushed onto a stack. The rule then is that only the report on top
of the stack can be reported (that means calling dm_report_output).
This way we make sure that the output is not interleaved and provides
determinism and control over the output.

Different formats may allow or disallow some of the existing report
flags controlling output itself (DM_REPORT_OUTPUT_*) to be set or not so
once the report is pushed to a group, the grouping code makes sure that
all the reports have compatible flags set and then these flags are
restored once each report is popped from the report group stack.

We also allow to push/pop non-report item in which case such an item
creates a structure (e.g. to put several reports together with any
opening and/or closing lines needed on output which pose as extra
formatting structure besides formatting the reports).

The dm_report_group_push function accepts an argument to pass any
format-specific data needed (e.g. handle, name, structures passed
along while working with reports...).

We can call dm_report_output directly anytime we need (with the only
restriction that we can call dm_report_output only for the report that
is currently on top of the group's stack). Or we don't need to call
dm_report_output explicitly in which case all the reports in a stack are
reported on output automatically once we call dm_report_group_destroy.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_128 |    4 +
 libdm/libdevmapper.h                |   14 +++
 libdm/libdm-report.c                |  188 ++++++++++++++++++++++++++++++++++-
 4 files changed, 203 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6fb1745..c16f0c1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Add dm_report_group_{create,push,pop,destroy} to support report grouping.
 
 Version 1.02.127 - 11th June 2016
 =================================
diff --git a/libdm/.exported_symbols.DM_1_02_128 b/libdm/.exported_symbols.DM_1_02_128
new file mode 100644
index 0000000..6e365d5
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_128
@@ -0,0 +1,4 @@
+dm_report_group_create
+dm_report_group_push
+dm_report_group_pop
+dm_report_group_destroy
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d2f40c9..c99ebe8 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2704,6 +2704,20 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
 /*
+ * Report group support.
+ */
+struct dm_report_group;
+
+typedef enum {
+	DM_REPORT_GROUP_SINGLE,
+} dm_report_group_type_t;
+
+struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
+int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data);
+int dm_report_group_pop(struct dm_report_group *group);
+int dm_report_group_destroy(struct dm_report_group *group);
+
+/*
  * Stats counter access methods
  *
  * Each method returns the corresponding stats counter value from the
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 3896b3c..ab87ba7 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -32,6 +32,8 @@ struct selection {
 	struct selection_node *selection_root;
 };
 
+struct report_group_item;
+
 struct dm_report {
 	struct dm_pool *mem;
 
@@ -71,6 +73,29 @@ struct dm_report {
 	/* Null-terminated array of reserved values */
 	const struct dm_report_reserved_value *reserved_values;
 	struct dm_hash_table *value_cache;
+
+	struct report_group_item *group_item;
+};
+
+struct dm_report_group {
+	dm_report_group_type_t type;
+	struct dm_pool *mem;
+	struct dm_list items;
+	int indent;
+};
+
+struct report_group_item {
+	struct dm_list list;
+	struct dm_report_group *group;
+	struct dm_report *report;
+	union {
+		uint32_t orig_report_flags;
+		uint32_t finished_count;
+	} store;
+	struct report_group_item *parent;
+	int output_done:1;
+	int needs_closing:1;
+	void *data;
 };
 
 /*
@@ -4426,16 +4451,171 @@ int dm_report_is_empty(struct dm_report *rh)
 	return dm_list_empty(&rh->rows) ? 1 : 0;
 }
 
+static struct report_group_item *_get_topmost_report_group_item(struct dm_report_group *group)
+{
+	struct report_group_item *item;
+
+	if (group && !dm_list_empty(&group->items))
+		item = dm_list_item(dm_list_first(&group->items), struct report_group_item);
+	else
+		item = NULL;
+
+	return item;
+}
+
 int dm_report_output(struct dm_report *rh)
 {
-	if (dm_list_empty(&rh->rows))
-		return 1;
+	int r;
+
+	if (dm_list_empty(&rh->rows)) {
+		r = 1;
+		goto out;
+	}
 
 	if ((rh->flags & RH_SORT_REQUIRED))
 		_sort_rows(rh);
 
 	if ((rh->flags & DM_REPORT_OUTPUT_COLUMNS_AS_ROWS))
-		return _output_as_rows(rh);
+		r = _output_as_rows(rh);
 	else
-		return _output_as_columns(rh);
+		r = _output_as_columns(rh);
+out:
+	if (r && rh && rh->group_item)
+		rh->group_item->output_done = 1;
+	return r;
+}
+
+struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data)
+{
+	struct dm_report_group *group;
+	struct dm_pool *mem;
+	struct report_group_item *item;
+
+	if (!(mem = dm_pool_create("report_group", 1024))) {
+		log_error("dm_report: dm_report_init_group: failed to allocate mem pool");
+		return NULL;
+	}
+
+	if (!(group = dm_pool_zalloc(mem, sizeof(*group)))) {
+		log_error("dm_report: failed to allocate report group structure");
+		goto bad;
+	}
+
+	group->mem = mem;
+	group->type = type;
+	dm_list_init(&group->items);
+
+	if (!(item = dm_pool_zalloc(mem, sizeof(*item)))) {
+		log_error("dm_report: faile to allocate root report group item");
+		goto bad;
+	}
+
+	dm_list_add_h(&group->items, &item->list);
+
+	switch (type) {
+		default:
+			goto_bad;
+	}
+
+	return group;
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
+}
+
+int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data)
+{
+	struct report_group_item *item, *tmp_item;
+
+	if (!group)
+		return 1;
+
+	if (!(item = dm_pool_zalloc(group->mem, sizeof(*item)))) {
+		log_error("dm_report: dm_report_group_push: group item allocation failed");
+		return 0;
+	}
+
+	if ((item->report = report)) {
+		item->store.orig_report_flags = report->flags;
+		report->group_item = item;
+	}
+	item->group = group;
+	item->data = data;
+
+	dm_list_iterate_items(tmp_item, &group->items) {
+		if (!tmp_item->report) {
+			item->parent = tmp_item;
+			break;
+		}
+	}
+
+	dm_list_add_h(&group->items, &item->list);
+
+	switch (group->type) {
+		default:
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	dm_list_del(&item->list);
+	dm_pool_free(group->mem, item);
+	return 0;
+}
+
+int dm_report_group_pop(struct dm_report_group *group)
+{
+	struct report_group_item *item;
+
+	if (!group)
+		return 1;
+
+	if (!(item = _get_topmost_report_group_item(group))) {
+		log_error("dm_report: dm_report_group_pop: group has no items");
+		return 0;
+	}
+
+	switch (group->type) {
+		default:
+			return 0;
+        }
+
+	dm_list_del(&item->list);
+
+	if (item->report) {
+		item->report->flags = item->store.orig_report_flags;
+		item->report->group_item = NULL;
+	}
+
+	if (item->parent)
+		item->parent->store.finished_count++;
+
+	dm_pool_free(group->mem, item);
+	return 1;
+}
+
+int dm_report_group_destroy(struct dm_report_group *group)
+{
+	struct report_group_item *item, *tmp_item;
+	int r = 0;
+
+	if (!group)
+		return 1;
+
+	dm_list_iterate_items_safe(item, tmp_item, &group->items) {
+		if (item->report && !dm_report_output(item->report))
+			goto_out;
+		if (!dm_report_group_pop(group))
+			goto_out;
+	}
+
+	switch (group->type) {
+		default:
+			goto_out;
+        }
+
+	r = 1;
+out:
+	dm_pool_destroy(group->mem);
+	return r;
 }


