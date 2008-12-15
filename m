From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Dec 2008 13:30:47 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20081215133047.10964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-15 13:30:46

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	Fix segfault when invalid field given in reporting commands.
	
	Problem is dm_report_init() may return NULL and subsequent call to
	dm_report_set_output_field_name_prefix() doesn't handle NULL value.
	
	Example:
	pvs --nameprefixes --rows --unquoted --noheadings -opv_name,fred
	Logical Volume Fields
	---------------------
	lv_uuid              - Unique identifier
	lv_name              - Name.  LVs created for internal use are enclosed in brackets.
	...
	
	Physical Volume Segment Fields
	------------------------------
	pvseg_start          - Physical Extent number of start of segment.
	pvseg_size           - Number of extents in segment.
	
	Unrecognised field: fred
	Segmentation fault

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1008&r2=1.1009
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2008/12/11 13:45:28	1.1008
+++ LVM2/WHATS_NEW	2008/12/15 13:30:45	1.1009
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix segfault when invalid field given in reporting commands.
   Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.
   Use better random seed value in temp file creation.
--- LVM2/lib/report/report.c	2008/12/04 15:54:27	1.90
+++ LVM2/lib/report/report.c	2008/12/15 13:30:46	1.91
@@ -1108,7 +1108,7 @@
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
-	if (field_prefixes)
+	if (rh && field_prefixes)
 		dm_report_set_output_field_name_prefix(rh, "lvm2_");
 
 	return rh;


