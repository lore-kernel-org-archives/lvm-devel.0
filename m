From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 10:37:26 +0000 (UTC)
Subject: master - libdm: report: also check whether field type is supported for field-specific reserved value
Message-ID: <20141218103726.62E7D61147@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aaf25ec6bd2201d4219765d7bfca05636b554145
Commit:        aaf25ec6bd2201d4219765d7bfca05636b554145
Parent:        e471ea7890cf555ad920ca67a38254dd2504dabe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 11:29:48 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 11:29:48 2014 +0100

libdm: report: also check whether field type is supported for field-specific reserved value

We only checked global per-report-type reserved values for compatibility
with selection code. This patch also adds a check for per-report-field
reserved values. This avoids problems where unsupported report type is
used as reserved value which could cause hard to debug problems
otherwise. So this additional check stops from registering unsupported
and unhandled per-field reserved values.

Registerting such unsupported reserved value is a programmatic error,
so report internal error in this case to stop us from making a mistake
here in the future or even today where STR_LIST fields can't have
reserved values yet.
---
 libdm/libdm-report.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index e3c3d2f..5ff6cda 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1995,9 +1995,12 @@ dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)
  * Used to check whether the reserved_values definition passed to
  * dm_report_init_with_selection contains only supported reserved value types.
  */
-static int _check_reserved_values_supported(const struct dm_report_reserved_value reserved_values[])
+static int _check_reserved_values_supported(const struct dm_report_field_type fields[],
+					    const struct dm_report_reserved_value reserved_values[])
 {
 	const struct dm_report_reserved_value *iter;
+	const struct dm_report_field_reserved_value *field_res;
+	const struct dm_report_field_type *field;
 	static uint32_t supported_reserved_types = DM_REPORT_FIELD_TYPE_NUMBER |
 						   DM_REPORT_FIELD_TYPE_SIZE |
 						   DM_REPORT_FIELD_TYPE_PERCENT |
@@ -2008,9 +2011,25 @@ static int _check_reserved_values_supported(const struct dm_report_reserved_valu
 
 	iter = reserved_values;
 
-	while (iter->type) {
-		if (!(iter->type & supported_reserved_types))
-			return 0;
+	while (iter->value) {
+		if (iter->type) {
+			if (!(iter->type & supported_reserved_types)) {
+				log_error(INTERNAL_ERROR "_check_reserved_values_supported: "
+					  "global reserved value for type 0x%x not supported",
+					   iter->type);
+				return 0;
+			}
+		} else {
+			field_res = (const struct dm_report_field_reserved_value *) iter->value;
+			field = &fields[field_res->field_num];
+			if (!(field->flags & supported_reserved_types)) {
+				log_error(INTERNAL_ERROR "_check_reserved_values_supported: "
+					  "field-specific reserved value of type 0x%x for "
+					  "field %s not supported",
+					   field->flags & DM_REPORT_FIELD_TYPE_MASK, field->id);
+				return 0;
+			}
+		}
 		iter++;
 	}
 
@@ -2906,7 +2925,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
-	if (!_check_reserved_values_supported(reserved_values)) {
+	if (!_check_reserved_values_supported(fields, reserved_values)) {
 		log_error(INTERNAL_ERROR "dm_report_init_with_selection: "
 			  "trying to register unsupported reserved value type, "
 			  "skipping report selection");


