From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:09 +0000 (UTC)
Subject: master - report: select: use _check_report_selection in dm_report_object to report only objects that satisfy the report selection
Message-ID: <20140617143409.7B1AC60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc6458de878af27667612ff7873243454bb63566
Commit:        bc6458de878af27667612ff7873243454bb63566
Parent:        d33280a978c3176e5c589c9cd477b766204e4914
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:36 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: use _check_report_selection in dm_report_object to report only objects that satisfy the report selection

This is rebased and edited version of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

This activates the actual selection process in dm_report_object.
---
 libdm/libdm-report.c |   39 +++++++++++++++++++++++++++------------
 1 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 51224f1..93cba9f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -953,19 +953,20 @@ static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 int dm_report_object(struct dm_report *rh, void *object)
 {
 	struct field_properties *fp;
-	struct row *row;
+	struct row *row = NULL;
 	struct dm_report_field *field;
 	void *data = NULL;
 	int len;
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
@@ -976,25 +977,25 @@ int dm_report_object(struct dm_report *rh, void *object)
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
 
 		if (!(data = _report_get_field_data(rh, fp, object))) {
-			log_error("dm_report_object: no data for field %s",
+			log_error("dm_report_object: "
+				  "no data assigned to field %s",
 				  rh->fields[fp->field_num].id);
-			return 0;
+			goto out;
 		}
 
 		if (!rh->fields[fp->field_num].report_fn(rh, rh->mem,
@@ -1003,24 +1004,38 @@ int dm_report_object(struct dm_report *rh, void *object)
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
 		len = (int) strlen(field->report_string);
-		if (len > field->props->width)
+		if ((len > field->props->width))
 			field->props->width = len;
 
 		if ((rh->flags & RH_SORT_REQUIRED) &&
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


