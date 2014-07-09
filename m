From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:45 +0000 (UTC)
Subject: master - report: report unknown/-1 for binary fields with unknown value
Message-ID: <20140709135745.6D9B6600EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a05862732d8e809f888313c546e97381c4e1f49
Commit:        1a05862732d8e809f888313c546e97381c4e1f49
Parent:        f76879ba440aa93f2e237335fe2cca6951a636bf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 8 12:15:14 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 8 16:16:02 2014 +0200

report: report unknown/-1 for binary fields with unknown value

Also respect --binary arg and/or report/binary_values_as_numeric
when displaying unknown values. If textual form is used, use "unknown",
if numeric value is used, use "-1" (which we already use to denote
unknown numeric values in other reports like lv_kernel_major and
lv_kernel_minor).
---
 lib/report/report.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 7cc3599..4ec75aa 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -192,6 +192,7 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 };
 
 static const char *_str_unknown = "unknown";
+static const char *_str_minus_one = "-1";
 
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
@@ -1313,6 +1314,17 @@ static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 		return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
 }
 
+static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			      struct dm_report_field *field, void *private)
+{
+	const struct cmd_context *cmd = (const struct cmd_context *) private;
+
+	if (cmd->report_binary_values_as_numeric)
+		return _field_set_value(field, _str_minus_one, &_reserved_number_undef_64);
+	else
+		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
 static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
@@ -1537,7 +1549,7 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lvi->info->exists)
 		return _binary_disp(rh, mem, field, lvi->info->suspended, "suspended", private);
 
-	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+	return _binary_undef_disp(rh, mem, field, private);
 }
 
 static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1549,7 +1561,7 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lvi->info->exists)
 		return _binary_disp(rh, mem, field, lvi->info->live_table, "live table present", private);
 
-	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+	return _binary_undef_disp(rh, mem, field, private);
 }
 
 static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1561,7 +1573,7 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lvi->info->exists)
 		return _binary_disp(rh, mem, field, lvi->info->inactive_table, "inactive table present", private);
 
-	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+	return _binary_undef_disp(rh, mem, field, private);
 }
 
 static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1573,7 +1585,7 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lvi->info->exists)
 		return _binary_disp(rh, mem, field, lvi->info->open_count, "open", private);
 
-	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+	return _binary_undef_disp(rh, mem, field, private);
 }
 
 static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,


