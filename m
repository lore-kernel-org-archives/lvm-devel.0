From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Sep 2007 13:25:32 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20070924132532.13191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-24 13:25:31

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Refactor lvcreate stripe parameter validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.713&r2=1.714
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/WHATS_NEW	2007/09/21 18:06:56	1.713
+++ LVM2/WHATS_NEW	2007/09/24 13:25:31	1.714
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Refactor lvcreate stripe and mirror parameter validation.
   All tools: print --help output to stdout, not stderr.
   After a diagnostic, suggest --help, rather than printing all --help output.
   Add %PVS extents option to lvresize, lvextend, and lvcreate.
--- LVM2/tools/lvcreate.c	2007/09/20 21:39:08	1.146
+++ LVM2/tools/lvcreate.c	2007/09/24 13:25:31	1.147
@@ -174,28 +174,13 @@
 	return 1;
 }
 
-/* The stripe size is limited by the size of a uint32_t, but since the
- * value given by the user is doubled, and the final result must be a
- * power of 2, we must divide UINT_MAX by four and add 1 (to round it
- * up to the power of 2) */
-static int _read_stripe_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd,
-			       int *pargc __attribute((unused)))
+/*
+ * Generic stripe parameter checks.
+ * FIXME: Should eventually be moved into lvm library.
+ */
+static int _validate_stripe_params(struct cmd_context *cmd,
+				   struct lvcreate_params *lp)
 {
-	if (arg_count(cmd, stripesize_ARG)) {
-		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative stripesize is invalid");
-			return 0;
-		}
-		/* Check to make sure we won't overflow lp->stripe_size */
-		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
-			log_error("Stripe size cannot be larger than %s",
-				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
-			return 0;
-		}
-		lp->stripe_size = 2 * arg_uint_value(cmd, stripesize_ARG, 0);
-	}
-
 	if (lp->stripes == 1 && lp->stripe_size) {
 		log_print("Ignoring stripesize argument with single stripe");
 		lp->stripe_size = 0;
@@ -226,6 +211,35 @@
 	return 1;
 }
 
+/* The stripe size is limited by the size of a uint32_t, but since the
+ * value given by the user is doubled, and the final result must be a
+ * power of 2, we must divide UINT_MAX by four and add 1 (to round it
+ * up to the power of 2) */
+static int _read_stripe_params(struct lvcreate_params *lp,
+			       struct cmd_context *cmd,
+			       int *pargc __attribute((unused)))
+{
+	if (arg_count(cmd, stripesize_ARG)) {
+		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative stripesize is invalid");
+			return 0;
+		}
+		/* Check to make sure we won't overflow lp->stripe_size */
+		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
+			log_error("Stripe size cannot be larger than %s",
+				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+			return 0;
+		}
+		lp->stripe_size = 2 * arg_uint_value(cmd, stripesize_ARG, 0);
+	}
+
+
+	if (!_validate_stripe_params(cmd, lp))
+		return 0;
+
+	return 1;
+}
+
 static int _read_mirror_params(struct lvcreate_params *lp,
 			       struct cmd_context *cmd,
 			       int *pargc __attribute((unused)))


