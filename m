From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  5 Dec 2014 11:01:09 +0000 (UTC)
Subject: master - libdm: report: add dm_report_compact_fields
Message-ID: <20141205110109.F3B14609E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5edf6a56c4077edd238bf08bf369e7d82bca4ecf
Commit:        5edf6a56c4077edd238bf08bf369e7d82bca4ecf
Parent:        44394cd246dceec20dd404e3d39ba5867176d54b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 5 11:42:43 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 5 12:00:28 2014 +0100

libdm: report: add dm_report_compact_fields

Add new dm_report_compact_fields function to cause report outout
(dm_report_output) to ignore fields which don't have any value set
in any of the rows reported. This provides support for compact report
output where only fields which have something to report are displayed.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    7 +++++
 libdm/libdm-report.c |   67 +++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 66 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 98b0a5c..dcd35fa 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.93 -
 ====================================
+  Add dm_report_compact_fields to remove empty fields from report output.
   Remove unimplemented dm_report_set_output_selection from libdevmapper.h.
 
 Version 1.02.92 - 24th November 2014
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3c93dfd..fef0351 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1753,6 +1753,13 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						const struct dm_report_reserved_value reserved_values[],
 						void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
+
+/*
+ * Compact report output so that if field value is empty for all rows in
+ * the report, drop the field from output completely (including headers).
+ */
+int dm_report_compact_fields(struct dm_report *rh);
+
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index a1bab05..7dd52d4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -64,6 +64,7 @@ struct dm_report {
 #define FLD_SORT_KEY	0x00002000
 #define FLD_ASCENDING	0x00004000
 #define FLD_DESCENDING	0x00008000
+#define FLD_COMPACTED	0x00010000
 
 struct field_properties {
 	struct dm_list list;
@@ -84,16 +85,16 @@ struct op_def {
 	const char *desc;
 };
 
-#define FLD_CMP_MASK		0x00FF0000
-#define FLD_CMP_UNCOMPARABLE	0x00010000
-#define FLD_CMP_EQUAL		0x00020000
-#define FLD_CMP_NOT		0x00040000
-#define FLD_CMP_GT		0x00080000
-#define FLD_CMP_LT		0x00100000
-#define FLD_CMP_REGEX		0x00200000
-#define FLD_CMP_NUMBER		0x00400000
+#define FLD_CMP_MASK		0x0FF00000
+#define FLD_CMP_UNCOMPARABLE	0x00100000
+#define FLD_CMP_EQUAL		0x00200000
+#define FLD_CMP_NOT		0x00400000
+#define FLD_CMP_GT		0x00800000
+#define FLD_CMP_LT		0x01000000
+#define FLD_CMP_REGEX		0x02000000
+#define FLD_CMP_NUMBER		0x04000000
 /*
- * #define FLD_CMP_STRING 0x00400000
+ * #define FLD_CMP_STRING 0x08000000
  * We could defined FLD_CMP_STRING here for completeness here,
  * but it's not needed - we can check operator compatibility with
  * field type by using FLD_CMP_REGEX and FLD_CMP_NUMBER flags only.
@@ -1689,6 +1690,54 @@ out:
 	return r;
 }
 
+int dm_report_compact_fields(struct dm_report *rh)
+{
+	struct dm_report_field *field;
+	struct field_properties *fp;
+	struct row *row;
+
+	if (!rh || dm_list_empty(&rh->rows)) {
+		log_error("dm_report_enable_compact_output: no report fields to compact");
+		return 0;
+	}
+
+	/*
+	 * At first, mark all fields with FLD_HIDDEN flag.
+	 * Also, mark field with FLD_COMPACTED flag, but only
+	 * the ones that didn't have FLD_HIDDEN set before.
+	 * This prevents losing the original FLD_HIDDEN flag
+	 * in next step...
+	 */
+	dm_list_iterate_items(fp, &rh->field_props) {
+		if (!(fp->flags & FLD_HIDDEN))
+			fp->flags |= (FLD_COMPACTED | FLD_HIDDEN);
+	}
+
+	/*
+	 * ...check each field in a row and if its report value
+	 * is not empty, drop the FLD_COMPACTED and FLD_HIDDEN
+	 * flag if FLD_COMPACTED flag is set. It's important
+	 * to keep FLD_HIDDEN flag for the fields that were
+	 * already marked with FLD_HIDDEN before - these don't
+	 * have FLD_COMPACTED set - check this condition!
+	 */
+	dm_list_iterate_items(row, &rh->rows) {
+		dm_list_iterate_items(field, &row->fields) {
+			if ((field->report_string && *field->report_string) &&
+			     field->props->flags & FLD_COMPACTED)
+					field->props->flags &= ~(FLD_COMPACTED | FLD_HIDDEN);
+			}
+	}
+
+	/*
+	 * The fields left with FLD_COMPACTED and FLD_HIDDEN flag are
+	 * the ones which have blank value in all rows. The FLD_HIDDEN
+	 * will cause such field to not be reported on output at all.
+	 */
+
+	return 1;
+}
+
 /*
  * Selection parsing
  */


