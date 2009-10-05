From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:03:55 -0000
Subject: LVM2/tools pvcreate.c toollib.c toollib.h
Message-ID: <20091005200355.25378.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:03:55

Modified files:
	tools          : pvcreate.c toollib.c toollib.h 

Log message:
	Move pvcreate_validate_params into toollib to allow calling from mutiple tools.
	
	For implicit pvcreate support, we need to call this from vgcreate and vgextend,
	so move it into toollib.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/tools/pvcreate.c	2009/10/05 20:03:25	1.86
+++ LVM2/tools/pvcreate.c	2009/10/05 20:03:54	1.87
@@ -78,114 +78,6 @@
 	return 1;
 }
 
-/*
- * Intial sanity checking of non-recovery related command-line arguments.
- *
- * Output arguments:
- * pp: structure allocated by caller, fields written / validated here
- */
-static int pvcreate_validate_params(struct cmd_context *cmd,
-				    int argc, char **argv,
-				    struct pvcreate_params *pp)
-{
-	if (!argc) {
-		log_error("Please enter a physical volume path");
-		return 0;
-	}
-
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return 0;
-	}
-
-	pp->yes = arg_count(cmd, yes_ARG);
-	pp->force = arg_count(cmd, force_ARG);
-
-	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu",
-			  LABEL_SCAN_SECTORS);
-		return 0;
-	} else {
-		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
-						  DEFAULT_LABELSECTOR);
-	}
-
-	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, metadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG)   ||
-	     arg_count(cmd, dataalignment_ARG)  ||
-	     arg_count(cmd, dataalignmentoffset_ARG))) {
-		log_error("Metadata and data alignment parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
-	if (arg_count(cmd, metadatacopies_ARG) &&
-	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return 0;
-	}
-
-	if (arg_count(cmd, zero_ARG))
-		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-
-	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume data alignment may not be negative");
-		return 0;
-	}
-	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
-
-	if (pp->data_alignment > ULONG_MAX) {
-		log_error("Physical volume data alignment is too big.");
-		return 0;
-	}
-
-	if (pp->data_alignment && pp->pe_start) {
-		if (pp->pe_start % pp->data_alignment)
-			log_warn("WARNING: Ignoring data alignment %" PRIu64
-				 " incompatible with --restorefile value (%"
-				 PRIu64").", pp->data_alignment, pp->pe_start);
-		pp->data_alignment = 0;
-	}
-
-	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume data alignment offset may not be negative");
-		return 0;
-	}
-	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
-
-	if (pp->data_alignment_offset > ULONG_MAX) {
-		log_error("Physical volume data alignment offset is too big.");
-		return 0;
-	}
-
-	if (pp->data_alignment_offset && pp->pe_start) {
-		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
-			 " incompatible with --restorefile value (%"
-			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
-		pp->data_alignment_offset = 0;
-	}
-
-	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative");
-		return 0;
-	}
-
-	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd,
-						 "metadata/pvmetadatasize",
-						 DEFAULT_PVMETADATASIZE);
-
-	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
-	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd,
-						   "metadata/pvmetadatacopies",
-						   DEFAULT_PVMETADATACOPIES);
-
-	return 1;
-}
-
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i;
--- LVM2/tools/toollib.c	2009/09/29 20:33:49	1.172
+++ LVM2/tools/toollib.c	2009/10/05 20:03:54	1.173
@@ -1271,3 +1271,112 @@
 		lvconvert_poll(cmd, lv, 1);
 	}
 }
+
+/*
+ * Intial sanity checking of non-recovery related command-line arguments.
+ *
+ * Output arguments:
+ * pp: structure allocated by caller, fields written / validated here
+ */
+int pvcreate_validate_params(struct cmd_context *cmd,
+			     int argc, char **argv,
+			     struct pvcreate_params *pp)
+{
+	if (!argc) {
+		log_error("Please enter a physical volume path");
+		return 0;
+	}
+
+	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
+		log_error("Option y can only be given with option f");
+		return 0;
+	}
+
+	pp->yes = arg_count(cmd, yes_ARG);
+	pp->force = arg_count(cmd, force_ARG);
+
+	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
+		log_error("labelsector must be less than %lu",
+			  LABEL_SCAN_SECTORS);
+		return 0;
+	} else {
+		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
+						  DEFAULT_LABELSECTOR);
+	}
+
+	if (!(cmd->fmt->features & FMT_MDAS) &&
+	    (arg_count(cmd, metadatacopies_ARG) ||
+	     arg_count(cmd, metadatasize_ARG)   ||
+	     arg_count(cmd, dataalignment_ARG)  ||
+	     arg_count(cmd, dataalignmentoffset_ARG))) {
+		log_error("Metadata and data alignment parameters only "
+			  "apply to text format.");
+		return 0;
+	}
+
+	if (arg_count(cmd, metadatacopies_ARG) &&
+	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
+		log_error("Metadatacopies may only be 0, 1 or 2");
+		return 0;
+	}
+
+	if (arg_count(cmd, zero_ARG))
+		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+
+	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment may not be negative");
+		return 0;
+	}
+	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
+
+	if (pp->data_alignment > ULONG_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment && pp->pe_start) {
+		if (pp->pe_start % pp->data_alignment)
+			log_warn("WARNING: Ignoring data alignment %" PRIu64
+				 " incompatible with --restorefile value (%"
+				 PRIu64").", pp->data_alignment, pp->pe_start);
+		pp->data_alignment = 0;
+	}
+
+	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment offset may not be negative");
+		return 0;
+	}
+	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
+
+	if (pp->data_alignment_offset > ULONG_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment_offset && pp->pe_start) {
+		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
+			 " incompatible with --restorefile value (%"
+			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
+		pp->data_alignment_offset = 0;
+	}
+
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
+
+	return 1;
+}
+
--- LVM2/tools/toollib.h	2009/09/29 20:22:35	1.64
+++ LVM2/tools/toollib.h	2009/10/05 20:03:55	1.65
@@ -107,5 +107,8 @@
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
+int pvcreate_validate_params(struct cmd_context *cmd,
+			     int argc, char **argv,
+			     struct pvcreate_params *pp);
 
 #endif


