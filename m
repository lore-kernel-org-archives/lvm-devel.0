From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 28 Jun 2010 19:10:16 -0000
Subject: LVM2/tools lvchange.c
Message-ID: <20100628191016.16125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-06-28 19:10:16

Modified files:
	tools          : lvchange.c 

Log message:
	Refactor the handles_missing_pv logic in lvchange.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/tools/lvchange.c	2010/05/06 11:15:56	1.120
+++ LVM2/tools/lvchange.c	2010/06/28 19:10:16	1.121
@@ -714,32 +714,31 @@
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!arg_count(cmd, available_ARG) && !arg_count(cmd, contiguous_ARG)
-	    && !arg_count(cmd, permission_ARG) && !arg_count(cmd, readahead_ARG)
-	    && !arg_count(cmd, minor_ARG) && !arg_count(cmd, major_ARG)
-	    && !arg_count(cmd, persistent_ARG) && !arg_count(cmd, addtag_ARG)
-	    && !arg_count(cmd, deltag_ARG) && !arg_count(cmd, refresh_ARG)
-	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)
-	    && !arg_count(cmd, poll_ARG) && !arg_count(cmd, resync_ARG)) {
+	int update = /* options other than -a, --refresh or --monitor */
+		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
+		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
+		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG);
+
+	if (!update &&
+            !arg_count(cmd, available_ARG) && !arg_count(cmd, refresh_ARG) &&
+            !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG) &&
+            /* for persistent_ARG */
+	    !arg_count(cmd, minor_ARG) && !arg_count(cmd, major_ARG)) {
 		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
 			  "--monitor or --poll");
 		return EINVALID_CMD_LINE;
 	}
 
-	int avail_only = /* i.e. only one of -a or --refresh is given */
-	    !(arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
-	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
-	     arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG));
 
 	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
-	     arg_count(cmd, sysinit_ARG)) && !avail_only) {
+	     arg_count(cmd, sysinit_ARG)) && update) {
 		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (avail_only)
+	if (!update)
 		cmd->handles_missing_pvs = 1;
 
 	if (!argc) {
@@ -769,6 +768,6 @@
 	}
 
 	return process_each_lv(cmd, argc, argv,
-			       avail_only ? 0 : READ_FOR_UPDATE, NULL,
+			       update ? READ_FOR_UPDATE : 0, NULL,
 			       &lvchange_single);
 }


