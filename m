From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Nov 2010 13:31:56 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20101101133156.18419.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-11-01 13:31:55

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Allocate buffer for reporting functions dynamically to support long outputs.
	Fix memory leak of field_id in _output_field function.
	
	There's been a patch added recently to use dynamic allocation for metadata
	tags buffer to remove the 4k limit (for writing metadata out). However, when
	using reporting commands like vgs and lvs, we still need to fix libdm reporting
	functions themselves to support such long outputs. So the buffer used in those
	reporting functions is dynamic now.
	
	The patch also includes a fix for field_id memory leak which was found in
	the _output_field function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.420&r2=1.421
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW_DM	2010/10/25 16:38:20	1.420
+++ LVM2/WHATS_NEW_DM	2010/11/01 13:31:55	1.421
@@ -1,5 +1,7 @@
 Version 1.02.57
 ===================================
+  Fix memory leak of field_id in _output_field function.
+  Allocate buffer for reporting functions dynamically to support long outputs.
 
 Version 1.02.56 - 25th October 2010
 ===================================
--- LVM2/libdm/libdm-report.c	2010/09/30 21:06:52	1.37
+++ LVM2/libdm/libdm-report.c	2010/11/01 13:31:55	1.38
@@ -757,7 +757,8 @@
 {
 	struct field_properties *fp;
 	const char *heading;
-	char buf[1024];
+	char *buf = NULL;
+	size_t buf_size = 0;
 
 	if (rh->flags & RH_HEADINGS_PRINTED)
 		return 1;
@@ -773,6 +774,18 @@
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
@@ -780,7 +793,7 @@
 
 		heading = rh->fields[fp->field_num].heading;
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
-			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
+			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
 				log_error("dm_report: snprintf heading failed");
 				goto bad;
@@ -806,9 +819,12 @@
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
@@ -892,7 +908,8 @@
 	int32_t width;
 	uint32_t align;
 	const char *repstr;
-	char buf[4096];
+	char *buf = NULL;
+	size_t buf_size = 0;
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = strdup(rh->fields[field->props->field_num].id))) {
@@ -902,11 +919,13 @@
 
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
 
@@ -935,25 +954,33 @@
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
@@ -962,10 +989,15 @@
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


