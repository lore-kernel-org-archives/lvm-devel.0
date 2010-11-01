From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Nov 2010 13:50:52 -0000
Subject: LVM2/libdm libdm-report.c
Message-ID: <20101101135052.8570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-11-01 13:50:51

Modified files:
	libdm          : libdm-report.c 

Log message:
	Use dm_strdup/dm_free instead of strdup/free.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/libdm/libdm-report.c	2010/11/01 13:31:55	1.38
+++ LVM2/libdm/libdm-report.c	2010/11/01 13:50:51	1.39
@@ -912,20 +912,20 @@
 	size_t buf_size = 0;
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
-		if (!(field_id = strdup(rh->fields[field->props->field_num].id))) {
+		if (!(field_id = dm_strdup(rh->fields[field->props->field_num].id))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
 			log_error("dm_report: Unable to extend output line");
-			free(field_id);
+			dm_free(field_id);
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
 			log_error("dm_report: Unable to extend output line");
-			free(field_id);
+			dm_free(field_id);
 			return 0;
 		}
 


