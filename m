From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2008 19:26:35 -0000
Subject: LVM2 ./WHATS_NEW tools/pvcreate.c
Message-ID: <20080721192635.14866.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-21 19:26:33

Modified files:
	.              : WHATS_NEW 
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate to divide parameter parsing & validation from create logic.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.932&r2=1.933
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2008/07/17 03:16:59	1.932
+++ LVM2/WHATS_NEW	2008/07/21 19:26:33	1.933
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Refactor pvcreate to divide parameter parsing & validation from create logic.
   Check for label_write() failure in _text_pv_write().
   Add pvcreate tests and update vgsplit tests to handle lvm1 and lvm2 metadata.
   Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.
--- LVM2/tools/pvcreate.c	2008/06/24 20:10:32	1.63
+++ LVM2/tools/pvcreate.c	2008/07/21 19:26:33	1.64
@@ -275,57 +275,84 @@
 	return ECMD_FAILED;
 }
 
-int pvcreate(struct cmd_context *cmd, int argc, char **argv)
+/*
+ * Intial sanity checking of command-line arguments and fill in parameters
+ * for pvcreate command.  More comprehensive validation is done in
+ * pvcreate_validate_params().
+ */
+static int pvcreate_fill_params(struct cmd_context *cmd,
+				int argc, char **argv,
+				struct pvcreate_params *pp)
 {
-	int i, r;
-	int ret = ECMD_PROCESSED;
-	struct pvcreate_params pp;
-
 	if (!argc) {
 		log_error("Please enter a physical volume path");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
 		log_error("--uuid is required with --restorefile");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_count(cmd, uuidstr_ARG) && argc != 1) {
 		log_error("Can only set uuid on one volume at once");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
 		log_error("Option y can only be given with option f");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
 		log_error("labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&
 	    (arg_count(cmd, metadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG))) {
 		log_error("Metadata parameters only apply to text format");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_count(cmd, metadatacopies_ARG) &&
 	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (arg_count(cmd, zero_ARG))
-		pp.zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 	else if (arg_count(cmd, restorefile_ARG) || arg_count(cmd, uuidstr_ARG))
-		pp.zero = 0;
+		pp->zero = 0;
 	else
-		pp.zero = 1;
+		pp->zero = 1;
+
+	return 1;
+}
+
+
+static int pvcreate_validate_params(struct cmd_context *cmd,
+				    struct pvcreate_params *pp)
+{
+	return 1;
+}
+
+int pvcreate(struct cmd_context *cmd, int argc, char **argv)
+{
+	int i, r;
+	int ret = ECMD_PROCESSED;
+	struct pvcreate_params pp;
+
+	if (!pvcreate_fill_params(cmd, argc, argv, &pp)) {
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!pvcreate_validate_params(cmd, &pp)) {
+		    return EINVALID_CMD_LINE;
+	}
 
 	for (i = 0; i < argc; i++) {
 		r = pvcreate_single(cmd, argv[i], &pp);


