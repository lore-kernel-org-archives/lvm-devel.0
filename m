From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:45 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: use _check_report_selection in dm_report_object to report only objects that satisfy the report selection
Message-ID: <20140606120345.E35B461051@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcdc0a09b2fed1f9aebc1adb8a19687b428989d8
Commit:        bcdc0a09b2fed1f9aebc1adb8a19687b428989d8
Parent:        5c3a72eb7ec90a8bc945ec04477208d8c1d2f528
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:36 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:11:20 2014 +0200

report: select: use _check_report_selection in dm_report_object to report only objects that satisfy the report selection

This is rebased and edited version of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

This activates the actual selection process in dm_report_object.
---
 libdm/libdm-report.c |   40 +++++++++++++++++++++++++++++-----------
 1 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5c33ef5..6b18ec9 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -948,18 +948,19 @@ static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 int dm_report_object(struct dm_report *rh, void *object)
 {
 	struct field_properties *fp;
-	struct row *row;
+	struct row *row = NULL;
 	struct dm_report_field *field;
 	void *data = NULL;
+	int r = 0;
 
 	if (!rh) {
 		log_error(INTERNAL_ERROR "dm_report handler is NULL.");
-		return 0;
+		goto out;
 	}
 
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
 		log_error("dm_report_object: struct row allocation failed");
-		return 0;
+		goto out;
 	}
 
 	row->rh = rh;
@@ -970,24 +971,27 @@ int dm_report_object(struct dm_report *rh, void *object)
 			       rh->keys_count))) {
 		log_error("dm_report_object: "
 			  "row sort value structure allocation failed");
-		return 0;
+		goto out;
 	}
 
 	dm_list_init(&row->fields);
-	dm_list_add(&rh->rows, &row->list);
 
 	/* For each field to be displayed, call its report_fn */
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (!(field = dm_pool_zalloc(rh->mem, sizeof(*field)))) {
 			log_error("dm_report_object: "
 				  "struct dm_report_field allocation failed");
-			return 0;
+			goto out;
 		}
 		field->props = fp;
 
 		data = _report_get_field_data(rh, fp, object);
-		if (!data)
-			return 0;
+		if (!data) {
+			log_error("dm_report_object: "
+				  "no data assigned to field %s",
+				  rh->fields[fp->field_num].id);
+			goto out;
+		}
 
 		if (!rh->fields[fp->field_num].report_fn(rh, rh->mem,
 							 field, data,
@@ -995,9 +999,20 @@ int dm_report_object(struct dm_report *rh, void *object)
 			log_error("dm_report_object: "
 				  "report function failed for field %s",
 				  rh->fields[fp->field_num].id);
-			return 0;
+			goto out;
 		}
 
+		dm_list_add(&row->fields, &field->list);
+	}
+
+	if (!_check_report_selection(rh, &row->fields)) {
+		r = 1;
+		goto out;
+	}
+
+	dm_list_add(&rh->rows, &row->list);
+
+	dm_list_iterate_items(field, &row->fields) {
 		if (((int) strlen(field->report_string) > field->props->width))
 			field->props->width = (int) strlen(field->report_string);
 
@@ -1005,13 +1020,16 @@ int dm_report_object(struct dm_report *rh, void *object)
 		    (field->props->flags & FLD_SORT_KEY)) {
 			(*row->sort_fields)[field->props->sort_posn] = field;
 		}
-		dm_list_add(&row->fields, &field->list);
 	}
 
 	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
 		return dm_report_output(rh);
 
-	return 1;
+	r = 1;
+out:
+	if (!r)
+		dm_pool_free(rh->mem, row);
+	return r;
 }
 
 /*


