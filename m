From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2010 18:36:48 -0000
Subject: LVM2/libdm libdm-report.c
Message-ID: <20100215183648.3915.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-02-15 18:36:48

Modified files:
	libdm          : libdm-report.c 

Log message:
	Fix dm_report_field_uint64 to really use 64bit.
	(function is currently not in use)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/libdm/libdm-report.c	2010/02/15 18:34:00	1.34
+++ LVM2/libdm/libdm-report.c	2010/02/15 18:36:48	1.35
@@ -207,7 +207,7 @@
 int dm_report_field_uint64(struct dm_report *rh,
 			   struct dm_report_field *field, const uint64_t *data)
 {
-	const int value = *data;
+	const uint64_t value = *data;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -221,12 +221,12 @@
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 21, "%d", value) < 0) {
-		log_error("dm_report_field_uint64: uint64 too big: %d", value);
+	if (dm_snprintf(repstr, 21, "%" PRIu64 , value) < 0) {
+		log_error("dm_report_field_uint64: uint64 too big: %" PRIu64, value);
 		return 0;
 	}
 
-	*sortval = (const uint64_t) value;
+	*sortval = value;
 	field->sort_value = sortval;
 	field->report_string = repstr;
 


