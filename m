From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2011 21:51:31 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20110125215131.11155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-25 21:51:31

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Initialize pool object for each row
	
	Fix assert abort of dmsetup (when compiled with pool debug)
	dmsetup splitname --nameprefixes --noheadings --rows gvg-a2
	
	Move pool begin in the inner loop - otherwise it would using
	already 'ended' pool object.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.438&r2=1.439
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW_DM	2011/01/10 14:51:33	1.438
+++ LVM2/WHATS_NEW_DM	2011/01/25 21:51:30	1.439
@@ -1,5 +1,6 @@
 Version 1.02.62 - 
 ===================================
+  Initialize pool object for each row in _output_as_rows().
 
 Version 1.02.61 - 10th January 2011
 ===================================
--- LVM2/libdm/libdm-report.c	2010/11/19 13:17:27	1.40
+++ LVM2/libdm/libdm-report.c	2011/01/25 21:51:31	1.41
@@ -1006,11 +1006,6 @@
 	struct dm_report_field *field;
 	struct row *row;
 
-	if (!dm_pool_begin_object(rh->mem, 512)) {
-		log_error("dm_report: Unable to allocate output line");
-		return 0;
-	}
-
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN) {
 			dm_list_iterate_items(row, &rh->rows) {
@@ -1020,6 +1015,11 @@
 			continue;
 		}
 
+		if (!dm_pool_begin_object(rh->mem, 512)) {
+			log_error("dm_report: Unable to allocate output line");
+			return 0;
+		}
+
 		if ((rh->flags & DM_REPORT_OUTPUT_HEADINGS)) {
 			if (!dm_pool_grow_object(rh->mem, rh->fields[fp->field_num].heading, 0)) {
 				log_error("dm_report: Failed to extend row for field name");


