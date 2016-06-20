From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:11 +0000 (UTC)
Subject: master - refactor: move field width calculation and sort preparation from _do_report_object to dm_report_output
Message-ID: <20160620094111.73E2560FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ba5f4b8e977a6f2f45f95777da508b42d84c01a
Commit:        0ba5f4b8e977a6f2f45f95777da508b42d84c01a
Parent:        102cc4c1e241ee7c3f6cc8c863a06dd29f373fbc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 12 14:07:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

refactor: move field width calculation and sort preparation from _do_report_object to dm_report_output

This also prepares code for repeated dm_report_output calls.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |   28 ++++++++++++++++------------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index fa4b9e6..7e98e1f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Move field width handling/sort init from dm_report_object to dm_report_output.
   Add _LOG_BYPASS_REPORT flag for bypassing any log report currently set.
   Introduce DM_REPORT_GROUP_JSON for report group with JSON output format.
   Introduce DM_REPORT_GROUP_BASIC for report group with basic report output.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 13f2027..7a5d6e5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1913,7 +1913,6 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 	struct row *row = NULL;
 	struct dm_report_field *field;
 	void *data = NULL;
-	int len;
 	int r = 0;
 
 	if (!rh) {
@@ -2021,17 +2020,6 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 
 	dm_list_add(&rh->rows, &row->list);
 
-	dm_list_iterate_items(field, &row->fields) {
-		len = (int) strlen(field->report_string);
-		if ((len > field->props->width))
-			field->props->width = len;
-
-		if ((rh->flags & RH_SORT_REQUIRED) &&
-		    (field->props->flags & FLD_SORT_KEY)) {
-			(*row->sort_fields)[field->props->sort_posn] = field;
-		}
-	}
-
 	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
 		return dm_report_output(rh);
 out:
@@ -4627,6 +4615,9 @@ static int _print_basic_report_header(struct dm_report *rh)
 
 int dm_report_output(struct dm_report *rh)
 {
+	struct row *row;
+	struct dm_report_field *field;
+	size_t len;
 	int r = 0;
 
 	if (_is_json_report(rh) &&
@@ -4638,6 +4629,19 @@ int dm_report_output(struct dm_report *rh)
 		goto out;
 	}
 
+	dm_list_iterate_items(row, &rh->rows) {
+		dm_list_iterate_items(field, &row->fields) {
+			len = (int) strlen(field->report_string);
+			if ((len > field->props->width))
+				field->props->width = len;
+
+			if ((rh->flags & RH_SORT_REQUIRED) &&
+			    (field->props->flags & FLD_SORT_KEY)) {
+				(*row->sort_fields)[field->props->sort_posn] = field;
+			}
+		}
+	}
+
 	if ((rh->flags & RH_SORT_REQUIRED))
 		_sort_rows(rh);
 


