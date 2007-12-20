From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2007 16:49:38 -0000
Subject: LVM2 lib/report/report.c tools/reporter.c
Message-ID: <20071220164938.15053.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-20 16:49:38

Modified files:
	lib/report     : report.c 
	tools          : reporter.c 

Log message:
	avoid some compiler warnings

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/report/report.c	2007/12/14 21:53:02	1.68
+++ LVM2/lib/report/report.c	2007/12/20 16:49:37	1.69
@@ -639,9 +639,11 @@
 	return _size64_disp(rh, mem, field, &start, private);
 }
 
-static int _segstartpe_disp(struct dm_report *rh, struct dm_pool *mem,
-			  struct dm_report_field *field,
-			  const void *data, void *private)
+static int _segstartpe_disp(struct dm_report *rh,
+			    struct dm_pool *mem __attribute((unused)),
+			    struct dm_report_field *field,
+			    const void *data,
+			    void *private __attribute((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
--- LVM2/tools/reporter.c	2007/12/14 21:53:02	1.31
+++ LVM2/tools/reporter.c	2007/12/20 16:49:37	1.32
@@ -289,7 +289,7 @@
 
 	/* Change report type if fields specified makes this necessary */
 	if ((report_type & PVSEGS) ||
-	    (report_type & PVS) && (report_type & LVS))
+	    ((report_type & PVS) && (report_type & LVS)))
 		report_type = PVSEGS;
 	else if (report_type & PVS)
 		report_type = PVS;


