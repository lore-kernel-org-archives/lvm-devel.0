From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:43 +0000 (UTC)
Subject: master - libdm: report: postpone printing of JSON starting '{' character till it's needed
Message-ID: <20160809173943.B312D60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d86caf952ee208ef2b3b56937af670c76db75ba0
Commit:        d86caf952ee208ef2b3b56937af670c76db75ba0
Parent:        9c2113928430e25a4cc7b68a94aca7d8388b3b60
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 11:05:20 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

libdm: report: postpone printing of JSON starting '{' character till it's needed

This patch moves printing of starting '{' character for JSON output up
untili it's known there's any further output following - either the
content or ending '}' character.

Also, remove unnecessary switch for different report group types and
calling individual functions to handle dm_report_group_create as that
code is shared for all existing types at the moment.
---
 libdm/libdm-report.c |   50 ++++++++++++++------------------------------------
 1 files changed, 14 insertions(+), 36 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 886d8a2..d1f2dd8 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4674,6 +4674,14 @@ static struct report_group_item *_get_topmost_report_group_item(struct dm_report
 	return item;
 }
 
+static void _json_output_start(struct dm_report_group *group)
+{
+	if (!group->indent) {
+		log_print(JSON_OBJECT_START);
+		group->indent += JSON_INDENT_UNIT;
+	}
+}
+
 static int _json_output_array_start(struct dm_pool *mem, struct report_group_item *item)
 {
 	const char *name = (const char *) item->data;
@@ -4713,6 +4721,8 @@ bad:
 
 static int _prepare_json_report_output(struct dm_report *rh)
 {
+	_json_output_start(rh->group_item->group);
+
 	if (rh->group_item->output_done && dm_list_empty(&rh->rows))
 		return 1;
 
@@ -4795,23 +4805,6 @@ void dm_report_destroy_rows(struct dm_report *rh)
 	_destroy_rows(rh);
 }
 
-static int _report_group_create_single(struct dm_report_group *group)
-{
-	return 1;
-}
-
-static int _report_group_create_basic(struct dm_report_group *group)
-{
-	return 1;
-}
-
-static int _report_group_create_json(struct dm_report_group *group)
-{
-	log_print(JSON_OBJECT_START);
-	group->indent += JSON_INDENT_UNIT;
-	return 1;
-}
-
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data)
 {
 	struct dm_report_group *group;
@@ -4839,23 +4832,6 @@ struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void
 
 	dm_list_add_h(&group->items, &item->list);
 
-	switch (type) {
-		case DM_REPORT_GROUP_SINGLE:
-			if (!_report_group_create_single(group))
-				goto_bad;
-			break;
-		case DM_REPORT_GROUP_BASIC:
-			if (!_report_group_create_basic(group))
-				goto_bad;
-			break;
-		case DM_REPORT_GROUP_JSON:
-			if (!_report_group_create_json(group))
-				goto_bad;
-			break;
-		default:
-			goto_bad;
-	}
-
 	return group;
 bad:
 	dm_pool_destroy(mem);
@@ -4907,6 +4883,7 @@ static int _report_group_push_json(struct report_group_item *item, const char *n
 					 DM_REPORT_OUTPUT_COLUMNS_AS_ROWS);
 		item->report->flags |= DM_REPORT_OUTPUT_BUFFERED;
 	} else {
+		_json_output_start(item->group);
 		if (name) {
 			if (!_json_output_array_start(item->group->mem, item))
 				return_0;
@@ -5061,8 +5038,9 @@ static int _report_group_destroy_basic(void)
 	return 1;
 }
 
-static int _report_group_destroy_json(void)
+static int _report_group_destroy_json(struct dm_report_group *group)
 {
+	_json_output_start(group);
 	log_print(JSON_OBJECT_END);
 	return 1;
 }
@@ -5092,7 +5070,7 @@ int dm_report_group_destroy(struct dm_report_group *group)
 				goto_out;
 			break;
 		case DM_REPORT_GROUP_JSON:
-			if (!_report_group_destroy_json())
+			if (!_report_group_destroy_json(group))
 				goto_out;
 			break;
 		default:


