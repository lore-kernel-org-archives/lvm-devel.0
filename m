From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Jul 2016 10:30:08 +0000 (UTC)
Subject: master - libdm: report: fix json reporting to escape '"' character that may appear in reported string
Message-ID: <20160726103008.F385260254@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9697ea0067ef574aff09f1c8f25e1c7fab74c17
Commit:        f9697ea0067ef574aff09f1c8f25e1c7fab74c17
Parent:        d180bf63119580073235191c3527c9c8ee9cacbb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 26 12:27:41 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 26 12:27:41 2016 +0200

libdm: report: fix json reporting to escape '"' character that may appear in reported string

---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |   32 +++++++++++++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 53d0388..00f897a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.132 - 
 =================================
+  Fix json reporting to escape '"' character that may appear in reported string.
 
 Version 1.02.131 - 15th July 2016
 =================================
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 8993201..02fead5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4320,6 +4320,7 @@ static int _sort_rows(struct dm_report *rh)
 #define JSON_OBJECT_END        "}"
 #define JSON_ARRAY_START       "["
 #define JSON_ARRAY_END         "]"
+#define JSON_ESCAPE_CHAR       "\\"
 
 #define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
 
@@ -4346,6 +4347,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	int32_t width;
 	uint32_t align;
 	const char *repstr;
+	const char *p1_repstr, *p2_repstr;
 	char *buf = NULL;
 	size_t buf_size = 0;
 
@@ -4393,9 +4395,33 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	repstr = field->report_string;
 	width = field->props->width;
 	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
-		if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
-			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			return 0;
+		if (_is_json_report(rh)) {
+			/* Escape any JSON_QUOTE that may appear in reported string. */
+			p1_repstr = repstr;
+			while ((p2_repstr = strstr(p1_repstr, JSON_QUOTE))) {
+				if (p2_repstr > p1_repstr) {
+					if (!dm_pool_grow_object(rh->mem, p1_repstr, p2_repstr - p1_repstr)) {
+						log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+						return 0;
+					}
+				}
+				if (!dm_pool_grow_object(rh->mem, JSON_ESCAPE_CHAR, 1) ||
+				    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+					return 0;
+				}
+				p1_repstr = p2_repstr + 1;
+			}
+
+			if (!dm_pool_grow_object(rh->mem, p1_repstr, 0)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+		} else {
+			if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
 		}
 	} else {
 		if (!(align = field->props->flags & DM_REPORT_FIELD_ALIGN_MASK))


