From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  8 Apr 2016 08:55:24 +0000 (UTC)
Subject: master - cleanup: use #define for field's quote and pair character and also for the error msg while extending output line
Message-ID: <20160408085524.239BC61BB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2e59e05eda9283911a8c7ea14c73ea4c30f8fa8
Commit:        f2e59e05eda9283911a8c7ea14c73ea4c30f8fa8
Parent:        248f47d489df42ce29f74f71185a4e266a9e78e0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 8 10:55:13 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 8 10:55:13 2016 +0200

cleanup: use #define for field's quote and pair character and also for the error msg while extending output line

---
 libdm/libdm-report.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 8250a35..3896b3c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4175,6 +4175,11 @@ static int _sort_rows(struct dm_report *rh)
 	return 1;
 }
 
+#define STANDARD_QUOTE		"\'"
+#define STANDARD_PAIR		"="
+
+#define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
+
 /*
  * Produce report output
  */
@@ -4196,27 +4201,27 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 
 		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			dm_free(field_id);
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			dm_free(field_id);
 			return 0;
 		}
 
 		dm_free(field_id);
 
-		if (!dm_pool_grow_object(rh->mem, "=", 1)) {
-			log_error("dm_report: Unable to extend output line");
+		if (!dm_pool_grow_object(rh->mem, STANDARD_PAIR, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			return 0;
 		}
 
 		if (!(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED) &&
-		    !dm_pool_grow_object(rh->mem, "\'", 1)) {
-			log_error("dm_report: Unable to extend output line");
+		    !dm_pool_grow_object(rh->mem, STANDARD_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			return 0;
 		}
 	}
@@ -4225,7 +4230,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	width = field->props->width;
 	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
 		if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			return 0;
 		}
 	} else {
@@ -4248,7 +4253,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
-				log_error("dm_report: Unable to extend output line");
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 				goto bad;
 			}
 		} else if (align & DM_REPORT_FIELD_ALIGN_RIGHT) {
@@ -4258,7 +4263,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
-				log_error("dm_report: Unable to extend output line");
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 				goto bad;
 			}
 		}
@@ -4266,8 +4271,8 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 	if ((rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) &&
 	    !(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED))
-		if (!dm_pool_grow_object(rh->mem, "\'", 1)) {
-			log_error("dm_report: Unable to extend output line");
+		if (!dm_pool_grow_object(rh->mem, STANDARD_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			goto bad;
 		}
 
@@ -4345,7 +4350,7 @@ static int _output_as_rows(struct dm_report *rh)
 
 			if (!dm_list_end(&rh->rows, &row->list))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-					log_error("dm_report: Unable to extend output line");
+					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 					goto bad;
 				}
 		}
@@ -4393,7 +4398,7 @@ static int _output_as_columns(struct dm_report *rh)
 
 			if (!dm_list_end(&row->fields, fh))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-					log_error("dm_report: Unable to extend output line");
+					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 					goto bad;
 				}
 


