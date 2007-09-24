From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Sep 2007 13:29:49 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20070924132949.14829.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-24 13:29:49

Modified files:
	tools          : lvcreate.c 

Log message:
	Refactor lvcreate mirror parameter validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/tools/lvcreate.c	2007/09/24 13:25:31	1.147
+++ LVM2/tools/lvcreate.c	2007/09/24 13:29:49	1.148
@@ -240,31 +240,14 @@
 	return 1;
 }
 
-static int _read_mirror_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd,
-			       int *pargc __attribute((unused)))
+/*
+ * Generic mirror parameter checks.
+ * FIXME: Should eventually be moved into lvm library.
+ */
+static int _validate_mirror_params(struct cmd_context *cmd,
+				   struct lvcreate_params *lp)
 {
-	int region_size;
 	int pagesize = lvm_getpagesize();
-	const char *mirrorlog;
-
-	if (arg_count(cmd, regionsize_ARG)) {
-		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative regionsize is invalid");
-			return 0;
-		}
-		lp->region_size = 2 * arg_uint_value(cmd, regionsize_ARG, 0);
-	} else {
-		region_size = 2 * find_config_tree_int(cmd,
-					"activation/mirror_region_size",
-					DEFAULT_MIRROR_REGION_SIZE);
-		if (region_size < 0) {
-			log_error("Negative regionsize in configuration file "
-				  "is invalid");
-			return 0;
-		}
-		lp->region_size = region_size;
-	}
 
 	if (lp->region_size & (lp->region_size - 1)) {
 		log_error("Region size (%" PRIu32 ") must be a power of 2",
@@ -284,6 +267,16 @@
 		return 0;
 	}
 
+	return 1;
+}
+
+static int _read_mirror_params(struct lvcreate_params *lp,
+			       struct cmd_context *cmd,
+			       int *pargc __attribute((unused)))
+{
+	int region_size;
+	const char *mirrorlog;
+
 	if (arg_count(cmd, corelog_ARG))
 		lp->corelog = 1;
 
@@ -308,6 +301,27 @@
 
 	lp->nosync = arg_count(cmd, nosync_ARG) ? 1 : 0;
 
+	if (arg_count(cmd, regionsize_ARG)) {
+		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative regionsize is invalid");
+			return 0;
+		}
+		lp->region_size = 2 * arg_uint_value(cmd, regionsize_ARG, 0);
+	} else {
+		region_size = 2 * find_config_tree_int(cmd,
+					"activation/mirror_region_size",
+					DEFAULT_MIRROR_REGION_SIZE);
+		if (region_size < 0) {
+			log_error("Negative regionsize in configuration file "
+				  "is invalid");
+			return 0;
+		}
+		lp->region_size = region_size;
+	}
+
+	if (!_validate_mirror_params(cmd, lp))
+		return 0;
+
 	return 1;
 }
 


