From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 01 Nov 2010 14:08:11 +0100
Subject: [PATCH] Use dynamic allocation for buffer when reporting tags
In-Reply-To: <4CCEACE2.8060609@redhat.com>
References: <4CCEACE2.8060609@redhat.com>
Message-ID: <4CCEBBBB.2050705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OK, here's updated version (based on quick hints from Milan).

Peter
---
 libdm/libdm-report.c |   52 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7631e21..951ecb3 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -757,7 +757,8 @@ static int _report_headings(struct dm_report *rh)
 {
 	struct field_properties *fp;
 	const char *heading;
-	char buf[1024];
+	char *buf = NULL;
+	size_t buf_size = 0;
 
 	if (rh->flags & RH_HEADINGS_PRINTED)
 		return 1;
@@ -773,6 +774,18 @@ static int _report_headings(struct dm_report *rh)
 		return 0;
 	}
 
+	dm_list_iterate_items(fp, &rh->field_props) {
+		if (buf_size < fp->width)
+			buf_size = fp->width;
+	}
+	/* Including trailing '\0'! */
+	buf_size++;
+
+	if (!(buf = dm_malloc(buf_size))) {
+		log_error("dm_report: Could not allocate memory for heading buffer.");
+		goto bad;
+	}
+
 	/* First heading line */
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN)
@@ -780,7 +793,7 @@ static int _report_headings(struct dm_report *rh)
 
 		heading = rh->fields[fp->field_num].heading;
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
-			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
+			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
 				log_error("dm_report: snprintf heading failed");
 				goto bad;
@@ -806,9 +819,12 @@ static int _report_headings(struct dm_report *rh)
 	}
 	log_print("%s", (char *) dm_pool_end_object(rh->mem));
 
+	dm_free(buf);
+
 	return 1;
 
       bad:
+	dm_free(buf);
 	dm_pool_abandon_object(rh->mem);
 	return 0;
 }
@@ -892,7 +908,8 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	int32_t width;
 	uint32_t align;
 	const char *repstr;
-	char buf[4096];
+	char *buf = NULL;
+	size_t buf_size = 0;
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = strdup(rh->fields[field->props->field_num].id))) {
@@ -902,11 +919,13 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
 			log_error("dm_report: Unable to extend output line");
+			free(field_id);
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
 			log_error("dm_report: Unable to extend output line");
+			free(field_id);
 			return 0;
 		}
 
@@ -935,25 +954,33 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		if (!(align = field->props->flags & DM_REPORT_FIELD_ALIGN_MASK))
 			align = (field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ? 
 				DM_REPORT_FIELD_ALIGN_RIGHT : DM_REPORT_FIELD_ALIGN_LEFT;
+
+		/* Including trailing '\0'! */
+		buf_size = width + 1;
+		if (!(buf = dm_malloc(buf_size))) {
+			log_error("dm_report: Could not allocate memory for output line buffer.");
+			return 0;
+		}
+
 		if (align & DM_REPORT_FIELD_ALIGN_LEFT) {
-			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
+			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 width, width, repstr) < 0) {
 				log_error("dm_report: left-aligned snprintf() failed");
-				return 0;
+				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
 				log_error("dm_report: Unable to extend output line");
-				return 0;
+				goto bad;
 			}
 		} else if (align & DM_REPORT_FIELD_ALIGN_RIGHT) {
-			if (dm_snprintf(buf, sizeof(buf), "%*.*s",
+			if (dm_snprintf(buf, buf_size, "%*.*s",
 					 width, width, repstr) < 0) {
 				log_error("dm_report: right-aligned snprintf() failed");
-				return 0;
+				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
 				log_error("dm_report: Unable to extend output line");
-				return 0;
+				goto bad;
 			}
 		}
 	}
@@ -962,10 +989,15 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	    !(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED))
 		if (!dm_pool_grow_object(rh->mem, "\'", 1)) {
 			log_error("dm_report: Unable to extend output line");
-			return 0;
+			goto bad;
 		}
 
+	dm_free(buf);
 	return 1;
+
+bad:
+	dm_free(buf);
+	return 0;
 }
 
 static int _output_as_rows(struct dm_report *rh)


