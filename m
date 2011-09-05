From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Sep 2011 12:54:30 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20110905125430.23508.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-05 12:54:30

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Remove incorrect requirement for -j or -m from lvchange error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2089&r2=1.2090
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/WHATS_NEW	2011/09/01 19:22:11	1.2089
+++ LVM2/WHATS_NEW	2011/09/05 12:54:29	1.2090
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Remove incorrect requirement for -j or -m from lvchange error message.
   Fix unsafe table load when splitting off smaller mirror from a larger one.
   Use size_t return type for text_vg_export_raw() and export_vg_to_buffer().
   Add configure --enable-lvmetad for building the (experimental) LVMetaD.
--- LVM2/tools/lvchange.c	2011/03/29 12:51:58	1.129
+++ LVM2/tools/lvchange.c	2011/09/05 12:54:29	1.130
@@ -715,10 +715,8 @@
 
 	if (!update &&
             !arg_count(cmd, available_ARG) && !arg_count(cmd, refresh_ARG) &&
-            !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG) &&
-            /* for persistent_ARG */
-	    !arg_count(cmd, minor_ARG) && !arg_count(cmd, major_ARG)) {
-		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
+            !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
+		log_error("Need 1 or more of -a, -C, -M, -p, -r, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
 			  "--monitor or --poll");
 		return EINVALID_CMD_LINE;


