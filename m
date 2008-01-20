From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Jan 2008 01:23:47 -0000
Subject: LVM2 ./WHATS_NEW tools/reporter.c
Message-ID: <20080120012347.6882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-20 01:23:46

Modified files:
	.              : WHATS_NEW 
	tools          : reporter.c 

Log message:
	Fix pvs, vgs, lvs error exit status on some error paths.
	(note -o help is now considered error)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.773&r2=1.774
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2008/01/19 12:36:37	1.773
+++ LVM2/WHATS_NEW	2008/01/20 01:23:46	1.774
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Fix pvs, vgs, lvs error exit status on some error paths.
 
 Version 2.02.31 - 19th January 2008
 ===================================
--- LVM2/tools/reporter.c	2008/01/07 20:42:57	1.33
+++ LVM2/tools/reporter.c	2008/01/20 01:23:46	1.34
@@ -240,13 +240,13 @@
 		opts = arg_str_value(cmd, options_ARG, "");
 		if (!opts || !*opts) {
 			log_error("Invalid options string: %s", opts);
-			return 0;
+			return EINVALID_CMD_LINE;
 		}
 		if (*opts == '+') {
 			if (!(str = dm_pool_alloc(cmd->mem,
 					 strlen(options) + strlen(opts) + 1))) {
 				log_error("options string allocation failed");
-				return 0;
+				return ECMD_FAILED;
 			}
 			strcpy(str, options);
 			strcat(str, ",");
@@ -273,8 +273,10 @@
 
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
-					  headings)))
-		return_0;
+					  headings))) {
+		stack;
+		return ECMD_FAILED;
+	}
 
 	/* Ensure options selected are compatible */
 	if (report_type & SEGS)
@@ -284,7 +286,7 @@
 	if ((report_type & LVS) && (report_type & PVS) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	/* Change report type if fields specified makes this necessary */


