From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Sep 2007 17:18:38 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20070917171838.18417.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-09-17 17:18:37

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
	[E.g. They fail if tags or --alloc anywhere used.]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.708&r2=1.709
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/WHATS_NEW	2007/09/17 17:06:31	1.708
+++ LVM2/WHATS_NEW	2007/09/17 17:18:37	1.709
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
   Fix strdup memory leak in str_list_dup().
   Link with -lpthread when static SELinux libraries require that.
   Detect command line PE values that exceed their 32-bit range.
--- LVM2/tools/lvcreate.c	2007/08/30 19:34:19	1.144
+++ LVM2/tools/lvcreate.c	2007/09/17 17:18:37	1.145
@@ -180,10 +180,8 @@
  * up to the power of 2) */
 static int _read_stripe_params(struct lvcreate_params *lp,
 			       struct cmd_context *cmd,
-			       int *pargc)
+			       int *pargc __attribute((unused)))
 {
-	int argc = *pargc;
-
 	if (arg_count(cmd, stripesize_ARG)) {
 		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative stripesize is invalid");
@@ -211,12 +209,6 @@
 			  display_size(cmd, (uint64_t) lp->stripe_size));
 	}
 
-	if (argc && (unsigned) argc < lp->stripes) {
-		log_error("Too few physical volumes on "
-			  "command line for %d-way striping", lp->stripes);
-		return 0;
-	}
-
 	if (lp->stripes < 1 || lp->stripes > MAX_STRIPES) {
 		log_error("Number of stripes (%d) must be between %d and %d",
 			  lp->stripes, 1, MAX_STRIPES);
@@ -236,19 +228,12 @@
 
 static int _read_mirror_params(struct lvcreate_params *lp,
 			       struct cmd_context *cmd,
-			       int *pargc)
+			       int *pargc __attribute((unused)))
 {
-	int argc = *pargc;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 	const char *mirrorlog;
 
-	if (argc && (unsigned) argc < lp->mirrors) {
-		log_error("Too few physical volumes on "
-			  "command line for %d-way mirroring", lp->mirrors);
-		return 0;
-	}
-
 	if (arg_count(cmd, regionsize_ARG)) {
 		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative regionsize is invalid");


