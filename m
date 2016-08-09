From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:45 +0000 (UTC)
Subject: master - libdm: report: add dm_report_group_output_and_pop_all
Message-ID: <20160809173945.CEA1D60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d1125e5b785014d3bae34acd158c528a4222871
Commit:        7d1125e5b785014d3bae34acd158c528a4222871
Parent:        d86caf952ee208ef2b3b56937af670c76db75ba0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 13:50:45 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

libdm: report: add dm_report_group_output_and_pop_all

The dm_report_group_output_and_pop_all calls dm_report_output and
dm_report_group_pop for all the items that are currently in report
group. This is just a shortcut that makes it easier to output and
pop group's content so the group handle can be reused again without
a need to initialize and configure it again.

The functionality of dm_report_group_output_and_pop_all is the
same as dm_report_destroy but without destroying the report group
handle.
---
 libdm/.exported_symbols.DM_1_02_133 |    1 +
 libdm/libdevmapper.h                |    1 +
 libdm/libdm-report.c                |   59 ++++++++++++----------------------
 3 files changed, 23 insertions(+), 38 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_133 b/libdm/.exported_symbols.DM_1_02_133
index 4318f80..f104808 100644
--- a/libdm/.exported_symbols.DM_1_02_133
+++ b/libdm/.exported_symbols.DM_1_02_133
@@ -1 +1,2 @@
 dm_report_destroy_rows
+dm_report_group_output_and_pop_all
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 844a455..5246b15 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2974,6 +2974,7 @@ typedef enum {
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
 int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data);
 int dm_report_group_pop(struct dm_report_group *group);
+int dm_report_group_output_and_pop_all(struct dm_report_group *group);
 int dm_report_group_destroy(struct dm_report_group *group);
 
 /*
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index d1f2dd8..fed79d4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -5028,57 +5028,40 @@ int dm_report_group_pop(struct dm_report_group *group)
 	return 1;
 }
 
-static int _report_group_destroy_single(void)
+int dm_report_group_output_and_pop_all(struct dm_report_group *group)
 {
-	return 1;
-}
+	struct report_group_item *item, *tmp_item;
 
-static int _report_group_destroy_basic(void)
-{
-	return 1;
-}
+	dm_list_iterate_items_safe(item, tmp_item, &group->items) {
+		if (!item->parent) {
+			item->store.finished_count = 0;
+			continue;
+		}
+		if (item->report && !dm_report_output(item->report))
+			return_0;
+		if (!dm_report_group_pop(group))
+			return_0;
+	}
+
+	if (group->type == DM_REPORT_GROUP_JSON) {
+		_json_output_start(group);
+		log_print(JSON_OBJECT_END);
+		group->indent -= JSON_INDENT_UNIT;
+	}
 
-static int _report_group_destroy_json(struct dm_report_group *group)
-{
-	_json_output_start(group);
-	log_print(JSON_OBJECT_END);
 	return 1;
 }
 
 int dm_report_group_destroy(struct dm_report_group *group)
 {
-	struct report_group_item *item, *tmp_item;
-	int r = 0;
+	int r = 1;
 
 	if (!group)
 		return 1;
 
-	dm_list_iterate_items_safe(item, tmp_item, &group->items) {
-		if (item->report && !dm_report_output(item->report))
-			goto_out;
-		if (!dm_report_group_pop(group))
-			goto_out;
-	}
-
-	switch (group->type) {
-		case DM_REPORT_GROUP_SINGLE:
-			if (!_report_group_destroy_single())
-				goto_out;
-			break;
-		case DM_REPORT_GROUP_BASIC:
-			if (!_report_group_destroy_basic())
-				goto_out;
-			break;
-		case DM_REPORT_GROUP_JSON:
-			if (!_report_group_destroy_json(group))
-				goto_out;
-			break;
-		default:
-			goto_out;
-        }
+	if (!dm_report_group_output_and_pop_all(group))
+		r = 0;
 
-	r = 1;
-out:
 	dm_pool_destroy(group->mem);
 	return r;
 }


