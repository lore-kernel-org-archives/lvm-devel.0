From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Sep 2007 20:05:29 -0000
Subject: LVM2 ./WHATS_NEW lib/report/columns.h lib/repo ...
Message-ID: <20070910200529.16725.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-10 20:05:29

Modified files:
	.              : WHATS_NEW 
	lib/report     : columns.h report.c 

Log message:
	Add pvseg_free field to 'pvs' output

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.702&r2=1.703
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/WHATS_NEW	2007/09/07 11:24:19	1.702
+++ LVM2/WHATS_NEW	2007/09/10 20:05:29	1.703
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Add pvseg_free field to 'pvs' output.
   Include strerror string in dev_open_flags' stat failure message.
   Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
--- LVM2/lib/report/columns.h	2007/08/20 20:55:27	1.21
+++ LVM2/lib/report/columns.h	2007/09/10 20:05:29	1.22
@@ -83,4 +83,5 @@
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.")
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size", "Number of extents in segment.")
+FIELD(PVSEGS, pvseg, STR, "Free", lvseg, 5, lvseg, "pvseg_free", "Whether the segment is free or allocated to an LV.")
 /* *INDENT-ON* */
--- LVM2/lib/report/report.c	2007/08/22 14:38:17	1.61
+++ LVM2/lib/report/report.c	2007/09/10 20:05:29	1.62
@@ -62,6 +62,15 @@
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
+static int _lvseg_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+		       struct dm_report_field *field,
+		       const void *data, void *private __attribute((unused)))
+{
+	const struct lv_segment *seg = *(const struct lv_segment **) data;
+	dm_report_field_set_value(field, seg ? "N" : "Y", NULL);
+	return 1;
+}
+
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute((unused)))


