From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2007 18:20:00 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20070710182000.30019.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-10 18:20:00

Modified files:
	lib/report     : report.c 

Log message:
	tidy

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/lib/report/report.c	2007/07/10 18:18:33	1.58
+++ LVM2/lib/report/report.c	2007/07/10 18:20:00	1.59
@@ -723,7 +723,7 @@
 			const void *data, void *private)
 {
 	struct lvmcache_info *info; 
-	uint32_t count = 0;
+	uint32_t count;
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
 	info = info_from_pvid(pvid);
@@ -906,8 +906,8 @@
 #undef FIELD
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
-                  report_type_t *report_type, const char *separator,
-                  int aligned, int buffered, int headings)
+		  report_type_t *report_type, const char *separator,
+		  int aligned, int buffered, int headings)
 {
 	uint32_t report_flags = 0;
 
@@ -920,7 +920,7 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
-        return dm_report_init(report_type, _report_types, _fields, format,
+	return dm_report_init(report_type, _report_types, _fields, format,
 			      separator, report_flags, keys, cmd);
 }
 


