From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Apr 2010 19:10:22 -0000
Subject: LVM2/tools reporter.c
Message-ID: <20100423191022.12193.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-04-23 19:10:21

Modified files:
	tools          : reporter.c 

Log message:
	Remove redundant check in _lvs_single now that the caller
	(process_each_lv_in_vg) provides it.
	
	Also, removing this check from _lvs_single now allows displaying hidden
	LVs that are specifically named on the command line.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/tools/reporter.c	2010/03/16 15:30:49	1.59
+++ LVM2/tools/reporter.c	2010/04/23 19:10:20	1.60
@@ -33,9 +33,6 @@
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL)) {
 		stack;
 		return ECMD_FAILED;


