From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 01 Nov 2010 13:04:50 +0100
Subject: [PATCH] Use dynamic allocation for buffer when reporting tags
Message-ID: <4CCEACE2.8060609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There's been a patch done recently to use dynamic allocation
for metadata tags buffer which works fine now even with large
set of tags/long tags (rhbz #633033).

But we need the same dynamic allocation when trying to output
the list of tags in reports which still use constant size
buffer and hence makes problems (rhbz #648219).

Peter
---
 libdm/libdm-report.c |   48 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7631e21..55b8b80 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -757,7 +757,8 @@ static int _report_headings(struct dm_report *rh)
 {
 	struct field_properties *fp;
 	const char *heading;
-	char buf[1024];
+	char *buf;
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
@@ -806,9 +819,13 @@ static int _report_headings(struct dm_report *rh)
 	}
 	log_print("%s", (char *) dm_pool_end_object(rh->mem));
 
+	dm_free(buf);
+
 	return 1;
 
       bad:
+	if (buf)
+		dm_free(buf);
 	dm_pool_abandon_object(rh->mem);
 	return 0;
 }
@@ -892,7 +909,8 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	int32_t width;
 	uint32_t align;
 	const char *repstr;
-	char buf[4096];
+	char *buf;
+	size_t buf_size = 0;
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = strdup(rh->fields[field->props->field_num].id))) {
@@ -935,25 +953,33 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
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
@@ -966,6 +992,10 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 
 	return 1;
+
+bad:
+	dm_free(buf);
+	return 0;
 }
 
 static int _output_as_rows(struct dm_report *rh)


