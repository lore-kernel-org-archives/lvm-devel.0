From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2008 19:27:22 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20080721192722.15094.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-21 19:27:22

Modified files:
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - divide parameter parsing & validation from create logic.
	
	Move size (setphysicalvolumesize option), metadatacopies and metadatasize
	validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/tools/pvcreate.c	2008/07/21 19:26:33	1.64
+++ LVM2/tools/pvcreate.c	2008/07/21 19:27:22	1.65
@@ -18,6 +18,9 @@
 
 struct pvcreate_params {
 	int zero;
+	uint64_t size;
+	int pvmetadatacopies;
+	uint64_t pvmetadatasize;
 };
 
 const char _really_init[] =
@@ -142,11 +145,8 @@
 	void *existing_pv;
 	struct id id, *idp = NULL;
 	const char *uuid = NULL;
-	uint64_t size = 0;
 	struct device *dev;
 	struct list mdas;
-	int pvmetadatacopies;
-	uint64_t pvmetadatasize;
 	struct volume_group *vg;
 	const char *restorefile;
 	uint64_t pe_start = 0;
@@ -196,28 +196,6 @@
 	if (sigint_caught())
 		goto error;
 
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume size may not be negative");
-		goto error;
-	}
-	size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
-
-	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative");
-		goto error;
-	}
-	pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pvmetadatasize)
-		pvmetadatasize = find_config_tree_int(cmd,
-						 "metadata/pvmetadatasize",
-						 DEFAULT_PVMETADATASIZE);
-
-	pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
-	if (pvmetadatacopies < 0)
-		pvmetadatacopies = find_config_tree_int(cmd,
-						   "metadata/pvmetadatacopies",
-						   DEFAULT_PVMETADATACOPIES);
-
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
 			  pv_name);
@@ -225,9 +203,9 @@
 	}
 
 	list_init(&mdas);
-	if (!(pv = pv_create(cmd, dev, idp, size, pe_start,
-			     extent_count, extent_size,
-			     pvmetadatacopies, pvmetadatasize, &mdas))) {
+	if (!(pv = pv_create(cmd, dev, idp, pp->size, pe_start,
+			     extent_count, extent_size, pp->pvmetadatacopies,
+			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -276,13 +254,17 @@
 }
 
 /*
- * Intial sanity checking of command-line arguments and fill in parameters
- * for pvcreate command.  More comprehensive validation is done in
- * pvcreate_validate_params().
+ * Intial sanity checking of command-line arguments and fill in 'pp' fields.
+ *
+ * Input arguments:
+ * cmd, argc, argv
+ *
+ * Output arguments:
+ * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_fill_params(struct cmd_context *cmd,
-				int argc, char **argv,
-				struct pvcreate_params *pp)
+static int pvcreate_validate_params(struct cmd_context *cmd,
+				    int argc, char **argv,
+				    struct pvcreate_params *pp)
 {
 	if (!argc) {
 		log_error("Please enter a physical volume path");
@@ -330,30 +312,43 @@
 	else
 		pp->zero = 1;
 
-	return 1;
-}
+	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume size may not be negative");
+		return 0;
+	}
+	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
+	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
+		log_error("Metadata size may not be negative");
+		return 0;
+	}
+
+	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+	if (!pp->pvmetadatasize)
+		pp->pvmetadatasize = find_config_tree_int(cmd,
+						 "metadata/pvmetadatasize",
+						 DEFAULT_PVMETADATASIZE);
+
+	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
+	if (pp->pvmetadatacopies < 0)
+		pp->pvmetadatacopies = find_config_tree_int(cmd,
+						   "metadata/pvmetadatacopies",
+						   DEFAULT_PVMETADATACOPIES);
 
-static int pvcreate_validate_params(struct cmd_context *cmd,
-				    struct pvcreate_params *pp)
-{
 	return 1;
 }
 
+
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, r;
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
 
-	if (!pvcreate_fill_params(cmd, argc, argv, &pp)) {
+	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!pvcreate_validate_params(cmd, &pp)) {
-		    return EINVALID_CMD_LINE;
-	}
-
 	for (i = 0; i < argc; i++) {
 		r = pvcreate_single(cmd, argv[i], &pp);
 		if (r > ret)


