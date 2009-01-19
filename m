From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Jan 2009 20:53:35 -0000
Subject: LVM2/libdm libdm-report.c
Message-ID: <20090119205335.20737.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-19 20:53:35

Modified files:
	libdm          : libdm-report.c 

Log message:
	Rename _parse_options() to _parse_fields() for naming consistency.
	
	In libdm, we only ever use 'fields', while the tools use 'options' and
	'fields' interchangeably.
	
	Ideally it would be good to use 'fields' consistently everywhere.
	However, 'options' most likely comes from the tool commandline '-o' and
	'--options' which cannot be changed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/libdm/libdm-report.c	2009/01/10 03:14:24	1.28
+++ LVM2/libdm/libdm-report.c	2009/01/19 20:53:35	1.29
@@ -491,8 +491,8 @@
 	return 0;
 }
 
-static int _parse_options(struct dm_report *rh, const char *format,
-			  unsigned report_type_only)
+static int _parse_fields(struct dm_report *rh, const char *format,
+			 unsigned report_type_only)
 {
 	const char *ws;		/* Word start */
 	const char *we = format;	/* Word end */
@@ -562,9 +562,9 @@
 	memset(rh, 0, sizeof(*rh));
 
 	/*
-	 * rh->report_types is updated in _parse_options() and _parse_keys()
+	 * rh->report_types is updated in _parse_fields() and _parse_keys()
 	 * to contain all types corresponding to the fields specified by
-	 * options or keys.
+	 * fields or keys.
 	 */
 	if (report_types)
 		rh->report_types = *report_types;
@@ -606,14 +606,14 @@
 	 * the field lists twice.  The first time we only update the report type.
 	 * FIXME Use one pass instead and expand the "all" field afterwards.
 	 */
-	if (!_parse_options(rh, output_fields, 1) ||
+	if (!_parse_fields(rh, output_fields, 1) ||
 	    !_parse_keys(rh, sort_keys, 1)) {
 		dm_report_free(rh);
 		return NULL;
 	}
 
 	/* Generate list of fields for output based on format string & flags */
-	if (!_parse_options(rh, output_fields, 0) ||
+	if (!_parse_fields(rh, output_fields, 0) ||
 	    !_parse_keys(rh, sort_keys, 0)) {
 		dm_report_free(rh);
 		return NULL;


