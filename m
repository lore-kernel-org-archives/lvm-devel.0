From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2007 17:48:30 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20070118174830.31424.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-18 17:48:29

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	No longer necessary to specify alignment for report fields.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.546&r2=1.547
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2007/01/17 17:56:15	1.546
+++ LVM2/WHATS_NEW	2007/01/18 17:48:29	1.547
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  No longer necessary to specify alignment for report fields.
 
 Version 2.02.19 - 17th January 2007
 ===================================
--- LVM2/lib/report/report.c	2007/01/16 18:06:11	1.51
+++ LVM2/lib/report/report.c	2007/01/18 17:48:29	1.52
@@ -866,8 +866,8 @@
  * Import column definitions
  */
 
-#define STR (DM_REPORT_FIELD_STRING | DM_REPORT_FIELD_ALIGN_LEFT)
-#define NUM (DM_REPORT_FIELD_NUMBER | DM_REPORT_FIELD_ALIGN_RIGHT)
+#define STR DM_REPORT_FIELD_TYPE_STRING
+#define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, func, id) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp},
 
 static struct dm_report_field_type _fields[] = {


