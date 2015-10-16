From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 16 Oct 2015 15:07:25 +0000 (UTC)
Subject: master - libdm: add dm_report_compact_given_fields
Message-ID: <20151016150725.130AB60FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=508f0f5a21af8decf32944e01ecf17c0059a9c9f
Commit:        508f0f5a21af8decf32944e01ecf17c0059a9c9f
Parent:        df34fcdafd20ac195e588a06c8fc5a904fa71669
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 16 15:50:13 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 16 17:05:54 2015 +0200

libdm: add dm_report_compact_given_fields

dm_report_compact_given_fields is the same as dm_report_compact_fields,
but it processes only given fields, not all the fields in the report
like dm_report_compact_field does.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_110 |    1 +
 libdm/libdevmapper.h                |    7 ++++
 libdm/libdm-report.c                |   62 +++++++++++++++++++++++++++++++++-
 4 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dffcd34..9818846 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Add dm_report_compact_given_fields to remove given empty fields from report.
   Use libdm status parsing and local mem raid dmeventd plugin.
   Use local mem pool and lock only lvm2 execution for mirror dmeventd plugin.
   Lock protect only lvm2 execution for snapshot and thin dmeventd plugin.
diff --git a/libdm/.exported_symbols.DM_1_02_110 b/libdm/.exported_symbols.DM_1_02_110
new file mode 100644
index 0000000..71d04a9
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_110
@@ -0,0 +1 @@
+dm_report_compact_given_fields
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 8077867..1a2036b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2549,6 +2549,13 @@ int dm_report_object_is_selected(struct dm_report *rh, void *object, int do_outp
 int dm_report_compact_fields(struct dm_report *rh);
 
 /*
+ * The same as dm_report_compact_fields, but for selected fields only.
+ * The "fields" arg is comma separated list of field names (the same format
+ * as used for "output_fields" arg in dm_report_init fn).
+*/
+int dm_report_compact_given_fields(struct dm_report *rh, const char *fields);
+
+/*
  * Returns 1 if there is no data waiting to be output.
  */
 int dm_report_is_empty(struct dm_report *rh);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 681ad04..b2e70d5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -81,6 +81,7 @@ struct dm_report {
 #define FLD_ASCENDING	0x00004000
 #define FLD_DESCENDING	0x00008000
 #define FLD_COMPACTED	0x00010000
+#define FLD_COMPACT_ONE 0x00020000
 
 struct field_properties {
 	struct dm_list list;
@@ -2013,7 +2014,7 @@ out:
 	return r;
 }
 
-int dm_report_compact_fields(struct dm_report *rh)
+static int _do_report_compact_fields(struct dm_report *rh, int global)
 {
 	struct dm_report_field *field;
 	struct field_properties *fp;
@@ -2036,7 +2037,9 @@ int dm_report_compact_fields(struct dm_report *rh)
 	 * in next step...
 	 */
 	dm_list_iterate_items(fp, &rh->field_props) {
-		if (!(fp->flags & FLD_HIDDEN))
+		if (fp->flags & FLD_HIDDEN)
+			continue;
+		if (global || (fp->flags & FLD_COMPACT_ONE))
 			fp->flags |= (FLD_COMPACTED | FLD_HIDDEN);
 	}
 
@@ -2065,6 +2068,61 @@ int dm_report_compact_fields(struct dm_report *rh)
 	return 1;
 }
 
+int dm_report_compact_fields(struct dm_report *rh)
+{
+	return _do_report_compact_fields(rh, 1);
+}
+
+static int _field_to_compact_match(struct dm_report *rh, const char *field, size_t flen)
+{
+	struct field_properties *fp;
+	uint32_t f;
+	int implicit;
+
+	if ((_get_field(rh, field, flen, &f, &implicit))) {
+		dm_list_iterate_items(fp, &rh->field_props) {
+			if ((fp->implicit == implicit) && (fp->field_num == f)) {
+				fp->flags |= FLD_COMPACT_ONE;
+				break;
+			}
+		}
+		return 1;
+	}
+
+	return 0;
+}
+
+static int _parse_fields_to_compact(struct dm_report *rh, const char *fields)
+{
+	const char *ws;		  /* Word start */
+	const char *we = fields;  /* Word end */
+
+	if (!fields)
+		return 1;
+
+	while (*we) {
+		while (*we && *we == ',')
+			we++;
+		ws = we;
+		while (*we && *we != ',')
+			we++;
+		if (!_field_to_compact_match(rh, ws, (size_t) (we - ws))) {
+			log_error("dm_report: Unrecognized field: %.*s", (int) (we - ws), ws);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+int dm_report_compact_given_fields(struct dm_report *rh, const char *fields)
+{
+	if (!_parse_fields_to_compact(rh, fields))
+		return_0;
+
+	return _do_report_compact_fields(rh, 0);
+}
+
 int dm_report_object(struct dm_report *rh, void *object)
 {
 	return _do_report_object(rh, object, 1, NULL);


