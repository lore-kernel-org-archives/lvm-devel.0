From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:14 +0000 (UTC)
Subject: master - libdm: report: implement DM_REPORT_GROUP_BASIC for extended report output
Message-ID: <20160620094014.D37D460FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=230b7ff0f6c844bde2185baa9db63961baefb3d0
Commit:        230b7ff0f6c844bde2185baa9db63961baefb3d0
Parent:        a9fe57db1c285ef7052a1054891f5eb7dbbb01b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 23 10:47:03 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 10:42:26 2016 +0200

libdm: report: implement DM_REPORT_GROUP_BASIC for extended report output

This patch introduces DM_REPORT_GROUP_BASIC report group type. This
type has exactly the classical output format as we know from before
introduction of report groups. However, in addition to that, it allows
to put several reports into a group - this is the very basic grouping
scheme that doesn't change the output format itself:

  Report: report1_name
  Header1  Header2 ...
  value    value   ...
  value    value   ...
  ...      ...     ...

  Report: report2_name
  Header1  Header2 ...
  value    value   ...
  value    value   ...
  ...      ...     ...
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    1 +
 libdm/libdm-report.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 71 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index fdae74b..9e1985a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Introduce DM_REPORT_GROUP_BASIC for report group with basic report output.
   Introduce DM_REPORT_GROUP_SINGLE for report group having single report only.
   Add dm_report_group_{create,push,pop,destroy} to support report grouping.
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c99ebe8..fbe4322 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2710,6 +2710,7 @@ struct dm_report_group;
 
 typedef enum {
 	DM_REPORT_GROUP_SINGLE,
+	DM_REPORT_GROUP_BASIC
 } dm_report_group_type_t;
 
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7ea5ebf..d73598f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4205,6 +4205,12 @@ static int _sort_rows(struct dm_report *rh)
 
 #define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
 
+static int _is_basic_report(struct dm_report *rh)
+{
+	return rh->group_item &&
+	       (rh->group_item->group->type == DM_REPORT_GROUP_BASIC);
+}
+
 /*
  * Produce report output
  */
@@ -4463,9 +4469,29 @@ static struct report_group_item *_get_topmost_report_group_item(struct dm_report
 	return item;
 }
 
+static int _print_basic_report_header(struct dm_report *rh)
+{
+	const char *report_name = (const char *) rh->group_item->data;
+	size_t len = strlen(report_name);
+	char *underline;
+
+	if (!(underline = dm_pool_zalloc(rh->mem, len + 1)))
+		return_0;
+
+	memset(underline, '=', len);
+
+	if (rh->group_item->parent->store.finished_count > 0)
+		log_print("%s", "");
+	log_print("%s", report_name);
+	log_print("%s", underline);
+
+	dm_pool_free(rh->mem, underline);
+	return 1;
+}
+
 int dm_report_output(struct dm_report *rh)
 {
-	int r;
+	int r = 0;
 
 	if (dm_list_empty(&rh->rows)) {
 		r = 1;
@@ -4475,6 +4501,9 @@ int dm_report_output(struct dm_report *rh)
 	if ((rh->flags & RH_SORT_REQUIRED))
 		_sort_rows(rh);
 
+	if (_is_basic_report(rh) && !_print_basic_report_header(rh))
+		goto_out;
+
 	if ((rh->flags & DM_REPORT_OUTPUT_COLUMNS_AS_ROWS))
 		r = _output_as_rows(rh);
 	else
@@ -4490,6 +4519,11 @@ static int _report_group_create_single(struct dm_report_group *group)
 	return 1;
 }
 
+static int _report_group_create_basic(struct dm_report_group *group)
+{
+	return 1;
+}
+
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data)
 {
 	struct dm_report_group *group;
@@ -4522,6 +4556,10 @@ struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void
 			if (!_report_group_create_single(group))
 				goto_bad;
 			break;
+		case DM_REPORT_GROUP_BASIC:
+			if (!_report_group_create_basic(group))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4551,6 +4589,14 @@ static int _report_group_push_single(struct report_group_item *item, void *data)
 	return 1;
 }
 
+static int _report_group_push_basic(struct report_group_item *item, const char *name)
+{
+	if (!item->report && !name && item->parent->store.finished_count > 0)
+		log_print("%s", "");
+
+	return 1;
+}
+
 int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4584,6 +4630,10 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 			if (!_report_group_push_single(item, data))
 				goto_bad;
 			break;
+		case DM_REPORT_GROUP_BASIC:
+			if (!_report_group_push_basic(item, data))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4600,6 +4650,11 @@ static int _report_group_pop_single(struct report_group_item *item)
 	return 1;
 }
 
+static int _report_group_pop_basic(struct report_group_item *item)
+{
+	return 1;
+}
+
 int dm_report_group_pop(struct dm_report_group *group)
 {
 	struct report_group_item *item;
@@ -4617,6 +4672,10 @@ int dm_report_group_pop(struct dm_report_group *group)
 			if (!_report_group_pop_single(item))
 				return_0;
 			break;
+		case DM_REPORT_GROUP_BASIC:
+			if (!_report_group_pop_basic(item))
+				return_0;
+			break;
 		default:
 			return 0;
         }
@@ -4640,6 +4699,11 @@ static int _report_group_destroy_single(void)
 	return 1;
 }
 
+static int _report_group_destroy_basic(void)
+{
+	return 1;
+}
+
 int dm_report_group_destroy(struct dm_report_group *group)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4660,6 +4724,10 @@ int dm_report_group_destroy(struct dm_report_group *group)
 			if (!_report_group_destroy_single())
 				goto_out;
 			break;
+		case DM_REPORT_GROUP_BASIC:
+			if (!_report_group_destroy_basic())
+				goto_out;
+			break;
 		default:
 			goto_out;
         }


