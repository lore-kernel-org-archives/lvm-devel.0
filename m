From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Feb 2007 15:18:31 -0000
Subject: LVM2 ./WHATS_NEW tools/reporter.c
Message-ID: <20070214151831.22804.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-14 15:18:31

Modified files:
	.              : WHATS_NEW 
	tools          : reporter.c 

Log message:
	Fix a leak in a reporting error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.574&r2=1.575
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2007/02/13 16:10:14	1.574
+++ LVM2/WHATS_NEW	2007/02/14 15:18:30	1.575
@@ -1,5 +1,6 @@
 Version 2.02.23 - 
 ====================================
+  Fix a leak in a reporting error path (2.02.19).
 
 Version 2.02.22 - 13th February 2007
 ====================================
--- LVM2/tools/reporter.c	2007/01/27 02:32:31	1.20
+++ LVM2/tools/reporter.c	2007/02/14 15:18:31	1.21
@@ -286,7 +286,7 @@
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
 					  headings)))
-		return 0;
+		return_0;
 
 	/* Ensure options selected are compatible */
 	if (report_type & SEGS)
@@ -295,6 +295,7 @@
 		report_type |= PVS;
 	if ((report_type & LVS) && (report_type & PVS)) {
 		log_error("Can't report LV and PV fields at the same time");
+		dm_report_free(report_handle);
 		return 0;
 	}
 


