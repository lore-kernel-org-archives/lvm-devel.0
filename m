From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:05 +0000 (GMT)
Subject: main - libdm: report: use 'null' for undefined numeric values in JSON_STD output
Message-ID: <20220811110605.3B7373858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e31621cebfb38f652233e2f80dd081cca5e8374
Commit:        1e31621cebfb38f652233e2f80dd081cca5e8374
Parent:        99299eb728d29b996a5ddacef7bafff2029e7d2e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 29 16:00:25 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: use 'null' for undefined numeric values in JSON_STD output

For JSON_STD format, use 'null' if a field has no value at all.

In JSON format, we print undefined numeric values this way:

  "key" = ""

while in JSON_STD format, we print undefined numeric values this way:

  "key" = null

(Keep in mind that 'null' is different from 0 (zero value) which is
a defined value.)
---
 device_mapper/libdm-report.c | 8 +++++++-
 libdm/libdm-report.c         | 8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 866ad454e..3c4b01127 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4360,6 +4360,7 @@ static int _sort_rows(struct dm_report *rh)
 #define JSON_ARRAY_START       "["
 #define JSON_ARRAY_END         "]"
 #define JSON_ESCAPE_CHAR       "\\"
+#define JSON_NULL              "null"
 
 #define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
 
@@ -4449,8 +4450,13 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	repstr = field->report_string;
+	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
+		repstr = JSON_NULL;
+	else
+		repstr = field->report_string;
+
 	width = field->props->width;
+
 	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
 		if (_is_json_report(rh)) {
 			/* Escape any JSON_QUOTE that may appear in reported string. */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 122a911c8..df52ee088 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4359,6 +4359,7 @@ static int _sort_rows(struct dm_report *rh)
 #define JSON_ARRAY_START       "["
 #define JSON_ARRAY_END         "]"
 #define JSON_ESCAPE_CHAR       "\\"
+#define JSON_NULL              "null"
 
 #define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
 
@@ -4448,8 +4449,13 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	repstr = field->report_string;
+	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
+		repstr = JSON_NULL;
+	else
+		repstr = field->report_string;
+
 	width = field->props->width;
+
 	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
 		if (_is_json_report(rh)) {
 			/* Escape any JSON_QUOTE that may appear in reported string. */

