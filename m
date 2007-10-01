From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Oct 2007 15:01:26 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20071001150126.9685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-01 15:01:26

Modified files:
	tools          : lvcreate.c 

Log message:
	Remove unused pargc parameter

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/tools/lvcreate.c	2007/09/24 21:30:00	1.149
+++ LVM2/tools/lvcreate.c	2007/10/01 15:01:26	1.150
@@ -216,8 +216,7 @@
  * power of 2, we must divide UINT_MAX by four and add 1 (to round it
  * up to the power of 2) */
 static int _read_stripe_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd,
-			       int *pargc __attribute((unused)))
+			       struct cmd_context *cmd)
 {
 	if (arg_count(cmd, stripesize_ARG)) {
 		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
@@ -271,8 +270,7 @@
 }
 
 static int _read_mirror_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd,
-			       int *pargc __attribute((unused)))
+			       struct cmd_context *cmd)
 {
 	int region_size;
 	const char *mirrorlog;
@@ -429,8 +427,8 @@
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, cmd) ||
-	    !_read_stripe_params(lp, cmd, &argc) ||
-	    !_read_mirror_params(lp, cmd, &argc)) {
+	    !_read_stripe_params(lp, cmd) ||
+	    !_read_mirror_params(lp, cmd)) {
 		stack;
 		return 0;
 	}


