From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:04 +0000 (GMT)
Subject: main - libdm: report: remove double quotes around numeric values in JSON_STD output
Message-ID: <20220811110604.1B6AA3858429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99299eb728d29b996a5ddacef7bafff2029e7d2e
Commit:        99299eb728d29b996a5ddacef7bafff2029e7d2e
Parent:        02f015990b2d077f304e19c9ff11728d4480bee8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 27 09:29:55 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: remove double quotes around numeric values in JSON_STD output

In JSON format, we print numeric values this way:

  "key" = "N"

while in JSON_STD format, we print numeric value this way:

  "key" = N

(Where N is a numeric value.)
---
 device_mapper/libdm-report.c | 27 ++++++++++++++++++++-------
 libdm/libdm-report.c         | 27 ++++++++++++++++++++-------
 2 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 2e1f443f6..866ad454e 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4382,6 +4382,11 @@ static int _is_json_report(struct dm_report *rh)
 		rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD);
 }
 
+static int _is_pure_numeric_field(struct dm_report_field *field)
+{
+	return field->props->flags & (DM_REPORT_FIELD_TYPE_NUMBER | DM_REPORT_FIELD_TYPE_PERCENT);
+}
+
 /*
  * Produce report output
  */
@@ -4401,10 +4406,16 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
 		    !dm_pool_grow_object(rh->mem, fields[field->props->field_num].id, 0) ||
 		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-			log_error("dm_report: Unable to extend output line");
-			return 0;
+		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			goto bad;
+		}
+
+		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
 		}
 	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = strdup(fields[field->props->field_num].id))) {
@@ -4513,9 +4524,11 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 			}
 		}
 	} else if (_is_json_report(rh)) {
-		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			goto bad;
+		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
 		}
 	}
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b43ac4298..122a911c8 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4381,6 +4381,11 @@ static int _is_json_report(struct dm_report *rh)
 		rh->group_item->group->type == DM_REPORT_GROUP_JSON_STD);
 }
 
+static int _is_pure_numeric_field(struct dm_report_field *field)
+{
+	return field->props->flags & (DM_REPORT_FIELD_TYPE_NUMBER | DM_REPORT_FIELD_TYPE_PERCENT);
+}
+
 /*
  * Produce report output
  */
@@ -4400,10 +4405,16 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
 		    !dm_pool_grow_object(rh->mem, fields[field->props->field_num].id, 0) ||
 		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-			log_error("dm_report: Unable to extend output line");
-			return 0;
+		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			goto bad;
+		}
+
+		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
 		}
 	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = dm_strdup(fields[field->props->field_num].id))) {
@@ -4512,9 +4523,11 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 			}
 		}
 	} else if (_is_json_report(rh)) {
-		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			goto bad;
+		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
 		}
 	}
 

