From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jan 2007 16:26:23 -0000
Subject: LVM2 ./WHATS_NEW tools/vgreduce.c
Message-ID: <20070131162623.18518.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-31 16:26:23

Modified files:
	.              : WHATS_NEW 
	tools          : vgreduce.c 

Log message:
	Fix some &->&& vgreduce cmdline validation.  [Andre Noll]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.568&r2=1.569
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2007/01/30 21:37:18	1.568
+++ LVM2/WHATS_NEW	2007/01/31 16:26:22	1.569
@@ -1,5 +1,6 @@
 Version 2.02.22 - 
 ===================================
+  Fix some vgreduce --removemissing command line validation.
 
 Version 2.02.21 - 30th January 2007
 ===================================
--- LVM2/tools/vgreduce.c	2007/01/09 23:14:34	1.55
+++ LVM2/tools/vgreduce.c	2007/01/31 16:26:23	1.56
@@ -427,13 +427,13 @@
 	int ret = 1;
 	int consistent = 1;
 
-	if (!argc & !arg_count(cmd, removemissing_ARG)) {
+	if (!argc && !arg_count(cmd, removemissing_ARG)) {
 		log_error("Please give volume group name and "
 			  "physical volume paths");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!argc & arg_count(cmd, removemissing_ARG)) {
+	if (!argc && arg_count(cmd, removemissing_ARG)) {
 		log_error("Please give volume group name");
 		return EINVALID_CMD_LINE;
 	}


