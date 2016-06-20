From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:09 +0000 (UTC)
Subject: master - libdm: report: remember special field to display selection status in struct row's field_sel_status variable
Message-ID: <20160620094109.6369C60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=102cc4c1e241ee7c3f6cc8c863a06dd29f373fbc
Commit:        102cc4c1e241ee7c3f6cc8c863a06dd29f373fbc
Parent:        f50d4011cdd3ef38c15b9dea05e73321592d93c2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 12 14:03:32 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

libdm: report: remember special field to display selection status in struct row's field_sel_status variable

This allows for moving parts of the code from dm_report_object to
dm_report_output which is important for subsequent patches that allow
for repeated dm_report_output, not destroying rows on each
dm_report_output call.
---
 libdm/libdm-report.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 3fa596e..13f2027 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -254,6 +254,7 @@ struct row {
 	struct dm_list fields;			  /* Fields in display order */
 	struct dm_report_field *(*sort_fields)[]; /* Fields in sort order */
 	int selected;
+	struct dm_report_field *field_sel_status;
 };
 
 /*
@@ -1910,7 +1911,7 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 	const struct dm_report_field_type *fields;
 	struct field_properties *fp;
 	struct row *row = NULL;
-	struct dm_report_field *field, *field_sel_status = NULL;
+	struct dm_report_field *field;
 	void *data = NULL;
 	int len;
 	int r = 0;
@@ -1962,7 +1963,7 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 		if (fp->implicit) {
 			fields = _implicit_report_fields;
 			if (!strcmp(fields[fp->field_num].id, SPECIAL_FIELD_SELECTED_ID))
-				field_sel_status = field;
+				row->field_sel_status = field;
 		} else
 			fields = rh->fields;
 
@@ -1994,7 +1995,7 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 	if (!_check_report_selection(rh, &row->fields)) {
 		row->selected = 0;
 
-		if (!field_sel_status)
+		if (!row->field_sel_status)
 			goto out;
 
 		/*
@@ -2004,14 +2005,14 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 		 * The "selected" field reports the result
 		 * of the selection.
 		 */
-		_implicit_report_fields[field_sel_status->props->field_num].report_fn(rh,
-						rh->mem, field_sel_status, row, rh->private);
+		_implicit_report_fields[row->field_sel_status->props->field_num].report_fn(rh,
+						rh->mem, row->field_sel_status, row, rh->private);
 		/*
 		 * If the "selected" field is not displayed, e.g.
 		 * because it is part of the sort field list,
 		 * skip the display of the row as usual.
 		 */
-		if (field_sel_status->props->flags & FLD_HIDDEN)
+		if (row->field_sel_status->props->flags & FLD_HIDDEN)
 			goto out;
 	}
 


